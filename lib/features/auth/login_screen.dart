import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/core/analytics/app_analytics.dart';
import '/flutter_flow/nav/nav.dart';
import '/features/auth/onboarding_screen.dart';
import '/index.dart';
import '/shared/widgets/loading_indicator.dart';

/// Email and social authentication entry point.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = 'Login';
  static const routePath = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const _authTabKey = 'paedia_auth_tab_index';

  late TabController _tabs;
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  final _signInEmail = TextEditingController();
  final _signInPassword = TextEditingController();
  final _signUpEmail = TextEditingController();
  final _signUpPassword = TextEditingController();
  bool _obscureSignIn = true;
  bool _obscureSignUp = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(_persistAuthTab);
    _restoreAuthTab();
  }

  Future<void> _restoreAuthTab() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_authTabKey) ?? 0;
    if (mounted && index != _tabs.index) {
      _tabs.index = index.clamp(0, 1);
    }
  }

  void _persistAuthTab() {
    if (_tabs.indexIsChanging) return;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setInt(_authTabKey, _tabs.index),
    );
  }

  @override
  void dispose() {
    _tabs.removeListener(_persistAuthTab);
    _tabs.dispose();
    _signInEmail.dispose();
    _signInPassword.dispose();
    _signUpEmail.dispose();
    _signUpPassword.dispose();
    super.dispose();
  }

  Future<void> _runAuth(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      GoRouter.of(context).prepareAuthEvent();
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _afterAuth(
      {required String method, required bool isSignUp}) async {
    if (!mounted) return;
    if (isSignUp) {
      await AppAnalytics.logSignUp(method: method);
    } else {
      await AppAnalytics.logLogin(method: method);
    }
    context.go(resolvePostLoginPath());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/Paedia_-_leaf_Sage_green.png',
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(height: 8),
                  Text('Paedia', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      height: 520,
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabs,
                            tabs: const [
                              Tab(text: 'Log In'),
                              Tab(text: 'Create Account'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabs,
                              children: [
                                _SignInForm(
                                  formKey: _signInFormKey,
                                  email: _signInEmail,
                                  password: _signInPassword,
                                  obscure: _obscureSignIn,
                                  busy: _busy,
                                  onToggleObscure: () => setState(
                                    () => _obscureSignIn = !_obscureSignIn,
                                  ),
                                  onSignIn: () {
                                    if (!_signInFormKey.currentState!
                                        .validate()) {
                                      return;
                                    }
                                    _runAuth(() async {
                                      final user =
                                          await authManager.signInWithEmail(
                                        context,
                                        _signInEmail.text.trim(),
                                        _signInPassword.text,
                                      );
                                      if (user == null) return;
                                      await _afterAuth(
                                          method: 'email', isSignUp: false);
                                    });
                                  },
                                  onGoogle: () => _runAuth(() async {
                                    final user = await authManager
                                        .signInWithGoogle(context);
                                    if (user == null) return;
                                    await _afterAuth(
                                        method: 'google', isSignUp: false);
                                  }),
                                  onApple: () => _runAuth(() async {
                                    final user = await authManager
                                        .signInWithApple(context);
                                    if (user == null) return;
                                    await _afterAuth(
                                        method: 'apple', isSignUp: false);
                                  }),
                                  onForgot: () => context.pushNamed(
                                      ForgotPasswordWidget.routeName),
                                ),
                                _SignUpForm(
                                  formKey: _signUpFormKey,
                                  email: _signUpEmail,
                                  password: _signUpPassword,
                                  obscure: _obscureSignUp,
                                  busy: _busy,
                                  onToggleObscure: () => setState(
                                    () => _obscureSignUp = !_obscureSignUp,
                                  ),
                                  onSignUp: () {
                                    if (!_signUpFormKey.currentState!
                                        .validate()) {
                                      return;
                                    }
                                    _runAuth(() async {
                                      final user = await authManager
                                          .createAccountWithEmail(
                                        context,
                                        _signUpEmail.text.trim(),
                                        _signUpPassword.text,
                                      );
                                      if (user == null) return;
                                      await _afterAuth(
                                          method: 'email', isSignUp: true);
                                    });
                                  },
                                  onGoogle: () => _runAuth(() async {
                                    final user = await authManager
                                        .signInWithGoogle(context);
                                    if (user == null) return;
                                    await _afterAuth(
                                        method: 'google', isSignUp: true);
                                  }),
                                  onApple: () => _runAuth(() async {
                                    final user = await authManager
                                        .signInWithApple(context);
                                    if (user == null) return;
                                    await _afterAuth(
                                        method: 'apple', isSignUp: true);
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email';
  if (!email.contains('@') || !email.contains('.')) {
    return 'Enter a valid email address';
  }
  return null;
}

String? _validatePassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return 'Enter your password';
  if (password.length < 6) return 'Password must be at least 6 characters';
  return null;
}

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
    required this.formKey,
    required this.email,
    required this.password,
    required this.obscure,
    required this.busy,
    required this.onToggleObscure,
    required this.onSignUp,
    required this.onGoogle,
    required this.onApple,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final bool obscure;
  final bool busy;
  final VoidCallback onToggleObscure;
  final VoidCallback onSignUp;
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: _AuthFormScroll(
        children: [
          Text(
            'Create your account. You\'ll set gender and start date on the next screen.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: _validateEmail,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: password,
            obscureText: obscure,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: _validatePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: onToggleObscure,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: busy ? null : onSignUp,
            child: busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: LoadingIndicator(size: 20),
                  )
                : const Text('Get Started'),
          ),
          const SizedBox(height: 16),
          const _OrDivider(),
          _SocialButtons(
            busy: busy,
            onGoogle: onGoogle,
            onApple: onApple,
          ),
        ],
      ),
    );
  }
}

class _SignInForm extends StatelessWidget {
  const _SignInForm({
    required this.formKey,
    required this.email,
    required this.password,
    required this.obscure,
    required this.busy,
    required this.onToggleObscure,
    required this.onSignIn,
    required this.onGoogle,
    required this.onApple,
    required this.onForgot,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final bool obscure;
  final bool busy;
  final VoidCallback onToggleObscure;
  final VoidCallback onSignIn;
  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final VoidCallback onForgot;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: _AuthFormScroll(
        children: [
          TextFormField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: _validateEmail,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: password,
            obscureText: obscure,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: _validatePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: onToggleObscure,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child:
                TextButton(onPressed: onForgot, child: const Text('Forgot?')),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: busy ? null : onSignIn,
            child: busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: LoadingIndicator(size: 20),
                  )
                : const Text('Sign In'),
          ),
          const SizedBox(height: 16),
          const _OrDivider(),
          _SocialButtons(
            busy: busy,
            onGoogle: onGoogle,
            onApple: onApple,
          ),
        ],
      ),
    );
  }
}

class _AuthFormScroll extends StatelessWidget {
  const _AuthFormScroll({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text('Or continue with', textAlign: TextAlign.center),
    );
  }
}

class _SocialButtons extends StatelessWidget {
  const _SocialButtons({
    required this.busy,
    required this.onGoogle,
    required this.onApple,
  });

  final bool busy;
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: busy ? null : onGoogle,
          icon: const FaIcon(FontAwesomeIcons.google, size: 18),
          label: const Text('Continue with Google'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: busy ? null : onApple,
          icon: const FaIcon(FontAwesomeIcons.apple, size: 18),
          label: const Text('Continue with Apple'),
        ),
      ],
    );
  }
}
