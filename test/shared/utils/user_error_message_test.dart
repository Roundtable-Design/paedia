import 'package:flutter_test/flutter_test.dart';
import 'package:paedia/shared/utils/user_error_message.dart';

void main() {
  test('userFriendlyError maps network failures', () {
    expect(
      userFriendlyError(Exception('SocketException: connection refused')),
      contains('internet connection'),
    );
  });

  test('userFriendlyError provides generic fallback', () {
    expect(
      userFriendlyError(Exception('unknown xyz')),
      'Something went wrong. Please try again.',
    );
  });
}
