/// 앱이 Supabase 서버에 붙어 있는지, 서버 없이 도는 데모 모드인지 판단한다.
///
/// 값은 빌드할 때 `--dart-define`으로 넣는다.
/// - `SUPABASE_URL`, `SUPABASE_ANON_KEY`: 실제 서버에 붙을 때
/// - `DEMO_MODE=true`: 서버 설정이 있어도 샘플 데이터 데모로 띄울 때
library;

const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

/// 데모 모드를 강제로 켜는 스위치.
const bool demoModeFlag = bool.fromEnvironment('DEMO_MODE');

/// 서버 주소와 키가 모두 있으면 true.
bool get backendReady => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

/// 서버 없이 샘플 데이터로 바로 체험하는 모드.
///
/// Supabase 설정이 비어 있는 웹 빌드(또는 `DEMO_MODE=true` 빌드)에서 켜진다.
bool get demoMode => demoModeFlag || !backendReady;
