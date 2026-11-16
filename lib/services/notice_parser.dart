import '../models/notice_draft.dart';

/// 하이클래스 알림장 텍스트를 **숙제(homework) / 일정(family_events) / 시간표(timetable_entries)**
/// 후보로 나눠 주는 규칙 기반 파서.
///
/// 하이클래스에는 공식 오픈 API가 없어서, 학부모가 앱/웹에서 알림장을 복사해
/// 붙여넣으면 이 파서가 초등 알림장의 관용 표현(번호 목록, `[숙제]`, `[준비물]`,
/// `내일까지`, `11/20(목)`, `이번주 목요일` 등)을 읽어 등록 후보를 만든다.
/// 최종 저장 여부는 항상 사용자가 미리보기에서 확인한다.
///
/// Flutter에 의존하지 않으므로 `dart run`으로도 그대로 시험할 수 있다.
class NoticeParser {
  NoticeParser({DateTime? today, this.memberLabel = '아들'})
      : _today = noticeDateOnly(today ?? DateTime.now());

  /// 기준일(오늘). '내일', '이번주 금요일' 같은 상대 표현을 계산할 때 쓴다.
  final DateTime _today;

  /// 일정(family_events)에 넣을 대상 라벨.
  final String memberLabel;

  /// 실제 하이클래스 알림장 원문(광주제석초 3학년 2반, 2026-11-16 월).
  /// "예시 알림장 채우기" 버튼이 이 글을 채운다.
  static const String exampleNotice = '1.시간표 : 미술, 미술, 국어, 체육, 수학, 창체\n'
      '2. 받아쓰기 9급 틀린 것 3번 써오기\n'
      '3. 전교임원후보자 선거운동 기간\n'
      '이번주 월,화,수 08:30~08:50와 중간놀이\n'
      '이번주 목요일 후보자 토론회 후 투표 실시\n'
      '4. 이번주 목요일 수능일 등교 시간 변경\n'
      '9시 40분~50분까지 등교하기\n'
      '5. 차, 길, 사람 조심.\n'
      '*개별체험학습 실시 후 7일 이내에 학교 홈페이지에 체험학습 보고서 등록 부탁드립니다. (7일 이후는 양식 출력하여 서면 제출)';

  /// 다른 형태(섹션 제목 + 불릿) 알림장 예시.
  static const String sectionExampleNotice = '[숙제]\n'
      '- 수학익힘책 42~43쪽 풀어오기 (금요일까지)\n'
      '- 국어 5단원 받아쓰기 10급 3번 쓰기\n'
      '[준비물]\n'
      '- 체험학습 준비물: 도시락, 물, 돗자리\n'
      '[일정]\n'
      '- 11/20(목) 현장체험학습 (09:00~15:00)\n'
      '- 다음주 화요일 학부모 공개수업';

  static const List<String> exampleNotices = <String>[
    exampleNotice,
    sectionExampleNotice,
  ];

  // ── 공개 API ──────────────────────────────────────────────────────────

  NoticeParseResult parse(String rawText) {
    final warnings = <String>[];
    final items = <NoticeDraftItem>[];
    NoticeTimetableDraft? timetable;
    var sequence = 0;

    final lines = _normalizeLines(rawText);
    final segments = _splitSegments(lines);

    if (segments.isEmpty) {
      warnings.add('알림장에서 항목을 찾지 못했어요. 한 줄에 하나씩 적거나 번호(1. 2.)로 구분해 주세요.');
    }

    for (final segment in segments) {
      final parsed = _parseSegment(segment, sequence);
      sequence = parsed.nextSequence;
      timetable ??= parsed.timetable;
      items.addAll(parsed.items);
    }

    final unique = _removeDuplicates(items);
    if (timetable != null) {
      warnings.add(
        '시간표 ${timetable.periodCount}과목도 함께 등록할 수 있어요. '
        '같은 날짜·교시에 이미 시간표가 있으면 새 값으로 덮어써요.',
      );
    }
    if (unique.isEmpty && timetable == null) {
      warnings.add('분류된 항목이 없어요. 원문을 조금 다듬어 다시 시도해 주세요.');
    }

    return NoticeParseResult(
      items: unique,
      timetable: timetable,
      warnings: warnings,
    );
  }

