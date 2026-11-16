import 'package:flutter/foundation.dart';

import '../models/notice_draft.dart';

/// 데모 모드에서 쓰는 가족 공간 정보다.
const String demoFamilyId = 'demo-family';
const String demoUserId = 'demo-user';
const String demoFamilyName = '우리 가족';
const String demoDisplayName = '엄마';
const String demoClassLabel = '광주제석초 3학년 2반';
const String demoChildLabel = '아들';

/// 서버(Supabase) 연결 전에도 홈·미션·달력·가족 탭과 알림장 가져오기를
/// 그대로 써 볼 수 있게 해 주는 인메모리 저장소.
///
/// 광주제석초 3학년 2반 알림장(2026년 11월 16일 월요일)을 기준으로
/// 오늘 시간표 6교시, 숙제 미션 4개, 이번 주 가족 일정(목~토 부산 해운대 여행,
/// 수능일 등교 시간 변경 등)을 미리 채워 둔다.
/// 메모리에만 있으므로 화면을 새로 고치면 샘플 데이터로 돌아간다.
class DemoStore extends ChangeNotifier {
  DemoStore._() {
    _seed();
  }

  /// 앱 전체가 함께 쓰는 하나의 저장소.
  static final DemoStore instance = DemoStore._();

  final List<Map<String, dynamic>> _homework = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> _events = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> _timetable = <Map<String, dynamic>>[];

  int _seq = 0;

  String _nextId() => 'demo-${++_seq}';

  DateTime get _today => noticeDateOnly(DateTime.now());

  // ── 읽기 ──────────────────────────────────────────────────────────────

  /// 미션 탭에 보여 줄 숙제 전체(마감일 순).
  List<Map<String, dynamic>> homeworkRows() =>
      _homework.map(_copy).toList()..sort(_byDueDate);

  /// 오늘 이후 마감인 미션(오늘의 미션 카드 계산용).
  List<Map<String, dynamic>> missionsDueFrom(DateTime day) {
    final from = noticeYmd(day);
    return homeworkRows()
        .where((row) => '${row['due_date'] ?? ''}'.compareTo(from) >= 0)
        .toList();
  }

  /// 특정 날짜의 가족 일정(시작 시간 순, 시간 미정은 뒤로).
  List<Map<String, dynamic>> eventsOn(DateTime day) {
    final target = noticeYmd(day);
    final rows = _events
        .where((row) => row['event_date'] == target)
        .map(_copy)
        .toList()
      ..sort((a, b) => _timeKey(a['start_time']).compareTo(_timeKey(b['start_time'])));
    return rows;
  }

  /// 특정 날짜의 시간표(교시 순).
  List<Map<String, dynamic>> timetableOn(DateTime day) {
    final target = noticeYmd(day);
    return _timetable
        .where((row) => row['class_date'] == target)
        .map(_copy)
        .toList()
      ..sort(
        (a, b) => (a['period'] as num).compareTo(b['period'] as num),
      );
  }

  int get homeworkTotal => _homework.length;

  // ── 쓰기 ──────────────────────────────────────────────────────────────

  /// 숙제 체크 상태를 바꾼다.
  void setHomeworkDone(Object? id, bool done) {
    final index = _homework.indexWhere((row) => row['id'] == id);
    if (index < 0) return;
    _homework[index] = <String, dynamic>{
      ..._homework[index],
      'is_done': done,
      'completed_at': done ? DateTime.now().toIso8601String() : null,
      'completed_by': done ? demoUserId : null,
    };
    notifyListeners();
  }

  /// 숙제를 추가한다(숙제 추가 대화상자, 알림장 가져오기).
  void addHomeworkRows(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return;
    for (final row in rows) {
      _homework.add(<String, dynamic>{
        'id': row['id'] ?? _nextId(),
        'family_id': row['family_id'] ?? demoFamilyId,
        'title': row['title'] ?? '',
        'subject': row['subject'],
        'due_date': row['due_date'] ?? noticeYmd(_today),
        'details': row['details'],
        'is_done': row['is_done'] ?? false,
        'completed_at': row['completed_at'],
        'completed_by': row['completed_by'],
        'created_by': row['created_by'] ?? demoUserId,
      });
    }
    notifyListeners();
  }

