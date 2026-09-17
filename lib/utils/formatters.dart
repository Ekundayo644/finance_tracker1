import 'package:intl/intl.dart';

final NumberFormat currencyFormat = NumberFormat.currency(
  symbol: '₦',
  decimalDigits: 2,
);

final DateFormat dateFormat = DateFormat('MMM d, y');
final DateFormat monthFormat = DateFormat('MMMM y');

String formatCurrency(double amount) => currencyFormat.format(amount);
String formatDate(DateTime date) => dateFormat.format(date);