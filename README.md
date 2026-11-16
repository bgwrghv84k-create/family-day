# Family Day — Flutter + Supabase MVP starter

Family Day is a cross-platform family calendar and elementary-school homework tracker for iOS and Android.

## Included in this starter
- Flutter app shell with Home / Calendar / Homework / Family tabs
- Email/password authentication through Supabase Auth
- Family space creation
- Homework list with completion checkboxes and completion metadata
- 퀘스트 스타일 UI: 코발트·네이비 + 에메랄드 민트 + 포인트 골드 테마, **오늘의 미션 진행도 카드**(완료/전체 + 프로그레스 바 + 전부 끝내면 `오늘 미션 클리어! 🏆` 배지), 체크할 때 햅틱·스낵바 피드백
- Today's timetable display and family event display
- **HiClass 알림장 가져오기**: 붙여넣기 → 숙제·준비물·일정·시간표 자동 분류 → 미리보기/수정 → Supabase 일괄 등록
- Supabase SQL schema with Row Level Security policies
- Parser + widget tests (`flutter test`, 31 tests)

## Important current limitations
This is the first implementation scaffold, not yet a store-ready app. Family invitation/onboarding, full event create/edit UI, timetable management UI, push notifications, and realtime subscriptions still need implementation and testing. HiClass should only be connected through an official/authorized method; do not store a HiClass password in this app or scrape authenticated pages. The 알림장 가져오기 feature works only from text the parent copies themselves — it never logs in to HiClass.

## 웹으로 바로 보기 (샘플 데이터 데모 모드 · PWA)

Supabase를 아직 연결하지 않아도 웹 빌드는 **샘플 데이터 데모 모드**로 시작합니다.
(`SUPABASE_URL`/`SUPABASE_ANON_KEY`가 비어 있거나 `--dart-define=DEMO_MODE=true`로 빌드한 경우. 빈 화면 대신 바로 체험할 수 있습니다.)

- 대상: 광주제석초 3학년 2반 (2026년 11월 16일 월요일 기준)
- 오늘 시간표 6교시(미술·미술·국어·체육·수학·창체), 숙제 미션 4개, 이번 주 가족 일정(목~토 부산 해운대 여행, 수능일 등교 시간 변경, 전교임원후보자 선거운동·토론회)
- 체크하면 미션 진행도가 오르고, 4개를 모두 끝내면 `🏆 오늘 미션 클리어!` 가 뜹니다.
- 알림장 가져오기는 파싱 → 미리보기 → 등록까지 메모리 저장소(`lib/services/demo_store.dart`)에 그대로 반영되고 홈·미션·달력 탭이 함께 새로 고쳐집니다. 화면을 새로 고치면 처음 샘플로 돌아갑니다.
- 앱바의 `DEMO` 배지, 가족 탭의 "샘플 데이터 데모 모드" 카드에서 데모 상태를 확인하고 `샘플 데이터로 되돌리기`로 초기화할 수 있습니다.

### 빌드

```bash
# GitHub Pages 프로젝트 사이트(/family-day/)에 올릴 빌드
flutter build web --release --base-href "/family-day/"

# 루트(/)에 올리거나 로컬에서 미리 볼 빌드
flutter build web --release
```

- 결과물은 `build/web` 입니다.
- PWA 설정: `web/index.html`(`apple-mobile-web-app-*`, `theme-color`, `viewport-fit=cover`), `web/manifest.json`(이름·테마·아이콘·`standalone`). 아이콘은 `python3 tool/make_icons.py`로 다시 만들 수 있습니다.
- 아이폰 사파리에서 열고 **공유 → 홈 화면에 추가** 하면 주소창 없는 전체 화면 앱처럼 실행됩니다.
- 데모 링크: <https://bgwrghv84k-create.github.io/family-day/>

## Requirements
- Flutter stable 3.27+ (`CardThemeData`, `WidgetStateProperty` 사용. 최신 stable 3.50에서 `flutter analyze` / `flutter test` 통과 확인)
- A Supabase project
- Xcode for iOS builds (macOS required)
- Android Studio / Android SDK for Android builds

## Backend setup
1. Create a Supabase project.
2. In Supabase SQL Editor, run `supabase/schema.sql`.
3. In Project Settings → API, copy the Project URL and anon/public key.
4. Run the app with:

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

Never put the Supabase `service_role` key in the mobile app.

The 알림장 가져오기 기능은 새 테이블을 쓰지 않습니다. 이미 있는 `homework`, `family_events`, `timetable_entries`와 그 RLS 정책을 그대로 사용하므로, 예전 schema를 이미 적용한 프로젝트도 마이그레이션 없이 동작합니다.

