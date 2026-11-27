// Manajemen sesi pengguna aktif untuk validasi kepemilikan laporan (Issue #10)
class AuthSession {
  static const String defaultUserId = 'user_pradita_01';
  static const String defaultUserName = 'Mahasiswa Pradita';

  static String currentUserId = defaultUserId;
  static String currentUserName = defaultUserName;
  static bool isAdmin = false;

  static void login({
    required String userId,
    required String userName,
    bool admin = false,
  }) {
    currentUserId = userId;
    currentUserName = userName;
    isAdmin = admin;
  }

  static void resetToDefault() {
    currentUserId = defaultUserId;
    currentUserName = defaultUserName;
    isAdmin = false;
  }
}
