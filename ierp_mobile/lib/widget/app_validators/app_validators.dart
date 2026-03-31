class AppValidators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  // Phone validation (Vietnam)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final phoneRegex = RegExp(r'^(0|\+84)[0-9]{9}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  // Password validation
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < minLength) {
      return 'Mật khẩu phải có ít nhất $minLength ký tự';
    }
    return null;
  }

  // Required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập ${fieldName ?? "thông tin"}';
    }
    return null;
  }

  // Min length
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập ${fieldName ?? "thông tin"}';
    }
    if (value.length < min) {
      return '${fieldName ?? "Thông tin"} phải có ít nhất $min ký tự';
    }
    return null;
  }

  // Max length
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return '${fieldName ?? "Thông tin"} không được vượt quá $max ký tự';
    }
    return null;
  }

  // Number only
  static String? numberOnly(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Chỉ được nhập số';
    }
    return null;
  }

  // Price validation
  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập giá';
    }
    final priceValue = double.tryParse(value.replaceAll(',', ''));
    if (priceValue == null || priceValue <= 0) {
      return 'Giá không hợp lệ';
    }
    return null;
  }

  // Combine multiple validators
  static String? Function(String?) combine(
      List<String? Function(String?)> validators,
      ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}