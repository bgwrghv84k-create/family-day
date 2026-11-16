import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notice_draft.dart';
import 'app_mode.dart';
import 'demo_store.dart';

/// 알림장에서 분류한 항목을 Supabase `homework` / `family_events` /
/// `timetable_entries` 테이블에 한 번에 등록한다.
///
/// 여러 행을 한 번의 insert로 보내고, 시간표는 (가족, 날짜, 교시) 기준으로
/// upsert 해서 같은 날 다시 가져와도 행이 겹치지 않는다.
class NoticeImportService {
  NoticeImportService({SupabaseClient? client, this.memberLabel = '아들'})
      : _client = client;

  final SupabaseClient? _client;
  final String memberLabel;

  SupabaseClient get _db => _client ?? Supabase.instance.client;

  Future<NoticeImportResult> import({
    required String familyId,
    required List<NoticeDraftItem> items,
    NoticeTimetableDraft? timetable,
  }) async {
    final userId = demoMode ? demoUserId : _db.auth.currentUser?.id;
    if (userId == null) {
      return const NoticeImportResult(error: '로그인이 풀렸어요. 다시 로그인한 뒤 시도해 주세요.');
    }
    if (familyId.isEmpty) {
      return const NoticeImportResult(
        error: '가족 공간 정보를 찾지 못했어요. 앱을 다시 열어 주세요.',
      );
    }

    final selected = items
        .where((item) => item.selected && item.title.trim().isNotEmpty)
        .toList();

    final homeworkRows = <Map<String, dynamic>>[];
    final eventRows = <Map<String, dynamic>>[];
    for (final item in selected) {
      if (item.kind == NoticeItemKind.homework) {
        homeworkRows.add(
          item.toHomeworkRow(familyId: familyId, userId: userId),
        );
      } else {
        eventRows.add(
          item.toEventRow(
            familyId: familyId,
            userId: userId,
            memberLabel: memberLabel,
          ),
        );
      }
    }

    final timetableRows = (timetable != null && timetable.selected)
        ? timetable.toRows(familyId: familyId, userId: userId)
        : <Map<String, dynamic>>[];

    // 서버 없이 도는 데모: 메모리 저장소에 바로 반영한다.
    if (demoMode) {
      final store = DemoStore.instance;
      store.addHomeworkRows(homeworkRows);
      store.addEventRows(eventRows);
      store.upsertTimetableRows(timetableRows);
      return NoticeImportResult(
        homeworkCount: homeworkRows.length,
        eventCount: eventRows.length,
        timetableCount: timetableRows.length,
      );
    }

    var homeworkCount = 0;
    var eventCount = 0;
    var timetableCount = 0;
    final errors = <String>[];

    if (homeworkRows.isNotEmpty) {
      try {
        await _db.from('homework').insert(homeworkRows);
        homeworkCount = homeworkRows.length;
      } on PostgrestException catch (error) {
        errors.add(_friendlyMessage('숙제', error));
      } catch (error) {
        errors.add('숙제를 등록하지 못했어요: $error');
      }
    }

    if (eventRows.isNotEmpty) {
      try {
        await _db.from('family_events').insert(eventRows);
        eventCount = eventRows.length;
      } on PostgrestException catch (error) {
        errors.add(_friendlyMessage('일정', error));
      } catch (error) {
        errors.add('일정을 등록하지 못했어요: $error');
      }
    }

    if (timetableRows.isNotEmpty) {
      try {
        await _db
            .from('timetable_entries')
            .upsert(timetableRows, onConflict: 'family_id,class_date,period');
        timetableCount = timetableRows.length;
      } on PostgrestException catch (error) {
        errors.add(_friendlyMessage('시간표', error));
      } catch (error) {
        errors.add('시간표를 등록하지 못했어요: $error');
      }
    }

    return NoticeImportResult(
      homeworkCount: homeworkCount,
      eventCount: eventCount,
      timetableCount: timetableCount,
      error: errors.isEmpty ? null : errors.join('\n'),
    );
  }

  String _friendlyMessage(String label, PostgrestException error) {
    final message = error.message.toLowerCase();
    if (error.code == '42501' ||
        message.contains('row-level security') ||
        message.contains('permission denied')) {
      return '$label: 등록 권한이 없어요. 부모 계정으로 로그인했는지 확인해 주세요.';
    }
    if (error.code == '23503') {
      return '$label: 가족 공간 정보를 확인하지 못했어요. 앱을 다시 열어 주세요.';
    }
    if (error.code == '23505' || message.contains('duplicate key')) {
      return '$label: 같은 항목이 이미 등록돼 있어요.';
    }
    if (error.code == '23502' || message.contains('null value')) {
      return '$label: 꼭 필요한 값이 비어 있어요. 날짜를 확인해 주세요.';
    }
    return '$label: ${error.message}';
  }
}
