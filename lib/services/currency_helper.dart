import 'package:intl/intl.dart';

class CurrencyHelper {
  static final _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(double price) {
    return _formatter.format(price);
  }
}