  // ── 1단계: 줄 정리와 구간 나누기 ────────────────────────────────────────

  static final RegExp _sectionRe = RegExp(r'^[\[\(【]\s*(.{1,14}?)\s*[\]\)】]$');
  static final RegExp _numberedRe = RegExp(r'^(\d{1,2})\s*[\.\)]\s*(.*)$');
  static final RegExp _circledRe = RegExp(r'^([①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮])\s*(.*)$');
  static final RegExp _bulletRe = RegExp(r'^[-•·▪◦∙*※▶▷○●◎■□→➤–—]\s*(.*)$');

  List<String> _normalizeLines(String rawText) {
    return rawText
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\u00a0', ' ')
        .replaceAll('\u3000', ' ')
        .replaceAll('\t', ' ')
        .split('\n')
        .map((line) => line.trim())
        .toList();
  }

  List<_Segment> _splitSegments(List<String> lines) {
    final segments = <_Segment>[];
    NoticeItemKind? sectionKind;
    _Segment? current;

    for (final line in lines) {
      if (line.isEmpty) {
        current = null;
        continue;
      }
      if (_isIgnorableLine(line)) continue;

      final section = _sectionRe.firstMatch(line);
      if (section != null) {
        sectionKind = _kindFromSectionTitle(section.group(1) ?? '');
        current = null;
        continue;
      }

      final numbered = _numberedRe.firstMatch(line);
      if (numbered != null) {
        final text = (numbered.group(2) ?? '').trim();
        // '제목: 내용'에서 제목이 사유서 양식 번호일 뿐인 줄은 무시
        current = _Segment(text: text, hintedKind: sectionKind);
        segments.add(current);
        continue;
      }

      final circled = _circledRe.firstMatch(line);
      if (circled != null) {
        current = _Segment(
          text: (circled.group(2) ?? '').trim(),
          hintedKind: sectionKind,
        );
        segments.add(current);
        continue;
      }

      final bullet = _bulletRe.firstMatch(line);
      if (bullet != null) {
        final text = (bullet.group(1) ?? '').trim();
        // '일시: ...', '준비물: ...' 처럼 항목의 세부 정보인 줄은 앞 항목에 붙인다.
        if (current != null && _isFieldLine(text)) {
          current.body.add(text);
          continue;
        }
        current = _Segment(text: text, hintedKind: sectionKind);
        segments.add(current);
        continue;
      }

      // 표시 없는 줄: 번호 항목의 이어지는 설명이면 붙이고, 아니면 새 구간.
      if (current != null && current.body.length < 10 && !current.closed) {
        current.body.add(line);
      } else {
        current = _Segment(text: line, hintedKind: sectionKind);
        segments.add(current);
      }
    }

    return segments
        .where((segment) => segment.text.isNotEmpty || segment.body.isNotEmpty)
        .toList();
  }

  static final RegExp _separatorRe = RegExp(r'^[\s\-=_~*※•·]{2,}$');
  static const Set<String> _ignoredLines = <String>{
    '알림장',
    '오늘의 알림장',
    '학급 알림장',
    '가정통신문',
    '하이클래스',
    '전체 알림',
    '알림',
  };

  bool _isIgnorableLine(String line) {
    if (_separatorRe.hasMatch(line)) return true;
    if (_ignoredLines.contains(line)) return true;
    return _isDateOnlyLine(line);
  }

  /// '일시:', '장소:', '준비물:' 처럼 앞 항목의 세부 항목을 적은 줄.
  bool _isFieldLine(String text) {
    final match = RegExp(r'^[가-힣]{1,6}\s*[:：]').firstMatch(text);
    if (match == null) return false;
    return text.length > (match.end + 1);
  }

  /// '2026. 11. 16. (월) 알림장', '11월 16일 월요일'처럼 날짜만 있는 머리글.
  bool _isDateOnlyLine(String line) {
    final dateMatch = _findDate(line);
    if (dateMatch == null || dateMatch.start > 1) return false;
    var rest = line.substring(dateMatch.end);
    rest = rest.replaceAll(RegExp(r'[\(\[]\s*[월화수목금토일]\s*[\)\]]'), ' ');
    rest = rest.replaceAll(RegExp(r'[월화수목금토일]\s*요일'), ' ');
    rest = rest.replaceAll(RegExp(r'(알림장|오늘의|학급|가정통신문|안내장)'), ' ');
    rest = rest.replaceAll(RegExp(r'[\s\-–~·•*※\.\,\(\)\[\]:/]'), '');
    return rest.length < 2;
  }

