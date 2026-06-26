import 'package:flutter/material.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pet_app/repositories/pet_weight_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetWeightTrackingPage extends StatefulWidget {
  final Pets pet;

  const PetWeightTrackingPage({super.key, required this.pet});

  @override
  State<PetWeightTrackingPage> createState() => _PetWeightTrackingPageState();
}

class _PetWeightTrackingPageState extends State<PetWeightTrackingPage> {
  String selectedPeriod = 'Month';
  final List<String> periods = ['Week', 'Month', 'Year', 'All'];
  final PetWeightRepository _weightRepo = PetWeightRepository();

  List<WeightRecord> _allRecords = [];

  @override
  void initState() {
    super.initState();
    _weightRepo.weightsStream(widget.pet.id).listen((records) {
      setState(() {
        _allRecords = records
            .map((data) => WeightRecord(
                  (data['date'] as Timestamp).toDate(),
                  (data['weight'] as num).toDouble(),
                ))
            .toList();
      });
    });
  }

  double get currentWeight =>
      _allRecords.isNotEmpty ? _allRecords.last.weight : 0.0;

  double get previousWeight => _allRecords.length > 1
      ? _allRecords[_allRecords.length - 2].weight
      : currentWeight;

  double get weightDifference => currentWeight - previousWeight;

  double get idealWeightMin => _calculateIdealWeight()[0];
  double get idealWeightMax => _calculateIdealWeight()[1];

  bool get isHealthyWeight =>
      currentWeight >= idealWeightMin && currentWeight <= idealWeightMax;

  List<double> _calculateIdealWeight() {
    // This would normally be calculated based on breed, age, etc.
    // Using mock data for demonstration
    if (widget.pet.species?.toLowerCase() == 'dog') {
      if (widget.pet.breed?.toLowerCase().contains('retriever') ?? false) {
        return [12.0, 15.0]; // Min and max ideal weight
      }
      return [10.0, 18.0];
    } else if (widget.pet.species?.toLowerCase() == 'cat') {
      return [3.5, 6.5];
    }
    return [5.0, 20.0]; // Default range
  }

