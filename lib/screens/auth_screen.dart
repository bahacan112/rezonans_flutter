import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/client.dart';
import '../auth/auth_provider.dart';
import '../auth/google.dart';
import '../theme.dart';
import '../widgets/starfield.dart';

enum _Flow { auth, forgot, reset }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _Flow flow = _Flow.auth;
  bool isLogin = true;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  final _newPassword = TextEditingController();

  bool busy = false;
  bool googleBusy = false;
  String? error;
  String? notice;
  String? devCode;

  Future<void> _onGoogle() async {
    _clearMsgs();
    setState(() => googleBusy = true);
    try {
      final idToken = await googleSignInIdToken();
      if (idToken == null) return; // cancelled
      if (!mounted) return;
      await context.read<AuthProvider>().signInWithGoogle(idToken);
    } catch (e) {
      setState(() => error = e is ApiException ? e.message : 'Google girişi başarısız: $e');
    } finally {
      if (mounted) setState(() => googleBusy = false);
    }
  }

  void _clearMsgs() => setState(() {
        error = null;
        notice = null;
      });

  Future<void> _run(Future<void> Function() fn) async {
    _clearMsgs();
    setState(() => busy = true);
    try {
      await fn();
    } catch (e) {
      setState(() => error = e is ApiException ? e.message : 'Beklenmeyen bir hata oluştu.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _submitAuth() => _run(() async {
        final auth = context.read<AuthProvider>();
        if (_email.text.trim().isEmpty || _password.text.isEmpty) {
          throw ApiException(0, 'E-posta ve şifre gerekli.');
        }
        if (_password.text.length < 8) throw ApiException(0, 'Şifre en az 8 karakter olmalı.');
        if (isLogin) {
          await auth.signIn(_email.text, _password.text);
        } else {
          await auth.signUp(_email.text, _password.text, _name.text);
        }
      });

  void _submitForgot() => _run(() async {
        if (_email.text.trim().isEmpty) throw ApiException(0, 'E-posta gerekli.');
        final res = await api.forgotPassword(_email.text.trim());
        final code = res?['devCode'] as String?;
        setState(() {
          devCode = code;
          _code.text = code ?? '';
          notice = code != null
              ? 'Geliştirme modu: kodunuz aşağıda hazır. Yeni şifrenizi belirleyin.'
              : 'Eğer bu e-posta kayıtlıysa, sıfırlama kodu gönderildi.';
          flow = _Flow.reset;
        });
      });

  void _submitReset() => _run(() async {
        if (_code.text.trim().length != 6) throw ApiException(0, '6 haneli kodu girin.');
        if (_newPassword.text.length < 8) throw ApiException(0, 'Yeni şifre en az 8 karakter olmalı.');
        await api.resetPassword(_email.text.trim(), _code.text.trim(), _newPassword.text);
        setState(() {
          flow = _Flow.auth;
          isLogin = true;
          _password.clear();
          _newPassword.clear();
          _code.clear();
          devCode = null;
          notice = 'Şifreniz güncellendi. Yeni şifrenizle giriş yapabilirsiniz.';
        });
      });

  @override
  Widget build(BuildContext context) {
    final subtitle = flow == _Flow.auth
        ? "Kozmik Portal'a Giriş"
        : flow == _Flow.forgot
            ? 'Şifre Sıfırlama'
            : 'Yeni Şifre Belirle';

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: Starfield(glowColor: KpColors.portal)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              child: Column(
                children: [
                  _logo(),
                  const SizedBox(height: 16),
                  Text('SCHUMANN REZONANSI',
                      style: AppText.sans(
                          size: 18,
                          weight: FontWeight.w800,
                          color: AppColors.primaryGold,
                          letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppText.sans(size: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 28),
                  _card(),
                  const SizedBox(height: 20),
                  Text('Devam ederek kozmik enerji akışını takip etmeyi kabul edersiniz.',
                      textAlign: TextAlign.center,
                      style: AppText.sans(size: 10, color: Colors.white24, height: 1.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logo() => Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.primaryGold.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryGold, width: 1.5),
        ),
        child: ClipOval(child: Image.asset('assets/icon.jpg', fit: BoxFit.cover)),
      );

  Widget _card() => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (notice != null) ...[
              Text(notice!, style: AppText.sans(size: 12, color: KpColors.quiet, height: 1.4)),
              const SizedBox(height: 14),
            ],
            if (flow == _Flow.auth) ..._authBody(),
            if (flow == _Flow.forgot) ..._forgotBody(),
            if (flow == _Flow.reset) ..._resetBody(),
          ],
        ),
      );

  List<Widget> _authBody() => [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(children: [
            _tab('Giriş Yap', isLogin, () => setState(() => isLogin = true)),
            _tab('Kayıt Ol', !isLogin, () => setState(() => isLogin = false)),
          ]),
        ),
        const SizedBox(height: 20),
        if (!isLogin) _field('İsim (opsiyonel)', _name, hint: 'Adınız'),
        _field('E-posta', _email, hint: 'ornek@eposta.com', keyboard: TextInputType.emailAddress),
        _field('Şifre', _password, hint: 'En az 8 karakter', obscure: true),
        if (isLogin)
          GestureDetector(
            onTap: () => setState(() {
              _clearMsgs();
              flow = _Flow.forgot;
            }),
            child: Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 4),
              child: Text('Şifremi unuttum?',
                  style: AppText.sans(size: 12, weight: FontWeight.w600, color: AppColors.primaryGold)),
            ),
          ),
        if (error != null) _errorText(),
        const SizedBox(height: 8),
        _primaryBtn(isLogin ? 'Giriş Yap' : 'Hesap Oluştur', _submitAuth),
        _divider(),
        _googleBtn(),
      ];

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(children: [
          Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('veya', style: AppText.sans(size: 11, color: AppColors.textMuted)),
          ),
          Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
        ]),
      );

  Widget _googleBtn() => SizedBox(
        height: 50,
        child: OutlinedButton(
          onPressed: googleBusy ? null : _onGoogle,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: googleBusy
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('G', style: AppText.sans(size: 16, weight: FontWeight.w900, color: const Color(0xFF4285F4))),
                  const SizedBox(width: 10),
                  Text('Google ile devam et', style: AppText.sans(size: 14, weight: FontWeight.w600)),
                ]),
        ),
      );

  List<Widget> _forgotBody() => [
        Text('Hesabınızın e-postasını girin; size 6 haneli bir sıfırlama kodu göndereceğiz.',
            style: AppText.sans(size: 12, color: AppColors.textMuted, height: 1.4)),
        const SizedBox(height: 16),
        _field('E-posta', _email, hint: 'ornek@eposta.com', keyboard: TextInputType.emailAddress),
        if (error != null) _errorText(),
        _primaryBtn('Sıfırlama Kodu Gönder', _submitForgot),
        _backLink(),
      ];

  List<Widget> _resetBody() => [
        if (devCode != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KpColors.portal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KpColors.portal.withValues(alpha: 0.3)),
            ),
            child: Column(children: [
              Text('GELİŞTİRME MODU — KODUNUZ',
                  style: AppText.sans(size: 9, weight: FontWeight.w700, color: KpColors.portal, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(devCode!, style: AppText.mono(size: 26, weight: FontWeight.w700, letterSpacing: 6)),
            ]),
          ),
        _field('Sıfırlama Kodu (6 hane)', _code, hint: '000000', keyboard: TextInputType.number),
        _field('Yeni Şifre', _newPassword, hint: 'En az 8 karakter', obscure: true),
        if (error != null) _errorText(),
        _primaryBtn('Şifreyi Güncelle', _submitReset),
        _backLink(),
      ];

  Widget _tab(String label, bool active, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: () {
            _clearMsgs();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: active ? AppColors.primaryGold.withValues(alpha: 0.15) : null,
              borderRadius: BorderRadius.circular(9),
              border: active ? Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)) : null,
            ),
            alignment: Alignment.center,
            child: Text(label,
                style: AppText.sans(
                    size: 13,
                    weight: FontWeight.w600,
                    color: active ? AppColors.primaryGold : AppColors.textMuted)),
          ),
        ),
      );

  Widget _field(String label, TextEditingController c,
          {String? hint, bool obscure = false, TextInputType? keyboard}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppText.sans(size: 11, weight: FontWeight.w500, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            obscureText: obscure,
            keyboardType: keyboard,
            style: AppText.sans(size: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppText.sans(size: 14, color: Colors.white24),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryGold),
              ),
            ),
          ),
        ]),
      );

  Widget _errorText() => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: Text(error!, style: AppText.sans(size: 12, weight: FontWeight.w500, color: KpColors.storm)),
      );

  Widget _primaryBtn(String label, VoidCallback onTap) => SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: busy ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGold,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: busy
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
              : Text(label, style: AppText.sans(size: 14, weight: FontWeight.w800, color: Colors.black)),
        ),
      );

  Widget _backLink() => Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Center(
          child: GestureDetector(
            onTap: () => setState(() {
              _clearMsgs();
              flow = _Flow.auth;
            }),
            child: Text('← Girişe dön',
                style: AppText.sans(size: 12, weight: FontWeight.w600, color: AppColors.primaryGold)),
          ),
        ),
      );
}