  /// 가족 일정을 추가한다.
  void addEventRows(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return;
    for (final row in rows) {
      _events.add(<String, dynamic>{
        'id': row['id'] ?? _nextId(),
        'family_id': row['family_id'] ?? demoFamilyId,
        'title': row['title'] ?? '',
        'event_date': row['event_date'] ?? noticeYmd(_today),
        'start_time': row['start_time'],
        'end_time': row['end_time'],
        'member_label': row['member_label'] ?? demoChildLabel,
        'notes': row['notes'],
        'created_by': row['created_by'] ?? demoUserId,
      });
    }
    notifyListeners();
  }

  /// 시간표를 (가족, 날짜, 교시) 기준으로 덮어쓴다.
  void upsertTimetableRows(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return;
    for (final row in rows) {
      final index = _timetable.indexWhere(
        (existing) =>
            existing['class_date'] == row['class_date'] &&
            existing['period'] == row['period'],
      );
      final merged = <String, dynamic>{
        'id': row['id'] ?? (index >= 0 ? _timetable[index]['id'] : _nextId()),
        'family_id': row['family_id'] ?? demoFamilyId,
        'class_date': row['class_date'],
        'period': row['period'],
        'subject': row['subject'] ?? '',
        'memo': row['memo'],
        'created_by': row['created_by'] ?? demoUserId,
      };
      if (index >= 0) {
        _timetable[index] = merged;
      } else {
        _timetable.add(merged);
      }
    }
    notifyListeners();
  }

  /// 샘플 데이터로 되돌린다.
  void reset() {
    _seed();
    notifyListeners();
  }

  // ── 시드 데이터 ────────────────────────────────────────────────────────

  void _seed() {
    _homework.clear();
    _events.clear();
    _timetable.clear();
    _seq = 0;

    final today = _today;
    final tomorrow = today.add(const Duration(days: 1));
    final wednesday = today.add(const Duration(days: 2));
    final tripStart = _upcomingWeekday(DateTime.thursday);
    final tripDay2 = tripStart.add(const Duration(days: 1));
    final tripDay3 = tripStart.add(const Duration(days: 2));

    // 오늘의 미션 4개 (모두 미완료 상태에서 시작).
    _homework.addAll(<Map<String, dynamic>>[
      _homeworkRow(
        title: '받아쓰기 9급 틀린 것 3번 쓰기',
        subject: '국어',
        due: today,
        details: '알림장 2번 · 내일 아침에 검사해요',
      ),
      _homeworkRow(
        title: '수학익힘책 42~43쪽 풀어오기',
        subject: '수학',
        due: today,
        details: '5단원 들이와 무게',
      ),
      _homeworkRow(
        title: '영어 단어 10개 소리 내어 읽기',
        subject: '영어',
        due: tomorrow,
      ),
      _homeworkRow(
        title: '독서록 한 편 쓰기',
        subject: '독서',
        due: tomorrow,
        details: '여행 가기 전에 마무리하기',
      ),
    ]);

    // 오늘(월) 시간표 6교시.
    const subjects = <String>['미술', '미술', '국어', '체육', '수학', '창체'];
    for (var index = 0; index < subjects.length; index++) {
      _timetable.add(<String, dynamic>{
        'id': _nextId(),
        'family_id': demoFamilyId,
        'class_date': noticeYmd(today),
        'period': index + 1,
        'subject': subjects[index],
        'memo': subjects[index] == '체육' ? '운동화 챙기기' : null,
        'created_by': demoUserId,
      });
    }

    // 이번 주 가족 일정.
    _events.addAll(<Map<String, dynamic>>[
      _eventRow(
        title: '전교임원후보자 선거운동',
        day: today,
        start: '08:30:00',
        end: '08:50:00',
        notes: '이번 주 월·화·수 08:30~08:50, 중간놀이 시간에도 해요',
      ),
      _eventRow(
        title: '가족 회의 · 부산 여행 일정 확인',
        day: today,
        start: '20:00:00',
        memberLabel: '가족',
        notes: '목요일 출발 시간과 짐 목록 정하기',
      ),
      _eventRow(
        title: '부산 여행 짐 싸기',
        day: wednesday,
        start: '19:00:00',
        memberLabel: '가족',
        notes: '아들 체험학습 준비물도 함께 챙기기',
      ),
      _eventRow(
        title: '수능일 등교 시간 변경',
        day: tripStart,
        start: '09:40:00',
        end: '09:50:00',
        notes: '9시 40분~50분까지 등교 (평소보다 늦게)',
      ),
      _eventRow(
        title: '전교임원후보자 토론회 · 투표',
        day: tripStart,
        start: '10:30:00',
        notes: '토론회 후 투표 실시',
      ),
      _eventRow(
        title: '부산 해운대 여행 1일차 · 출발',
        day: tripStart,
        start: '09:00:00',
        memberLabel: '가족',
        notes: '해운대 도착 후 첫날 저녁은 고기 맛집',
      ),
      _eventRow(
        title: '부산 해운대 여행 2일차 · 더뷰 호텔',
        day: tripDay2,
        start: '18:00:00',
        memberLabel: '가족',
        notes: '18:00 더뷰 호텔 체크인',
      ),
      _eventRow(
        title: '부산 해운대 여행 3일차 · 귀가',
        day: tripDay3,
        start: '15:00:00',
        memberLabel: '가족',
      ),
    ]);
  }

