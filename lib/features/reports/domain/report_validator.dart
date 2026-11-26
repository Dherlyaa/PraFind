class ReportValidator {
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama barang tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Nama barang minimal 3 karakter';
    }
    return null;
  }

  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Lokasi kejadian wajib diisi';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Deskripsi wajib diisi';
    }
    return null;
  }
}