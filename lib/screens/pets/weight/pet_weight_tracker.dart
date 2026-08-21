import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pet_app/design/design.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/repositories/pet_weight_repository.dart';
import 'package:pet_app/utils/firestore_date.dart';

/// Escrita do TUTOR no **prontuário** de pesagens (`pets/{petId}/weights`):
/// GATED (§13.4). A rule libera a subcoleção para LEITURA do dono, mas a
/// escrita é do vet vinculado — pesagem clínica tem autoridade do vet.
///
/// Isso **não** bloqueia o tutor de manter o peso atual do pet: esse valor vai
/// para `pets/{petId}.weight`, que o dono pode atualizar hoje
/// (`allow update: if uid == ownerId`). A tela separa as duas fontes.
/// Fica `final` (não `const`) de propósito: com `const` o analisador marca o
/// caminho gated como dead_code.
// ignore: prefer_const_declarations
final bool kTutorWeightWriteEnabled = false;

/// Períodos do filtro do histórico.
enum _Period { week, month, year, all }

const Map<_Period, String> _periodLabels = {
  _Period.week: 'Semana',
  _Period.month: 'Mês',
  _Period.year: 'Ano',
  _Period.all: 'Tudo',
};

class PetWeightTrackingPage extends StatefulWidget {
  final Pets pet;

  const PetWeightTrackingPage({super.key, required this.pet});

  @override
  State<PetWeightTrackingPage> createState() => _PetWeightTrackingPageState();
}

class _PetWeightTrackingPageState extends State<PetWeightTrackingPage> {
  final PetWeightRepository _weightRepo = PetWeightRepository();
  _Period _period = _Period.month;

  /// Peso informado pelo tutor (campo `weight` do doc do pet). Guardado no
  /// state para a tela refletir a edição sem depender de recarregar o pet.
  late String? _selfWeight = widget.pet.weight;
  bool _savingSelfWeight = false;

