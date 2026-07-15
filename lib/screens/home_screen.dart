import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/more_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  final _tabs = const [
    _DashboardTab(),
    _PlaceholderTab(title: 'حضوري', icon: Icons.calendar_month),
    _PlaceholderTab(title: 'الراتب', icon: Icons.account_balance_wallet),
  ];

  void _onNavTap(int index) {
    if (index == 3) {
      showMoreSheet(context);
      return;
    }
    setState(() => _tabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(bottom: false, child: _tabs[_tabIndex]),
      bottomNavigationBar: _BottomNav(
        currentIndex: _tabIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home, 'الرئيسية'),
      (Icons.calendar_month, 'حضوري'),
      (Icons.account_balance_wallet, 'الراتب'),
      (Icons.grid_view_rounded, 'المزيد'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(items.length, (i) {
            final active = i == currentIndex && i != 3;
            final (icon, label) = items[i];
            return Expanded(
              child: InkWell(
                onTap: () => onTap(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon,
                        size: 20,
                        color: active ? AppColors.primary : AppColors.textMuted),
                    const SizedBox(height: 3),
                    Text(label,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? AppColors.primary : AppColors.textMuted,
                        )),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// ===================== تبويب الرئيسية (الداشبورد) =====================
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(),
          Transform.translate(
            offset: const Offset(0, -34),
            child: const _PunchCard(),
          ),
          Transform.translate(
            offset: const Offset(0, -18),
            child: Column(
              children: const [
                _SectionTitle(icon: Icons.bar_chart, title: 'إحصائيات الشهر'),
                _StatsRow(),
                SizedBox(height: 18),
                _SectionTitle(icon: Icons.calendar_today, title: 'تقويم الحضور'),
                _CalendarCard(),
                SizedBox(height: 18),
                _SectionTitle(icon: Icons.wallet, title: 'الراتب'),
                _SalaryCard(),
                SizedBox(height: 18),
                _SectionTitle(icon: Icons.bolt, title: 'إجراءات سريعة'),
                _QuickActions(),
                SizedBox(height: 18),
                _SectionTitle(icon: Icons.notifications, title: 'آخر الإشعارات'),
                _NotificationsCard(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('م',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('محمد زكريا',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.white70),
                    SizedBox(width: 3),
                    Text('الإدارة الرئيسية — مكة المكرمة',
                        style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none, color: Colors.white, size: 18),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: Color(0xFFFF4444), shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PunchCard extends StatelessWidget {
  const _PunchCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.1), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary]),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fingerprint, color: Colors.white, size: 22),
                    SizedBox(height: 2),
                    Text('حضور',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 6, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text('وقت العمل الآن',
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('08:03 AM',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    const SizedBox(height: 2),
                    const Text('تم تسجيل الحضور ✓',
                        style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.dangerBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout, size: 16, color: AppColors.danger),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: const [
              _PunchTimeItem(value: '08:00 AM', label: 'بداية الدوام'),
              _VDivider(),
              _PunchTimeItem(value: '05:00 PM', label: 'نهاية الدوام'),
              _VDivider(),
              _PunchTimeItem(value: '2.5 س', label: 'OT الشهر', color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: .8, height: 26, color: Colors.grey.shade200);
}

class _PunchTimeItem extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;
  const _PunchTimeItem({required this.value, required this.label, this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color ?? AppColors.textDark)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(title,
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();
  @override
  Widget build(BuildContext context) {
    final stats = [
      (Icons.check, '18', 'حضور', AppColors.primary, AppColors.primaryBg),
      (Icons.close, '2', 'غياب', AppColors.danger, AppColors.dangerBg),
      (Icons.bolt, '6.5', 'OT', AppColors.primary, AppColors.primaryBg),
      (Icons.show_chart, '90%', 'التزام', AppColors.info, AppColors.infoBg),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: stats.map((s) {
          final (icon, num, lbl, color, bg) = s;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 6)],
              ),
              child: Column(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                    child: Icon(icon, size: 12, color: color),
                  ),
                  const SizedBox(height: 6),
                  Text(num, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color)),
                  const SizedBox(height: 2),
                  Text(lbl, style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard();
  @override
  Widget build(BuildContext context) {
    // 0 = فاضي، 1 = حضور، 2 = غياب، 3 = اليوم، 4 = عطلة
    const days = [
      0, 1, 1, 1, 1, 4, 4,
      1, 1, 2, 1, 1, 4, 4,
      1, 1, 1, 1, 1, 4, 4,
      1, 1, 3, 0, 0, 4, 4,
    ];
    final headers = ['أح', 'إث', 'ثل', 'أر', 'خم', 'جم', 'سب'];

    Color bg(int t) => switch (t) {
          1 => AppColors.primaryBg,
          2 => AppColors.dangerBg,
          3 => AppColors.primary,
          4 => const Color(0xFFF5F5F5),
          _ => Colors.transparent,
        };
    Color fg(int t) => switch (t) {
          1 => AppColors.primary,
          2 => AppColors.danger,
          3 => Colors.white,
          4 => const Color(0xFFDDDDDD),
          _ => Colors.transparent,
        };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 6)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('يونيو 2026', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 3,
            crossAxisSpacing: 3,
            childAspectRatio: 1.4,
            children: [
              ...headers.map((h) => Center(
                  child: Text(h, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)))),
              ...days.asMap().entries.map((e) {
                final t = e.value;
                final label = t == 0 ? '' : '${e.key - 6}';
                return Container(
                  decoration: BoxDecoration(color: bg(t), borderRadius: BorderRadius.circular(6)),
                  alignment: Alignment.center,
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 11, color: fg(t), fontWeight: t == 3 ? FontWeight.w800 : FontWeight.w500)),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _SalaryCard extends StatelessWidget {
  const _SalaryCard();
  @override
  Widget build(BuildContext context) {
    final items = [
      ('الأساسي', '5,000 ر.س', Colors.white),
      ('أوفر تايم', '+250 ر.س', const Color(0xFF4ADE80)),
      ('خصم غياب', '-166 ر.س', const Color(0xFFF87171)),
      ('بدلات', '+800 ر.س', const Color(0xFF4ADE80)),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF2E2116)]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('صافي راتب مايو 2026',
              style: TextStyle(color: Colors.white60, fontSize: 11)),
          const SizedBox(height: 4),
          RichText(
            text: const TextSpan(children: [
              TextSpan(
                  text: '5,884 ',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
              TextSpan(text: 'ر.س', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.6,
            children: items.map((it) {
              final (lbl, val, color) = it;
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(lbl, style: const TextStyle(color: Colors.white60, fontSize: 9.5)),
                    Text(val, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w700)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();
  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.bolt, 'طلب OT', AppColors.primary, AppColors.primaryBg),
      (Icons.history, 'سجل الحضور', AppColors.primary, AppColors.primaryBg),
      (Icons.receipt_long, 'كشف الراتب', AppColors.info, AppColors.infoBg),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: actions.map((a) {
          final (icon, label, color, bg) = a;
          return Expanded(
            child: InkWell(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 6)],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                      child: Icon(icon, size: 16, color: color),
                    ),
                    const SizedBox(height: 8),
                    Text(label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard();
  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.check, AppColors.primary, AppColors.primaryBg, 'تم اعتماد OT', '23 يونيو — منذ ساعتين', 'معتمد'),
      (Icons.close, AppColors.danger, AppColors.dangerBg, 'تم رفض طلب OT', '20 يونيو — منذ 3 ساعات', 'مرفوض'),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 6)],
      ),
      child: Column(
        children: items.map((n) {
          final (icon, color, bg, title, time, badge) = n;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 14, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
                  child: Text(badge, style: TextStyle(fontSize: 10, color: color)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// ===================== تبويب مؤقت (حضوري / الراتب) =====================
class _PlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;
  const _PlaceholderTab({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 46, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('شاشة "$title" قريبًا',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
