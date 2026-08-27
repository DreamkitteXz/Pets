import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pet_app/design/design.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/repositories/pet_weight_repository.dart';

/// Linha do tempo de peso do pet — UMA só, compartilhada com o site.
///
/// A tela tinha duas fontes separadas ("MEU REGISTRO" no doc do pet e o
/// histórico clínico numa subcoleção) porque a escrita do tutor no prontuário
/// era GATED (§13.4): a rule só deixava o vet escrever. A rule de
/// `pets/{petId}/pesos` agora aceita o auto-relato do dono
/// (`source: 'tutor'`), então tutor e veterinário alimentam a mesma curva —
/// a mesma que o WeightChart da web desenha.
///
/// Cada atualização de peso vira um ponto no gráfico E atualiza
/// `pets/{petId}.weight` (o peso atual da ficha), no mesmo lote.

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
  bool _saving = false;

  late final Stream<List<WeightEntry>> _stream =
      _weightRepo.weightsStream(widget.pet.id);

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  /// Entradas vêm em ordem crescente de data (orderBy no repositório).
  List<WeightEntry> _filter(List<WeightEntry> all) {
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
        days = 30;
        break;
      case _Period.all:
        return all;
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
      body: StreamBuilder<List<WeightEntry>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading();
          }
          if (snapshot.hasError) {
            return AppErrorState(
              message: 'Não foi possível carregar o histórico de peso.',
              onRetry: () => setState(() {}),
            );
          }

          final all = snapshot.data ?? const <WeightEntry>[];
          final filtered = _filter(all);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxxl),
            children: [
              _CurrentWeightCard(
                all: all,
                // Peso da ficha do pet: cobre o caso de existir peso cadastrado
                // sem nenhuma pesagem ainda registrada.
                fallbackWeight: widget.pet.weightValue,
                saving: _saving,
                onRegister: _onRegisterWeight,
              ),
              if (all.isEmpty) ...[
                const SizedBox(height: AppSpacing.xxl),
                AppCard(
                  child: Row(
                    children: [
                      Icon(Icons.show_chart_rounded,
                          size: 20, color: context.colors.textTertiary),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Registre o peso para começar a curva. Pesagens '
                          'feitas pelo veterinário entram aqui também.',
                          style: AppTypography.callout
                              .copyWith(color: context.colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
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

  /// Registra a pesagem: vira ponto no gráfico e novo peso atual do pet.
  Future<void> _onRegisterWeight() async {
    final value = await showDialog<double>(
      context: context,
      builder: (_) => _WeightDialog(initial: widget.pet.weightValue),
    );
    if (value == null) return;

    setState(() => _saving = true);
    try {
      await _weightRepo.registerTutorWeight(widget.pet.id, value);
      if (!mounted) return;
      setState(() {
        // Mantém o objeto em memória coerente com o que a ficha do pet exibe.
        widget.pet.weight = value.toString();
        _saving = false;
      });
      // O gráfico não precisa de refresh: o snapshot da subcoleção reemite.
      _toast('Peso registrado.');
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      _toast('Não foi possível salvar o peso: $e');
    }
  }
}

/// Diálogo de entrada do peso. Stateful para poder descartar o controller.
class _WeightDialog extends StatefulWidget {
  final double? initial;
  const _WeightDialog({this.initial});

  @override
  State<_WeightDialog> createState() => _WeightDialogState();
}

class _WeightDialogState extends State<_WeightDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial == null
        ? ''
        : widget.initial!.toStringAsFixed(1).replaceAll('.', ','),
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed =
        double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      setState(() => _error = 'Informe um peso válido.');
      return;
    }
    if (parsed > 200) {
      setState(() => _error = 'Peso acima de 200 kg — confira o valor.');
      return;
    }
    Navigator.pop(context, parsed);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AlertDialog(
      title: const Text('Registrar peso'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: _controller,
            label: 'Peso (kg)',
            hint: 'Ex.: 14,5',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_error!,
                style: AppTypography.footnote.copyWith(color: c.accentRed)),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            'A pesagem entra no histórico do pet com a data de hoje e aparece '
            'na curva — para você e para o veterinário.',
            style: AppTypography.footnote.copyWith(color: c.textSecondary),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Registrar')),
      ],
    );
  }
}

// ====================================================================
// Peso atual — só fatos derivados dos registros reais.
//
// A faixa de "peso ideal" e o selo Saudável/Atenção que existiam aqui eram
// MOCK ("Using mock data for demonstration"): números chutados por espécie,
// apresentados como orientação clínica. Removidos — quem avalia peso ideal é
// o veterinário. Se isso virar produto, precisa de fonte de dados real.
// ====================================================================

class _CurrentWeightCard extends StatelessWidget {
  final List<WeightEntry> all;
  final double? fallbackWeight;
  final bool saving;
  final VoidCallback onRegister;

  const _CurrentWeightCard({
    required this.all,
    required this.fallbackWeight,
    required this.saving,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final current = all.isEmpty ? null : all.last;
    final previous = all.length > 1 ? all[all.length - 2] : null;
    final delta =
        (current == null || previous == null) ? null : current.weight - previous.weight;
    final displayWeight = current?.weight ?? fallbackWeight;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PESO ATUAL',
              style: AppTypography.caption
                  .copyWith(color: c.textTertiary, letterSpacing: 0.5)),
          const SizedBox(height: AppSpacing.sm),
          if (displayWeight != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  displayWeight.toStringAsFixed(1).replaceAll('.', ','),
                  style: AppTypography.largeTitle
                      .copyWith(color: c.textPrimary, fontSize: 44, height: 1),
                ),
                const SizedBox(width: 4),
                Text('kg',
                    style:
                        AppTypography.title2.copyWith(color: c.textSecondary)),
                const Spacer(),
                if (delta != null) _DeltaChip(delta: delta),
              ],
            )
          else
            Text('Nenhum peso registrado ainda',
                style: AppTypography.callout.copyWith(color: c.textSecondary)),
          if (current != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Registrado em ${DateFormat('dd/MM/yyyy').format(current.date)}'
              ' · ${_sourceLabel(current.source)}',
              style: AppTypography.footnote.copyWith(color: c.textSecondary),
            ),
          ],
          if (all.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Divider(height: 1, thickness: 1, color: c.separator),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                    child: _MiniStat(label: 'Pesagens', value: '${all.length}')),
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
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Registrar peso',
            icon: Icons.monitor_weight_rounded,
            variant: AppButtonVariant.secondary,
            loading: saving,
            onPressed: saving ? null : onRegister,
          ),
        ],
      ),
    );
  }

  static String _kg(double v) =>
      '${v.toStringAsFixed(1).replaceAll('.', ',')} kg';
}

