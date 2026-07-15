import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifs = [
      {
        'icon': Icons.precision_manufacturing,
        'title': 'تم اعتماد تشغيل حفارة كاتربيلر',
        'desc': 'مشروع القدية — 4,250 ر.س',
        'time': 'الآن',
        'unread': true,
      },
      {
        'icon': Icons.chat_bubble_outline,
        'title': 'رد جديد على سجل تشغيل',
        'desc': 'عمار عبد الصمد علّق على سجلك',
        'time': 'منذ دقيقتين',
        'unread': true,
      },
      {
        'icon': Icons.inventory_2_outlined,
        'title': 'إضافة سجل مواد جديد',
        'desc': 'مواسير دكتايل — MSA-26070002',
        'time': 'منذ 10 دقائق',
        'unread': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifs.length,
        itemBuilder: (context, i) {
          final n = notifs[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(n['icon'] as IconData, color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n['title'] as String,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(n['desc'] as String,
                          style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Text(n['time'] as String,
                          style: const TextStyle(fontSize: 9, color: Color(0xFFC2C9D1))),
                    ],
                  ),
                ),
                if (n['unread'] as bool)
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
