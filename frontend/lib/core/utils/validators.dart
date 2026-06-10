/// Email / password validators.
class Validators {
  Validators._();

  static bool isValidEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());
  }

  static bool isValidPassword(String value) => value.length >= 6;

  static bool isValidName(String value) => value.trim().length >= 2;
}