  NoticeItemKind? _kindFromSectionTitle(String title) {
    final text = title.trim();
    if (text.isEmpty) return null;
    if (_containsAny(text, _homeworkCues) && !text.contains('준비물')) {
      return NoticeItemKind.homework;
    }
    if (_containsAny(text, _prepCues)) return NoticeItemKind.event;
    if (_containsAny(text, _eventCues)) return NoticeItemKind.event;
    if (text.contains('숙제') || text.contains('과제')) return NoticeItemKind.homework;
    return null;
  }

  // ── 2단계: 구간 하나를 항목으로 ─────────────────────────────────────────

  _SegmentParseResult _parseSegment(_Segment segment, int sequence) {
    final items = <NoticeDraftItem>[];
    NoticeTimetableDraft? timetable;
    var seq = sequence;

    final body = List<String>.from(segment.body);
    var head = segment.text.trim();
    if (head.isEmpty && body.isNotEmpty) head = body.removeAt(0).trim();
    if (head.isEmpty) {
      return _SegmentParseResult(items: items, nextSequence: seq);
    }

    // (1) 시간표 줄: '1.시간표 : 미술, 미술, 국어, 체육, 수학, 창체'
    if (_looksLikeTimetable(head)) {
      final subjects = _subjectsFromTimetableText(head);
      if (subjects.length >= 2) {
        final date = _findDate(head)?.date ?? _today;
        timetable = NoticeTimetableDraft(
          date: date,
          subjects: subjects,
          details: head,
        );
        // 시간표 줄에 딸린 다른 안내 줄은 각각 항목으로 처리한다.
        for (final line in body) {
          final text = line.trim();
          if (text.isEmpty) continue;
          final nested = _parseSegment(
            _Segment(text: text, hintedKind: segment.hintedKind),
            seq,
          );
          seq = nested.nextSequence;
          items.addAll(nested.items);
        }
        return _SegmentParseResult(
          items: items,
          timetable: timetable,
          nextSequence: seq,
        );
      }
    }

    // (2) 일반 항목
    var titleLine = head;
    var dates = _findDate(head)?.dates ?? const <DateTime>[];
    _TimeRange? timeRange = _findTimeRange(head);
    final detailLines = <String>[];

    void emit() {
      final rawTitle = titleLine.trim();
      if (rawTitle.isEmpty) return;
      var title = _cleanTitle(rawTitle);
      if (_isMeaningless(title)) title = rawTitle;
      if (title.isEmpty || _isMeaningless(title)) return;

      final details = detailLines.join('\n').trim().isEmpty
          ? (title.endsWith('…') ? rawTitle : '')
          : detailLines.join('\n').trim();
      final kind = _decideKind(
        head: rawTitle,
        body: details,
        hinted: segment.hintedKind,
      );
      final optional = kind == NoticeItemKind.event &&
          timeRange == null &&
          dates.isEmpty &&
          _isOptionalNotice('$rawTitle $details');
      final subject =
          kind == NoticeItemKind.homework ? _detectSubject('$rawTitle $details') : null;
      final source = '$rawTitle${details.isEmpty ? '' : '\n$details'}';

      final hasDates = dates.isNotEmpty;
      final targetDates = hasDates
          ? (kind == NoticeItemKind.homework ? <DateTime>[dates.first] : dates)
          : <DateTime>[_today];

      for (final target in targetDates) {
        var date = target;
        if (kind == NoticeItemKind.homework) {
          date = hasDates ? date : _nextSchoolDay(_today);
          // 이미 지난 날짜를 숙제 마감일로 잡는 일은 없게 한다.
          if (date.isBefore(_today)) date = date.add(const Duration(days: 7));
        }
        seq += 1;
        items.add(
          NoticeDraftItem(
            id: seq,
            kind: kind,
            title: title,
            date: date,
            subject: subject,
            startTime: kind == NoticeItemKind.event ? timeRange?.start : null,
            endTime: kind == NoticeItemKind.event ? timeRange?.end : null,
            details: details.isEmpty ? null : details,
            selected: !optional,
            optional: optional,
            sourceText: source,
          ),
        );
      }
    }

    for (final line in body) {
      final text = line.trim();
      if (text.isEmpty) continue;
      final lineDate = _findDate(text);
      final lineTime = _findTimeRange(text);
      final substantive = _meaningfulLength(text) >= 4;

      // 이미 날짜가 잡힌 항목 아래에서 새 날짜가 나오면 별개 일정으로 나눈다.
      if (lineDate != null && dates.isNotEmpty && substantive) {
        emit();
        titleLine = text;
        dates = lineDate.dates;
        timeRange = lineTime;
        detailLines.clear();
        continue;
      }
      if (dates.isEmpty && lineDate != null) dates = lineDate.dates;
      if (timeRange == null && lineTime != null) timeRange = lineTime;
      detailLines.add(text);
    }
    emit();

    return _SegmentParseResult(
      items: items,
      timetable: timetable,
      nextSequence: seq,
    );
  }

