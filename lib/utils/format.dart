import 'package:intl/intl.dart';

class Format {
  static String currency(num value) {
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return f.format(value);
  }

  static String rupiah(num value) {
    return currency(value);
  }

  static String tanggal(String iso) {
    final dt = DateTime.parse(iso);
    return DateFormat('dd MMM yyyy').format(dt);
  }
}
