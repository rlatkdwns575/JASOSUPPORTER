import 'package:chatgptmini/data/providers/master_essay_selection_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MasterEssayPendingSelectionNotifier queues and takes ids', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final MasterEssayPendingSelectionNotifier notifier =
        container.read(masterEssayPendingSelectionProvider.notifier);
    notifier.queue('exp-1');
    notifier.queue('exp-1');
    notifier.queueAll(const ['exp-2', '']);
    expect(container.read(masterEssayPendingSelectionProvider), ['exp-1', 'exp-2']);

    final List<String> taken = notifier.takeAll();
    expect(taken, ['exp-1', 'exp-2']);
    expect(container.read(masterEssayPendingSelectionProvider), isEmpty);
  });

  test('MasterEssaySelectionNotifier toggle/selectAll/clear per question', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final MasterEssaySelectionNotifier notifier =
        container.read(masterEssaySelectionProvider.notifier);

    notifier.toggle(0, 'exp_a');
    notifier.toggle(0, 'exp_b');
    expect(notifier.idsFor(0), containsAll(['exp_a', 'exp_b']));
    expect(notifier.idsFor(1), isEmpty);

    notifier.toggle(0, 'exp_a');
    expect(notifier.idsFor(0), ['exp_b']);

    notifier.selectAll(1, const ['x', 'y', '']);
    expect(notifier.setFor(1), {'x', 'y'});

    notifier.clearQuestion(1);
    expect(notifier.idsFor(1), isEmpty);

    notifier.addAll(0, const ['exp_c']);
    expect(notifier.idsFor(0), containsAll(['exp_b', 'exp_c']));

    notifier.replaceQuestion(0, const ['only']);
    expect(notifier.idsFor(0), ['only']);

    notifier.selectAll(2, const ['z']);
    expect(notifier.allSelectedIds, containsAll(['only', 'z']));
  });
}
