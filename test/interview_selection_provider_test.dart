import 'package:chatgptmini/data/providers/interview_selection_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('InterviewSelectionNotifier toggle/replace/clear', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final InterviewSelectionNotifier notifier =
        container.read(interviewSelectionProvider.notifier);
    expect(container.read(interviewSelectionProvider), isEmpty);

    notifier.toggle('exp_1');
    expect(container.read(interviewSelectionProvider), {'exp_1'});
    notifier.toggle('exp_1');
    expect(container.read(interviewSelectionProvider), isEmpty);

    notifier.replaceWith(['a', 'b']);
    expect(container.read(interviewSelectionProvider), {'a', 'b'});
    expect(notifier.asList, containsAll(['a', 'b']));

    notifier.clear();
    expect(container.read(interviewSelectionProvider), isEmpty);
  });
}
