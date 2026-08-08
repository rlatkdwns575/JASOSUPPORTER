import 'package:chatgptmini/data/providers/attachment_session_provider.dart';
import 'package:chatgptmini/data/services/attachment_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AttachmentSessionNotifier add/remove/clear', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final AttachmentSessionNotifier notifier =
        container.read(attachmentSessionProvider.notifier);
    expect(container.read(attachmentSessionProvider), isEmpty);

    notifier.addAll([
      PickedAttachment(name: 'a.pdf', bytes: Uint8List.fromList(const [1, 2])),
    ]);
    expect(container.read(attachmentSessionProvider), hasLength(1));

    notifier.removeAt(0);
    expect(container.read(attachmentSessionProvider), isEmpty);

    notifier.addAll([
      PickedAttachment(name: 'b.png', bytes: Uint8List.fromList(const [3])),
    ]);
    notifier.clear();
    expect(container.read(attachmentSessionProvider), isEmpty);
  });
}
