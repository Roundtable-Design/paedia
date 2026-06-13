import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paedia/shared/widgets/offline_banner.dart';

void main() {
  group('isConnectivityOffline', () {
    test('returns false when results are unknown', () {
      expect(isConnectivityOffline(null), isFalse);
    });

    test('returns false when results are empty', () {
      expect(isConnectivityOffline([]), isFalse);
    });

    test('returns false when any connection is available', () {
      expect(
        isConnectivityOffline([ConnectivityResult.wifi]),
        isFalse,
      );
      expect(
        isConnectivityOffline(
          [ConnectivityResult.none, ConnectivityResult.wifi],
        ),
        isFalse,
      );
    });

    test('returns true only when all results are none', () {
      expect(
        isConnectivityOffline([ConnectivityResult.none]),
        isTrue,
      );
    });
  });
}
