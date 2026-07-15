import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'notifications_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  int _navIndex = 0;

  String? _lastClockIn;
  String? _lastClockOut;
  String _statusText = 'لم يُسجَّل بعد';

  Future<void> _handleFingerprint(String type) async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        _showMessage('البصمة غير متاحة على هذا الجهاز');
        return;
      }

      final didAuth = await _auth.authenticate(
        localizedReason: type == 'in'
            ? 'ضع بصمتك لتسجيل الحضور'
            : type == 'out'
                ? 'ضع بصمتك لتسجيل الانصراف'
                : 'ضع بصمتك لتسجيل الأوفر تايم',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuth) {
        final now = DateFormat('hh:mm a').format(DateTime.now());
        setState(() {
          if (type == 'in') {
            _lastClockIn = now;
            _statusText = 'حاضر ✓';
          } else if (type == 'out') {
            _lastClockOut = now;
            _statusText = 'تم الانصراف';
          }
        });
        // TODO: ابعت الطلب لسيرفر Laravel عبر ApiService.punchAttendance(type)
        _showMessage(
            type == 'in' ? 'تم تسجيل الحضور بنجاح' : type == 'out' ? 'تم تسجيل الانصراف بنجاح' : 'تم تسجيل الأوفر تايم بنجاح');
      }
    } catch (e) {
      _showMessage('حدث خطأ أثناء التحقق من البصمة');
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildFingerprintCard(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.business, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('سواعد عربية',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                Text('محمد زكريا',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFingerprintCard() {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _handleFingerprint(_lastClockIn == null ? 'in' : 'out'),
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryLight, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.fingerprint,
                    size: 50, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(_statusText,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text(
              _lastClockIn != null ? 'آخر حضور: $_lastClockIn' : 'اضغط على البصمة لتسجيل الحضور',
              style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _actionBtn('حضور', Icons.login, () => _handleFingerprint('in'))),
                const SizedBox(width: 8),
                Expanded(child: _actionBtn('انصراف', Icons.logout, () => _handleFingerprint('out'))),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: _actionBtn('تسجيل أوفر تايم', Icons.access_time, () => _handleFingerprint('ot'),
                  color: AppColors.info),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon, VoidCallback onTap, {Color? color}) {
    final c = color ?? AppColors.primary;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15, color: c),
      label: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFEEEEEE), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _quickCard(Icons.calendar_today, 'الإجازات', AppColors.info, AppColors.infoBg)),
        const SizedBox(width: 10),
        Expanded(child: _quickCard(Icons.receipt_long, 'كشف الراتب', AppColors.success, AppColors.successBg)),
        const SizedBox(width: 10),
        Expanded(child: _quickCard(Icons.history, 'سجل الحضور', AppColors.primary, AppColors.primaryBg)),
      ],
    );
  }

  Widget _quickCard(IconData icon, String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _navIndex,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      onTap: (i) {
        setState(() => _navIndex = i);
        if (i == 1) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.fingerprint), label: 'الحضور'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'الإشعارات'),
        BottomNavigationBarItem(icon: Icon(Icons.event_available_outlined), label: 'الإجازات'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'حسابي'),
      ],
    );
  }
}
