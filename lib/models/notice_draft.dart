/// 알림장(하이클래스) 가져오기에서 쓰는 데이터 모델.
///
/// Flutter에 의존하지 않는 순수 Dart 파일이라, 파서 단위 테스트와
/// 별도 스크립트 검증에서도 그대로 쓸 수 있다.
library;

/// 알림장에서 뽑아낸 항목의 종류.
enum NoticeItemKind {
  /// 숙제 → public.homework
  homework,

  /// 준비물 / 학급 일정 / 안내 → public.family_events
  event,
}

extension NoticeItemKindLabel on NoticeItemKind {
  String get label => this == NoticeItemKind.homework ? '숙제' : '일정';
}

const List<String> noticeWeekdayLabels = <String>['월', '화', '수', '목', '금', '토', '일'];

/// 시각을 버린 날짜(자정)로 맞춘다.
DateTime noticeDateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// '2026-11-16' 형태(Supabase date 컬럼용).
String noticeYmd(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// '11월 16일 (월)' 형태(화면 표시용).
String noticeKoDate(DateTime date) =>
    '${date.month}월 ${date.day}일 (${noticeWeekdayLabels[date.weekday - 1]})';

/// 'HH:mm' 문자열을 'HH:mm'으로 정리한다. 값이 없으면 빈 문자열.
String noticeHm(String? time) {
  if (time == null) return '';
  final parts = time.split(':');
  if (parts.length < 2) return time;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return time;
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// 'HH:mm'을 Supabase time 컬럼용 'HH:mm:ss'로 바꾼다.
String? noticeDbTime(String? time) {
  final hm = noticeHm(time);
  return hm.isEmpty ? null : '$hm:00';
}

/// 알림장에서 분류한 등록 후보 1건.
class NoticeDraftItem {
  NoticeDraftItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.date,
    this.subject,
    this.startTime,
    this.endTime,
    this.details,
    this.selected = true,
    this.optional = false,
    this.sourceText,
  });

  /// 미리보기 목록 안에서 항목을 구분하는 값(파서가 1부터 매긘다).
  final int id;

  NoticeItemKind kind;
  String title;
  DateTime date;
  String? subject;

  /// 'HH:mm'. 일정(family_events)에만 쓴다.
  String? startTime;
  String? endTime;
  String? details;

  /// 체크박스 상태.
  bool selected;

  /// 인사말·안전 안내처럼 등록 가치가 낮은 항목. 기본 선택 해제.
  final bool optional;

  /// 원문 줄(사용자가 대조할 수 있도록 남겨 둔다).
  final String? sourceText;

  bool get hasTime =>
      noticeHm(startTime).isNotEmpty || noticeHm(endTime).isNotEmpty;

  String get timeLabel {
    final start = noticeHm(startTime);
    final end = noticeHm(endTime);
    if (start.isEmpty) return end;
    if (end.isEmpty) return start;
    return '$start~$end';
  }

  Map<String, dynamic> toHomeworkRow({
    required String familyId,
    required String userId,
  }) {
    final trimmedSubject = (subject ?? '').trim();
    return <String, dynamic>{
      'family_id': familyId,
      'title': title.trim(),
      'subject': trimmedSubject.isEmpty ? null : trimmedSubject,
      'due_date': noticeYmd(date),
      'details': (details ?? '').trim().isEmpty ? null : details!.trim(),
      'created_by': userId,
    };
  }

  Map<String, dynamic> toEventRow({
    required String familyId,
    required String userId,
    String memberLabel = '아들',
  }) {
    return <String, dynamic>{
      'family_id': familyId,
      'title': title.trim(),
      'event_date': noticeYmd(date),
      'start_time': noticeDbTime(startTime),
      'end_time': noticeDbTime(endTime),
      'member_label': memberLabel,
      'notes': (details ?? '').trim().isEmpty ? null : details!.trim(),
      'created_by': userId,
    };
  }
}

/// '1.시간표 : 미술, 미술, 국어, 체육, 수학, 창체' 같은 줄에서 뽑은 시간표.
///
/// 저장하면 public.timetable_entries 에 1교시부터 순서대로 들어간다.
class NoticeTimetableDraft {
  NoticeTimetableDraft({
    required this.date,
    required this.subjects,
    this.selected = true,
    this.details,
  });

