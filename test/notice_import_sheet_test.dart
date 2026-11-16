import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:family_day/widgets/notice_import_sheet.dart';

void main() {
  testWidgets('예시 알림장을 채우고 자동 분류하면 미리보기와 등록 버튼이 나온다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoticeImportSheet(
            familyId: 'family-1',
            role: 'parent',
            today: DateTime(2026, 11, 16),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('알림장 가져오기'), findsOneWidget);
    expect(find.text('예시 알림장 채우기'), findsOneWidget);

    await tester.tap(find.text('예시 알림장 채우기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('자동 분류하기'));
    await tester.pumpAndSettle();

    // 시간표 1건 + 항목 8건, 안전 안내 1건은 기본 해제
    expect(find.textContaining('분류 결과 9건'), findsOneWidget);
    expect(find.textContaining('선택 8건'), findsWidgets);

    final list = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('시간표 6교시'), 200, scrollable: list);
    expect(find.text('시간표 6교시'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('받아쓰기 9급 틀린 것 3번 써오기'),
      200,
      scrollable: list,
    );
    expect(find.text('받아쓰기 9급 틀린 것 3번 써오기'), findsOneWidget);
    expect(find.text('선택 항목 등록'), findsOneWidget);
  });

  testWidgets('전체 해제를 누르면 등록 버튼이 꺼진다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoticeImportSheet(
            familyId: 'family-1',
            today: DateTime(2026, 11, 16),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('예시 알림장 채우기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('자동 분류하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('전체 선택'));
    await tester.pumpAndSettle();
    expect(find.textContaining('선택 9건'), findsWidgets);
    await tester.tap(find.text('전체 해제'));
    await tester.pumpAndSettle();

    expect(find.text('선택 0건'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '선택 항목 등록'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('작은 화면(320 너비)에서도 미리보기가 넘치지 않는다', (tester) async {
    // 폭은 작은 폰(320dp), 높이는 세로로 길게 두어 스크롤 없이 확인한다.
    tester.view.physicalSize = const Size(960, 3600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoticeImportSheet(
            familyId: 'family-1',
            today: DateTime(2026, 11, 16),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('예시 알림장 채우기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('자동 분류하기'));
    await tester.pumpAndSettle();

    expect(find.textContaining('분류 결과 9건'), findsOneWidget);
  });

  testWidgets('빈 입력으로 자동 분류하면 안내 문구가 나온다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoticeImportSheet(familyId: 'family-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('자동 분류하기'));
    await tester.pumpAndSettle();

    expect(find.textContaining('알림장 내용을 먼저'), findsOneWidget);
  });
}
