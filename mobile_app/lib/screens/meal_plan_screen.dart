import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meal.dart';
import '../providers/meal_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

  static const _mealOrder = ['breakfast', 'lunch', 'dinner', 'snack'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: AppColors.backgroundDecoration,
        child: SafeArea(
          child: Consumer<MealProvider>(
            builder: (context, provider, _) {
              return RefreshIndicator(
                onRefresh: provider.sync,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                  children: [
                    const Center(
                      child: Text(
                        'Meal Plan',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _status(provider),
                    const SizedBox(height: 12),
                    if (provider.meals.isEmpty)
                      _empty(provider)
                    else
                      ..._buildGroups(context, provider),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _status(MealProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Text(
          'Menyinkronkan menu...',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      );
    }
    if (provider.errorMessage != null) {
      return Center(
        child: Text(
          provider.errorMessage!,
          style: const TextStyle(color: Color(0xFFFFD08A), fontSize: 12),
        ),
      );
    }
    if (provider.pendingCount > 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            size: 14,
            color: Color(0xFFFFD08A),
          ),
          const SizedBox(width: 6),
          Text(
            '${provider.pendingCount} perubahan belum tersinkron',
            style: const TextStyle(color: Color(0xFFFFD08A), fontSize: 12),
          ),
          TextButton(
            onPressed: provider.sync,
            child: const Text(
              'Sinkronkan',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _empty(MealProvider provider) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Rencana menu mingguanmu sedang disiapkan PT.\nTarik ke bawah untuk memuat ulang.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  List<Widget> _buildGroups(BuildContext context, MealProvider provider) {
    final grouped = <String, List<Meal>>{};
    for (final meal in provider.meals) {
      final key = meal.dayOfWeek ?? 'none';
      grouped.putIfAbsent(key, () => []).add(meal);
    }

    final keys = <String>[
      ...dayOrder.where(grouped.containsKey),
      if (grouped.containsKey('none')) 'none',
    ];

    final widgets = <Widget>[];
    for (final key in keys) {
      final meals = grouped[key]!;
      meals.sort((a, b) {
        final ai = _mealOrder.indexOf(a.mealType);
        final bi = _mealOrder.indexOf(b.mealType);
        return (ai == -1 ? 99 : ai).compareTo(bi == -1 ? 99 : bi);
      });

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            key == 'none' ? 'Tanpa hari' : dayLabel(key),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      );

      for (final meal in meals) {
        widgets.add(_mealCard(context, provider, meal));
      }
    }
    return widgets;
  }

  Widget _mealCard(BuildContext context, MealProvider provider, Meal meal) {
    final detail = [
      mealTypeLabel(meal.mealType),
      if (meal.calories != null) '${meal.calories} kkal',
    ].join(' - ');

    final macros = <String>[
      if (meal.proteinG != null) 'P ${meal.proteinG!.toStringAsFixed(0)}g',
      if (meal.carbsG != null) 'K ${meal.carbsG!.toStringAsFixed(0)}g',
      if (meal.fatG != null) 'L ${meal.fatG!.toStringAsFixed(0)}g',
    ].join('  ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white38),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.restaurant_menu, color: Colors.tealAccent),
        ),
        title: Text(meal.foodName, style: const TextStyle(color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            if (macros.isNotEmpty)
              Text(
                macros,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!meal.synced)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.cloud_upload_outlined,
                  size: 16,
                  color: Color(0xFFFFD08A),
                ),
              ),
            Checkbox(
              value: meal.isDone,
              activeColor: Colors.greenAccent,
              checkColor: Colors.black,
              onChanged: (_) => provider.toggleDone(meal.id),
            ),
          ],
        ),
        onTap: () => provider.toggleDone(meal.id),
      ),
    );
  }
}
