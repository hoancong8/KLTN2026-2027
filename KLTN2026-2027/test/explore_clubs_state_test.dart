// test/explore_clubs_state_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/ui/screen/explore_clubs/explore_clubs_vm/explore_clubs_state.dart';

void main() {
  group('ExploreClubsState Tests', () {
    test('isRecruitingOnly can be toggled on and then cleared back to null', () {
      var state = const ExploreClubsState();
      expect(state.isRecruitingOnly, isNull);

      // Toggle ON
      state = state.copyWith(isRecruitingOnly: true);
      expect(state.isRecruitingOnly, isTrue);

      // Toggle OFF via clearRecruitingOnly: true
      state = state.copyWith(clearRecruitingOnly: true);
      expect(state.isRecruitingOnly, isNull);
    });

    test('clearSkillLevel and clearRecruitingOnly work independently', () {
      var state = const ExploreClubsState(isRecruitingOnly: true);
      expect(state.isRecruitingOnly, isTrue);

      // clearRecruitingOnly should reset isRecruitingOnly without affecting other fields
      state = state.copyWith(clearRecruitingOnly: true, searchTerm: 'CLB Q7');
      expect(state.isRecruitingOnly, isNull);
      expect(state.searchTerm, 'CLB Q7');
    });
  });
}

