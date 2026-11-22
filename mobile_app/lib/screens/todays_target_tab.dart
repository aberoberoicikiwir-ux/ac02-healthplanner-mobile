import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/daily_provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import 'meal_plan_screen.dart';
import 'workout_plan_screen.dart';

class TodaysTargetTab extends StatelessWidget {
  const TodaysTargetTab({super.key});

  Future<void> _openLogSheet(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, num?>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _DailyLogSheet(),
    );
    if (result == null || !context.mounted) return;

    final daily = context.read<DailyProvider>();
    final ok = await daily.saveToday(
      steps: result['steps']?.toInt(),
      waterLiters: result['water_liters']?.toDouble(),
      weightKg: result['weight_kg']?.toDouble(),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Log hari ini tersimpan.'
              : daily.errorMessage ?? 'Gagal menyimpan log.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Container(
      decoration: AppColors.backgroundDecoration,
      child: RefreshIndicator(
        onRefresh: context.read<DailyProvider>().loadAll,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.white,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              expandedHeight: 160,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Health & Workout Planner',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                background: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Image.asset('assets/images/logo.png', height: 70),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'Hello, ${auth.displayName ?? 'User'}!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "Today's target",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  const _TargetCard(),
                  const SizedBox(height: 16),
                  Consumer<WorkoutProvider>(
                    builder: (context, workoutProvider, child) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Latihan Selesai',
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${workoutProvider.completedCount} / ${workoutProvider.totalCount} latihan',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.directions_walk,
                              size: 36,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openLogSheet(context),
                      icon: const Icon(Icons.edit_note),
                      label: const Text('Catat Langkah / Air / Berat Hari Ini'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _shortcutCard(
                          context: context,
                          icon: Icons.fitness_center,
                          label: 'Workout Plan',
                          page: const WorkoutPlanScreen(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _shortcutCard(
                          context: context,
                          icon: Icons.restaurant_menu,
                          label: 'Meal Plan',
                          page: const MealPlanScreen(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shortcutCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Widget page,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white38),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.tealAccent),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard();

  String _num(num? value, {String suffix = ''}) {
    if (value == null) return '-';
    final text = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
    return '$text$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final daily = context.watch<DailyProvider>();
    final target = daily.target;
    final log = daily.todayLog;

    if (daily.loading && target == null && log == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined, color: Colors.tealAccent),
              const SizedBox(width: 8),
              const Text(
                'Target Hari Ini',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (daily.errorMessage != null)
                const Icon(Icons.cloud_off, size: 16, color: Color(0xFFFFD08A)),
            ],
          ),
          const SizedBox(height: 12),
          _progressRow(
            label: 'Langkah',
            value: _num(log?.steps),
            target: _num(target?.targetSteps),
            progress: _ratio(log?.steps, target?.targetSteps),
          ),
          const SizedBox(height: 10),
          _progressRow(
            label: 'Air',
            value: _num(log?.waterLiters, suffix: ' L'),
            target: _num(target?.targetWaterLiters, suffix: ' L'),
            progress: _ratio(log?.waterLiters, target?.targetWaterLiters),
          ),
          const SizedBox(height: 10),
          _progressRow(
            label: 'Kalori',
            value: _num(log?.caloriesBurned, suffix: ' kkal'),
            target: _num(target?.targetCalories, suffix: ' kkal'),
            progress: _ratio(log?.caloriesBurned, target?.targetCalories),
          ),
          if (target == null) ...[
            const SizedBox(height: 10),
            const Text(
              'Target belum disiapkan PT.',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
          if (daily.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              daily.errorMessage!,
              style: const TextStyle(color: Color(0xFFFFD08A), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  double _ratio(num? value, num? target) {
    if (value == null || target == null || target <= 0) return 0;
    return (value / target).clamp(0, 1).toDouble();
  }

  Widget _progressRow({
    required String label,
    required String value,
    required String target,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text(
              '$value / $target',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white24,
            color: Colors.tealAccent,
          ),
        ),
      ],
    );
  }
}

class _DailyLogSheet extends StatefulWidget {
  const _DailyLogSheet();

  @override
  State<_DailyLogSheet> createState() => _DailyLogSheetState();
}

class _DailyLogSheetState extends State<_DailyLogSheet> {
  late final TextEditingController _steps;
  late final TextEditingController _water;
  late final TextEditingController _weight;
  String? _error;

  @override
  void initState() {
    super.initState();
    final log = context.read<DailyProvider>().todayLog;
    _steps = TextEditingController(text: _text(log?.steps));
    _water = TextEditingController(text: _text(log?.waterLiters));
    _weight = TextEditingController(text: _text(log?.weightKg));
  }

  String _text(num? value) {
    if (value == null) return '';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  @override
  void dispose() {
    _steps.dispose();
    _water.dispose();
    _weight.dispose();
    super.dispose();
  }

  void _submit() {
    final stepsText = _steps.text.trim();
    final waterText = _water.text.trim();
    final weightText = _weight.text.trim();

    final steps = stepsText.isEmpty
        ? null
        : int.tryParse(stepsText.replaceAll('.', '').replaceAll(',', ''));
    final water = waterText.isEmpty
        ? null
        : double.tryParse(waterText.replaceAll(',', '.'));
    final weight = weightText.isEmpty
        ? null
        : double.tryParse(weightText.replaceAll(',', '.'));

    if (stepsText.isNotEmpty && steps == null) {
      setState(() => _error = 'Langkah harus berupa angka bulat.');
      return;
    }
    if (waterText.isNotEmpty && water == null) {
      setState(() => _error = 'Air harus berupa angka.');
      return;
    }
    if (weightText.isNotEmpty && weight == null) {
      setState(() => _error = 'Berat harus berupa angka.');
      return;
    }

    Navigator.pop(context, <String, num?>{
      'steps': steps,
      'water_liters': water,
      'weight_kg': weight,
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catat Hari Ini',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _steps,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Langkah'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _water,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Air (liter)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _weight,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Berat badan (kg)'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Color(0xFFE24B4A))),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}
