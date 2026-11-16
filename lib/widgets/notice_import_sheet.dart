import 'package:flutter/material.dart';

import '../models/notice_draft.dart';
import '../services/notice_import_service.dart';
import '../services/notice_parser.dart';

/// 알림장 가져오기 시트를 연다. 등록에 성공하면 결과를 돌려주고, 취소하면 null.
Future<NoticeImportResult?> showNoticeImportSheet(
  BuildContext context, {
  required String familyId,
  String? role,
  DateTime? today,
}) {
  return showModalBottomSheet<NoticeImportResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (_) => NoticeImportSheet(
      familyId: familyId,
      role: role,
      today: today,
    ),
  );
}

/// 하이클래스 알림장을 붙여넣어 숙제·일정·시간표로 나누고, 확인한 뒤 등록하는 화면.
class NoticeImportSheet extends StatefulWidget {
  const NoticeImportSheet({
    super.key,
    required this.familyId,
    this.role,
    this.today,
  });

  final String familyId;
  final String? role;
  final DateTime? today;

  @override
  State<NoticeImportSheet> createState() => _NoticeImportSheetState();
}

class _NoticeImportSheetState extends State<NoticeImportSheet> {
  final TextEditingController _text = TextEditingController();
  final NoticeImportService _service = NoticeImportService();
  final Map<int, TextEditingController> _titleControllers =
      <int, TextEditingController>{};
  final Map<int, TextEditingController> _subjectControllers =
      <int, TextEditingController>{};

  TextEditingController? _timetableController;
  NoticeParseResult? _result;
  bool _busy = false;
  String? _error;
  int _exampleIndex = 0;

  @override
  void dispose() {
    _text.dispose();
    _disposeControllers();
    _timetableController?.dispose();
    super.dispose();
  }

  void _disposeControllers() {
    for (final controller in _titleControllers.values) {
      controller.dispose();
    }
    for (final controller in _subjectControllers.values) {
      controller.dispose();
    }
    _titleControllers.clear();
    _subjectControllers.clear();
    _timetableController?.dispose();
    _timetableController = null;
  }

  void _fillExample() {
    final examples = NoticeParser.exampleNotices;
    setState(() {
      _text.text = examples[_exampleIndex % examples.length];
      _exampleIndex = (_exampleIndex + 1) % examples.length;
      _error = null;
    });
  }

  void _runParser() {
    final raw = _text.text.trim();
    if (raw.isEmpty) {
      setState(() => _error = '알림장 내용을 먼저 붙여넣어 주세요.');
      return;
    }
    final parser = NoticeParser(today: widget.today);
    final result = parser.parse(raw);
    _disposeControllers();
    setState(() {
      _result = result;
      _error = result.isEmpty ? '분류된 항목이 없어요. 번호(1. 2.)나 줄바꿈으로 항목을 나눠 다시 시도해 주세요.' : null;
    });
  }

  int get _selectedCount {
    final result = _result;
    if (result == null) return 0;
    return result.selectedCount;
  }

  bool get _allSelected {
    final result = _result;
    if (result == null) return false;
    if (result.items.isEmpty && result.timetable == null) return false;
    final itemsSelected = result.items.every((item) => item.selected);
    final timetableSelected = result.timetable?.selected ?? true;
    return itemsSelected && timetableSelected;
  }

  void _toggleAll() {
    final result = _result;
    if (result == null) return;
    final target = !_allSelected;
    setState(() {
      for (final item in result.items) {
        item.selected = target;
      }
      final timetable = result.timetable;
      if (timetable != null) timetable.selected = target;
    });
  }