  List<NoticeDraftItem> _removeDuplicates(List<NoticeDraftItem> items) {
    final seen = <String>{};
    final result = <NoticeDraftItem>[];
    for (final item in items) {
      final key = '${item.kind.name}|${item.title.trim()}|${noticeYmd(item.date)}';
      if (item.title.trim().isEmpty) continue;
      if (!seen.add(key)) continue;
      result.add(item);
    }
    return result;
  }

  // ── 3단계: 종류/과목 판별 ──────────────────────────────────────────────

  static const List<String> _prepCues = <String>[
    '준비물',
    '가져오기',
    '가져 오기',
    '지참',
    '챙겨',
    '미리 준비',
  ];

  static const List<String> _homeworkCues = <String>[
    '숙제',
    '과제',
    '써오기',
    '써 오기',
    '써보기',
    '써 보기',
    '풀어오기',
    '풀어 오기',
    '풀어보기',
    '해오기',
    '해 오기',
    '읽어오기',
    '읽어 오기',
    '외워오기',
    '외워 오기',
    '외우기',
    '외워',
    '받아쓰기',
    '익힘책',
    '학습지',
    '문제집',
    '독서록',
    '독후감',
    '관찰일지',
    '일기',
    '노트에',
    '공책에',
    '조사해오기',
    '만들어오기',
    '완성해오기',
    '3번',
    '5번',
    '10번',
  ];

  static const List<String> _eventCues = <String>[
    '일시',
    '장소',
    '대상',
    '비용',
    '문의',
    '일정',
    '행사',
    '안내',
    '알림',
    '공지',
    '체험학습',
    '현장학습',
    '현장체험',
    '소풍',
    '운동회',
    '발표회',
    '공개수업',
    '수업공개',
    '상담',
    '면담',
    '선거',
    '투표',
    '토론회',
    '등교',
    '하교',
    '시간 변경',
    '시간변경',
    '휴업',
    '재량',
    '방학',
    '개학',
    '회의',
    '학부모',
    '제출',
    '보고서',
    '신청',
    '동의서',
    '가정통신문',
    '수련회',
    '축제',
    '시험',
    '평가',
    '단축',
    '임원',
    '후보',
    '조심',
    '지도',
    '주의',
    '급식',
    '견학',
    '봉사',
    '대회',
    '촬영',
    '설명회',
    '참가',
    '모집',
    '접수',
    '마감',
    '기간',
  ];

  static const List<String> _optionalCues = <String>[
    '조심',
    '안전',
    '인사',
    '감사',
    '주말',
    '즐거운',
    '건강',
    '손 씻',
  ];

  bool _containsAny(String text, List<String> cues) =>
      cues.any((cue) => text.contains(cue));

  NoticeItemKind _decideKind({
    required String head,
    required String body,
    NoticeItemKind? hinted,
  }) {
    final text = '$head $body';
    if (_containsAny(text, _prepCues)) return NoticeItemKind.event;
    if (_containsAny(text, _homeworkCues)) return NoticeItemKind.homework;
    if (_containsAny(text, _eventCues)) return NoticeItemKind.event;
    if (hinted != null) return hinted;
    // 아무 단서도 없으면 날짜가 있는 쪽은 숙제로(마감일), 없으면 일정 안내로.
    return _findDate(head) != null ? NoticeItemKind.homework : NoticeItemKind.event;
  }

