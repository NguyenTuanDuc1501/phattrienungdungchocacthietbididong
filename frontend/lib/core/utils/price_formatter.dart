/// Formats a double price into a display string.
class PriceFormatter {
  PriceFormatter._();

  static String format(double price) {
    if (price == price.roundToDouble()) {
      return '${price.toInt()}\$';
    }
    return '${price.toStringAsFixed(2)}\$';
  }
}