  Map<String, dynamic> _homeworkRow({
    required String title,
    required String subject,
    required DateTime due,
    String? details,
  }) =>
      <String, dynamic>{
        'id': _nextId(),
        'family_id': demoFamilyId,
        'title': title,
        'subject': subject,
        'due_date': noticeYmd(due),
        'details': details,
        'is_done': false,
        'completed_at': null,
        'completed_by': null,
        'created_by': demoUserId,
      };

  Map<String, dynamic> _eventRow({
    required String title,
    required DateTime day,
    String? start,
    String? end,
    String memberLabel = demoChildLabel,
    String? notes,
  }) =>
      <String, dynamic>{
        'id': _nextId(),
        'family_id': demoFamilyId,
        'title': title,
        'event_date': noticeYmd(day),
        'start_time': start,
        'end_time': end,
        'member_label': memberLabel,
        'notes': notes,
        'created_by': demoUserId,
      };

  /// 이번 주(월요일 시작)의 해당 요일. 오늘이 그 요일보다 뒤면 다음 주를 돌려준다.
  DateTime _upcomingWeekday(int weekday) {
    final monday = _today.subtract(Duration(days: _today.weekday - 1));
    var target = monday.add(Duration(days: weekday - 1));
    if (target.isBefore(_today)) {
      target = target.add(const Duration(days: 7));
    }
    return noticeDateOnly(target);
  }

  Map<String, dynamic> _copy(Map<String, dynamic> row) =>
      <String, dynamic>{...row};

  int _byDueDate(Map<String, dynamic> a, Map<String, dynamic> b) {
    final byDate = '${a['due_date'] ?? ''}'.compareTo('${b['due_date'] ?? ''}');
    if (byDate != 0) return byDate;
    return '${a['title'] ?? ''}'.compareTo('${b['title'] ?? ''}');
  }

  /// 정렬용 시간 키('HH:mm:ss' → 'HH:mm'). 시간이 없으면 뒤로 보낸다.
  String _timeKey(Object? value) {
    final hm = noticeHm(value?.toString());
    return hm.isEmpty ? '99:99' : hm;
  }
}