  bool _isOptionalNotice(String text) => _containsAny(text, _optionalCues);

  static const Map<String, List<String>> _subjectAliases = <String, List<String>>{
    '국어': <String>['국어', '받아쓰기', '글쓰기', '낭독', '시 외우기'],
    '수학': <String>['수학익힘책', '수학익힘', '수학', '연산'],
    '독서': <String>['독서록', '독후감', '독서'],
    '영어': <String>['영어'],
    '과학': <String>['과학', '실험관찰'],
    '사회': <String>['사회', '지도공부'],
    '도덕': <String>['도덕'],
    '음악': <String>['음악', '리코더'],
    '미술': <String>['미술', '그리기'],
    '체육': <String>['체육', '줄넘기'],
    '창체': <String>['창체', '창의적 체험'],
    '실과': <String>['실과'],
    '한자': <String>['한자'],
    '컴퓨터': <String>['컴퓨터', '코딩'],
  };

  /// 제목·상세에서 가장 먼저 나오는 과목 이름을 찾는다.
  String? _detectSubject(String text) {
    String? best;
    var bestIndex = -1;
    for (final entry in _subjectAliases.entries) {
      for (final alias in entry.value) {
        final index = text.indexOf(alias);
        if (index < 0) continue;
        if (bestIndex == -1 || index < bestIndex) {
          bestIndex = index;
          best = entry.key;
        }
      }
    }
    return best;
  }

  // ── 4단계: 시간표 ─────────────────────────────────────────────────────

  bool _looksLikeTimetable(String text) {
    if (text.contains('시간표')) return true;
    if (RegExp(r'\d{1,2}\s*교시').allMatches(text).length >= 2) return true;
    return false;
  }

  List<String> _subjectsFromTimetableText(String text) {
    // '1교시 국어 2교시 수학 …' 형태
    final periodMatches =
        RegExp(r'(\d{1,2})\s*교시\s*[:：]?\s*([가-힣A-Za-z]{1,8})').allMatches(text).toList();
    if (periodMatches.length >= 2) {
      return periodMatches
          .map((match) => (match.group(2) ?? '').trim())
          .where((value) => value.isNotEmpty)
          .toList();
    }

    var body = text;
    final colonIndex = body.indexOf(RegExp(r'[:：]'));
    if (colonIndex >= 0) {
      body = body.substring(colonIndex + 1);
    } else {
      final keywordIndex = body.indexOf('시간표');
      if (keywordIndex >= 0) body = body.substring(keywordIndex + 3);
    }
    body = body.replaceAll(RegExp(r'^[\s\-–~:]+'), '').trim();
    if (body.isEmpty) return const <String>[];
    return NoticeTimetableDraft.splitSubjects(body);
  }

  // ── 5단계: 날짜/시각 읽기 ──────────────────────────────────────────────

