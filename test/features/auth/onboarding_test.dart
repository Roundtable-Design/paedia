import 'package:flutter_test/flutter_test.dart';
import 'package:paedia/data/models/user_profile.dart';
import 'package:paedia/features/auth/onboarding_screen.dart';

void main() {
  test('userNeedsOnboarding when gender or start date missing', () {
    expect(userNeedsOnboarding(null), isTrue);
    expect(
      userNeedsOnboarding(
        const UserProfile(uid: '1', email: 'a@b.com', displayName: 'A'),
      ),
      isTrue,
    );
    expect(
      userNeedsOnboarding(
        const UserProfile(
          uid: '1',
          email: 'a@b.com',
          displayName: 'A',
          gender: 'male',
          startDate: null,
        ),
      ),
      isTrue,
    );
    expect(
      userNeedsOnboarding(
        UserProfile(
          uid: '1',
          email: 'a@b.com',
          displayName: 'A',
          gender: 'male',
          startDate: DateTime(2026, 1, 1),
        ),
      ),
      isFalse,
    );
  });
}
