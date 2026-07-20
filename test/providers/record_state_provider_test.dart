import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noteai/features/record/providers/record_state.dart';
import 'package:noteai/features/record/providers/record_state_provider.dart';

void main() {
  test('RecordStateNotifier initial state should be Idle', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(recordStateProvider);
    
    expect(state, isA<Idle>());
  });
}
