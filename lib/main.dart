import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import 'services/app_mode.dart';
import 'services/demo_store.dart';
import 'widgets/notice_import_sheet.dart';

/// Family Day 브랜드 팔레트.
/// 시원한 코발트 블루 + 네이비, 에메랄드 민트, 포인트 골드.
class AppColors {
  AppColors._();

  static const Color navy = Color(0xFF0D1B33);
  static const Color navySoft = Color(0xFF1B2F52);
  static const Color cobalt = Color(0xFF2563EB);
  static const Color cobaltDeep = Color(0xFF1D4ED8);
  static const Color cobaltSoft = Color(0xFFDCE7FF);
  static const Color mint = Color(0xFF12C9A0);
  static const Color mintSoft = Color(0xFFD6F7EC);
  static const Color gold = Color(0xFFF7B733);
  static const Color goldSoft = Color(0xFFFFF1D1);
  static const Color surface = Color(0xFFF2F6FF);
  static const Color ink = Color(0xFF10203C);
  static const Color inkSoft = Color(0xFF61728F);
  static const Color line = Color(0xFFE2E9F7);
  static const Color danger = Color(0xFFE24C4C);
}

ThemeData buildFamilyDayTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.cobalt,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.cobalt,
    onPrimary: Colors.white,
    primaryContainer: AppColors.cobaltSoft,
    onPrimaryContainer: AppColors.navy,
    secondary: AppColors.mint,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.mintSoft,
    onSecondaryContainer: AppColors.navy,
    tertiary: AppColors.gold,
    onTertiary: AppColors.navy,
    tertiaryContainer: AppColors.goldSoft,
    onTertiaryContainer: AppColors.navy,
    surface: Colors.white,
    onSurface: AppColors.ink,
    error: AppColors.danger,
  );

  final base = ThemeData(colorScheme: scheme, useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.surface,
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.navy,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.navy,
        fontSize: 19,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    ),
    textTheme: base.textTheme.copyWith(
      titleLarge: const TextStyle(
        color: AppColors.navy,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      titleMedium: const TextStyle(
        color: AppColors.navy,
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: const TextStyle(color: AppColors.ink, height: 1.35),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.cobalt,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cobalt,
        side: const BorderSide(color: AppColors.line, width: 1.2),
        minimumSize: const Size(0, 44),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.cobalt,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.cobalt,
      foregroundColor: Colors.white,
      extendedTextStyle: TextStyle(fontWeight: FontWeight.w700),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.mintSoft,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? AppColors.navy
              : AppColors.inkSoft,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.cobalt
              : AppColors.inkSoft,
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: const BorderSide(color: AppColors.inkSoft, width: 1.6),
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.mint
            : Colors.transparent,
      ),
      checkColor: const WidgetStatePropertyAll<Color>(Colors.white),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.mint,
      linearTrackColor: AppColors.line,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.navy,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.cobalt, width: 1.6),
      ),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 'M월 d일 EEEE', 'ko_KR' 같은 한국어 날짜 표기를 쓰려면 먼저 읽어 두어야 한다.
  await initializeDateFormatting('ko_KR');
  if (backendReady && !demoMode) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
  runApp(const FamilyDayApp());
}

/// 서버(Supabase)에 붙어 있을 때만 쓰는 클라이언트.
SupabaseClient get db => Supabase.instance.client;

class FamilyDayApp extends StatelessWidget {
  const FamilyDayApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Family Day',
        debugShowCheckedModeBanner: false,
        theme: buildFamilyDayTheme(),
        // 서버 설정이 없으면 샘플 데이터 데모로 바로 시작한다(빈 에러 화면 없음).
        home: demoMode
            ? const FamilyHome()
            : (!backendReady ? const SetupScreen() : const AuthGate()),
      );
}

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _BoltBadge(size: 76),
                  const SizedBox(height: 18),
                  const Text(
                    'Family Day',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '가족 일정과 아들의 학교생활을 한곳에서 관리해요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '아직 서버 연결 전이에요. README의 Supabase 설정을 완료한 뒤 앱을 실행해 주세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

/// 로고 대신 쓰는 민트/골드 번개 배지.
class _BoltBadge extends StatelessWidget {
  const _BoltBadge({this.size = 56});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[AppColors.navy, AppColors.cobalt],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(size * 0.32),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.cobalt.withAlpha(70),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          Icons.bolt_rounded,
          size: size * 0.58,
          color: AppColors.gold,
        ),
      );
}

