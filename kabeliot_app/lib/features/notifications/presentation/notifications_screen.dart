import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/mqtt/notification_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_scaffold.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(mqttNotificationsProvider);
    final notifier = ref.read(mqttNotificationsProvider.notifier);
    final unread = notifications.where((n) => !n.isRead).length;

    // Group by date label
    final groups = _groupByDate(notifications);

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text('Bildirimler', style: AppTextStyles.headingMedium),
            if (unread > 0) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$unread',
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: notifier.markAllRead,
            child: Text(
              'Tümünü Oku',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      child: SafeArea(
        child: notifications.isEmpty
            ? _EmptyState()
            : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                itemCount: groups.length,
                itemBuilder: (context, gi) {
                  final group = groups[gi];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: gi == 0 ? 0 : 16.h, bottom: 10.h),
                        child: Text(
                          group.label,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textDisabled,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      ...group.items.asMap().entries.map((e) {
                        final notif = e.value;
                        return _NotifCard(
                          notif: notif,
                          delay: Duration(milliseconds: gi * 80 + e.key * 50),
                          onTap: () => notifier.markRead(notif.id),
                        );
                      }),
                    ],
                  );
                },
              ),
      ),
    );
  }

  List<_NotifGroup> _groupByDate(List<AppNotification> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    final todayItems = <AppNotification>[];
    final yesterdayItems = <AppNotification>[];
    final weekItems = <AppNotification>[];
    final olderItems = <AppNotification>[];

    for (final n in notifications) {
      final d = DateTime(n.timestamp.year, n.timestamp.month, n.timestamp.day);
      if (d == today) {
        todayItems.add(n);
      } else if (d == yesterday) {
        yesterdayItems.add(n);
      } else if (!d.isBefore(weekStart)) {
        weekItems.add(n);
      } else {
        olderItems.add(n);
      }
    }

    return [
      if (todayItems.isNotEmpty) _NotifGroup(label: 'Bugün', items: todayItems),
      if (yesterdayItems.isNotEmpty) _NotifGroup(label: 'Dün', items: yesterdayItems),
      if (weekItems.isNotEmpty) _NotifGroup(label: 'Bu Hafta', items: weekItems),
      if (olderItems.isNotEmpty) _NotifGroup(label: 'Daha Önce', items: olderItems),
    ];
  }
}

class _NotifCard extends StatelessWidget {
  const _NotifCard({
    required this.notif,
    required this.delay,
    required this.onTap,
  });

  final AppNotification notif;
  final Duration delay;
  final VoidCallback onTap;

  String _formatTime(DateTime ts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(ts.year, ts.month, ts.day);
    if (d == today) {
      return '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
    }
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[ts.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notif.isRead;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isRead ? AppColors.surface : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isRead ? 3.w : 4.w,
                    color: isRead ? AppColors.border : notif.color,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(14.r),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36.r,
                            height: 36.r,
                            decoration: BoxDecoration(
                              color: notif.color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(notif.icon, color: notif.color, size: 18.r),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notif.title,
                                        style: AppTextStyles.headingSmall.copyWith(
                                          color: isRead
                                              ? AppColors.textSecondary
                                              : AppColors.textPrimary,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                    Text(_formatTime(notif.timestamp),
                                        style: AppTextStyles.labelSmall),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(notif.body, style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                          if (!isRead) ...[
                            SizedBox(width: 8.w),
                            Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: BoxDecoration(
                                color: notif.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: delay),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 64.r, color: AppColors.textDisabled),
          SizedBox(height: 16.h),
          Text('Henüz bildirim yok',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled)),
        ],
      ),
    );
  }
}

class _NotifGroup {
  const _NotifGroup({required this.label, required this.items});
  final String label;
  final List<AppNotification> items;
}
