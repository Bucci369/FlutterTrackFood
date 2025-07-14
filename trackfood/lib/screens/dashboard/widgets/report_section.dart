import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../providers/report_provider.dart';
import 'dart:math' as math;

class ReportSection extends ConsumerStatefulWidget {
  const ReportSection({super.key});

  @override
  ConsumerState<ReportSection> createState() => _ReportSectionState();
}

class _ReportSectionState extends ConsumerState<ReportSection> {
  bool showWeekly = true;

  @override
  Widget build(BuildContext context) {
    final days = showWeekly ? 7 : 30;
    final reportDataAsync = ref.watch(reportDataProvider(days));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF6F1E7), // Apple White
        border: Border.all(color: AppColors.separator, width: 1),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Report',
                style: AppTypography.title2.copyWith(
                  color: AppColors.label,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CupertinoSlidingSegmentedControl<bool>(
                groupValue: showWeekly,
                onValueChanged: (value) {
                  setState(() {
                    showWeekly = value ?? true;
                  });
                },
                children: {
                  true: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      '7 Tage',
                      style: AppTypography.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  false: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      '30 Tage',
                      style: AppTypography.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Data-dependent content
          reportDataAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CupertinoActivityIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Fehler beim Laden der Daten',
                style: AppTypography.body.copyWith(
                  color: AppColors.secondaryLabel,
                ),
              ),
            ),
            data: (reportData) => _buildReportContent(reportData),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(ReportData reportData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Actions
        Text(
          'Quick Actions',
          style: AppTypography.body.copyWith(
            color: AppColors.secondaryLabel,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),

        // Calorie Chart Section
        _buildCalorieChart(reportData),

        const SizedBox(height: 20),

        // Weight Chart Section
        _buildWeightChart(reportData),

        if (reportData.totalDays < (showWeekly ? 7 : 30))
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.info_circle,
                    color: CupertinoColors.systemYellow,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Daten für ${reportData.totalDays} von ${showWeekly ? 7 : 30} Tagen verfügbar',
                      style: AppTypography.caption1.copyWith(
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCalorieChart(ReportData reportData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.separator.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calorie',
                style: AppTypography.body.copyWith(
                  color: AppColors.label,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  _buildLegendDot(
                    CupertinoColors.systemRed.darkColor,
                    'Intake',
                  ),
                  const SizedBox(width: 12),
                  _buildLegendDot(CupertinoColors.systemOrange, 'Burned'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Y-axis labels and chart
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // Y-axis labels
                SizedBox(
                  width: 30,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildYAxisLabel('3k'),
                      _buildYAxisLabel('2k'),
                      _buildYAxisLabel('1k'),
                      _buildYAxisLabel('0'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Chart area
                Expanded(
                  child: CustomPaint(
                    painter: CalorieChartPainter(
                      intakeData: reportData.calorieIntakeData,
                      burnedData: reportData.calorieBurnedData,
                    ),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // X-axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: reportData.dateLabels
                .map(
                  (day) => Text(
                    day,
                    style: AppTypography.caption1.copyWith(
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart(ReportData reportData) {
    final hasWeightData = reportData.weightData.any((w) => w > 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5), // Light purple background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.separator.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight',
                style: AppTypography.body.copyWith(
                  color: AppColors.label,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasWeightData)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (reportData.weightData.first - reportData.weightData.last)
                          .abs()
                          .toStringAsFixed(1),
                      style: AppTypography.title3.copyWith(
                        color: AppColors.label,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Kg ${reportData.weightData.first > reportData.weightData.last ? 'Lost' : 'Gained'}',
                      style: AppTypography.caption1.copyWith(
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Weight chart
          SizedBox(
            height: 120,
            child: hasWeightData
                ? Row(
                    children: [
                      // Y-axis labels
                      SizedBox(
                        width: 30,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildYAxisLabel(
                              '${(reportData.weightData.reduce(math.max) + 2).toInt()}',
                            ),
                            _buildYAxisLabel(
                              '${reportData.weightData.reduce(math.max).toInt()}',
                            ),
                            _buildYAxisLabel(
                              '${reportData.weightData.reduce(math.min).toInt()}',
                            ),
                            _buildYAxisLabel(
                              '${(reportData.weightData.reduce(math.min) - 2).toInt()}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Chart area
                      Expanded(
                        child: CustomPaint(
                          painter: WeightChartPainter(
                            data: reportData.weightData,
                          ),
                          child: Container(),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      'Keine Gewichtsdaten verfügbar',
                      style: AppTypography.body.copyWith(
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 12),

          // X-axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: reportData.dateLabels
                .map(
                  (day) => Text(
                    day,
                    style: AppTypography.caption1.copyWith(
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption1.copyWith(
            color: AppColors.secondaryLabel,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildYAxisLabel(String label) {
    return Text(
      label,
      style: AppTypography.caption1.copyWith(
        color: AppColors.secondaryLabel,
        fontSize: 10,
      ),
    );
  }
}

class CalorieChartPainter extends CustomPainter {
  final List<double> intakeData;
  final List<double> burnedData;

  CalorieChartPainter({required this.intakeData, required this.burnedData});

  @override
  void paint(Canvas canvas, Size size) {
    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.separator.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    // Draw horizontal grid lines
    for (int i = 0; i <= 3; i++) {
      final y = (i / 3) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw vertical grid lines
    for (int i = 0; i < intakeData.length; i++) {
      final x = (i / (intakeData.length - 1)) * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw intake line
    _drawLine(
      canvas,
      size,
      intakeData,
      CupertinoColors.systemRed.darkColor,
      3000,
    );

    // Draw burned line
    _drawLine(canvas, size, burnedData, CupertinoColors.systemOrange, 3000);
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<double> data,
    Color color,
    double maxValue,
  ) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (data[i] / maxValue) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (data[i] / maxValue) * size.height;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(CalorieChartPainter oldDelegate) {
    return oldDelegate.intakeData != intakeData ||
        oldDelegate.burnedData != burnedData;
  }
}

class WeightChartPainter extends CustomPainter {
  final List<double> data;

  WeightChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.separator.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    // Draw horizontal grid lines
    for (int i = 0; i <= 3; i++) {
      final y = (i / 3) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final minValue = data.reduce(math.min) - 1;
    final maxValue = data.reduce(math.max) + 1;
    final range = maxValue - minValue;

    // Draw line
    final paint = Paint()
      ..color = CupertinoColors.systemGreen
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = range > 0
          ? size.height - ((data[i] - minValue) / range) * size.height
          : size.height / 2;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = CupertinoColors.systemGreen
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = range > 0
          ? size.height - ((data[i] - minValue) / range) * size.height
          : size.height / 2;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(WeightChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