/// 서버 연결 전 샘플 데이터로 도는 중임을 알리는 작은 배지.
class _DemoBadge extends StatelessWidget {
  const _DemoBadge();

  @override
  Widget build(BuildContext context) => Tooltip(
        message: '샘플 데이터로 체험하는 데모 모드예요',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.goldSoft,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: AppColors.gold.withAlpha(120)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.science_rounded, size: 13, color: AppColors.navy),
              SizedBox(width: 4),
              Text(
                'DEMO',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<AuthState>(
        stream: db.auth.onAuthStateChange,
        builder: (context, snapshot) => db.auth.currentSession == null
            ? const LoginScreen()
            : const FamilyHome(),
      );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool create = false;
  bool busy = false;
  String? error;

  Future<void> submit() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (create) {
        await db.auth.signUp(email: email.text.trim(), password: password.text);
      } else {
        await db.auth.signInWithPassword(
          email: email.text.trim(),
          password: password.text,
        );
      }
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: _BoltBadge(size: 68)),
                    const SizedBox(height: 14),
                    const Text(
                      'Family Day',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      create
                          ? '우리 가족 퀘스트 보드를 만들어요.'
                          : '오늘의 미션을 확인하러 왔어요!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.inkSoft),
                    ),
                    const SizedBox(height: 26),
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: '이메일'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: '비밀번호'),
                    ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          error!,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: busy ? null : submit,
                      child: Text(
                        busy ? '처리 중...' : (create ? '회원가입' : '로그인'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        create = !create;
                        error = null;
                      }),
                      child: Text(create ? '이미 계정이 있어요 · 로그인' : '처음 오셨나요? 회원가입'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class FamilyHome extends StatefulWidget {
  const FamilyHome({super.key});
  @override
  State<FamilyHome> createState() => _FamilyHomeState();
}

class _FamilyHomeState extends State<FamilyHome> {
  int tab = 0;
  int dataRevision = 0;
  String? familyId;
  String role = 'parent';
  String displayName = '가족';

  @override
  void initState() {
    super.initState();
    if (demoMode) {
      // 데모에서는 로그인 없이 가족 공간이 이미 있는 상태로 시작한다.
      familyId = demoFamilyId;
      role = 'parent';
      displayName = demoDisplayName;
      DemoStore.instance.addListener(_onDemoChanged);
      return;
    }
    loadMembership();
  }

  /// 데모 저장소(체크·알림장 등록·초기화)가 바뀌면 화면 데이터를 다시 읽는다.
  void _onDemoChanged() {
    if (mounted) setState(() => dataRevision++);
  }

  @override
  void dispose() {
    if (demoMode) DemoStore.instance.removeListener(_onDemoChanged);
    super.dispose();
  }

  Future<void> loadMembership() async {
    try {
      final row = await db
          .from('family_members')
          .select('family_id, role, display_name')
          .eq('user_id', db.auth.currentUser!.id)
          .maybeSingle();
      if (row != null && mounted) {
        setState(() {
          familyId = row['family_id'];
          role = row['role'];
          displayName = row['display_name'] ?? '가족';
        });
      }
    } catch (_) {}
  }

  /// 알림장 가져오기 시트를 열고, 등록된 항목이 있으면 화면을 새로 고친다.
  Future<void> openNoticeImport() async {
    final id = familyId;
    if (id == null) return;
    final result = await showNoticeImportSheet(context, familyId: id, role: role);
    if (!mounted || result == null) return;
    setState(() => dataRevision++);
    final message = result.error == null
        ? result.summary
        : '${result.summary}\n${result.error}';
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(result.error == null ? '⚡ $message' : message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      Dashboard(
        familyId: familyId,
        role: role,
        revision: dataRevision,
        onImportNotice: openNoticeImport,
      ),
      CalendarPage(familyId: familyId),
      HomeworkPage(
        familyId: familyId,
        role: role,
        revision: dataRevision,
        onImportNotice: openNoticeImport,
      ),
      FamilyPage(familyId: familyId, role: role, displayName: displayName),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _BoltBadge(size: 34),
            const SizedBox(width: 10),
            const Text('Family Day'),
          ],
        ),
        actions: [
          if (demoMode)
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: _DemoBadge(),
            )
          else
            IconButton(
              tooltip: '로그아웃',
              onPressed: () => db.auth.signOut(),
              icon: const Icon(Icons.logout_rounded),
            ),
        ],
      ),
      body: familyId == null
          ? NoFamilyScreen(onCreated: loadMembership)
          : pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: '달력',
          ),
          NavigationDestination(
            icon: Icon(Icons.rocket_launch_outlined),
            selectedIcon: Icon(Icons.rocket_launch_rounded),
            label: '미션',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded),
            label: '가족',
          ),
        ],
      ),
    );
  }
}

