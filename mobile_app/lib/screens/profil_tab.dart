import 'package:flutter/material.dart';

class ProfilTab extends StatefulWidget {
  const ProfilTab({super.key});

  @override
  State<ProfilTab> createState() => _ProfilTabState();
}

class _ProfilTabState extends State<ProfilTab> {
  // State lokal buat toggle notifikasi (sementara, belum nyambung backend)
  bool _notifOn = true;

  @override
  Widget build(BuildContext context) {
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
                  children: const [
                    Text('User',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text('Klien', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 2),
                    Text('PT: Belum ditentukan',
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
                      label: const Text('Edit', style: TextStyle(color: Colors.white)),
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
                  _switchRow(
                    icon: Icons.notifications_outlined,
                    label: 'Notifikasi',
                    value: _notifOn,
                    onChanged: (val) => setState(() => _notifOn = val),
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
                onPressed: () {
                  // Logout -> balik ke Login, hapus semua history navigasi
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.logout, size: 18, color: Color(0xFFF09595)),
                label: const Text('Logout',
                    style: TextStyle(color: Color(0xFFF09595), fontWeight: FontWeight.w600)),
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