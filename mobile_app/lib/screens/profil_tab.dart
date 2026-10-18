import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import 'login_screen.dart';

class ProfilTab extends StatelessWidget {
  const ProfilTab({super.key});

  @override
  Widget build(BuildContext context) {
    // watch = widget ini rebuild otomatis kalau Global State berubah.
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8E9AAF), Color(0xFF6E7B94)],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
          children: [
            // ===== 1. Header Profil =====
            Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 32, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama diambil dari AuthProvider (hasil login yang tersimpan)
                    Text(auth.username ?? 'User',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const Text('Klien',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 2),
                    const Text('PT: Belum ditentukan',
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ===== 2. Ringkasan Health Profile =====
            _sectionTitle('Health Profile'),
            const SizedBox(height: 10),
            _cardContainer(
              child: Column(
                children: [
                  _infoRow('Berat Badan', '68 kg'),
                  const Divider(color: Colors.white24, height: 20),
                  _infoRow('Target', 'Turun 5kg'),
                  const Divider(color: Colors.white24, height: 20),
                  _infoRow('Alergi', 'Tidak ada'),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: nanti arahkan ke form edit health profile
                      },
                      icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                      label: const Text('Edit',
                          style: TextStyle(color: Colors.white)),
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

            // ===== 3. Pengaturan Akun =====
            _sectionTitle('Pengaturan Akun'),
            const SizedBox(height: 10),
            _cardContainer(
              child: Column(
                children: [
                  _menuRow(
                    icon: Icons.lock_outline,
                    label: 'Ubah Kata Sandi',
                    onTap: () {},
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  // Disimpan di shared_preferences -> tetap ada setelah app ditutup
                  _switchRow(
                    icon: Icons.notifications_outlined,
                    label: 'Notifikasi',
                    value: settings.notificationsEnabled,
                    onChanged: (val) => settings.setNotificationsEnabled(val),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  // Khusus demo: membuktikan app tetap jalan dari database lokal
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

            // ===== 4. Tentang Aplikasi =====
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

            // ===== Logout =====
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  // Hapus token dari secure storage, lalu balik ke Login
                  // dan bersihkan semua history navigasi.
                  await context.read<AuthProvider>().logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout,
                    size: 18, color: Color(0xFFF09595)),
                label: const Text('Logout',
                    style: TextStyle(
                        color: Color(0xFFF09595), fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFF09595)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
          color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
    );
  }

  Widget _cardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
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
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
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
                child: Text(label, style: const TextStyle(color: Colors.white))),
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
              child: Text(label, style: const TextStyle(color: Colors.white))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }
}
