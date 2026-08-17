import 'package:chatgptmini/data/providers/career_providers.dart';
import 'package:chatgptmini/data/providers/chat_session_provider.dart';
import 'package:chatgptmini/data/providers/gemini_models_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 로그인·로그아웃 후 API 클라이언트·경력 데이터·채팅 세션을 새로 불러온다.
void refreshUserSessionData(Ref ref) {
  ref.invalidate(apiClientProvider);
  ref.invalidate(experiencesProvider);
  ref.invalidate(specItemsProvider);
  ref.invalidate(portfolioProjectsProvider);
  ref.invalidate(applicationRecordsProvider);
  ref.invalidate(interviewAnswersProvider);
  ref.invalidate(essayVersionCountsProvider);
  ref.invalidate(geminiModelsCatalogProvider);
  ref.invalidate(chatSessionProvider);
}
