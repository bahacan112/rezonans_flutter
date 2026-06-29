import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/client.dart';

enum AuthStatus { loading, signedOut, signedIn }

class AuthProvider extends ChangeNotifier {
  static const _tokenKey = 'auth_token';

  AuthStatus status = AuthStatus.loading;
  AuthUser? user;
  String? token;

  AuthProvider() {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_tokenKey);
    if (saved == null) {
      _set(AuthStatus.signedOut);
      return;
    }
    try {
      user = await api.me(saved);
      token = saved;
      _set(AuthStatus.signedIn);
    } catch (_) {
      await prefs.remove(_tokenKey);
      _set(AuthStatus.signedOut);
    }
  }

  void _set(AuthStatus s) {
    status = s;
    notifyListeners();
  }

  Future<void> _persist(AuthResponse r) async {
    token = r.token;
    user = r.user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, r.token);
    _set(AuthStatus.signedIn);
  }

  Future<void> signIn(String email, String password) async =>
      _persist(await api.login(email.trim(), password));

  Future<void> signUp(String email, String password, [String? name]) async =>
      _persist(await api.register(email.trim(), password, name?.trim()));

  Future<void> signInWithGoogle(String idToken) async =>
      _persist(await api.google(idToken));

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    token = null;
    user = null;
    _set(AuthStatus.signedOut);
  }

  Future<void> upgradePremium() async {
    if (token == null) return;
    user = await api.upgradePremium(token!);
    notifyListeners();
  }

  Future<void> refresh() async {
    if (token == null) return;
    try {
      user = await api.me(token!);
      notifyListeners();
    } catch (_) {
      await signOut();
    }
  }
}