class NoFamilyScreen extends StatefulWidget {
  const NoFamilyScreen({super.key, required this.onCreated});
  final VoidCallback onCreated;
  @override
  State<NoFamilyScreen> createState() => _NoFamilyScreenState();
}

class _NoFamilyScreenState extends State<NoFamilyScreen> {
  final name = TextEditingController(text: '우리 가족');
  final person = TextEditingController(text: '엄마');
  bool busy = false;
  String? error;

  Future<void> createFamily() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await db.rpc('create_family', params: {
        'p_family_name': name.text.trim(),
        'p_display_name': person.text.trim(),
      });
      widget.onCreated();
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const _BoltBadge(size: 62),
                const SizedBox(height: 14),
                const Text(
                  '가족 공간 만들기',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '가족 공간을 만든 뒤 아빠와 아들을 초대할 수 있어요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.inkSoft),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: '가족 공간 이름'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: person,
                  decoration: const InputDecoration(labelText: '내 이름 또는 호칭'),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      error!,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: busy ? null : createFamily,
                  child: Text(busy ? '만드는 중...' : '가족 공간 만들기'),
                ),
              ],
            ),
          ),
        ),
      );
}

class Dashboard extends StatelessWidget {
  const Dashboard({
    super.key,
    required this.familyId,
    required this.role,
    required this.onImportNotice,
    this.revision = 0,
  });

  final String? familyId;
  final String role;
  final VoidCallback onImportNotice;
  final int revision;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: AppColors.gold,
              ),
              const SizedBox(width: 6),
              Text(
                DateFormat('M월 d일 EEEE', 'ko_KR').format(DateTime.now()),
                style: const TextStyle(
                  color: AppColors.inkSoft,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '오늘 우리 가족은',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          MissionSummary(familyId: familyId, revision: revision),
          const SizedBox(height: 12),
          _ImportNoticeCard(onTap: onImportNotice),
          const SizedBox(height: 20),
          const _SectionTitle(icon: Icons.event_available_rounded, text: '오늘의 일정'),
          const SizedBox(height: 8),
          EventsList(familyId: familyId, onlyToday: true),
          const SizedBox(height: 20),
          const _SectionTitle(icon: Icons.schedule_rounded, text: '학교 시간표'),
          const SizedBox(height: 8),
          TimetableList(familyId: familyId),
        ],
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.mintSoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: AppColors.navy),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ],
      );
}

class _ImportNoticeCard extends StatelessWidget {
  const _ImportNoticeCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[AppColors.cobalt, AppColors.cobaltDeep],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: const [
                          Text(
                            '알림장 가져오기',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                              fontSize: 15,
                            ),
                          ),
                          _MiniChip(text: '퀘스트 생성', color: AppColors.gold),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '하이클래스 알림장을 붙여넣으면 숙제·준비물·일정으로 자동 분류해요.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkSoft,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.cobalt,
                ),
              ],
            ),
          ),
        ),
      );
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withAlpha(45),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
      );
}

/// 오늘의 숙제 진행도를 Supabase에서 읽어 미션 카드로 보여 준다.
class MissionSummary extends StatelessWidget {
  const MissionSummary({super.key, required this.familyId, this.revision = 0});
  final String? familyId;
  final int revision;