  DateTime date;
  List<String> subjects;
  bool selected;
  String? details;

  int get periodCount => subjects.length;

  String get subjectsText => subjects.join(', ');

  /// '미술, 미술 / 국어 · 체육' 같은 문자열을 과목 목록으로 나눈다.
  /// 같은 과목이 하루에 두 번 있어도(미술, 미술) 중복 제거하지 않는다.
  static List<String> splitSubjects(String text) {
    final normalized = text
        .replaceAll('，', ',')
        .replaceAll('、', ',')
        .replaceAll('ㆍ', ',')
        .replaceAll('·', ',')
        .replaceAll('/', ',')
        .replaceAll('|', ',')
        .replaceAll(RegExp(r'\s+'), ' ');
    final parts = <String>[];
    for (final raw in normalized.split(',')) {
      final value = raw.trim();
      if (value.isEmpty) continue;
      if (RegExp(r'^(교시|과목|시간표)$').hasMatch(value)) continue;
      parts.add(value);
    }
    if (parts.length == 1) {
      // 쉼표 없이 띄어쓰기만 있는 경우: '미술 미술 국어 체육' → 6과목처럼
      // 과목 이름이 두 글자 안팎일 때만 띄어쓰기로 나눈다.
      final words = parts.first.split(' ').where((e) => e.isNotEmpty).toList();
      if (words.length >= 3 &&
          words.every((e) => e.length <= 4 && !e.contains(RegExp(r'\d')))) {
        return words;
      }
    }
    if (parts.length > 12) return parts.sublist(0, 12);
    return parts;
  }

  List<Map<String, dynamic>> toRows({
    required String familyId,
    required String userId,
  }) {
    final rows = <Map<String, dynamic>>[];
    for (var index = 0; index < subjects.length; index++) {
      final subject = subjects[index].trim();
      if (subject.isEmpty) continue;
      rows.add(<String, dynamic>{
        'family_id': familyId,
        'class_date': noticeYmd(date),
        'period': index + 1,
        'subject': subject,
        'memo': null,
        'created_by': userId,
      });
    }
    return rows;
  }
}

/// 파서가 돌려주는 분류 결과.
class NoticeParseResult {
  NoticeParseResult({
    required this.items,
    this.timetable,
    List<String>? warnings,
  }) : warnings = warnings ?? <String>[];

  final List<NoticeDraftItem> items;
  final NoticeTimetableDraft? timetable;
  final List<String> warnings;

  bool get isEmpty => items.isEmpty && timetable == null;

  int get totalCount => items.length + (timetable == null ? 0 : 1);

  int get selectedCount =>
      items.where((item) => item.selected).length +
      ((timetable?.selected ?? false) ? 1 : 0);

  int get homeworkCount => items
      .where((item) => item.kind == NoticeItemKind.homework && item.selected)
      .length;

  int get eventCount => items
      .where((item) => item.kind == NoticeItemKind.event && item.selected)
      .length;

  int get timetableCount =>
      (timetable?.selected ?? false) ? (timetable?.periodCount ?? 0) : 0;
}

/// Supabase 등록 결과.
class NoticeImportResult {
  const NoticeImportResult({
    this.homeworkCount = 0,
    this.eventCount = 0,
    this.timetableCount = 0,
    this.error,
  });

  final int homeworkCount;
  final int eventCount;
  final int timetableCount;

  /// 등록 도중 문제가 생겼을 때 사용자에게 보여 줄 문장.
  final String? error;

  int get total => homeworkCount + eventCount + timetableCount;

  String get summary {
    final parts = <String>[];
    if (homeworkCount > 0) parts.add('숙제 $homeworkCount건');
    if (eventCount > 0) parts.add('일정 $eventCount건');
    if (timetableCount > 0) parts.add('시간표 $timetableCount과목');
    if (parts.isEmpty) return '등록된 항목이 없어요.';
    return '${parts.join(', ')}을(를) 등록했어요.';
  }
}