  _DateMatch? _findDate(String text) {
    final source = text.trim();
    if (source.isEmpty) return null;

    // 기간: 11/16~11/17, 11월 16일 ~ 11월 18일
    final rangeMatch = RegExp(
      r'(\d{1,2})\s*[/.월]\s*(\d{1,2})\s*일?\s*(?:\(\s*[월화수목금토일]\s*\))?\s*[~\-–—]\s*'
      r'(\d{1,2})\s*[/.월]\s*(\d{1,2})\s*일?',
    ).firstMatch(source);
    if (rangeMatch != null) {
      final start = _safeDate(
        _today.year,
        int.tryParse(rangeMatch.group(1)!),
        int.tryParse(rangeMatch.group(2)!),
      );
      final end = _safeDate(
        _today.year,
        int.tryParse(rangeMatch.group(3)!),
        int.tryParse(rangeMatch.group(4)!),
      );
      if (start != null && end != null && !end.isBefore(start)) {
        final dates = <DateTime>[];
        for (var day = start;
            !day.isAfter(end) && dates.length < 31;
            day = day.add(const Duration(days: 1))) {
          dates.add(day);
        }
        if (dates.isNotEmpty) return _matchOf(rangeMatch, dates);
      }
    }

    // 2026.11.16 / 2026-11-16 / 2026년 11월 16일
    var match = RegExp(r'(\d{4})\s*[.\-/년]\s*(\d{1,2})\s*[.\-/월]\s*(\d{1,2})\s*일?')
        .firstMatch(source);
    if (match != null) {
      final date = _safeDate(
        int.tryParse(match.group(1)!),
        int.tryParse(match.group(2)!),
        int.tryParse(match.group(3)!),
      );
      if (date != null) return _matchOf(match, <DateTime>[date]);
    }

    // 11월 20일
    match = RegExp(r'(\d{1,2})\s*월\s*(\d{1,2})\s*일').firstMatch(source);
    if (match != null) {
      final date = _safeDate(
        _today.year,
        int.tryParse(match.group(1)!),
        int.tryParse(match.group(2)!),
      );
      if (date != null) return _matchOf(match, <DateTime>[date]);
    }

    // 11/20, 11.20 (시간 08:30이나 소수점과 헷갈리지 않도록 앞뒤 문자 확인)
    for (final found in RegExp(r'(\d{1,2})\s*[/.]\s*(\d{1,2})').allMatches(source)) {
      final before = found.start > 0 ? source[found.start - 1] : '';
      final after = found.end < source.length ? source[found.end] : '';
      if (before == ':' || _isDigitChar(before)) continue;
      if (_isDigitChar(after)) continue;
      final date = _safeDate(
        _today.year,
        int.tryParse(found.group(1)!),
        int.tryParse(found.group(2)!),
      );
      if (date != null) return _matchOf(found, <DateTime>[date]);
    }

    // 주 단위: '이번주 월,화,수', '다음주 목요일', '이번 주 금요일'
    match = RegExp(
      r'(이번\s*주|이번주|금주|이번|다음\s*주|다음주|차주|다음)\s*'
      r'([월화수목금토일](?:\s*[,·/]\s*[월화수목금토일])*)\s*(?:요일)?',
    ).firstMatch(source);
    if (match != null) {
      final qualifier = (match.group(1) ?? '').replaceAll(RegExp(r'\s'), '');
      final shift =
          (qualifier == '다음' || qualifier == '다음주' || qualifier == '차주') ? 7 : 0;
      final monday = _mondayOf(_today).add(Duration(days: shift));
      final dates = <DateTime>[];
      for (final char in (match.group(2) ?? '').split('')) {
        final weekday = _weekdayNumber(char);
        if (weekday == null) continue;
        final date = monday.add(Duration(days: weekday - 1));
        if (!dates.any((existing) => existing == date)) dates.add(date);
      }
      if (dates.isNotEmpty) return _matchOf(match, dates);
    }

    // 상대 표현
    final relative = RegExp(r'(오늘|금일|내일|명일|모레|모래|글피)').firstMatch(source);
    if (relative != null) {
      final word = relative.group(1) ?? '';
      var offset = 1;
      if (word == '오늘' || word == '금일') offset = 0;
      if (word == '모레' || word == '모래') offset = 2;
      if (word == '글피') offset = 3;
      return _matchOf(
        relative,
        <DateTime>[_today.add(Duration(days: offset))],
      );
    }

    // 주말
    match = RegExp(r'(이번\s*주|다음\s*주)?\s*주말').firstMatch(source);
    if (match != null) {
      final shift = (match.group(1) ?? '').contains('다음') ? 7 : 0;
      final monday = _mondayOf(_today).add(Duration(days: shift));
      return _matchOf(match, <DateTime>[monday.add(const Duration(days: 5))]);
    }

    // '목요일', '금요일까지' → 오늘 이후 가장 가까운 그 요일
    match = RegExp(r'([월화수목금토일])\s*요일').firstMatch(source);
    if (match != null) {
      final weekday = _weekdayNumber(match.group(1) ?? '');
      if (weekday != null) {
        var date = _mondayOf(_today).add(Duration(days: weekday - 1));
        if (date.isBefore(_today)) date = date.add(const Duration(days: 7));
        return _matchOf(match, <DateTime>[date]);
      }
    }

    // '20일까지' → 이번 달 20일(이미 지났으면 다음 달)
    match = RegExp(r'(\d{1,2})\s*일\s*까지').firstMatch(source);
    if (match != null) {
      final day = int.tryParse(match.group(1)!);
      if (day != null && day >= 1 && day <= 31) {
        var date = _safeDate(_today.year, _today.month, day);
        if (date != null && date.isBefore(_today)) {
          final nextMonth = _today.month == 12 ? 1 : _today.month + 1;
          final nextYear = _today.month == 12 ? _today.year + 1 : _today.year;
          date = _safeDate(nextYear, nextMonth, day);
        }
        if (date != null) return _matchOf(match, <DateTime>[date]);
      }
    }

    return null;
  }

