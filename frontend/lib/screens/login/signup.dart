import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;
  String? _error;

  SupabaseClient get _sb => Supabase.instance.client;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String _prettyError(Object e) {
    if (e is AuthException) return e.message;
    return e.toString();
  }

  Future<void> _onSignup() async {
    final username = _username.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    final confirm = _confirm.text;

    if (username.isEmpty) {
      setState(() => _error = 'Please enter a username.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Please enter a valid email.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = 'Please enter your password.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final res = await _sb.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username, // stored in user_metadata
        },
      );

      if (!mounted) return;

      // Create profile entry in profiles table
      if (res.user != null) {
        try {
          await _sb.from('profiles').insert({
            'id': res.user!.id,
            'username': username,
            'email': email,
            'onboarding_done': false,
          });
        } catch (profileError) {
          print('Error creating profile: $profileError');
          // Continue anyway - profile can be created later
        }
      }

      // If email confirmation is ON, session will often be null
      if (res.session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check your email to confirm your account.'),
          ),
        );
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        // Email confirm OFF -> signed in immediately
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } catch (e) {
      setState(() => _error = _prettyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ===== Same specs as Login =====
  static const double _frameWidth = 393;

  static const Color _titleColor = Color(0xFF363E44);
  static const Color _fieldBg = Color(0xFFEDFFFC);
  static const Color _buttonBg = Color(0xFFF05B55);


  static const TextStyle _titleStyle = TextStyle(
    color: _titleColor,
    fontFamily: 'Tilt Warp',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.28125,
  );

  static const TextStyle _body16Comfortaa = TextStyle(
    color: _titleColor,
    fontFamily: 'Comfortaa',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.33,
  );

  static const TextStyle _hintComfortaa = TextStyle(
    color: Color(0xFFB9B9B9),
    fontFamily: 'Comfortaa',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.33,
  );

  static const TextStyle _dividerComfortaa = TextStyle(
    color: _titleColor,
    fontFamily: 'Comfortaa',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.33,
  );

  static const TextStyle _buttonTextComfortaa = TextStyle(
    color: Colors.white,
    fontFamily: 'Comfortaa',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.33,
  );

  static const TextStyle _linkComfortaa = TextStyle(
    color: _buttonBg,
    fontFamily: 'Comfortaa',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  Widget _authTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) {
    return SizedBox(
      width: 346,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          color: _fieldBg,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: TextField(
          controller: controller,
          obscureText: obscure,
          style: _body16Comfortaa.copyWith(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: _hintComfortaa,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _primaryButton() {
    return SizedBox(
      width: 346,
      height: 56,
      child: ElevatedButton(
        onPressed: _loading ? null : _onSignup,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _buttonBg,
          disabledBackgroundColor: _buttonBg.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('Sign up', style: _buttonTextComfortaa),
      ),
    );
  }

  Widget _dividerRow() {
    return Row(
      children: const [
        Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('Or Sign up with', style: _dividerComfortaa),
        ),
        Expanded(child: Divider(thickness: 1)),
      ],
    );
  }

  static Widget _socialBox({required Widget child}) {
    return SizedBox(
      width: 88,
      height: 56,
      child: OutlinedButton(
        onPressed: null, // OAuth chưa làm thì disable
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: _titleColor, width: 1),
        ),
        child: Center(child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _frameWidth),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                              onPressed: () => Navigator.maybePop(context),
                              icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: _titleColor),
                            ),
                            const SizedBox(height: 18),
                            const SizedBox(
                              width: 344,
                              child: Text(
                                "Welcome to\nLandmark Lens!",
                                style: _titleStyle,
                              ),
                            ),
                            const SizedBox(height: 28),

                            _authTextField(controller: _username, hint: "Username"),
                            const SizedBox(height: 16),
                            _authTextField(controller: _email, hint: "Email"),
                            const SizedBox(height: 16),
                            _authTextField(controller: _password, hint: "Password", obscure: true),
                            const SizedBox(height: 16),
                            _authTextField(controller: _confirm, hint: "Confirm password", obscure: true),

                            if (_error != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                _error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontFamily: 'Comfortaa',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.33,
                                ),
                              ),
                            ] else
                              const SizedBox(height: 10),

                            const SizedBox(height: 10),
                            _primaryButton(),

                            const SizedBox(height: 40),
                            _dividerRow(),
                            const SizedBox(height: 18),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _socialBox(
                                  child: const Text(
                                    'f',
                                    style: TextStyle(
                                      color: _titleColor,
                                      fontFamily: 'Comfortaa',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                _socialBox(
                                  child: const Text(
                                    'G',
                                    style: TextStyle(
                                      color: _titleColor,
                                      fontFamily: 'Comfortaa',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                _socialBox(
                                  child: const Icon(Icons.apple, size: 26, color: _titleColor),
                                ),
                              ],
                            ),

                            const Spacer(),

                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Already have an account? ', style: _body16Comfortaa),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                    child: const Text('Sign In', style: _linkComfortaa),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
