class RegularExpressions {
  static final RegExp nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
  static final RegExp numberRegExp = RegExp(r'\d');
  static final RegExp phoneRegExp = RegExp(r'^01\d{8,9}$');
  static final RegExp emailRegExp = RegExp(r"^[a-zA-Z\d.a-zA-Z\d.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z\d]+\.[a-zA-Z]+");
}