  _DateMatch _matchOf(RegExpMatch match, List<DateTime> dates) {
    return _DateMatch(
      dates: dates,
      raw: match.group(0) ?? '',
      start: match.start,
      end: match.end,
    );
  }

  _TimeRange? _findTimeRange(String text) {
    // 09:00~15:00, 08:30-08:50
    var match = RegExp(r'(\d{1,2})\s*:\s*(\d{2})\s*[~\-–—]\s*(\d{1,2})\s*:\s*(\d{2})')
        .firstMatch(text);
    if (match != null) {
      final start = _hm(int.tryParse(match.group(1)!), int.tryParse(match.group(2)!));
      final end = _hm(int.tryParse(match.group(3)!), int.tryParse(match.group(4)!));
      if (start != null && end != null) return _TimeRange(start, end);
    }

    // 9시 40분~50분, 9시~10시, 오후 2시~4시
    match = RegExp(
      r'(오전|오후)?\s*(\d{1,2})\s*시\s*(?:(\d{1,2})\s*분)?\s*[~\-–—]\s*'
      r'(?:(\d{1,2})\s*시)?\s*(?:(\d{1,2})\s*분)?',
    ).firstMatch(text);
    if (match != null) {
      final meridiem = match.group(1);
      final hour1 = int.tryParse(match.group(2)!);
      final minute1 = int.tryParse(match.group(3) ?? '') ?? 0;
      final hour2Raw = match.group(4);
      final minute2Raw = match.group(5);
      if (hour1 != null && (hour2Raw != null || minute2Raw != null)) {
        var hour2 = hour2Raw != null ? int.tryParse(hour2Raw) : hour1;
        final minute2 = minute2Raw != null ? int.tryParse(minute2Raw) : 0;
        var startHour = hour1;
        if (meridiem == '오후') {
          if (startHour < 12) startHour += 12;
          if (hour2 != null && hour2 < 12) hour2 += 12;
        }
        final start = _hm(startHour, minute1);
        final end = _hm(hour2, minute2);
        if (start != null && end != null) return _TimeRange(start, end);
      }
    }

    // 한 시각만: '오후 3시', '9시 30분'
    match = RegExp(r'(오전|오후)?\s*(\d{1,2})\s*시\s*(?:(\d{1,2})\s*분)?').firstMatch(text);
    if (match != null) {
      final meridiem = match.group(1);
      var hour = int.tryParse(match.group(2) ?? '');
      final minute = int.tryParse(match.group(3) ?? '') ?? 0;
      if (hour != null) {
        if (meridiem == '오후' && hour < 12) hour += 12;
        final value = _hm(hour, minute);
        if (value != null) return _TimeRange(value, null);
      }
    }

    return null;
  }

