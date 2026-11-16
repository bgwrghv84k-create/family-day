import 'package:flutter_test/flutter_test.dart';

import 'package:family_day/models/notice_draft.dart';
import 'package:family_day/services/notice_parser.dart';

void main() {
  // 2026-11-16 월요일 기준
  final parser = NoticeParser(today: DateTime(2026, 11, 16));

  group('실제 하이클래스 알림장', () {
    final result = parser.parse(NoticeParser.exampleNotice);

    test('시간표 줄을 6과목으로 읽는다', () {
      expect(result.timetable, isNotNull);
      expect(result.timetable!.subjects, <String>[
        '미술',
        '미술',
        '국어',
        '체육',
        '수학',
        '창체',
      ]);
      expect(noticeYmd(result.timetable!.date), '2026-11-16');
      expect(result.timetable!.periodCount, 6);
    });

    test('받아쓰기는 국어 숙제, 마감은 다음 등교일', () {
      final homework = result.items
          .where((item) => item.kind == NoticeItemKind.homework)
          .toList();
      expect(homework, hasLength(1));
      expect(homework.first.title, '받아쓰기 9급 틀린 것 3번 써오기');
      expect(homework.first.subject, '국어');
      expect(noticeYmd(homework.first.date), '2026-11-17');
    });

    test('선거운동 기간은 월·화·수 3일에 08:30~08:50 일정으로 들어간다', () {
      final election = result.items
          .where((item) => item.title.contains('선거운동'))
          .toList();
      expect(election, hasLength(3));
      expect(
        election.map((item) => noticeYmd(item.date)).toList(),
        <String>['2026-11-16', '2026-11-17', '2026-11-18'],
      );
      expect(election.every((item) => item.timeLabel == '08:30~08:50'), isTrue);
      expect(
        election.every((item) => item.kind == NoticeItemKind.event),
        isTrue,
      );
      expect(election.first.details, contains('중간놀이'));
    });

    test('목요일 토론회는 별도 일정으로 나뉜다', () {
      final debate =
          result.items.where((item) => item.title.contains('토론회')).toList();
      expect(debate, hasLength(1));
      expect(noticeYmd(debate.first.date), '2026-11-19');
    });

    test('수능일 등교 시간 변경은 목요일 09:40~09:50 일정', () {
      final exam = result.items.where((item) => item.title.contains('수능'));
      expect(exam, hasLength(1));
      expect(noticeYmd(exam.first.date), '2026-11-19');
      expect(exam.first.timeLabel, '09:40~09:50');
      expect(exam.first.details, contains('9시 40분'));
    });

    test('안전 안내는 참고 항목으로 기본 선택 해제된다', () {
      final safety = result.items.where((item) => item.title.contains('조심'));
      expect(safety, hasLength(1));
      expect(safety.first.optional, isTrue);
      expect(safety.first.selected, isFalse);
    });

    test('개별체험학습 안내는 일정으로 분류된다', () {
      final trip = result.items
          .where((item) => item.title.contains('개별체험학습'))
          .toList();
      expect(trip, hasLength(1));
      expect(trip.first.kind, NoticeItemKind.event);
      expect(trip.first.details, contains('보고서 등록'));
    });

    test('기본 선택 상태는 안전 안내만 빠진다', () {
      expect(result.items.where((item) => item.selected), hasLength(7));
      expect(result.selectedCount, 8); // 항목 7건 + 시간표 1건
    });
  });

  group('섹션형 알림장', () {
    final result = parser.parse(NoticeParser.sectionExampleNotice);

    test('[숙제] 항목은 숙제로, 준비물은 일정으로', () {
      expect(result.items.where((item) => item.kind == NoticeItemKind.homework),
          hasLength(2));
      expect(
        result.items.any((item) =>
            item.kind == NoticeItemKind.event && item.title.contains('준비물')),
        isTrue,
      );
    });

    test('괄호 안 마감일을 읽고 제목에서 뺀다', () {
      final row = result.items.firstWhere(
          (item) => item.title == '수학익힘책 42~43쪽 풀어오기');
      expect(row.subject, '수학');
      expect(noticeYmd(row.date), '2026-11-20');
    });

    test('날짜·시간이 있는 행사는 시각까지 읽는다', () {
      final trip =
          result.items.firstWhere((item) => item.title == '현장체험학습');
      expect(noticeYmd(trip.date), '2026-11-20');
      expect(trip.timeLabel, '09:00~15:00');
    });

    test('"다음주 화요일"을 다음 주로 계산한다', () {
      final openClass =
          result.items.firstWhere((item) => item.title.contains('공개수업'));
      expect(noticeYmd(openClass.date), '2026-11-24');
    });
  });

  group('날짜 계산', () {
    test('금요일에 "내일까지"가 없으면 다음 월요일이 마감', () {
      final friday = NoticeParser(today: DateTime(2026, 11, 20));
      final result = friday.parse('받아쓰기 10급 3번 써오기');
      expect(noticeYmd(result.items.first.date), '2026-11-23');
    });

    test('"11월 25일" 같은 표기를 읽는다', () {
      final result = parser.parse('11월 25일 현장체험학습 준비물: 도시락');
      expect(noticeYmd(result.items.first.date), '2026-11-25');
    });

    test('"이번주 금요일"을 이번 주 금요일로 읽는다', () {
      final result = parser.parse('이번주 금요일 학부모 상담');
      expect(noticeYmd(result.items.first.date), '2026-11-20');
    });

    test('이미 지난 요일은 다음 주로 넘긴다', () {
      final wednesday = NoticeParser(today: DateTime(2026, 11, 18));
      final result = wednesday.parse('월요일까지 독서록 쓰기');
      expect(noticeYmd(result.items.first.date), '2026-11-23');
    });
  });

  group('저장용 행 만들기', () {
    test('숙제 행에는 마감일과 과목이 들어간다', () {
      final item = NoticeDraftItem(
        id: 1,
        kind: NoticeItemKind.homework,
        title: '수학익힘 12쪽',
        subject: '수학',
        date: DateTime(2026, 11, 17),
      );
      final row = item.toHomeworkRow(familyId: 'family-1', userId: 'user-1');
      expect(row['due_date'], '2026-11-17');
      expect(row['subject'], '수학');
      expect(row['family_id'], 'family-1');
      expect(row['created_by'], 'user-1');
    });

    test('일정 행의 시각은 HH:mm:ss 로 보낸다', () {
      final item = NoticeDraftItem(
        id: 2,
        kind: NoticeItemKind.event,
        title: '선거운동',
        date: DateTime(2026, 11, 16),
        startTime: '08:30',
        endTime: '08:50',
      );
      final row = item.toEventRow(familyId: 'family-1', userId: 'user-1');
      expect(row['event_date'], '2026-11-16');
      expect(row['start_time'], '08:30:00');
      expect(row['end_time'], '08:50:00');
      expect(row['member_label'], '아들');
    });

    test('시간표는 1교시부터 순서대로 행이 된다', () {
      final timetable = NoticeTimetableDraft(
        date: DateTime(2026, 11, 16),
        subjects: <String>['미술', '미술', '국어', '체육', '수학', '창체'],
      );
      final rows = timetable.toRows(familyId: 'family-1', userId: 'user-1');
      expect(rows, hasLength(6));
      expect(rows.first['period'], 1);
      expect(rows.first['subject'], '미술');
      expect(rows.last['period'], 6);
      expect(rows.last['subject'], '창체');
    });

    test('같은 과목이 두 번 있어도 합치지 않는다', () {
      expect(
        NoticeTimetableDraft.splitSubjects('미술, 미술, 국어'),
        <String>['미술', '미술', '국어'],
      );
    });
  });
}