  Future<void> _pickItemDate(NoticeDraftItem item) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: item.date,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035, 12, 31),
      helpText: '날짜 선택',
    );
    if (picked != null) {
      setState(() => item.date = noticeDateOnly(picked));
    }
  }

  Future<void> _pickTimetableDate(NoticeTimetableDraft timetable) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: timetable.date,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035, 12, 31),
      helpText: '시간표를 넣을 날짜',
    );
    if (picked != null) {
      setState(() => timetable.date = noticeDateOnly(picked));
    }
  }

  Future<void> _submit() async {
    final result = _result;
    if (result == null || _busy) return;
    if (_selectedCount == 0) {
      setState(() => _error = '등록할 항목을 하나 이상 선택해 주세요.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });

    final imported = await _service.import(
      familyId: widget.familyId,
      items: result.items,
      timetable: result.timetable,
    );

    if (!mounted) return;
    setState(() => _busy = false);
    if (imported.total == 0 && imported.error != null) {
      setState(() => _error = imported.error);
      return;
    }
    Navigator.of(context).pop(imported);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = _result;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.92,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
              child: Row(
                children: [
                  const Icon(Icons.assignment_outlined, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '알림장 가져오기',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    tooltip: '닫기',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  Text(
                    '하이클래스 알림장을 그대로 복사해 붙여넣으면 숙제·준비물·일정·시간표로 나눠 드려요. '
                    '등록 전에 미리보기에서 확인하고 고칠 수 있어요.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.blueGrey.shade600, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _text,
                    minLines: 6,
                    maxLines: 12,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      labelText: '알림장 내용',
                      hintText: '예) 1.시간표 : 미술, 미술, 국어, 체육, 수학, 창체\n'
                          '2. 받아쓰기 9급 틀린 것 3번 써오기',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : _fillExample,
                          icon: const Icon(Icons.auto_fix_high, size: 16),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('예시 알림장 채우기'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _busy ? null : _runParser,
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('자동 분류하기'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.role == 'child')
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        '자녀 계정에서는 숙제·시간표 등록이 제한될 수 있어요.',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.orange.shade800),
                      ),
                    ),
                  if (_error != null)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  if (result != null) ..._buildPreview(context, result),
                ],
              ),
            ),
            _buildFooter(context, result),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPreview(BuildContext context, NoticeParseResult result) {
    final theme = Theme.of(context);
    return <Widget>[
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: Text(
              '분류 결과 ${result.totalCount}건 · 선택 ${result.selectedCount}건',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: _busy ? null : _toggleAll,
            child: Text(_allSelected ? '전체 해제' : '전체 선택'),
          ),
        ],
      ),
      Text(
        '숙제/일정 표시를 누르면 종류가 바뀌어요. 제목·과목·날짜를 고치고, 등록할 것만 체크하세요.',
        style: theme.textTheme.bodySmall
            ?.copyWith(color: Colors.blueGrey.shade600, height: 1.4),
      ),
      const SizedBox(height: 12),
      if (result.timetable != null) _buildTimetableCard(context, result.timetable!),
      ...result.items.map((item) => _buildItemCard(context, item)),
      for (final warning in result.warnings)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 14, color: Colors.blueGrey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  warning,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.blueGrey.shade600),
                ),
              ),
            ],
          ),
        ),
    ];
  }

  Widget _buildTimetableCard(
    BuildContext context,
    NoticeTimetableDraft timetable,
  ) {
    final theme = Theme.of(context);
    _timetableController ??=
        TextEditingController(text: timetable.subjectsText);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: timetable.selected,
                  onChanged: (value) =>
                      setState(() => timetable.selected = value ?? false),
                ),
                const Icon(Icons.schedule_outlined, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '시간표 ${timetable.periodCount}교시',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.calendar_today, size: 14),
                    label: Text(noticeKoDate(timetable.date)),
                    onPressed: _busy
                        ? null
                        : () => _pickTimetableDate(timetable),
                  ),
                  if (timetable.selected)
                    Text(
                      '${timetable.periodCount}개 교시 등록',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.blueGrey.shade600),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 0, 0),
              child: TextField(
                controller: _timetableController,
                decoration: const InputDecoration(
                  isDense: true,
                  labelText: '과목 (쉼표로 구분, 1교시부터)',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 13),
                onChanged: (value) => setState(
                  () => timetable.subjects = NoticeTimetableDraft.splitSubjects(value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, NoticeDraftItem item) {
    final theme = Theme.of(context);
    final titleController = _titleControllers.putIfAbsent(
      item.id,
      () => TextEditingController(text: item.title),
    );
    final subjectController = _subjectControllers.putIfAbsent(
      item.id,
      () => TextEditingController(text: item.subject ?? ''),
    );
    final isHomework = item.kind == NoticeItemKind.homework;
    final kindColor =
        isHomework ? const Color(0xFF2F6DB5) : const Color(0xFFB25E2A);
    final details = (item.details ?? '').trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: item.selected,
                  onChanged: (value) =>
                      setState(() => item.selected = value ?? false),
                ),
                Expanded(
                  child: TextField(
                    controller: titleController,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: '제목',
                    ),
                    onChanged: (value) => item.title = value,
                  ),
                ),
                const SizedBox(width: 6),
                Tooltip(
                  message: '눌러서 숙제 ↔ 일정 변경',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _busy
                        ? null
                        : () => setState(
                              () => item.kind = isHomework
                                  ? NoticeItemKind.event
                                  : NoticeItemKind.homework,
                            ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: kindColor.withAlpha(28),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isHomework
                                ? Icons.menu_book_outlined
                                : Icons.event_outlined,
                            size: 14,
                            color: kindColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.kind.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: kindColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.calendar_today, size: 14),
                    label: Text(
                      isHomework
                          ? '마감 ${noticeKoDate(item.date)}'
                          : noticeKoDate(item.date),
                    ),
                    onPressed: _busy ? null : () => _pickItemDate(item),
                  ),
                  if (isHomework)
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: subjectController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: '과목',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => item.subject = value,
                      ),
                    ),
                  if (!isHomework && item.hasTime)
                    Chip(
                      avatar: const Icon(Icons.schedule, size: 14),
                      label: Text(
                        item.timeLabel,
                        style: const TextStyle(fontSize: 12),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (item.optional)
                    Chip(
                      label: const Text('참고', style: TextStyle(fontSize: 12)),
                      backgroundColor: Colors.grey.shade200,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
            if (details.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 0, 0),
                child: Text(
                  details,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.blueGrey.shade600, height: 1.3),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, NoticeParseResult? result) {
    final theme = Theme.of(context);
    final count = _selectedCount;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: theme.dividerColor.withAlpha(40)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                result == null
                    ? '자동 분류 후 등록할 항목을 골라 주세요.'
                    : '선택 $count건',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton.icon(
              onPressed: (result == null || _busy || count == 0) ? null : _submit,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_busy ? '등록 중…' : '선택 항목 등록'),
            ),
          ],
        ),
      ),
    );
  }
}