  List<WeightRecord> _getFilteredRecords() {
    final now = DateTime.now();
    final weightRecords = _allRecords;

    switch (selectedPeriod) {
      case 'Week':
        return weightRecords
            .where((record) =>
                record.date.isAfter(now.subtract(const Duration(days: 7))))
            .toList();
      case 'Month':
        return weightRecords
            .where((record) =>
                record.date.isAfter(now.subtract(const Duration(days: 30))))
            .toList();
      case 'Year':
        return weightRecords
            .where((record) =>
                record.date.isAfter(now.subtract(const Duration(days: 365))))
            .toList();
      case 'All':
      default:
        return List.from(weightRecords);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = _getFilteredRecords();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Peso',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF080809),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF212121)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.add_circle_outline, color: Color(0xFF212121)),
            onPressed: () => _showAddWeightDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Weight Summary Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A80F0), Color(0xFF3461D4)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A80F0).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Peso Atual',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              weightDifference >= 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${weightDifference.abs().toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${currentWeight.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          ' kg',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 60,
                    child: WeightMiniChart(
                      records: filteredRecords,
                      idealMin: idealWeightMin,
                      idealMax: idealWeightMax,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWeightInfoItem(
                        'Peso Ideal',
                        '${idealWeightMin.toStringAsFixed(1)}-${idealWeightMax.toStringAsFixed(1)} kg',
                      ),
                      _buildWeightInfoItem(
                        'Status',
                        isHealthyWeight ? 'Saudável' : 'Atenção',
                        isHealthyWeight
                            ? Icons.check_circle
                            : Icons.warning_amber_rounded,
                        isHealthyWeight
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Time Period Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: periods.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text(periods[index]),
                        selected: selectedPeriod == periods[index],
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedPeriod = periods[index];
                            });
                          }
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF4A80F0).withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: selectedPeriod == periods[index]
                              ? const Color(0xFF4A80F0)
                              : const Color(0xFF707070),
                          fontWeight: selectedPeriod == periods[index]
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: selectedPeriod == periods[index]
                                ? const Color(0xFF4A80F0)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Detailed Weight Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Histórico de Peso',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: WeightDetailChart(
                        records: filteredRecords,
                        idealMin: idealWeightMin,
                        idealMax: idealWeightMax,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Weight Records List
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Registros de Peso',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                  filteredRecords.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'Nenhum registro para o período selecionado',
                              style: TextStyle(color: Color(0xFF707070)),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredRecords.length,
                          itemBuilder: (context, index) {
                            final record = filteredRecords[
                                filteredRecords.length - 1 - index];
                            final isFirst = index == 0;
                            final previousRecord = isFirst
                                ? null
                                : filteredRecords[
                                    filteredRecords.length - index];
                            final difference = previousRecord != null
                                ? record.weight - previousRecord.weight
                                : 0.0;

                            return _buildWeightRecordItem(record, difference);
                          },
                        ),
                ],
              ),
            ),
            const SizedBox(height: 80), // For FAB spacing
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWeightDialog(),
        backgroundColor: const Color(0xFF4A80F0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildWeightInfoItem(String label, String value,
      [IconData? icon, Color? iconColor]) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 18,
            color: iconColor ?? Colors.white,
          ),
          const SizedBox(width: 6),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeightRecordItem(WeightRecord record, double difference) {
    final isGain = difference > 0;
    final isFirst = difference == 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('dd MMM, yyyy').format(record.date),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('HH:mm').format(record.date),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF707070),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '${record.weight.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              if (!isFirst) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isGain
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGain ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: isGain ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${difference.abs().toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isGain ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showAddWeightDialog() {
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Peso'),
        content: TextField(
          controller: weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Peso (kg)',
            hintText: 'Ex: 14.5',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final weightText = weightController.text.trim();
              if (weightText.isNotEmpty) {
                try {
                  final weight = double.parse(weightText);
                  await _weightRepo.addWeight(widget.pet.id, weight);
                  Navigator.pop(context);
                } catch (e) {
                  // Show error for invalid number format
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Por favor, insira um número válido')),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

// Weight Record Model
class WeightRecord {
  final DateTime date;
  final double weight;

  WeightRecord(this.date, this.weight);
}

// Small Weight Line Chart for Summary Card
class WeightMiniChart extends StatelessWidget {
  final List<WeightRecord> records;
  final double idealMin;
  final double idealMax;

  const WeightMiniChart({
    super.key,
    required this.records,
    required this.idealMin,
    required this.idealMax,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text(
          'Sem dados para exibir',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: false),
        minX: 0,
        maxX: (records.length - 1).toDouble(),
        minY: _getMinY(),
        maxY: _getMaxY(),
        lineBarsData: [
          LineChartBarData(
            spots: _getSpots(),
            isCurved: true,
            barWidth: 3,
            color: Colors.white,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return List.generate(records.length, (index) {
      return FlSpot(index.toDouble(), records[index].weight);
    });
  }

  double _getMinY() {
    if (records.isEmpty) return 0;
    final min = records.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    return (min - 1).clamp(0, double.infinity);
  }

  double _getMaxY() {
    if (records.isEmpty) return 10;
    final max = records.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    return max + 1;
  }
}

// Detailed Weight Chart
class WeightDetailChart extends StatelessWidget {
  final List<WeightRecord> records;
  final double idealMin;
  final double idealMax;

  const WeightDetailChart({
    super.key,
    required this.records,
    required this.idealMin,
    required this.idealMax,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text(
          'Sem dados para exibir',
          style: TextStyle(color: Color(0xFF707070)),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFFEEEEEE),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(
                  color: Color(0xFF707070),
                  fontSize: 10,
                ),
              ),
              reservedSize: 28,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < records.length) {
                  final date = records[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd/MM').format(date),
                      style: const TextStyle(
                        color: Color(0xFF707070),
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 28,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFEEEEEE)),
            left: BorderSide(color: Color(0xFFEEEEEE)),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // fl_chart 1.x: tooltipBgColor virou getTooltipColor (callback).
            getTooltipColor: (touchedSpot) => const Color(0xFF4A80F0),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < records.length) {
                  final record = records[index];
                  return LineTooltipItem(
                    '${record.weight.toStringAsFixed(1)} kg\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: DateFormat('dd/MM/yyyy').format(record.date),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
        minX: 0,
        maxX: (records.length - 1).toDouble(),
        minY: _getMinY(),
        maxY: _getMaxY(),
        lineBarsData: [
          // Ideal weight range area
          LineChartBarData(
            spots: List.generate(records.length, (index) {
              return FlSpot(index.toDouble(), idealMax);
            }),
            isCurved: false,
            barWidth: 0,
            color: Colors.transparent,
            belowBarData: BarAreaData(
              show: true,
              cutOffY: idealMin,
              applyCutOffY: true,
              color: Colors.green.withOpacity(0.1),
            ),
          ),

          // Weight line
          LineChartBarData(
            spots: _getSpots(),
            isCurved: true,
            barWidth: 3,
            color: const Color(0xFF4A80F0),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 5,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: const Color(0xFF4A80F0),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF4A80F0).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return List.generate(records.length, (index) {
      return FlSpot(index.toDouble(), records[index].weight);
    });
  }

  double _getMinY() {
    if (records.isEmpty) return 0;
    final min = records.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    // Use the lower of the min weight or ideal min weight, minus a bit of padding
    return (min < idealMin ? min : idealMin) - 1;
  }

  double _getMaxY() {
    if (records.isEmpty) return 10;
    final max = records.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    // Use the higher of the max weight or ideal max weight, plus a bit of padding
    return (max > idealMax ? max : idealMax) + 1;
  }
}
