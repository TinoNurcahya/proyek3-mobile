import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import '../../widgets/bottom_navbar.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/empty_state_widget.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    final provider = context.read<NotificationProvider>();
    Future.microtask(() {
      provider.fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Sora',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Consumer<NotificationProvider>(
                    builder: (context, provider, child) {
                      if (provider.unreadCount == 0) return const SizedBox();
                      return TextButton(
                        onPressed: provider.markAllAsRead,
                        child: Text(
                          'Tandai Semua Dibaca (${provider.unreadCount})',
                          style: const TextStyle(
                            color: Color(0xFFC67C4E),
                            fontSize: 11,
                            fontFamily: 'Sora',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.notifications.isEmpty) {
                    return const LoadingWidget(message: 'Memuat notifikasi...');
                  }
                  if (provider.notifications.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'Belum Ada Notifikasi',
                      message: 'Notifikasimu akan muncul di sini setelah\nkamu menerimanya.',
                      icon: Icons.notifications_none_rounded,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => provider.fetchNotifications(),
                    color: const Color(0xFFC67C4E),
                    child: _buildList(provider.notifications),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/order');
          if (index == 2) Navigator.pushReplacementNamed(context, '/scan');
          if (index == 3) Navigator.pushReplacementNamed(context, '/notification');
          if (index == 4) Navigator.pushReplacementNamed(context, '/profile');
        },
        onProfile: () => Navigator.pushReplacementNamed(context, '/profile'),
        onLogout: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
      ),
    );
  }

  Widget _buildList(List<NotificationModel> notifications) {
    // Kelompokkan berdasarkan group
    final groups = notifications.map((n) => n.group).toSet().toList();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: groups.map((group) {
        final notifsByGroup = notifications
            .where((n) => n.group == group)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 10),
              child: Text(
                group,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...notifsByGroup.map((notif) => _buildNotifCard(notif)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildNotifCard(NotificationModel notif) {
    // Tap card = mark as read
    return GestureDetector(
      onTap: () {
        if (!notif.isRead) {
          context.read<NotificationProvider>().markAsRead(notif.id);
        }
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: notif.isRead ? Colors.white : const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(14),
        border: notif.isRead
            ? null
            : Border.all(color: const Color(0xFFC67C4E).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF9E5BE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: Color(0xFFC67C4E),
              size: 22,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontFamily: 'Sora',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.subtitle,
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontFamily: 'Sora',
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => context
                    .read<NotificationProvider>()
                    .deleteNotification(notif.id),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFBE4B4B),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 8, bottom: 14),
                child: Text(
                  notif.time,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontFamily: 'Sora',
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
     ),
    );
  }
}
