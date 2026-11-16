import 'package:family_day/main.dart';
import 'package:family_day/models/notice_draft.dart';
import 'package:family_day/services/demo_store.dart';
import 'package:family_day/services/notice_import_service.dart';
import 'package:family_day/services/notice_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Widget _app(Widget home) => MaterialApp(theme: buildFamilyDayTheme(), home: home);

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
  });

  setUp(() => DemoStore.instance.reset());

  group('데모 저장소 시드', () {
    test('오늘 시간표 6교시·미션 4개·이번 주 여행 일정이 들어 있다', () {
      final store = DemoStore.instance;
      final today = noticeDateOnly(DateTime.now());

      final timetable = store.timetableOn(today);
      expect(timetable.length, 6);
      expect(timetable.first['subject'], '미술');
      expect(timetable.last['subject'], '창체');

      expect(store.homeworkRows().length, 4);
      expect(store.missionsDueFrom(today).length, 4);
      expect(
        store.missionsDueFrom(today).every((row) => row['is_done'] == false),
        isTrue,
      );

      // 이번 주 목~토 부산 해운대 여행 일정이 잡혀 있다.
      final titles = <String>[];
      for (var i = 0; i < 7; i++) {
        for (final event in store.eventsOn(today.add(Duration(days: i)))) {
          titles.add('${event['title']}');
        }
      }
      expect(titles.where((t) => t.contains('부산 해운대 여행')).length, 3);
      expect(titles.any((t) => t.contains('수능일 등교 시간 변경')), isTrue);
      expect(titles.any((t) => t.contains('전교임원후보자 선거운동')), isTrue);
    });

    test('체크와 초기화가 메모리 상태에 반영된다', () {
      final store = DemoStore.instance;
      final first = store.homeworkRows().first;

      store.setHomeworkDone(first['id'], true);
      final checked = store.homeworkRows().firstWhere(
        (row) => row['id'] == first['id'],
      );
      expect(checked['is_done'], isTrue);
      expect(checked['completed_at'], isNotNull);

      store.reset();
      expect(
        store.homeworkRows().every((row) => row['is_done'] == false),
        isTrue,
      );
    });
  });

  group('데모 화면', () {
    testWidgets('홈 탭에 미션 카드·일정·시간표가 보인다', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(const FamilyHome()));
      await tester.pumpAndSettle();

      expect(find.text('오늘 우리 가족은'), findsOneWidget);
      expect(find.text('남은 미션 4개'), findsOneWidget);
      // 오늘 일정(선거운동, 가족 회의)과 시간표가 실제로 채워져 있다.
      expect(find.textContaining('전교임원후보자 선거운동'), findsOneWidget);
      expect(find.text('체육'), findsOneWidget);
      expect(find.text('DEMO'), findsOneWidget);
    });

    testWidgets('미션 탭에서 모두 체크하면 오늘 미션 클리어가 뜬다', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(const FamilyHome()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('미션'));
      await tester.pumpAndSettle();

      expect(find.text('좋아요! 0/4 완료 ⚡'), findsNothing);
      expect(find.text('남은 미션 4개'), findsOneWidget);

      final boxes = find.byType(Checkbox);
      expect(boxes, findsNWidgets(4));
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.byType(Checkbox).at(i));
        await tester.pump();
        // 스낵바가 사라질 때까지 진행해서 다음 체크박스를 가리지 않게 한다.
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
      }

      expect(find.text('오늘 미션 클리어!'), findsWidgets);
      expect(find.textContaining('오늘 미션 클리어! 🏆'), findsOneWidget);
    });

    testWidgets('가족 탭에서 데모 안내와 샘플 되돌리기를 쓸 수 있다', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(const FamilyHome()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('가족'));
      await tester.pumpAndSettle();

      expect(find.textContaining('광주제석초 3학년 2반'), findsOneWidget);
      expect(find.text('샘플 데이터 데모 모드'), findsOneWidget);
      expect(find.text('샘플 데이터로 되돌리기'), findsOneWidget);
    });
  });

  group('데모 알림장 가져오기', () {
    test('하이클래스 알림장을 데모 저장소에 숙제·일정으로 등록한다', () async {
      final parser = NoticeParser();
      final result = parser.parse(NoticeParser.exampleNotice);
      expect(result.isEmpty, isFalse);

      final imported = await NoticeImportService().import(
        familyId: demoFamilyId,
        items: result.items,
        timetable: result.timetable,
      );

      expect(imported.error, isNull);
      expect(imported.total, greaterThan(0));

      final store = DemoStore.instance;
      expect(store.timetableOn(DateTime.now()).length, 6);
      expect(store.homeworkRows().length, 4 + imported.homeworkCount);
      expect(
        store.homeworkRows().any((row) => '${row['title']}'.contains('받아쓰기')),
        isTrue,
      );
      final eventTitles = <String>[];
      for (var i = 0; i < 4; i++) {
        for (final event in store.eventsOn(
          DateTime.now().add(Duration(days: i)),
        )) {
          eventTitles.add('${event['title']}');
        }
      }
      expect(eventTitles.any((t) => t.contains('등교 시간 변경')), isTrue);
    });
  });
}
