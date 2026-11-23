// lib/domain/utils/gender_helper.dart

class GenderHelper {
  static bool isFemale({int? explicitGender, String? genderString, String? fullName}) {
    if (explicitGender == 2) return true;
    if (genderString != null && genderString.isNotEmpty) {
      final g = genderString.toUpperCase();
      if (g == 'FEMALE' || g == 'NU' || g == 'NỮ' || g == '2') return true;
    }
    if (fullName != null && fullName.isNotEmpty) {
      final lower = fullName.toLowerCase();
      final words = lower.split(RegExp(r'\s+'));
      if (words.contains('thị') || words.contains('thi') || words.contains('nu') || words.contains('nữ')) {
        return true;
      }
    }
    if (explicitGender == 1) return false;
    if (genderString != null && genderString.isNotEmpty) {
      final g = genderString.toUpperCase();
      if (g == 'MALE' || g == 'NAM' || g == '1') return false;
    }
    return false;
  }
}
