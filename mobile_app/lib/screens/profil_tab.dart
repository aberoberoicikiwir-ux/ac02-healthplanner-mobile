import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'health_profile_screen.dart';

class ProfilTab extends StatelessWidget {
  const ProfilTab({super.key});

  Future<void> _editProfile(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HealthProfileFormScreen(isEdit: true),
      ),
    );
  }

  Future<void> _choosePt(BuildContext context) async {
    final controller = TextEditingController(text: 'pt_demo');
    final username = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih PT'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Masukkan username Personal Trainer. Contoh akun demo: pt_demo.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Username PT'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (username == null || username.isEmpty || !context.mounted) return;

    final profile = context.read<ProfileProvider>();
    final ok = await profile.choosePt(username);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'PT berhasil dipilih.'
              : profile.errorMessage ?? 'Gagal memilih PT.',
        ),
      ),
    );
  }

  Future<void> _editServerUrl(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final controller = TextEditingController(text: settings.apiBaseUrl);
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alamat Server'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Untuk emulator Android biasanya http://10.0.2.2:3000/api. '
              'Untuk HP fisik pakai IP laptop, mis. http://192.168.1.5:3000/api.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: 'Base URL'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, settings.defaultApiBaseUrl),
            child: const Text('Default'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (url == null || !context.mounted) return;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat harus diawali http:// atau https://'),
        ),
      );
      return;
    }
    await settings.setApiBaseUrl(url);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Alamat server disimpan.')));
  }

  String _genderLabel(String? value) {
    switch (value) {
      case 'male':
        return 'Laki-laki';
      case 'female':
        return 'Perempuan';
      default:
        return '-';
    }
  }

  String _activityLabel(String? value) {
    switch (value) {
      case 'sedentary':
        return 'Sangat jarang';
      case 'light':
        return 'Ringan';
      case 'moderate':
        return 'Sedang';
      case 'active':
        return 'Aktif';
      case 'very_active':
        return 'Sangat aktif';
      default:
        return '-';
    }
  }

  String _number(num? value, {String suffix = ''}) {
    if (value == null) return '-';
    final text = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
    return '$text$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();

    return Container(
      decoration: AppColors.backgroundDecoration,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: profile.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.displayName ?? 'User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Klien',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.hasPt
                              ? 'PT: sudah terhubung'
                              : 'PT: belum dipilih',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _sectionTitle('Health Profile'),
              const SizedBox(height: 10),
              _cardContainer(
                child: Column(
                  children: [
                    _infoRow(
                      'Berat Badan',
                      _number(profile.weightCurrent, suffix: ' kg'),
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    _infoRow(
                      'Target Berat',
                      _number(profile.weightTarget, suffix: ' kg'),
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    _infoRow(
                      'Tinggi Badan',
                      _number(profile.heightCm, suffix: ' cm'),
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    _infoRow('Alergi', profile.allergies ?? '-'),
                    const Divider(color: Colors.white24, height: 20),
                    _infoRow('Jenis Kelamin', _genderLabel(profile.gender)),
                    const Divider(color: Colors.white24, height: 20),
                    _infoRow('Tanggal Lahir', profile.birthDate ?? '-'),
                    const Divider(color: Colors.white24, height: 20),
                    _infoRow(
                      'Aktivitas',
                      _activityLabel(profile.activityLevel),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _editProfile(context),
                        icon: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Edit',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white38),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Personal Trainer'),
              const SizedBox(height: 10),
              _cardContainer(
                child: _menuRow(
                  icon: Icons.person_add_alt_1,
                  label: profile.hasPt ? 'Ganti PT' : 'Pilih PT',
                  onTap: () => _choosePt(context),
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Pengaturan Akun'),
              const SizedBox(height: 10),
              _cardContainer(
                child: Column(
                  children: [
                    _menuRow(
                      icon: Icons.dns_outlined,
                      label: 'Alamat Server',
                      onTap: () => _editServerUrl(context),
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    _switchRow(
                      icon: Icons.notifications_outlined,
                      label: 'Notifikasi',
                      value: settings.notificationsEnabled,
                      onChanged: (val) => settings.setNotificationsEnabled(val),
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    _switchRow(
                      icon: Icons.wifi_off,
                      label: 'Simulasi offline (demo)',
                      value: settings.simulateOffline,
                      onChanged: (val) => settings.setSimulateOffline(val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Lainnya'),
              const SizedBox(height: 10),
              _cardContainer(
                child: _menuRow(
                  icon: Icons.help_outline,
                  label: 'Bantuan / FAQ',
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.read<AuthProvider>().logout(),
                  icon: const Icon(
                    Icons.logout,
                    size: 18,
                    color: Color(0xFFF09595),
                  ),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Color(0xFFF09595),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF09595)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _cardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: child,
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(color: Colors.white)),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _switchRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
