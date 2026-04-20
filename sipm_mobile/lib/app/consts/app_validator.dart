class AppValidator {
  String? validateEmptyText(String? value, String errorMessage) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }
    return null;
  }

  String? validateEmail(
    String? value, {
    required String requiredMsg,
    String? invaliMsg,
  }) {
    if (value == null || value.isEmpty) {
      return requiredMsg;
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return invaliMsg;
    }
    return null;
  }

  String? validatePassword(
    String? value, {
    required String requiredMsg,
    required String minLengthMsg,
    // required String noNumberMsg,
    // required String noSpecialCharMsg,
  }) {
    if (value == null || value.isEmpty) {
      return requiredMsg;
    }
    if (value.length < 4) {
      return minLengthMsg;
    }
    // if (!value.contains(RegExp(r'[A-Z]'))) {
    //   return noNumberMsg;
    // }
    // if (!value.contains(RegExp(r'[[!@#$%^&*(),.?":{}|<>]]'))) {
    //   return noSpecialCharMsg;
    // }
    return null;
  }

  String? validatePhoneNumber(
    String? value, {
    required String requiredPhone,
    required String invalPhone,
  }) {
    if (value == null || value.isEmpty) {
      return requiredPhone;
    }
    final phoneRegExp = RegExp(r'^\d{10}$');
    if (!phoneRegExp.hasMatch(value)) {
      return invalPhone;
    }
    return null;
  }
}
