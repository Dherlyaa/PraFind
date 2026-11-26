import 'package:flutter_test/flutter_test.dart';
import 'package:pradita_find_mobile/features/reports/domain/report_validator.dart';

void main() {
  group('ReportValidator', () {
    test('Mengembalikan error jika nama barang kosong', () {
      expect(ReportValidator.validateTitle(''), 'Nama barang tidak boleh kosong');
      expect(ReportValidator.validateTitle('   '), 'Nama barang tidak boleh kosong');
    });

    test('Mengembalikan null jika nama barang valid', () {
      expect(ReportValidator.validateTitle('KTM Mahasiswa'), isNull);
    });

    test('Mengembalikan error jika lokasi kosong', () {
      expect(ReportValidator.validateLocation(''), 'Lokasi kejadian wajib diisi');
    });

    test('Mengembalikan error jika deskripsi kosong', () {
      expect(ReportValidator.validateDescription(''), 'Deskripsi wajib diisi');
    });
  });
}