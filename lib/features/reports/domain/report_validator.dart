// Validator input form untuk mencegah input kosong atau hanya karakter spasi (Issue #5 & #11)
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
    if (value.trim().length < 3) {
      return 'Lokasi kejadian minimal 3 karakter';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Deskripsi wajib diisi';
    }
    if (value.trim().length < 5) {
      return 'Deskripsi minimal 5 karakter';
    }
    return null;
  }

  static String? validateReporterName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama pelapor wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Nama pelapor minimal 2 karakter';
    }
    return null;
  }

  static String? validateContact(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kontak pelapor wajib diisi';
    }
    final trimmed = value.trim();
    final digitsOnly = trimmed.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    final isPhone = RegExp(r'^\d{9,15}$').hasMatch(digitsOnly);
    final isEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
    final isInstagram = RegExp(r'^@[A-Za-z0-9._]{2,30}$').hasMatch(trimmed);

    if (!isPhone && !isEmail && !isInstagram) {
      return 'Masukkan nomor WhatsApp, email, atau @instagram yang valid';
    }
    return null;
  }
}
