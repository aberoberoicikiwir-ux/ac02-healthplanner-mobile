import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import 'workout_detail_screen.dart';

class WorkoutPlanScreen extends StatelessWidget {
  const WorkoutPlanScreen({super.key});

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _AddWorkoutDialog(),
    );
    if (result == null || !context.mounted) return;
    await context.read<WorkoutProvider>().addWorkout(
          name: result['name']!,
          detail: result['detail']!,
        );
  }

  // Status sinkronisasi (loading / offline / terakhir sinkron) dan
  // jumlah perubahan yang belum terkirim.
  Widget _buildStatus(WorkoutProvider provider) {
    Widget text;
    if (provider.isLoading) {
      text = const Text('Menyinkronkan data...',
          style: TextStyle(color: Colors.white70, fontSize: 12));
    } else if (provider.errorMessage != null) {
      text = Text(provider.errorMessage!,
          style: const TextStyle(color: Color(0xFFFFD08A), fontSize: 12));
    } else if (provider.lastSynced != null) {
      text = Text('Terakhir sinkron: ${_formatTime(provider.lastSynced!)}',
          style: const TextStyle(color: Colors.white60, fontSize: 12));
    } else {
      text = const SizedBox.shrink();
    }

    return Column(
      children: [
        text,
        if (provider.pendingCount > 0 && !provider.isLoading)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_upload_outlined,
                  size: 14, color: Color(0xFFFFD08A)),
              const SizedBox(width: 6),
              Text('${provider.pendingCount} perubahan belum tersinkron',
                  style: const TextStyle(
                      color: Color(0xFFFFD08A), fontSize: 12)),
              TextButton(
                onPressed: provider.sync,
                child: const Text('Sinkronkan',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
      ],
    );
  }

  // Empty state: belum ada data sama sekali di database
  Widget _buildEmpty(WorkoutProvider provider) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: provider.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Belum ada data latihan.\nTarik ke bawah untuk memuat ulang.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
        ),
      ],
    );
  }

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
      // Tombol "+" : tambah latihan tambahan di luar rencana
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8E9AAF), Color(0xFF6E7B94)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Text('Workout Plan',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w300,
                      color: Colors.white)),
              const SizedBox(height: 12),
              Image.asset('assets/images/logo.png', height: 50),
              const SizedBox(height: 12),
              Expanded(
                child: Consumer<WorkoutProvider>(
                  builder: (context, workoutProvider, child) {
                    final workouts = workoutProvider.workouts;
                    return Column(
                      children: [
                        _buildStatus(workoutProvider),
                        const SizedBox(height: 8),
                        Expanded(
                          // Tarik ke bawah = sinkron ulang dengan server
                          child: RefreshIndicator(
                            onRefresh: workoutProvider.sync,
                            child: workouts.isEmpty
                                ? _buildEmpty(workoutProvider)
                                : ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 0, 20, 90),
                                    itemCount: workouts.length,
                                    itemBuilder: (context, index) {
                                      final w = workouts[index];

                                      final card = Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 14),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.white38),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: ListTile(
                                          leading: Container(
                                            width: 46,
                                            height: 46,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1E3A8A),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                                Icons.fitness_center,
                                                color: Colors.tealAccent),
                                          ),
                                          title: Text(w.name,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                          subtitle: Text(w.detail,
                                              style: const TextStyle(
                                                  color: Colors.white60)),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Ikon awan = belum tersinkron
                                              if (!w.synced)
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(right: 8),
                                                  child: Icon(
                                                      Icons
                                                          .cloud_upload_outlined,
                                                      size: 18,
                                                      color:
                                                          Color(0xFFFFD08A)),
                                                ),
                                              w.isDone
                                                  ? const Icon(
                                                      Icons.check_circle,
                                                      color:
                                                          Colors.greenAccent)
                                                  : const Icon(
                                                      Icons.chevron_right,
                                                      color: Colors.white70),
                                            ],
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      WorkoutDetailScreen(
                                                          workoutId: w.id)),
                                            );
                                          },
                                        ),
                                      );

                                      // Rencana dari server tidak bisa dihapus
                                      if (!w.isLocal) return card;

                                      // Latihan buatan sendiri: geser ke kiri = hapus
                                      return Dismissible(
                                        key: ValueKey(w.id),
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 14),
                                          padding:
                                              const EdgeInsets.only(right: 24),
                                          alignment: Alignment.centerRight,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE24B4A),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.white),
                                        ),
                                        onDismissed: (_) => workoutProvider
                                            .deleteWorkout(w.id),
                                        child: card,
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog tambah latihan. Dibuat StatefulWidget supaya controller
/// teksnya di-dispose dengan benar.
class _AddWorkoutDialog extends StatefulWidget {
  const _AddWorkoutDialog();

  @override
  State<_AddWorkoutDialog> createState() => _AddWorkoutDialogState();
}

class _AddWorkoutDialogState extends State<_AddWorkoutDialog> {
  final _nameController = TextEditingController();
  final _detailController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Nama latihan wajib diisi');
      return;
    }
    final detail = _detailController.text.trim();
    Navigator.pop(context, {
      'name': name,
      'detail': detail.isEmpty ? 'Latihan tambahan' : detail,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah latihan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Nama latihan',
              errorText: _error,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _detailController,
            decoration: const InputDecoration(
              labelText: 'Detail (mis. 3 sets x 10 reps)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}