  // Pesagens com data ou peso ilegíveis são descartadas em vez de derrubarem
  // o stream inteiro.
  late final Stream<List<WeightRecord>> _stream =
      _weightRepo.weightsStream(widget.pet.id).map((rows) {
    final records = <WeightRecord>[];
    for (final data in rows) {
      final date = readFirestoreDate(data['date']);
      final weight = data['weight'];
      if (date == null || weight is! num) continue;
      records.add(WeightRecord(date, weight.toDouble()));
    }
    return records;
  });

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  /// Records vêm em ordem crescente de data (orderBy no repositório).
  List<WeightRecord> _filter(List<WeightRecord> all) {
    if (_period == _Period.all) return all;
    final now = DateTime.now();
    int days;
    switch (_period) {
      case _Period.week:
        days = 7;
        break;
      case _Period.year:
        days = 365;
        break;
      case _Period.month:
      default:
        days = 30;
        break;
    }
    final cutoff = now.subtract(Duration(days: days));
    return all.where((r) => r.date.isAfter(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Peso',
      subtitle: widget.pet.name,
      showBack: true,
      bodyPadding: false,
      actions: [
        IconButton(
          onPressed: _savingSelfWeight ? null : _onEditSelfWeight,
          icon: const Icon(Icons.edit_rounded),
          color: context.colors.accentBlue,
          tooltip: 'Atualizar meu registro de peso',
        ),
      ],
      body: StreamBuilder<List<WeightRecord>>(
        stream: _stream,
        builder: (context, snapshot) {
          // O histórico é do prontuário (vet). Falha ou vazio nele não pode
          // esconder o peso informado pelo tutor, que é outra fonte.
          final all = snapshot.data ?? const <WeightRecord>[];
          final loadingHistory =
              !snapshot.hasData && !snapshot.hasError;
          final filtered = _filter(all);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxxl),
            children: [
              _SelfWeightCard(
                weight: _selfWeight,
                saving: _savingSelfWeight,
                onEdit: _onEditSelfWeight,
              ),
              const SizedBox(height: AppSpacing.xxl),
              const _SectionLabel(
                label: 'Histórico clínico',
                hint: 'Pesagens feitas pelo veterinário',
              ),
              const SizedBox(height: AppSpacing.sm),
              if (loadingHistory)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: AppLoading(),
                )
              else if (snapshot.hasError)
                AppCard(
                  child: Text(
                    'Não foi possível carregar o histórico de pesagens.',
                    style: AppTypography.callout
                        .copyWith(color: context.colors.textSecondary),
                  ),
                )
              else if (all.isEmpty)
                AppCard(
                  child: Row(
                    children: [
                      Icon(Icons.monitor_weight_rounded,
                          size: 20, color: context.colors.textTertiary),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Nenhuma pesagem do veterinário ainda. Quando '
                          'houver, a curva de evolução aparece aqui.',
                          style: AppTypography.callout
                              .copyWith(color: context.colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _SummaryCard(all: all),
                const SizedBox(height: AppSpacing.xxl),
                _PeriodSelector(
                  selected: _period,
                  onChanged: (p) => setState(() => _period = p),
                ),
                const SizedBox(height: AppSpacing.lg),
                _ChartCard(records: filtered),
                const SizedBox(height: AppSpacing.xxl),
                _RecordsSection(records: filtered),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Edita o peso informado pelo tutor (`pets/{petId}.weight`).
  ///
  /// Este caminho NÃO passa pelo gate §13.4: ele grava no documento do pet,
  /// onde a rule permite `update` ao dono. O prontuário de pesagens continua
  /// sendo escrito só pelo vet.
  Future<void> _onEditSelfWeight() async {
    final controller = TextEditingController(
      text: (_selfWeight ?? '').replaceAll('.', ','),
    );

    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Peso do seu pet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: controller,
              label: 'Peso (kg)',
              hint: 'Ex.: 14,5',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Esse é o peso que você acompanha em casa. Ele não substitui a '
              'pesagem do veterinário.',
              style: AppTypography.footnote
                  .copyWith(color: dialogContext.colors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = double.tryParse(
                  controller.text.trim().replaceAll(',', '.'));
              if (parsed == null || parsed <= 0) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Informe um peso válido.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext, parsed);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (value == null) return;

    setState(() => _savingSelfWeight = true);
    try {
      await _weightRepo.updateSelfReportedWeight(widget.pet.id, value);
      if (!mounted) return;
      setState(() {
        _selfWeight = value.toString();
        // Mantém o objeto em memória coerente com o que o hub do pet exibe.
        widget.pet.weight = _selfWeight;
        _savingSelfWeight = false;
      });
    } catch (e) {
      if (mounted) setState(() => _savingSelfWeight = false);
      _toast('Não foi possível salvar o peso: $e');
    }
  }
}

/// Peso informado pelo tutor — fonte separada do prontuário do veterinário.
class _SelfWeightCard extends StatelessWidget {
  final String? weight;
  final bool saving;
  final VoidCallback onEdit;

  const _SelfWeightCard({
    required this.weight,
    required this.saving,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final parsed = double.tryParse((weight ?? '').replaceAll(',', '.'));
    final temPeso = parsed != null && parsed > 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('MEU REGISTRO',
                    style: AppTypography.caption
                        .copyWith(color: c.textTertiary, letterSpacing: 0.5)),
              ),
              if (saving)
                SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: c.accentBlue),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (temPeso)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  parsed.toStringAsFixed(1).replaceAll('.', ','),
                  style: AppTypography.largeTitle
                      .copyWith(color: c.textPrimary, fontSize: 40, height: 1),
                ),
                const SizedBox(width: 4),
                Text('kg',
                    style:
                        AppTypography.title2.copyWith(color: c.textSecondary)),
              ],
            )
          else
            Text('Você ainda não informou o peso',
                style: AppTypography.callout.copyWith(color: c.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: temPeso ? 'Atualizar peso' : 'Informar peso',
            icon: Icons.monitor_weight_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: saving ? null : onEdit,
          ),
        ],
      ),
    );
  }
}

/// Rótulo de seção com uma linha de contexto.
class _SectionLabel extends StatelessWidget {
  final String label;
  final String hint;
  const _SectionLabel({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppTypography.caption
                  .copyWith(color: c.textTertiary, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(hint,
              style: AppTypography.footnote.copyWith(color: c.textTertiary)),
        ],
      ),
    );
  }
}

// ====================================================================
// Resumo — só fatos derivados dos registros reais.
//
// A faixa de "peso ideal" e o selo Saudável/Atenção que existiam aqui eram
// MOCK ("Using mock data for demonstration"): números chutados por espécie,
// apresentados como orientação clínica. Removidos — quem avalia peso ideal é
// o veterinário. Se isso virar produto, precisa de fonte de dados real.
// ====================================================================

class _SummaryCard extends StatelessWidget {
  final List<WeightRecord> all;
  const _SummaryCard({required this.all});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final current = all.last;
    final previous = all.length > 1 ? all[all.length - 2] : null;
    final delta = previous == null ? null : current.weight - previous.weight;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PESO ATUAL',
              style: AppTypography.caption
                  .copyWith(color: c.textTertiary, letterSpacing: 0.5)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                current.weight.toStringAsFixed(1).replaceAll('.', ','),
                style: AppTypography.largeTitle.copyWith(
                  color: c.textPrimary,
                  fontSize: 44,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Text('kg',
                  style: AppTypography.title2.copyWith(color: c.textSecondary)),
              const Spacer(),
              if (delta != null) _DeltaChip(delta: delta),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Última pesagem em ${DateFormat('dd/MM/yyyy').format(current.date)}',
            style: AppTypography.footnote.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(height: 1, thickness: 1, color: c.separator),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Pesagens',
                  value: '${all.length}',
                ),
              ),
              Container(width: 1, height: 30, color: c.separator),
              Expanded(
                child: _MiniStat(
                  label: 'Menor',
                  value: _kg(all
                      .map((r) => r.weight)
                      .reduce((a, b) => a < b ? a : b)),
                ),
              ),
              Container(width: 1, height: 30, color: c.separator),
              Expanded(
                child: _MiniStat(
                  label: 'Maior',
                  value: _kg(all
                      .map((r) => r.weight)
                      .reduce((a, b) => a > b ? a : b)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _kg(double v) =>
      '${v.toStringAsFixed(1).replaceAll('.', ',')} kg';
}

/// Variação em relação à pesagem anterior. Sem julgamento de valor: ganhar ou
/// perder peso não é bom nem ruim por si — quem interpreta é o vet.
class _DeltaChip extends StatelessWidget {
  final double delta;
  const _DeltaChip({required this.delta});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final stable = delta.abs() < 0.05;
    final label = stable
        ? 'estável'
        : '${delta > 0 ? '+' : '−'}'
            '${delta.abs().toStringAsFixed(1).replaceAll('.', ',')} kg';

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: c.surfaceSecondary,
        borderRadius: AppRadius.pill_,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            stable
                ? Icons.remove_rounded
                : (delta > 0
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded),
            size: 14,
            color: c.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(label,
              style: AppTypography.caption.copyWith(
                  color: c.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.subhead.copyWith(color: c.textPrimary)),
        const SizedBox(height: 1),
        Text(label,
            style: AppTypography.caption.copyWith(color: c.textTertiary)),
      ],
    );
  }
}

// ====================================================================
// Filtro de período
// ====================================================================

class _PeriodSelector extends StatelessWidget {
  final _Period selected;
  final ValueChanged<_Period> onChanged;
  const _PeriodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.surfaceSecondary,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
      ),
      child: Row(
        children: _Period.values.map((p) {
          final isSelected = p == selected;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: AppDurations.fast,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected ? c.surfaceGroupedSecondary : null,
                  borderRadius:
                      const BorderRadius.all(Radius.circular(AppRadius.sm)),
                  boxShadow: isSelected
                      ? AppShadows.card(Theme.of(context).brightness)
                      : null,
                ),
                child: Text(
                  _periodLabels[p]!,
                  textAlign: TextAlign.center,
                  style: AppTypography.subhead.copyWith(
                    color: isSelected ? c.textPrimary : c.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ====================================================================
// Gráfico
// ====================================================================

class _ChartCard extends StatelessWidget {
  final List<WeightRecord> records;
  const _ChartCard({required this.records});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      child: SizedBox(
        height: 200,
        child: records.length < 2
            ? Center(
                child: Text(
                  records.isEmpty
                      ? 'Nenhuma pesagem no período selecionado.'
                      : 'Uma única pesagem no período — sem curva para traçar.',
                  textAlign: TextAlign.center,
                  style:
                      AppTypography.callout.copyWith(color: c.textSecondary),
                ),
              )
            : _WeightChart(records: records),
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<WeightRecord> records;
  const _WeightChart({required this.records});

  double get _minWeight =>
      records.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
  double get _maxWeight =>
      records.map((e) => e.weight).reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Margem de 10% do intervalo (mínimo 0,5 kg) para a curva não encostar
    // nas bordas quando a variação é pequena.
    final span = _maxWeight - _minWeight;
    final pad = span < 1 ? 0.5 : span * 0.1;
    final minY = (_minWeight - pad).clamp(0.0, double.infinity);
    final maxY = _maxWeight + pad;

    final labelStyle =
        AppTypography.caption.copyWith(color: c.textTertiary, fontSize: 10);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: c.separator, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1).replaceAll('.', ','),
                style: labelStyle,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              // No máximo ~5 rótulos no eixo X, para não empilhar texto.
              interval: (records.length / 5).ceilToDouble().clamp(1, 999),
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= records.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                      DateFormat('dd/MM').format(records[i].date),
                      style: labelStyle),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // fl_chart 1.x: tooltipBgColor virou getTooltipColor (callback).
            getTooltipColor: (_) => c.textPrimary,
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              final i = spot.x.toInt();
              if (i < 0 || i >= records.length) return null;
              final record = records[i];
              return LineTooltipItem(
                '${record.weight.toStringAsFixed(1).replaceAll('.', ',')} kg\n',
                AppTypography.subhead.copyWith(
                    color: c.surfaceGroupedSecondary,
                    fontWeight: FontWeight.w700),
                children: [
                  TextSpan(
                    text: DateFormat('dd/MM/yyyy').format(record.date),
                    style: AppTypography.caption.copyWith(
                        color: c.surfaceGroupedSecondary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w400),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        minX: 0,
        maxX: (records.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(records.length,
                (i) => FlSpot(i.toDouble(), records[i].weight)),
            isCurved: true,
            curveSmoothness: 0.25,
            barWidth: 3,
            color: c.accentBlue,
            dotData: FlDotData(
              show: records.length <= 12,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: c.surfaceGroupedSecondary,
                strokeWidth: 2.5,
                strokeColor: c.accentBlue,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  c.tint(c.accentBlue, 0.18),
                  c.tint(c.accentBlue, 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// Lista de registros
// ====================================================================

class _RecordsSection extends StatelessWidget {
  final List<WeightRecord> records;
  const _RecordsSection({required this.records});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (records.isEmpty) {
      return AppListSection(
        header: 'Registros',
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text('Nenhuma pesagem no período selecionado.',
                style: AppTypography.callout.copyWith(color: c.textSecondary)),
          ),
        ],
      );
    }

    // Mais recente primeiro; a variação compara com a pesagem imediatamente
    // anterior (que, na lista invertida, é o próximo item).
    final rows = <Widget>[];
    for (var i = records.length - 1; i >= 0; i--) {
      final record = records[i];
      final delta = i == 0 ? null : record.weight - records[i - 1].weight;
      rows.add(_RecordRow(record: record, delta: delta));
    }

    return AppListSection(header: 'Registros', children: rows);
  }
}

class _RecordRow extends StatelessWidget {
  final WeightRecord record;
  final double? delta;
  const _RecordRow({required this.record, required this.delta});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('dd/MM/yyyy').format(record.date),
                    style:
                        AppTypography.callout.copyWith(color: c.textPrimary)),
                const SizedBox(height: 2),
                Text(DateFormat('HH:mm').format(record.date),
                    style: AppTypography.footnote
                        .copyWith(color: c.textTertiary)),
              ],
            ),
          ),
          if (delta != null) ...[
            _DeltaChip(delta: delta!),
            const SizedBox(width: AppSpacing.md),
          ],
          Text(
            '${record.weight.toStringAsFixed(1).replaceAll('.', ',')} kg',
            style: AppTypography.headline.copyWith(color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// Uma pesagem: data + peso em kg.
class WeightRecord {
  final DateTime date;
  final double weight;

  WeightRecord(this.date, this.weight);
}
