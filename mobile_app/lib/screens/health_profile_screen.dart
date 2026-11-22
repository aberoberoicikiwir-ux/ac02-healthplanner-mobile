import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';

class HealthProfileGate extends StatefulWidget {
  const HealthProfileGate({super.key});

  @override
  State<HealthProfileGate> createState() => _HealthProfileGateState();
}

class _HealthProfileGateState extends State<HealthProfileGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();
      if (!provider.loaded) provider.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profile, _) {
        if (!profile.loaded && profile.loading) {
          return const _ProfileLoading();
        }
        if (!profile.loaded && profile.errorMessage != null) {
          return _ProfileError(
            message: profile.errorMessage!,
            onRetry: profile.load,
          );
        }
        if (profile.profile != null) {
          return const MainNavigationScreen();
        }
        return const HealthProfileFormScreen();
      },
    );
  }
}

class _ProfileLoading extends StatelessWidget {
  const _ProfileLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat profil...'),
          ],
        ),
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HealthProfileFormScreen extends StatefulWidget {
  const HealthProfileFormScreen({super.key, this.isEdit = false});

  final bool isEdit;

  @override
  State<HealthProfileFormScreen> createState() =>
      _HealthProfileFormScreenState();
}

class _HealthProfileFormScreenState extends State<HealthProfileFormScreen> {
  final _weightCurrent = TextEditingController();
  final _weightTarget = TextEditingController();
  final _height = TextEditingController();
  final _allergies = TextEditingController();

  String? _gender;
  String? _activityLevel;
  String? _birthDate;
  String? _formError;
  bool _saving = false;
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final profile = context.read<ProfileProvider>().profile;
    if (profile == null) return;

    _weightCurrent.text = _numberText(profile['weight_current']);
    _weightTarget.text = _numberText(profile['weight_target']);
    _height.text = _numberText(profile['height_cm']);
    _allergies.text = profile['allergies']?.toString() ?? '';
    _gender = profile['gender']?.toString();
    _activityLevel = profile['activity_level']?.toString();
    _birthDate = profile['birth_date']?.toString();
  }

  String _numberText(dynamic value) {
    if (value is num) {
      if (value == value.roundToDouble()) return value.toInt().toString();
      return value.toString();
    }
    return '';
  }

  @override
  void dispose() {
    _weightCurrent.dispose();
    _weightTarget.dispose();
    _height.dispose();
    _allergies.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    DateTime initial = DateTime(2000, 1, 1);
    if (_birthDate != null) {
      initial = DateTime.tryParse(_birthDate!) ?? initial;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _birthDate =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _submit() async {
    final current = double.tryParse(_weightCurrent.text.replaceAll(',', '.'));
    final target = double.tryParse(_weightTarget.text.replaceAll(',', '.'));
    final height = _height.text.trim().isEmpty
        ? null
        : double.tryParse(_height.text.replaceAll(',', '.'));

    if (current == null || target == null) {
      setState(() => _formError = 'Berat badan dan target wajib diisi angka.');
      return;
    }
    if (_height.text.trim().isNotEmpty && height == null) {
      setState(() => _formError = 'Tinggi badan harus berupa angka.');
      return;
    }

    final body = <String, dynamic>{
      'weight_current': current,
      'weight_target': target,
    };
    if (height != null) body['height_cm'] = height;
    final allergies = _allergies.text.trim();
    if (allergies.isNotEmpty) body['allergies'] = allergies;
    if (_gender != null) body['gender'] = _gender;
    if (_activityLevel != null) body['activity_level'] = _activityLevel;
    if (_birthDate != null) body['birth_date'] = _birthDate;

    setState(() {
      _saving = true;
      _formError = null;
    });

    final provider = context.read<ProfileProvider>();
    final ok = widget.isEdit
        ? await provider.updateProfile(body)
        : await provider.createProfile(body);

    if (!mounted) return;
    setState(() => _saving = false);

    if (!ok) {
      setState(() => _formError = provider.errorMessage ?? 'Gagal menyimpan.');
      return;
    }

    if (widget.isEdit) {
      Navigator.pop(context);
    }
    // Untuk profil baru, HealthProfileGate otomatis membuka aplikasi.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Edit Data Kesehatan' : 'Lengkapi Data Kesehatan',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Data ini dipakai untuk menyusun rencana latihan dan menu yang sesuai.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          _numberField(_weightCurrent, 'Berat Badan (kg)'),
          const SizedBox(height: 16),
          _numberField(_weightTarget, 'Target Berat Badan (kg)'),
          const SizedBox(height: 16),
          TextField(
            controller: _height,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _decoration('Tinggi Badan (cm, opsional)'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _allergies,
            maxLength: 500,
            decoration: _decoration('Alergi (opsional, mis. kacang, udang)'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _gender,
            decoration: _decoration('Jenis Kelamin (opsional)'),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
              DropdownMenuItem(value: 'female', child: Text('Perempuan')),
            ],
            onChanged: (value) => setState(() => _gender = value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _activityLevel,
            decoration: _decoration('Tingkat Aktivitas (opsional)'),
            items: const [
              DropdownMenuItem(
                value: 'sedentary',
                child: Text('Sangat jarang'),
              ),
              DropdownMenuItem(value: 'light', child: Text('Ringan')),
              DropdownMenuItem(value: 'moderate', child: Text('Sedang')),
              DropdownMenuItem(value: 'active', child: Text('Aktif')),
              DropdownMenuItem(
                value: 'very_active',
                child: Text('Sangat aktif'),
              ),
            ],
            onChanged: (value) => setState(() => _activityLevel = value),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickBirthDate,
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              _birthDate == null
                  ? 'Pilih Tanggal Lahir (opsional)'
                  : 'Lahir: $_birthDate',
            ),
          ),
          const SizedBox(height: 20),
          if (_formError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _formError!,
                style: const TextStyle(color: Color(0xFFE24B4A)),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(widget.isEdit ? 'Simpan Perubahan' : 'Mulai'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _decoration(label),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