  String? _hm(int? hour, int? minute) {
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  // ── 6단계: 제목 다듬기 ────────────────────────────────────────────────

  String _cleanTitle(String text) {
    var title = text.trim();
    if (title.isEmpty) return '';

    // 라벨 제거
    title = title.replaceFirst(
      RegExp(r'^(숙제|과제|알림|공지|안내|일정|일시|시간표|학급일정|가정통신문)\s*[:：]\s*'),
      '',
    );

    // 앞머리 날짜/요일 표현은 날짜 칸으로 옮겼으니 제목에서 뺀다.
    final lead = _findDate(title);
    if (lead != null && lead.start <= 1 && lead.end <= title.length) {
      var rest = title.substring(lead.end).trim();
      rest = rest.replaceFirst(RegExp(r'^[\(\[]\s*[월화수목금토일]\s*[\)\]]\s*'), '');
      rest = rest.replaceFirst(RegExp(r'^(까지|부터|에는|에도|에|은|는)\s+'), '');
      if (rest.length >= 2) title = rest;
    }

    // 괄호 안 시간/마감 표현 정리
    title = title.replaceAll(RegExp(r'\(\s*[월화수목금토일]\s*\)'), ' ');
    title = title.replaceAllMapped(RegExp(r'\(([^()]{1,24})\)'), (match) {
      final inner = match.group(1) ?? '';
      if (_findDate(inner) != null ||
          _findTimeRange(inner) != null ||
          inner.contains('까지') ||
          inner.contains('부터')) {
        return ' ';
      }
      return match.group(0) ?? '';
    });
    title = title.replaceFirst(
      RegExp(r'\s*(?:이번|다음)?\s*주?\s*[월화수목금토일]요일?\s*까지\s*$'),
      '',
    );

    title = title.replaceAll(RegExp(r'\s+'), ' ').trim();
    title = title.replaceAll(RegExp(r'^[,\-·:\.]+'), '').trim();
    title = title.replaceAll(RegExp(r'[.。]+$'), '').trim();
    if (title.length > 60) title = '${title.substring(0, 60)}…';
    return title;
  }

  bool _isMeaningless(String text) {
    var stripped = text;
    stripped = stripped.replaceAll(RegExp(r'\d{1,4}\s*[년월일]'), ' ');
    stripped = stripped.replaceAll(RegExp(r'[월화수목금토일]\s*요일'), ' ');
    stripped = stripped.replaceAll(RegExp(r'\d{1,2}\s*[:시]\s*\d{0,2}\s*분?'), ' ');
    stripped = stripped.replaceAll(RegExp(r'[\s\-–~·•*※\.\,\(\)\[\]|/]'), '');
    return stripped.length < 2;
  }

  int _meaningfulLength(String text) {
    final stripped = text.replaceAll(RegExp(r'[\s\-–~·•*※\.\,\(\)\[\]]'), '');
    return stripped.length;
  }

  // ── 7단계: 날짜 도우미 ─────────────────────────────────────────────────

  DateTime _mondayOf(DateTime date) =>
      noticeDateOnly(date).subtract(Duration(days: date.weekday - 1));

  DateTime _nextSchoolDay(DateTime date) {
    var next = noticeDateOnly(date).add(const Duration(days: 1));
    while (next.weekday == DateTime.saturday || next.weekday == DateTime.sunday) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  DateTime? _safeDate(int? year, int? month, int? day) {
    if (year == null || month == null || day == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final date = DateTime(year, month, day);
    if (date.month != month || date.day != day) return null;
    return date;
  }

  int? _weekdayNumber(String char) {
    switch (char) {
      case '월':
        return DateTime.monday;
      case '화':
        return DateTime.tuesday;
      case '수':
        return DateTime.wednesday;
      case '목':
        return DateTime.thursday;
      case '금':
        return DateTime.friday;
      case '토':
        return DateTime.saturday;
      case '일':
        return DateTime.sunday;
    }
    return null;
  }

  bool _isDigitChar(String value) {
    if (value.isEmpty) return false;
    final code = value.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }
}

class _Segment {
  _Segment({required this.text, this.hintedKind});

  String text;
  final List<String> body = <String>[];
  final NoticeItemKind? hintedKind;

  /// 이 구간 아래에 이미 설명 줄이 충분히 붙었는지 표시(더 붙이지 않음).
  bool get closed => body.length >= 10;
}

class _SegmentParseResult {
  _SegmentParseResult({
    required this.items,
    required this.nextSequence,
    this.timetable,
  });

  final List<NoticeDraftItem> items;
  final NoticeTimetableDraft? timetable;
  final int nextSequence;
}

class _DateMatch {
  _DateMatch({
    required this.dates,
    required this.raw,
    required this.start,
    required this.end,
  });

  final List<DateTime> dates;
  final String raw;
  final int start;
  final int end;

  DateTime get date => dates.first;
}

class _TimeRange {
  _TimeRange(this.start, this.end);

  /// 'HH:mm'
  final String start;

  /// 'HH:mm' (없으면 null)
  final String? end;
}