String _sourceLabel(WeightSource source) =>
    source == WeightSource.tutor ? 'por você' : 'pelo veterinário';

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
  final List<WeightEntry> records;
  const _ChartCard({required this.records});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      child: SizedBox(
        height: 200,
        child: records.isEmpty
            ? Center(
                child: Text(
                  'Nenhuma pesagem no período selecionado.',
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
  final List<WeightEntry> records;
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

    // Uma pesagem só não traça curva: o eixo X precisa de largura, então o
    // ponto único é desenhado no centro de um intervalo artificial.
    final single = records.length == 1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: c.separator, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                final i = value.round();
                if (i < 0 || i >= records.length) return const SizedBox();
                if (single && value != 0) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(DateFormat('dd/MM').format(records[i].date),
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
                    text: '${DateFormat('dd/MM/yyyy').format(record.date)}'
                        ' · ${_sourceLabel(record.source)}',
                    style: AppTypography.caption.copyWith(
                        color: c.surfaceGroupedSecondary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w400),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        minX: single ? -1 : 0,
        maxX: single ? 1 : (records.length - 1).toDouble(),
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
              // Com muitos pontos os círculos viram ruído; com poucos, ajudam.
              show: records.length <= 12,
              getDotPainter: (spot, percent, barData, index) {
                // Pesagem do tutor tem miolo azul; a do vet, miolo vazado —
                // dá para ver na curva de quem veio cada ponto.
                final isTutor = index < records.length &&
                    records[index].source == WeightSource.tutor;
                return FlDotCirclePainter(
                  radius: 4,
                  color: isTutor ? c.accentBlue : c.surfaceGroupedSecondary,
                  strokeWidth: 2.5,
                  strokeColor: c.accentBlue,
                );
              },
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
  final List<WeightEntry> records;
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
  final WeightEntry record;
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
                Text(
                    '${DateFormat('HH:mm').format(record.date)}'
                    ' · ${_sourceLabel(record.source)}',
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
