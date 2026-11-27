import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../reports/presentation/pages/report_list_page.dart';
import '../../domain/auth_session.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    AppLogger.info('Auth', 'Memulai proses autentikasi');
    setState(() => _isAuthenticating = true);

    if (kIsWeb) {
      if (mounted) {
        setState(() => _isAuthenticating = false);
        AuthSession.login(
          userId: AuthSession.defaultUserId,
          userName: 'Mahasiswa Pradita (Web)',
        );
        _onLoginSuccess('Login Berhasil (Sesi Mahasiswa Web)!');
      }
      return;
    }

    try {
      final authenticated = await _performBiometricAuth();
      if (!mounted) return;

      setState(() => _isAuthenticating = false);
      if (authenticated) {
        AuthSession.login(
          userId: AuthSession.defaultUserId,
          userName: AuthSession.defaultUserName,
        );
        _onLoginSuccess('Login Berhasil!');
      } else {
        AppLogger.warn('Auth', 'Autentikasi dibatalkan atau gagal oleh pengguna');
        showAppSnackBar(context, 'Autentikasi dibatalkan atau gagal.');
      }
    } on PlatformException catch (e, stackTrace) {
      AppLogger.error(
        'Auth',
        'PlatformException saat autentikasi: ${e.code} - ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _isAuthenticating = false);
      showAppSnackBar(context, 'Error: ${e.message ?? 'Gagal autentikasi'}');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Auth',
        'Terjadi kesalahan saat autentikasi',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _isAuthenticating = false);
      showAppSnackBar(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<bool> _performBiometricAuth() async {
    final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final canAuthenticate =
        canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

    if (!canAuthenticate) {
      throw Exception('Perangkat ini tidak mendukung fitur biometrik.');
    }

    return _auth.authenticate(
      localizedReason:
          'Pindai sidik jari atau wajah Anda untuk masuk ke Pradita Find',
    );
  }

  void _onLoginSuccess(String message) {
    AppLogger.info('Auth', 'Autentikasi berhasil: $message');
    showAppSnackBar(context, message);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ReportListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Menampilkan logo resmi PraFind (Pradita Find) dari aset lokal
              // dengan fallback ikon keamanan apabila aset gagal dimuat
              Image.asset(
                'assets/images/logo_prafind.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.security, size: 100, color: Colors.blue),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pradita Find',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Silakan login untuk melanjutkan'),
              const SizedBox(height: 32),
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton.icon(
      onPressed: _isAuthenticating ? null : _authenticate,
      icon: _isAuthenticating
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.fingerprint),
      label: const Text('Login dengan Biometrik'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }
}
