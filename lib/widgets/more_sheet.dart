import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// عناصر قائمة "المزيد" — لاحقًا هتتحدد ديناميكيًا حسب صلاحيات
/// الموظف الفعلية من جدول user_module_access في السيرفر.
/// حاليًا القائمة ثابتة (Mock) لحد ما نبني الـ API.
const _moreItems = [
  (Icons.bolt, 'طلب OT', AppColors.primary, AppColors.primaryBg),
  (Icons.history, 'سجل الحضور', AppColors.primary, AppColors.primaryBg),
  (Icons.receipt_long, 'كشوف الرواتب', AppColors.info, AppColors.infoBg),
  (Icons.local_shipping, 'طلبات التحويل', AppColors.success, AppColors.successBg),
  (Icons.build, 'المعدات', AppColors.danger, AppColors.dangerBg),
  (Icons.inventory_2, 'المواد', AppColors.purple, AppColors.purpleBg),
  (Icons.groups, 'عمالة خارجية', AppColors.primary, AppColors.primaryBg),
  (Icons.event_busy, 'طلب إجازة', AppColors.info, AppColors.infoBg),
  (Icons.settings, 'إعدادات الحساب', Color(0xFF555555), Color(0xFFF5F5F5)),
  (Icons.logout, 'تسجيل الخروج', AppColors.danger, AppColors.dangerBg),
];

void showMoreSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const Text('كل الأقسام',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 4),
          const Text('الأقسام المعروضة حسب صلاحياتك فقط',
              style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: .78,
            children: _moreItems.map((item) {
              final (icon, label, color, bg) = item;
              return InkWell(
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$label — قريبًا')),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
                      child: Icon(icon, size: 20, color: color),
                    ),
                    const SizedBox(height: 6),
                    Text(label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}
