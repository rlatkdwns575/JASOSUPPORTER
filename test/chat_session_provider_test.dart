import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:chatgptmini/data/providers/chat_session_provider.dart';
import 'package:chatgptmini/domain/models/chat_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ChatSessionNotifier tracks messages and generating flag', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final ChatSessionNotifier notifier = container.read(chatSessionProvider.notifier);
    expect(container.read(chatSessionProvider).isGenerating, isFalse);

    notifier.addUserAndStart(
      AssistantMode.experienceSpec,
      ChatMessage(isMe: true, text: '안녕', sentAt: DateTime(2026, 7, 29)),
    );
    expect(container.read(chatSessionProvider).isGenerating, isTrue);
    expect(
      container.read(chatSessionProvider).roomFor(AssistantMode.experienceSpec).chats.single.text,
      '안녕',
    );

    final int index = notifier.addAssistantPlaceholder(AssistantMode.experienceSpec);
    notifier.appendAssistantChunk(AssistantMode.experienceSpec, index, '답');
    notifier.appendAssistantChunk(AssistantMode.experienceSpec, index, '변');
    expect(
      container.read(chatSessionProvider).roomFor(AssistantMode.experienceSpec).chats[index].text,
      '답변',
    );

    notifier.finishGenerating(AssistantMode.experienceSpec);
    expect(container.read(chatSessionProvider).isGenerating, isFalse);
  });
}
