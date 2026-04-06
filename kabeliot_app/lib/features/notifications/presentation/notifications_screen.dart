import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_scaffold.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Set<int> _readIds = {};

  static const _groups = [
    _NotifGroup(label: 'Bugün', items: [
      _NotifItem(id: 0, icon: Icons.wifi_rounded, color: AppColors.success, title: 'PCB-Kontrol-001 bağlandı', body: 'Cihaz MQTT sunucusuna başarıyla bağlandı.', time: '09:42'),
      _NotifItem(id: 1, icon: Icons.thermostat_rounded, color: AppColors.warning, title: 'Sıcaklık Uyarısı', body: 'Sensör-Node-02: Sıcaklık 42°C sınırını aştı.', time: '08:15'),
      _NotifItem(id: 2, icon: Icons.wifi_off_rounded, color: AppColors.error, title: 'Gateway-Ana bağlantısı kesildi', body: 'Cihaz 5 dakikadır yanıt vermiyor.', time: '07:30'),
    ]),
    _NotifGroup(label: 'Dün', items: [
      _NotifItem(id: 3, icon: Icons.toggle_on_rounded, color: AppColors.accent, title: 'Röle-01 açıldı', body: 'PCB-Motor-04 üzerindeki Röle-01 tetiklendi.', time: '18:55'),
      _NotifItem(id: 4, icon: Icons.battery_alert_rounded, color: AppColors.warning, title: 'Düşük Güç', body: 'Sensör-Node-05 pil seviyesi %15\'e düştü.', time: '14:20'),
    ]),
    _NotifGroup(label: 'Bu Hafta', items: [
      _NotifItem(id: 5, icon: Icons.system_update_rounded, color: AppColors.primary, title: 'Firmware Güncelleme', body: 'PCB-Kontrol-001 için yeni firmware mevcut.', time: 'Salı'),
      _NotifItem(id: 6, icon: Icons.add_circle_outline_rounded, color: AppColors.success, title: 'Yeni Cihaz Eklendi', body: 'Röle-Kontrol-06 sisteme başarıyla eklendi.', time: 'Pzt'),
    ]),
  ];

  int get _unreadCount => _groups.expand((g) => g.items).where((n) => !_readIds.contains(n.id)).length;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text('Bildirimler', style: AppTextStyles.headingMedium),
            if (_unreadCount > 0) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text('$_unreadCount', style: AppTextStyles.labelSmall.copyWith(color: Colors.white)),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _readIds.addAll(_groups.expand((g) => g.items).map((n) => n.id))),
            child: Text('Tümünü Oku', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      child: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          itemCount: _groups.length,
          itemBuilder: (context, gi) {
            final group = _groups[gi];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: gi == 0 ? 0 : 16.h, bottom: 10.h),
                  child: Text(group.label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled, letterSpacing: 1.2)),
                ),
                ...group.items.asMap().entries.map((e) {
                  final notif = e.value;
                  final isRead = _readIds.contains(notif.id);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: GestureDetector(
                      onTap: () => setState(() => _readIds.add(notif.id)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: isRead ? AppColors.surface : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border(
                            left: BorderSide(
                              color: isRead ? AppColors.border : notif.color,
                              width: isRead ? 1 : 3,
                            ),
                            top: const BorderSide(color: AppColors.border, width: 1),
                            right: const BorderSide(color: AppColors.border, width: 1),
                            bottom: const BorderSide(color: AppColors.border, width: 1),
                          ),
                        ),
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
                                            color: isRead ? AppColors.textSecondary : AppColors.textPrimary,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                      Text(notif.time, style: AppTextStyles.labelSmall),
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
                                decoration: BoxDecoration(color: notif.color, shape: BoxShape.circle),
                              ),
                            ],
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: gi * 80 + e.key * 50)),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NotifGroup {
  const _NotifGroup({required this.label, required this.items});
  final String label;
  final List<_NotifItem> items;
}

class _NotifItem {
  const _NotifItem({required this.id, required this.icon, required this.color, required this.title, required this.body, required this.time});
  final int id;
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
}