## First family setup
1. Create an account for the first parent.
2. Sign in and create the family space (e.g. 우리 가족 / 엄마).
3. Family invitation is the next implementation item. Do not share one login among family members; each person should have their own account.

## 화면 구성과 테마 (퀘스트 스타일)
초등 3학년 남자아이가 보기 좋아할 게임/퀘스트 느낌으로 다듬었습니다.

- **팔레트** (`AppColors`): 네이비 `#0D1B33`·코발트 `#2563EB`, 에메랄드 민트 `#12C9A0`, 포인트 골드 `#F7B733`. 배경은 옅은 블루그레이 `#F2F6FF`, 카드는 흰색 + 얇은 테두리.
- **오늘의 미션 카드** (`MissionCard`): 홈 탭과 숙제(미션) 탭 상단에 표시. 네이비→코발트 그라데이션 카드에 `완료 / 전체` 숫자, 남은 개수 헤드라인, 민트 프로그레스 바(애니메이션), `% 완료` 표시. 전부 끝내면 프로그레스가 금색으로 바뀌고 `🏆 오늘 미션 클리어!` 금색 배지가 나타납니다.
- **체크 피드백**: 숙제 체크 시 햅틱(medium impact) + 스낵바(`좋아요! 3/5 완료 ⚡`), 마지막 하나를 끝내면 `오늘 미션 클리어! 🏆 정말 대단해요!`. 완료된 카드는 민트 배경·트로피 아이콘·`✨`로 바뀝니다.
- **목록/상세**: 과목별 아이콘(수학=계산기, 국어=책, 체육=축구공 …), 과목 칩, 마감일 강조(지난 미션은 빨간색), 시간표는 코발트 그라데이션 교시 배지, 달력은 코발트 선택/민트 오늘/금색 마커.

```bash
flutter test   # 파서 20 + 알림장 시트 4 + 홈/미션 UI 7 = 31개
```

## 알림장 가져오기 (하이클래스 붙여넣기)

하이클래스는 공식 오픈 API가 없습니다. 그래서 이 기능은 **학부모가 하이클래스 앱/웹에서 알림장 본문을 복사해 붙여넣는** 방식만 사용합니다. 로그인 정보를 저장하거나 화면을 긁어오지 않습니다.

### 사용 흐름
1. 홈 탭의 `알림장 가져오기` 카드 또는 숙제 탭의 `알림장 가져오기` 버튼을 누릅니다.
2. 알림장 내용을 붙여넣습니다. (`예시 알림장 채우기`로 실제 3학년 2반 알림장 형식을 바로 시험해 볼 수 있습니다.)
3. `자동 분류하기`를 누르면 항목별 미리보기가 나옵니다.
4. 미리보기에서 항목별로
   - 체크박스로 등록 여부를 고르고,
   - `숙제`/`일정` 표시를 눌러 종류를 바꾸고,
   - 제목·과목·날짜(달력 선택)를 고치고,
   - 시간표는 과목 목록과 날짜를 고칩니다.
5. `선택 항목 등록`을 누르면 한 번에 저장되고, 홈·숙제·달력 화면이 새로 고쳐집니다.

### 분류 규칙
`lib/services/notice_parser.dart`가 규칙 기반으로 동작합니다. LLM 없이도 초등 알림장의 관용 표현을 읽습니다.

| 입력 형태 | 결과 |
| --- | --- |
| `1.시간표 : 미술, 미술, 국어, 체육, 수학, 창체`, `1교시 국어 2교시 수학` | `timetable_entries` (1교시부터 순서대로, 같은 날짜·교시는 upsert) |
| `2. 받아쓰기 9급 틀린 것 3번 써오기`, `- 수학익힘책 42쪽 풀어오기`, `[숙제]` 섹션 | `homework` (과목 자동 추정: 국어/수학/독서/영어/과학/사회/도덕/음악/미술/체육/창체 등) |
| `준비물:`, `가져오기`, `[준비물]` | `family_events` (일정) |
| `선거운동 기간`, `등교 시간 변경`, `현장체험학습`, `공개수업`, `보고서 제출` 등 안내/행사 | `family_events` (일정) |
| `차, 길, 사람 조심.` 같은 인사·안전 안내 | `family_events`에 `참고`로 표시되고 **기본 선택 해제** |