  @override
  Widget build(BuildContext context) {
    if (demoMode) {
      if (familyId == null) {
        return const MissionCard(done: 0, total: 0);
      }
      return AnimatedBuilder(
        animation: DemoStore.instance,
        builder: (context, _) {
          final missions = DemoStore.instance.missionsDueFrom(DateTime.now());
          final done = missions.where((row) => row['is_done'] == true).length;
          return MissionCard(done: done, total: missions.length);
        },
      );
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
        key: ValueKey<String>('mission-$familyId-$revision'),
        future: familyId == null
            ? Future<List<Map<String, dynamic>>>.value(<Map<String, dynamic>>[])
            : db
                .from('homework')
                .select()
                .eq('family_id', familyId!)
                .gte(
                  'due_date',
                  DateFormat('yyyy-MM-dd').format(DateTime.now()),
                )
                .order('due_date'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MissionCard(done: 0, total: 0, loading: true);
          }
          final rows = snapshot.data ?? const <Map<String, dynamic>>[];
          final done = rows.where((row) => row['is_done'] == true).length;
          return MissionCard(done: done, total: rows.length);
        },
      );
  }
}

/// 오늘의 미션 진행도 카드(게임 퀘스트 느낌).
class MissionCard extends StatelessWidget {
  const MissionCard({
    super.key,
    required this.done,
    required this.total,
    this.loading = false,
  });

  final int done;
  final int total;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final safeTotal = total < 0 ? 0 : total;
    final safeDone = done.clamp(0, safeTotal);
    final ratio = safeTotal == 0 ? 0.0 : safeDone / safeTotal;
    final cleared = safeTotal > 0 && safeDone >= safeTotal;

