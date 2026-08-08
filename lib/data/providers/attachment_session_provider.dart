import 'package:chatgptmini/data/services/attachment_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 현재 채팅 턴에 첨부된 바이너리 파일 목록.
class AttachmentSessionNotifier extends Notifier<List<PickedAttachment>> {
  @override
  List<PickedAttachment> build() => const <PickedAttachment>[];

  void addAll(List<PickedAttachment> attachments) {
    if (attachments.isEmpty) {
      return;
    }
    state = [...state, ...attachments];
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.length) {
      return;
    }
    final List<PickedAttachment> next = [...state]..removeAt(index);
    state = next;
  }

  void clear() {
    if (state.isEmpty) {
      return;
    }
    state = const <PickedAttachment>[];
  }
}

final attachmentSessionProvider =
    NotifierProvider<AttachmentSessionNotifier, List<PickedAttachment>>(
  AttachmentSessionNotifier.new,
);

final attachmentServiceProvider = Provider<AttachmentService>((Ref ref) {
  return const AttachmentService();
});
