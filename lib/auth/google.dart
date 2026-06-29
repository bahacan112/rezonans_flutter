import 'package:google_sign_in/google_sign_in.dart';

/// Web (server) client ID — same one the backend verifies the ID token against.
const _webClientId =
    '518484091286-d5v1ecqtaveem727duvl85s94orn3j1o.apps.googleusercontent.com';

bool _initialized = false;

/// Runs the native Google sign-in and returns an ID token (or null if cancelled).
Future<String?> googleSignInIdToken() async {
  final gsi = GoogleSignIn.instance;
  if (!_initialized) {
    await gsi.initialize(serverClientId: _webClientId);
    _initialized = true;
  }
  try {
    final account = await gsi.authenticate();
    return account.authentication.idToken;
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled) return null;
    rethrow;
  }
}
