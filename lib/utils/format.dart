import 'package:intl/intl.dart';

class Format {
  // ==========================
  // FORMAT RUPIAH
  // ==========================
  static String rupiah(int value) {
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return f.format(value);
  }

  // ==========================
  // FORMAT TANGGAL AMAN
  // Contoh: 12 Jan 2024
  // ==========================
  static String tanggal(dynamic iso) {
    if (iso == null) return '-';

    try {
      final DateTime? dt =
          DateTime.tryParse(iso.toString());

      if (dt == null) return '-';

      return DateFormat('dd MMM yyyy', 'id_ID')
          .format(dt);
    } catch (_) {
      return '-';
    }
  }

  // ==========================
  // FORMAT BULAN & TAHUN
  // Contoh: Januari 2024
  // ==========================
  static String bulanTahun(dynamic iso) {
    if (iso == null) return '-';

    try {
      final DateTime? dt =
          DateTime.tryParse(iso.toString());

      if (dt == null) return '-';

      return DateFormat('MMMM yyyy', 'id_ID')
          .format(dt);
    } catch (_) {
      return '-';
    }
  }

  // ==========================
  // FORMAT TANGGAL + JAM
  // Contoh: 12 Jan 2024 • 14:32
  // ==========================
  static String tanggalJam(dynamic iso) {
    if (iso == null) return '-';

    try {
      final DateTime? dt =
          DateTime.tryParse(iso.toString());

      if (dt == null) return '-';

      return DateFormat(
        'dd MMM yyyy • HH:mm',
        'id_ID',
      ).format(dt);
    } catch (_) {
      return '-';
    }
  }
}
