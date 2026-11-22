import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/daily_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class ProgresTab extends StatelessWidget {
  const ProgresTab({super.key});

  @override
  Widget build(BuildContext context) {
    final daily = context.watch<DailyProvider>();
    final profile = context.watch<ProfileProvider>();
    final weightPoints = daily.weightPoints;
    final stepPoints = daily.stepPoints;

    return Container(
      decoration: AppColors.backgroundDecoration,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: daily.loadAll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            children: [
              const Text(
                'Progres',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              if (daily.loading && weightPoints.isEmpty && stepPoints.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else if (weightPoints.isEmpty && stepPoints.isEmpty)
                _emptyCard()
              else ...[
                _summaryCard(weightPoints, stepPoints, profile),
                const SizedBox(height: 16),
                _chartCard(
                  title: 'Berat Badan',
                  child: weightPoints.length < 2
                      ? _singleValue(
                          weightPoints.isEmpty
                              ? '-'
                              : '${_short(weightPoints.last.weightKg)} kg',
                        )
                      : SizedBox(
                          height: 150,
                          child: CustomPaint(
                            painter: _LineChartPainter(
                              values: weightPoints
                                  .map((e) => e.weightKg!.toDouble())
                                  .toList(),
                              color: Colors.tealAccent,
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                  footer: weightPoints.isEmpty
                      ? 'Belum ada data berat badan.'
                      : '${shortDate(weightPoints.first.logDate)} - ${shortDate(weightPoints.last.logDate)}',
                ),
                const SizedBox(height: 16),
                _chartCard(
                  title: 'Langkah Harian',
                  child: stepPoints.isEmpty
                      ? _singleValue('-')
                      : SizedBox(
                          height: 140,
                          child: _StepsBars(
                            values: stepPoints
                                .map((e) => e.steps!.toDouble())
                                .toList(),
                          ),
                        ),
                  footer: stepPoints.isEmpty
                      ? 'Belum ada data langkah.'
                      : '${shortDate(stepPoints.first.logDate)} - ${shortDate(stepPoints.last.logDate)}',
                ),
                if (daily.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    daily.errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFFFD08A),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _short(num? value) {
    if (value == null) return '-';
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  Widget _emptyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Grafik berat badan & langkah harian akan tampil setelah kamu mencatat log beberapa hari.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _summaryCard(
    List weightPoints,
    List stepPoints,
    ProfileProvider profile,
  ) {
    final lastWeight = weightPoints.isEmpty
        ? null
        : weightPoints.last.weightKg as num?;
    final target = profile.weightTarget;

    final recentSteps = stepPoints.length > 7
        ? stepPoints.sublist(stepPoints.length - 7)
        : stepPoints;
    double? avgSteps;
    if (recentSteps.isNotEmpty) {
      final total = recentSteps.fold<num>(
        0,
        (sum, e) => sum + (e.steps as num? ?? 0),
      );
      avgSteps = total / recentSteps.length;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryItem(
              'Berat terakhir',
              lastWeight == null ? '-' : '${_short(lastWeight)} kg',
            ),
          ),
          Expanded(
            child: _summaryItem(
              'Target',
              target == null ? '-' : '${_short(target)} kg',
            ),
          ),
          Expanded(
            child: _summaryItem(
              'Rata-rata langkah',
              avgSteps == null ? '-' : _short(avgSteps.round()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }

  Widget _chartCard({
    required String title,
    required Widget child,
    required String footer,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
          const SizedBox(height: 8),
          Text(
            footer,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _singleValue(String text) {
    return SizedBox(
      height: 140,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}

class _StepsBars extends StatelessWidget {
  const _StepsBars({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final shown = values.length > 14
        ? values.sublist(values.length - 14)
        : values;
    final maxValue = shown
        .fold<double>(0, (max, v) => v > max ? v : max)
        .clamp(1, 999999);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: shown.map((value) {
        final factor = (value / maxValue).clamp(0.0, 1.0);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 120 * factor,
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    var min = values.first;
    var max = values.first;
    for (final value in values) {
      if (value < min) min = value;
      if (value > max) max = value;
    }
    if (max == min) {
      max = min + 1;
    }

    final paintGrid = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    final dx = values.length == 1 ? 0.0 : size.width / (values.length - 1);
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final ratio = (values[i] - min) / (max - min);
      final y = size.height - ratio * size.height;
      final x = values.length == 1 ? size.width / 2 : i * dx;
      points.add(Offset(x, y));
    }

    final line = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, line);

    final dot = Paint()..color = color;
    for (final point in points) {
      canvas.drawCircle(point, 3, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}