    final String headline;
    final String caption;
    if (loading) {
      headline = '미션 불러오는 중...';
      caption = '오늘의 숙제를 확인하고 있어요';
    } else if (safeTotal == 0) {
      headline = '오늘은 미션이 없어요';
      caption = '알림장을 가져오면 미션이 자동으로 생겨요';
    } else if (cleared) {
      headline = '오늘 미션 클리어!';
      caption = '${safeTotal}개 전부 완료 · 내일 미션도 준비됐어요';
    } else {
      headline = '남은 미션 ${safeTotal - safeDone}개';
      caption = '하나씩 깨면 보상이 기다려요';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: <Color>[AppColors.navy, AppColors.cobalt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.cobalt.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag_rounded, size: 13, color: AppColors.gold),
                    SizedBox(width: 4),
                    Text(
                      '오늘의 미션',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (cleared)
                const _ClearBadge()
              else
                Text(
                  '$safeDone / $safeTotal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            headline,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: TextStyle(
              color: Colors.white.withAlpha(200),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.white.withAlpha(48),
                valueColor: AlwaysStoppedAnimation<Color>(
                  cleared ? AppColors.gold : AppColors.mint,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                cleared
                    ? Icons.emoji_events_rounded
                    : (safeDone == 0
                        ? Icons.play_circle_fill_rounded
                        : Icons.bolt_rounded),
                size: 16,
                color: cleared ? AppColors.gold : AppColors.mint,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  safeTotal == 0
                      ? '미션 0개'
                      : '${(ratio * 100).round()}% 완료 · $safeDone/${safeTotal}개',
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (cleared)
                const Text(
                  '🏆',
                  style: TextStyle(fontSize: 13),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClearBadge extends StatelessWidget {
  const _ClearBadge();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(99),
          boxShadow: <BoxShadow>[
            BoxShadow(color: AppColors.gold.withAlpha(90), blurRadius: 12),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🏆', style: TextStyle(fontSize: 12)),
            SizedBox(width: 5),
            Text(
              '오늘 미션 클리어!',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
}

class HomeworkPage extends StatefulWidget {
  const HomeworkPage({
    super.key,
    required this.familyId,
    required this.role,
    required this.onImportNotice,
    this.revision = 0,
  });

  final String? familyId;
  final String role;
  final VoidCallback onImportNotice;
  final int revision;

  @override
  State<HomeworkPage> createState() => _HomeworkPageState();
}

class _HomeworkPageState extends State<HomeworkPage> {
  List<Map<String, dynamic>> _items = <Map<String, dynamic>>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant HomeworkPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revision != widget.revision ||
        oldWidget.familyId != widget.familyId) {
      _load();
    }
  }

  Future<void> _load() async {
    final familyId = widget.familyId;
    if (familyId == null) {
      if (mounted) {
        setState(() {
          _items = <Map<String, dynamic>>[];
          _loading = false;
        });
      }
      return;
    }
    if (demoMode) {
      final rows = DemoStore.instance.homeworkRows();
      if (!mounted) return;
      setState(() {
        _items = rows;
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final rows = await db
          .from('homework')
          .select()
          .eq('family_id', familyId)
          .order('due_date');
      if (!mounted) return;
      setState(() {
        _items = List<Map<String, dynamic>>.from(rows);
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  List<Map<String, dynamic>> get _missionItems {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _items
        .where((row) => '${row['due_date'] ?? ''}'.compareTo(today) >= 0)
        .toList();
  }

  int get _missionDone =>
      _missionItems.where((row) => row['is_done'] == true).length;

  void _toast(String message, {bool trophy = false, bool error = false}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor:
            error ? AppColors.danger : (trophy ? AppColors.cobalt : AppColors.navy),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Text(
              trophy ? '🏆' : (error ? '⚠️' : '⚡'),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> toggle(Map<String, dynamic> item, bool value) async {
    if (demoMode) {
      DemoStore.instance.setHomeworkDone(item['id'], value);
    } else {
      try {
        await db.from('homework').update({
          'is_done': value,
          'completed_at': value ? DateTime.now().toIso8601String() : null,
          'completed_by': value ? db.auth.currentUser!.id : null,
        }).eq('id', item['id']);
      } catch (e) {
        if (mounted) {
          _toast('저장하지 못했어요. 잠시 후 다시 시도해 주세요.', error: true);
        }
        return;
      }
    }
    if (!mounted) return;
    final index = _items.indexWhere((row) => row['id'] == item['id']);
    if (index >= 0) {
      setState(() {
        _items[index] = <String, dynamic>{
          ..._items[index],
          'is_done': value,
        };
      });
    } else {
      setState(() {});
    }

    if (!value) {
      _toast('다시 할 일로 되돌렸어요.');
      return;
    }
    HapticFeedback.mediumImpact();
    final missions = _missionItems;
    final done = missions.where((row) => row['is_done'] == true).length;
    if (missions.isNotEmpty && done >= missions.length) {
      _toast('오늘 미션 클리어! 🏆 정말 대단해요!', trophy: true);
    } else {
      _toast('좋아요! ${done}/${missions.length} 완료 ⚡');
    }
  }

  Future<void> add() async {
    final title = TextEditingController();
    final subject = TextEditingController(text: '수학');
    DateTime due = DateTime.now();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, refresh) => AlertDialog(
          title: const Text('숙제 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: '숙제 내용'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: subject,
                decoration: const InputDecoration(labelText: '과목'),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () async {
                  final d = await showDatePicker(
                    context: c,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDate: due,
                  );
                  if (d != null) refresh(() => due = d);
                },
                child: Text('마감일: ${DateFormat('yyyy-MM-dd').format(due)}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
    if (ok == true &&
        title.text.trim().isNotEmpty &&
        widget.familyId != null) {
      final row = <String, dynamic>{
        'family_id': widget.familyId,
        'title': title.text.trim(),
        'subject': subject.text.trim(),
        'due_date': DateFormat('yyyy-MM-dd').format(due),
      };
      if (demoMode) {
        DemoStore.instance.addHomeworkRows(<Map<String, dynamic>>[
          <String, dynamic>{...row, 'created_by': demoUserId},
        ]);
      } else {
        await db.from('homework').insert(<String, dynamic>{
          ...row,
          'created_by': db.auth.currentUser!.id,
        });
      }
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                color: AppColors.cobalt,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '오늘의 미션',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.navy,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            textStyle: const TextStyle(fontSize: 13),
                          ),
                          onPressed: widget.onImportNotice,
                          icon: const Icon(Icons.assignment_outlined, size: 18),
                          label: const Text('알림장 가져오기'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '완료하면 체크! 부모 휴대폰에도 바로 반영돼요.',
                      style: TextStyle(color: AppColors.inkSoft, fontSize: 12.5),
                    ),
                    const SizedBox(height: 14),
                    MissionCard(done: _missionDone, total: _missionItems.length),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          '숙제를 불러오지 못했어요: $_error',
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ),
                    const SizedBox(height: 16),
                    ..._items.map((item) => _HomeworkTile(
                          item: item,
                          onChanged: (value) => toggle(item, value),
                        )),
                    if (_items.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: const Column(
                          children: [
                            Text('🎯', style: TextStyle(fontSize: 26)),
                            SizedBox(height: 8),
                            Text(
                              '등록된 숙제가 없어요.',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '알림장을 가져오면 오늘의 미션이 자동으로 채워져요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
        floatingActionButton: widget.role == 'child'
            ? null
            : FloatingActionButton.extended(
                onPressed: add,
                icon: const Icon(Icons.add_rounded),
                label: const Text('숙제 추가'),
              ),
      );
}

class _HomeworkTile extends StatelessWidget {
  const _HomeworkTile({required this.item, required this.onChanged});

  final Map<String, dynamic> item;
  final ValueChanged<bool> onChanged;

  static IconData _subjectIcon(String? subject) {
    switch (subject) {
      case '수학':
        return Icons.calculate_rounded;
      case '국어':
        return Icons.menu_book_rounded;
      case '영어':
        return Icons.translate_rounded;
      case '과학':
        return Icons.science_rounded;
      case '사회':
        return Icons.public_rounded;
      case '미술':
        return Icons.palette_rounded;
      case '체육':
        return Icons.sports_soccer_rounded;
      case '음악':
        return Icons.music_note_rounded;
      case '독서':
        return Icons.auto_stories_rounded;
      case '창체':
        return Icons.extension_rounded;
      default:
        return Icons.edit_note_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = item['is_done'] == true;
    final subject = (item['subject'] ?? '').toString().trim();
    final due = (item['due_date'] ?? '').toString();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isOverdue = !isDone && due.compareTo(today) < 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDone ? AppColors.mintSoft.withAlpha(120) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onChanged(!isDone),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDone
                    ? AppColors.mint.withAlpha(120)
                    : (isOverdue ? AppColors.danger.withAlpha(90) : AppColors.line),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(6, 8, 12, 8),
            child: Row(
              children: [
                Checkbox(
                  value: isDone,
                  onChanged: (value) => onChanged(value ?? false),
                ),
                const SizedBox(width: 2),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.goldSoft : AppColors.cobaltSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDone
                        ? Icons.emoji_events_rounded
                        : _subjectIcon(subject.isEmpty ? null : subject),
                    size: 19,
                    color: isDone ? AppColors.gold : AppColors.cobalt,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (item['title'] ?? '').toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: isDone ? AppColors.inkSoft : AppColors.ink,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                          decorationColor: AppColors.inkSoft,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (subject.isNotEmpty) ...[
                            _MiniChip(text: subject, color: AppColors.cobalt),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              isDone ? '완료!' : '마감 $due',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isDone
                                    ? AppColors.mint
                                    : (isOverdue
                                        ? AppColors.danger
                                        : AppColors.inkSoft),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isDone)
                  const Text('✨', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key, required this.familyId});
  final String? familyId;
  @override
  Widget build(BuildContext context) => CalendarView(familyId: familyId);
}

class CalendarView extends StatefulWidget {
  const CalendarView({super.key, required this.familyId});
  final String? familyId;
  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime focused = DateTime.now();
  DateTime selected = DateTime.now();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: TableCalendar(
                calendarFormat: CalendarFormat.month,
                locale: 'ko_KR',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: focused,
                selectedDayPredicate: (d) => isSameDay(d, selected),
                onDaySelected: (s, f) => setState(() {
                  selected = s;
                  focused = f;
                }),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.navy,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.cobalt,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.cobalt,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: AppColors.inkSoft,
                  ),
                  weekendStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: AppColors.cobalt,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: const BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.cobalt,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            DateFormat('M월 d일 일정', 'ko_KR').format(selected),
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          EventsList(familyId: widget.familyId, date: selected),
        ],
      );
}

class EventsList extends StatelessWidget {
  const EventsList({
    super.key,
    required this.familyId,
    this.onlyToday = false,
    this.date,
  });

  final String? familyId;
  final bool onlyToday;
  final DateTime? date;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Map<String, dynamic>>>(
        future: () async {
          if (familyId == null) return <Map<String, dynamic>>[];
          final d = date ?? DateTime.now();
          if (demoMode) return DemoStore.instance.eventsOn(d);
          final day = DateFormat('yyyy-MM-dd').format(d);
          return await db
              .from('family_events')
              .select()
              .eq('family_id', familyId!)
              .eq('event_date', day)
              .order('start_time');
        }(),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(minHeight: 4),
            );
          }
          if (rows.isEmpty) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '등록된 일정이 없어요.',
                  style: TextStyle(color: AppColors.inkSoft),
                ),
              ),
            );
          }
          return Column(
            children: rows.map((event) {
              final start = (event['start_time'] ?? '').toString();
              final time = start.length >= 5 ? start.substring(0, 5) : start;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.mintSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.event_available_rounded,
                        size: 19,
                        color: AppColors.navy,
                      ),
                    ),
                    title: Text(
                      (event['title'] ?? '').toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${time.isEmpty ? '시간 미정' : time} · ${event['member_label'] ?? '가족'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      );
}

class TimetableList extends StatelessWidget {
  const TimetableList({super.key, required this.familyId});
  final String? familyId;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Map<String, dynamic>>>(
        future: familyId == null
            ? Future<List<Map<String, dynamic>>>.value(<Map<String, dynamic>>[])
            : (demoMode
                ? Future<List<Map<String, dynamic>>>.value(
                    DemoStore.instance.timetableOn(DateTime.now()),
                  )
                : db
                    .from('timetable_entries')
                    .select()
                    .eq('family_id', familyId!)
                    .eq(
                      'class_date',
                      DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    )
                    .order('period')),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? [];
          if (rows.isEmpty) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '오늘 시간표가 아직 등록되지 않았어요.',
                  style: TextStyle(color: AppColors.inkSoft),
                ),
              ),
            );
          }
          return Card(
            child: Column(
              children: rows.map((entry) {
                final period = entry['period'];
                final memo = (entry['memo'] ?? '').toString();
                return ListTile(
                  dense: true,
                  leading: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: <Color>[AppColors.cobalt, AppColors.cobaltDeep],
                      ),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      '$period',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  title: Text(
                    (entry['subject'] ?? '').toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: memo.isEmpty
                      ? null
                      : Text(
                          memo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.inkSoft,
                          ),
                        ),
                );
              }).toList(),
            ),
          );
        },
      );
}

class FamilyPage extends StatelessWidget {
  const FamilyPage({
    super.key,
    required this.familyId,
    required this.role,
    required this.displayName,
  });

  final String? familyId;
  final String role;
  final String displayName;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '우리 가족',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[AppColors.cobalt, AppColors.mint],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white),
              ),
              title: Text(
                displayName,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                role == 'child' ? '자녀 계정' : '부모 계정',
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
              ),
              trailing: _MiniChip(
                text: role == 'child' ? 'HERO' : 'LEADER',
                color: role == 'child' ? AppColors.mint : AppColors.gold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (demoMode) ...[
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.mintSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: AppColors.navy,
                      ),
                    ),
                    title: const Text(
                      '아들 · $demoClassLabel',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    subtitle: const Text(
                      '오늘 6교시 · 미션과 시간표를 함께 보고 있어요',
                      style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                    ),
                    trailing: const _MiniChip(text: 'HERO', color: AppColors.mint),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.cobaltSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.man_rounded,
                        color: AppColors.cobalt,
                      ),
                    ),
                    title: const Text(
                      '아빠',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    subtitle: const Text(
                      '부모 계정 · 이번 주 여행 준비 중',
                      style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                    ),
                    trailing: const _MiniChip(text: 'MATE', color: AppColors.cobalt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.science_rounded, size: 16, color: AppColors.navy),
                        SizedBox(width: 6),
                        Text(
                          '샘플 데이터 데모 모드',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '아직 Supabase 서버를 연결하지 않아서 샘플 데이터로 보여 주고 있어요. '
                      '체크한 미션과 알림장에서 가져온 숙제·일정은 이 기기 메모리에만 저장되고, '
                      '화면을 새로 고치면 처음 샘플로 돌아가요.',
                      style: TextStyle(
                        color: AppColors.inkSoft,
                        height: 1.45,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () => DemoStore.instance.reset(),
                        icon: const Icon(Icons.restart_alt_rounded, size: 18),
                        label: const Text('샘플 데이터로 되돌리기'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '가족 초대 기능은 다음 개발 단계에서 초대 코드 방식으로 연결할 예정이에요.',
                style: TextStyle(color: AppColors.inkSoft, height: 1.4),
              ),
            ),
          ),
        ],
      );
}
