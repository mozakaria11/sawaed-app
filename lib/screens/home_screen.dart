import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/more_sheet.dart';
import '../services/api_service.dart';
import 'package:geolocator/geolocator.dart';

/// رقم/وقت البناء — بيتغير تلقائيًا مع كل عملية بناء جديدة عبر build.yml،
/// عشان تقدر تتأكد فورًا إنك شغال بآخر نسخة فعليًا.
const String kBuildStamp =
    String.fromEnvironment('BUILD_STAMP', defaultValue: 'محلي (غير محدد)');

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      _DashboardTab(userName: widget.userName),
      const _PlaceholderTab(title: 'حضوري', icon: Icons.calendar_month),
      const _PlaceholderTab(title: 'الراتب', icon: Icons.account_balance_wallet),
    ];
  }

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
class _DashboardTab extends StatefulWidget {
  final String userName;
  const _DashboardTab({required this.userName});

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  bool _loading = true;
  bool _punching = false;
  Map<String, dynamic>? _today;
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _payroll;
  String? _payrollError;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    final results = await Future.wait([
      ApiService.dashboardSummary(),
      ApiService.salaryLatest(),
    ]);
    final dashboardResult = results[0];
    final salaryResult = results[1];

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (dashboardResult['status'] == 'success') {
        _today = dashboardResult['today'];
        _stats = dashboardResult['stats'];
      }
      if (salaryResult['status'] == 'success') {
        _payroll = salaryResult['payroll'];
        _payrollError = null;
      } else {
        _payroll = null;
        _payrollError = salaryResult['message'] as String?;
      }
    });
  }

  Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage('من فضلك فعّل خدمة الموقع (GPS) من إعدادات الجهاز');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showMessage('يجب السماح بصلاحية الموقع لتسجيل الحضور');
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showMessage('صلاحية الموقع مرفوضة نهائيًا، فعّلها من إعدادات التطبيق');
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handlePunch() async {
    if (_punching) return;
    setState(() => _punching = true);

    final position = await _getCurrentPosition();
    if (position == null) {
      setState(() => _punching = false);
      return;
    }

    final isCheckedIn = _today?['is_checked_in'] == true;
    final result = isCheckedIn
        ? await ApiService.punchOut(position.latitude, position.longitude)
        : await ApiService.punchIn(position.latitude, position.longitude);

    if (!mounted) return;
    setState(() => _punching = false);

    if (result['success'] == true) {
      _showMessage(result['message'] ?? 'تم بنجاح');
      await _fetchAll();
    } else {
      final distance = result['distance'];
      final radius = result['allowed_radius'];
      final extra = (distance != null && radius != null)
          ? ' (المسافة: ${distance}م، المسموح: ${radius}م)'
          : '';
      _showMessage('${result['message'] ?? 'حدث خطأ'}$extra');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 120),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchAll,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(userName: widget.userName),
            Transform.translate(
              offset: const Offset(0, -34),
              child: _PunchCard(
                today: _today ?? const {},
                loading: _punching,
                onPunch: _handlePunch,
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -18),
              child: Column(
                children: [
                  const _SectionTitle(icon: Icons.bar_chart, title: 'إحصائيات الشهر'),
                  _StatsRow(stats: _stats ?? const {}),
                  const SizedBox(height: 18),
                  const _SectionTitle(icon: Icons.calendar_today, title: 'تقويم الحضور'),
                  const _CalendarCard(),
                  const SizedBox(height: 18),
                  const _SectionTitle(icon: Icons.wallet, title: 'الراتب'),
                  _SalaryCard(payroll: _payroll, errorMessage: _payrollError),
                  const SizedBox(height: 18),
                  const _SectionTitle(icon: Icons.bolt, title: 'إجراءات سريعة'),
                  const _QuickActions(),
                  const SizedBox(height: 18),
                  const _SectionTitle(icon: Icons.notifications, title: 'آخر الإشعارات'),
                  const _NotificationsCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String userName;
  const _Header({required this.userName});
  @override
  Widget build(BuildContext context) {
    final initial = userName.isNotEmpty ? userName.substring(0, 1) : 'م';
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
            child: Text(initial,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName.isNotEmpty ? userName : 'مستخدم',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 3),
                const Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.white70),
                    SizedBox(width: 3),
                    Text('الإدارة الرئيسية — مكة المكرمة',
                        style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                  ],
                ),
                const SizedBox(height: 3),
                Text('نسخة البناء: $kBuildStamp',
                    style: const TextStyle(color: Colors.white38, fontSize: 8.5)),
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
  final Map<String, dynamic> today;
  final bool loading;
  final VoidCallback onPunch;
  const _PunchCard({required this.today, required this.loading, required this.onPunch});

  @override
  Widget build(BuildContext context) {
    final clockIn = today['clock_in'] as String?;
    final clockOut = today['clock_out'] as String?;
    final shiftStart = today['shift_start'] as String? ?? '--:--';
    final shiftEnd = today['shift_end'] as String? ?? '--:--';
    final isCheckedIn = today['is_checked_in'] == true;
    final workDuration = today['work_duration'] as String?;

    final statusLabel = isCheckedIn ? 'وقت العمل الآن' : (clockIn == null ? 'لم يتم تسجيل الحضور بعد' : 'تم الانصراف');
    final mainTime = clockIn ?? '--:--';
    final hint = clockIn == null
        ? 'اضغط على أيقونة الحضور لتسجيل الدخول'
        : (isCheckedIn ? 'تم تسجيل الحضور ✓' : 'تم تسجيل الانصراف ✓');

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
              InkWell(
                borderRadius: BorderRadius.circular(33),
                onTap: loading ? null : onPunch,
                child: Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCheckedIn
                          ? [const Color(0xFF8A1010), const Color(0xFFD02020)]
                          : [AppColors.primaryDark, AppColors.primary],
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(isCheckedIn ? Icons.logout : Icons.fingerprint,
                                color: Colors.white, size: 22),
                            const SizedBox(height: 2),
                            Text(isCheckedIn ? 'انصراف' : 'حضور',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                          ],
                        ),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle, size: 6, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(statusLabel,
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(mainTime,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text(hint,
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
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
            children: [
              _PunchTimeItem(value: shiftStart, label: 'بداية الدوام'),
              const _VDivider(),
              _PunchTimeItem(value: shiftEnd, label: 'نهاية الدوام'),
              const _VDivider(),
              _PunchTimeItem(
                  value: workDuration ?? (clockOut ?? '--:--'),
                  label: workDuration != null ? 'مدة العمل' : 'وقت الانصراف',
                  color: AppColors.primary),
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
  final Map<String, dynamic> stats;
  const _StatsRow({required this.stats});
  @override
  Widget build(BuildContext context) {
    final present = stats['present']?.toString() ?? '0';
    final absent = stats['absent']?.toString() ?? '0';
    final otHours = stats['ot_hours']?.toString() ?? '0';
    final rate = stats['rate'] != null ? '${stats['rate']}%' : '0%';

    final statsList = [
      (Icons.check, present, 'حضور', AppColors.primary, AppColors.primaryBg),
      (Icons.close, absent, 'غياب', AppColors.danger, AppColors.dangerBg),
      (Icons.bolt, otHours, 'OT', AppColors.primary, AppColors.primaryBg),
      (Icons.show_chart, rate, 'التزام', AppColors.info, AppColors.infoBg),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: statsList.map((s) {
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
  final Map<String, dynamic>? payroll;
  final String? errorMessage;
  const _SalaryCard({this.payroll, this.errorMessage});

  String _fmt(num? v) {
    if (v == null) return '0';
    final n = v.toDouble();
    return n == n.roundToDouble()
        ? n.toInt().toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')
        : n.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    if (payroll == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 6)],
        ),
        child: Column(
          children: [
            const Icon(Icons.wallet_outlined, size: 30, color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text(errorMessage ?? 'لا يوجد راتب مسجل بعد',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
          ],
        ),
      );
    }

    final basic = payroll!['basic_salary'] as num? ?? 0;
    final housing = payroll!['housing_allowance'] as num? ?? 0;
    final transport = payroll!['transport_allowance'] as num? ?? 0;
    final overtime = payroll!['overtime_total'] as num? ?? 0;
    final deductions = payroll!['deductions_total'] as num? ?? 0;
    final net = payroll!['net_salary'] as num? ?? 0;
    final monthLabel = payroll!['month_label'] as String? ?? '';

    final items = [
      ('الأساسي', '${_fmt(basic)} ر.س', Colors.white),
      ('بدلات', '+${_fmt(housing + transport)} ر.س', const Color(0xFF4ADE80)),
      if (overtime > 0) ('أوفر تايم', '+${_fmt(overtime)} ر.س', const Color(0xFF4ADE80)),
      if (deductions > 0) ('خصومات', '-${_fmt(deductions)} ر.س', const Color(0xFFF87171)),
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
          Text('صافي راتب $monthLabel',
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: '${_fmt(net)} ',
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
              const TextSpan(text: 'ر.س', style: TextStyle(color: Colors.white70, fontSize: 13)),
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
