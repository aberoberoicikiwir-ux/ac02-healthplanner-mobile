import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/coach_message.dart';
import '../models/insight_notification.dart';
import '../providers/coach_provider.dart';
import '../providers/insight_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class InsightAiTab extends StatefulWidget {
  const InsightAiTab({super.key});

  @override
  State<InsightAiTab> createState() => _InsightAiTabState();
}

class _InsightAiTabState extends State<InsightAiTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightProvider>().load();
      context.read<CoachProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: AppColors.backgroundDecoration,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Insight AI',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                indicatorColor: Colors.tealAccent,
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: 'Insight'),
                  Tab(text: 'Tanya Coach'),
                ],
              ),
              Expanded(
                child: TabBarView(children: [_InsightFeed(), _CoachChat()]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<InsightProvider>(
      builder: (context, provider, _) {
        final ai = provider.aiInsights;
        final others = provider.otherNotifications;

        return RefreshIndicator(
          onRefresh: provider.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              if (provider.errorMessage != null)
                _banner(provider.errorMessage!),
              if (provider.loading && provider.notifications.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else if (ai.isEmpty && others.isEmpty)
                _empty()
              else ...[
                if (ai.isNotEmpty) ...[
                  _sectionTitle('Insight Mingguan'),
                  ...ai.map(
                    (n) => _NotificationCard(
                      notification: n,
                      onTap: n.isRead ? null : () => provider.markRead(n.id),
                    ),
                  ),
                ],
                if (others.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _sectionTitle('Pengingat & Sistem'),
                  ...others.map(
                    (n) => _NotificationCard(
                      notification: n,
                      onTap: n.isRead ? null : () => provider.markRead(n.id),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _banner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD08A).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFFFFD08A), fontSize: 12),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _empty() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Belum ada insight. Insight akan muncul setelah PT menyetujui rencana mingguanmu.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, this.onTap});

  final InsightNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isAi = notification.isAiInsight;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead ? Colors.white24 : Colors.tealAccent,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isAi ? Icons.auto_awesome : Icons.notifications_outlined,
                color: Colors.tealAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.tealAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatDateTime(notification.createdAt),
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachChat extends StatefulWidget {
  @override
  State<_CoachChat> createState() => _CoachChatState();
}

class _CoachChatState extends State<_CoachChat> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (context.read<SettingsProvider>().simulateOffline) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final ok = await context.read<CoachProvider>().send(text);
    if (ok && mounted) {
      _controller.clear();
      setState(() {});
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus riwayat chat?'),
        content: const Text('Semua percakapan dengan Coach akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<CoachProvider>().clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoachProvider>(
      builder: (context, provider, _) {
        final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
        final offline = context.watch<SettingsProvider>().simulateOffline;
        final bubbles = <Widget>[
          ...provider.messages.map((m) => _bubble(context, m)),
          if (provider.pendingMessage != null)
            _userBubble(provider.pendingMessage!, pending: true),
          if (provider.sending) _typingBubble(),
        ];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Coach AI bukan pengganti dokter/PT. Pertanyaan medis akan diarahkan ke profesional.',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ),
                  TextButton(
                    onPressed: provider.messages.isEmpty && !provider.sending
                        ? null
                        : _clearHistory,
                    child: const Text('Hapus', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
            if (offline)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Mode simulasi offline: kirim dinonaktifkan.',
                  style: TextStyle(color: Color(0xFFFFD08A), fontSize: 11),
                ),
              ),
            Expanded(
              child: provider.loading && provider.messages.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : bubbles.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Belum ada chat.\nTanyakan seputar latihan, menu, atau motivasi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: bubbles.length,
                      itemBuilder: (context, index) =>
                          bubbles[bubbles.length - 1 - index],
                    ),
            ),
            if (provider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  provider.errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFFFFD08A),
                    fontSize: 12,
                  ),
                ),
              ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, keyboardOpen ? 8 : 90),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(500),
                        ],
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Tanya Coach...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: AppColors.surfaceAlt,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed:
                          provider.sending ||
                              _controller.text.trim().isEmpty ||
                              offline
                          ? null
                          : _send,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      icon: provider.sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _bubble(BuildContext context, CoachMessage message) {
    if (message.isUser) return _userBubble(message.content);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Coach',
              style: TextStyle(
                color: Colors.tealAccent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: const TextStyle(color: Colors.white, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userBubble(String text, {bool pending = false}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: pending ? 0.6 : 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, height: 1.4),
        ),
      ),
    );
  }

  Widget _typingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'Coach sedang menulis...',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ),
    );
  }
}
