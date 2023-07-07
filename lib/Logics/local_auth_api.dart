import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthApi {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      debugPrint(e.message);
      return false;
    }
  }

  static Future<bool> authenticateWithBiometrics() async {
    final hasBiometrics = await LocalAuthApi.hasBiometrics();
    if (!hasBiometrics) return false;

    try {
      return await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to continue',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint(e.message);
      return false;
    }
  }
}