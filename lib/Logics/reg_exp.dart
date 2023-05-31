class RegularExpressions {
  static final RegExp nameRegExp = RegExp('[a-zA-Z]');
  static final RegExp numberRegExp = RegExp(r'\d');
  static final RegExp phoneRegExp = RegExp(r'^01\d{8,9}$');
}