- 줄머리 표시 `1.`, `2)`, `①`, `-`, `•`, `*`, `※` 를 항목 구분으로 씁니다. 표시 없는 줄은 앞 항목의 설명으로 붙습니다.
- `[숙제]`, `[준비물]`, `[일정]`, `[알림]` 같은 섹션 제목은 아래 항목의 종류를 정합니다.
- 한 항목 아래에서 새 날짜가 나오면 별개 일정으로 나눕니다(예: `3. 전교임원후보자 선거운동 기간` + `이번주 목요일 후보자 토론회`).
- 날짜 표현을 기준일(오늘)로 계산합니다: `오늘/내일/모레/글피`, `이번주 월,화,수`, `다음주 화요일`, `금요일까지`, `11/20`, `11월 20일`, `2026.11.20`, `20일까지`.
- 날짜가 여러 개인 일정(`월,화,수`)은 날짜마다 한 건씩 만들어 달력에 모두 표시되게 합니다.
- 마감일이 없는 숙제는 다음 등교일(주말 건너뜀)로 잡고, 이미 지난 날짜는 다음 주로 넘깁니다.
- 시간은 `08:30~08:50`, `9시 40분~50분`, `오후 2시~4시`를 읽어 `family_events.start_time/end_time`에 넣습니다.

### 저장 방식
`lib/services/notice_import_service.dart`가 선택된 항목만 모아 테이블별로 한 번씩 보냅니다.
- `homework`: `family_id`, `title`, `subject`, `due_date`, `details`, `created_by`
- `family_events`: `family_id`, `title`, `event_date`, `start_time`, `end_time`, `member_label`(기본 `아들`), `notes`, `created_by`
- `timetable_entries`: `family_id`, `class_date`, `period`, `subject`, `created_by` — `onConflict: family_id,class_date,period`로 upsert

RLS상 숙제/시간표 등록은 부모 역할만 가능하므로, 자녀 계정에서 시도하면 "등록 권한이 없어요" 안내를 보여 줍니다.

### 테스트
```bash
flutter test
```
- `test/notice_parser_test.dart`: 실제 하이클래스 알림장 원문, 섹션형 알림장, 날짜 계산, 저장용 행 변환
- `test/notice_import_sheet_test.dart`: 예시 채우기 → 자동 분류 → 미리보기 → 전체 선택/해제, 빈 입력 안내, 좁은 화면(320dp) 레이아웃
- `test/home_ui_test.dart`: 오늘의 미션 카드(진행 중/클리어/미션 없음), 홈 화면 렌더링, 테마 색상, 좁은 화면 레이아웃
- `test/demo_mode_test.dart`: 데모 시드 데이터(시간표 6교시·미션 4개·여행 일정), 체크/되돌리기, 홈·미션·가족 탭 렌더링, 알림장 가져오기의 메모리 반영

## Suggested next implementation milestones
1. Secure invite-code flow: parent creates a one-time child invite; child signs up on their own device and joins as `child`.
2. Role-aware policies: child can update only homework completion fields; parents can create/edit homework and manage events/timetable.
3. Realtime subscriptions so a child's check appears immediately on parent devices.
4. Event CRUD, weekly timetable editor, and an edit screen for imported items (지금은 가져오기 직후에만 수정 가능).
5. Push notifications and an authorized HiClass import workflow.

## 알림장 가져오기 확장 포인트
지금은 텍스트만 받지만, 파서와 등록 로직을 그대로 두고 입력부만 넓히면 됩니다.

- **스크린샷/사진 OCR**: `image_picker`로 알림장 캡처 이미지를 받고, `google_mlkit_text_recognition`(한국어) 등으로 텍스트를 뽑아 `NoticeParser.parse()`에 넘깁니다. 좌표 기반으로 줄을 합칠 때는 `NoticeParser`의 구분 규칙(번호/불릿)을 그대로 쓰면 됩니다.
- **LLM 보정**: 규칙 파서 결과를 그대로 쓰되, 분류가 애매한 항목만(예: 단서 없는 문장) 서버의 LLM에 제목·종류·날짜 후보를 물어 보정합니다. 초안은 항상 미리보기에서 사용자가 확인하므로 안전합니다.
- **이미지 → 항목 JSON**: 서버에서 OCR + LLM으로 `[{kind,title,subject,date,start,end,details}]` JSON을 만들면 `NoticeDraftItem`으로 바로 매핑할 수 있습니다.
- **하이클래스 공식 제휴/API**: 공식 경로가 열리면 `notice_import_service.dart`의 입력부만 API 응답으로 바꾸면 되고, 저장 로직은 그대로 재사용합니다.
