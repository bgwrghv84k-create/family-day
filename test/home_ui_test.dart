import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:family_day/main.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: buildFamilyDayTheme(),
      home: Scaffold(body: child),
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
  });

  group('오늘의 미션 카드', () {
    testWidgets('진행 중이면 남은 개수와 완료 수를 보여 준다', (tester) async {
      await tester.pumpWidget(_wrap(const MissionCard(done: 2, total: 5)));
      await tester.pumpAndSettle();

      expect(find.text('남은 미션 3개'), findsOneWidget);
      expect(find.text('2 / 5'), findsOneWidget);
      expect(find.textContaining('40% 완료'), findsOneWidget);
      expect(find.text('🏆'), findsNothing);
    });

    testWidgets('모두 완료하면 클리어 배지가 나온다', (tester) async {
      await tester.pumpWidget(_wrap(const MissionCard(done: 5, total: 5)));
      await tester.pumpAndSettle();

      expect(find.text('오늘 미션 클리어!'), findsWidgets);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('5 / 5'), findsNothing);
    });

    testWidgets('미션이 없으면 안내 문구를 보여 준다', (tester) async {
      await tester.pumpWidget(_wrap(const MissionCard(done: 0, total: 0)));
      await tester.pumpAndSettle();

      expect(find.text('오늘은 미션이 없어요'), findsOneWidget);
      expect(find.textContaining('알림장을 가져오면'), findsWidgets);
    });

    testWidgets('좁은 화면에서도 넘치지 않는다', (tester) async {
      tester.view.physicalSize = const Size(960, 1600);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(const MissionCard(done: 4, total: 7)));
      await tester.pumpAndSettle();

      expect(find.text('남은 미션 3개'), findsOneWidget);
    });
  });

  group('홈 화면', () {
    testWidgets('미션 카드와 알림장 가져오기 카드가 보인다', (tester) async {
      await tester.pumpWidget(
        _wrap(Dashboard(familyId: null, role: 'parent', onImportNotice: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('오늘 우리 가족은'), findsOneWidget);
      expect(find.text('오늘은 미션이 없어요'), findsOneWidget);
      expect(find.text('알림장 가져오기'), findsOneWidget);
      expect(find.text('오늘의 일정'), findsOneWidget);
      expect(find.text('학교 시간표'), findsOneWidget);
    });

    testWidgets('좁은 화면에서도 홈이 넘치지 않는다', (tester) async {
      tester.view.physicalSize = const Size(960, 3200);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(Dashboard(familyId: null, role: 'parent', onImportNotice: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('오늘 우리 가족은'), findsOneWidget);
    });
  });

  test('테마 색상이 브랜드 팔레트를 쓴다', () {
    final theme = buildFamilyDayTheme();
    expect(theme.colorScheme.primary, AppColors.cobalt);
    expect(theme.colorScheme.secondary, AppColors.mint);
    expect(theme.colorScheme.tertiary, AppColors.gold);
    expect(theme.scaffoldBackgroundColor, AppColors.surface);
  });
}
