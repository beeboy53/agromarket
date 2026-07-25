import 'package:intl/intl.dart';

/// Centralised formatting so every screen displays prices and
/// dates the same way.
class AppFormatters {
  AppFormatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormat = DateFormat('d MMM, yyyy');

  static String price(double value) => _currencyFormat.format(value);

  static String date(DateTime date) => _dateFormat.format(date);
}