import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '/auth/firebase_auth/auth_util.dart';
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
  late TabController _tabs;
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
  }

  @override
  void dispose() {
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

  Future<void> _afterAuth() async {
    if (!mounted) return;
    context.goNamedAuth(OnboardingScreen.routeName, mounted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final cardHeight = (screenHeight - 220).clamp(420.0, 620.0);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Image.asset(
                'assets/images/Paedia_-_leaf_Sage_green.png',
                width: 50,
                height: 50,
              ),
              const SizedBox(height: 8),
              Text('Paedia', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: cardHeight,
                  child: Card(
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabs,
                          tabs: const [
                            Tab(text: 'Create Account'),
                            Tab(text: 'Log In'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabs,
                            children: [
                              _SignUpForm(
                                email: _signUpEmail,
                                password: _signUpPassword,
                                obscure: _obscureSignUp,
                                busy: _busy,
                                onToggleObscure: () => setState(
                                  () => _obscureSignUp = !_obscureSignUp,
                                ),
                                onSignUp: () => _runAuth(() async {
                                  final user =
                                      await authManager.createAccountWithEmail(
                                    context,
                                    _signUpEmail.text,
                                    _signUpPassword.text,
                                  );
                                  if (user == null) return;
                                  await _afterAuth();
                                }),
                                onGoogle: () => _runAuth(() async {
                                  final user =
                                      await authManager.signInWithGoogle(
                                          context);
                                  if (user == null) return;
                                  await _afterAuth();
                                }),
                                onApple: () => _runAuth(() async {
                                  final user =
                                      await authManager.signInWithApple(
                                          context);
                                  if (user == null) return;
                                  await _afterAuth();
                                }),
                              ),
                              _SignInForm(
                                email: _signInEmail,
                                password: _signInPassword,
                                obscure: _obscureSignIn,
                                busy: _busy,
                                onToggleObscure: () => setState(
                                  () => _obscureSignIn = !_obscureSignIn,
                                ),
                                onSignIn: () => _runAuth(() async {
                                  final user =
                                      await authManager.signInWithEmail(
                                    context,
                                    _signInEmail.text,
                                    _signInPassword.text,
                                  );
                                  if (user == null) return;
                                  await _afterAuth();
                                }),
                                onGoogle: () => _runAuth(() async {
                                  final user =
                                      await authManager.signInWithGoogle(
                                          context);
                                  if (user == null) return;
                                  await _afterAuth();
                                }),
                                onApple: () => _runAuth(() async {
                                  final user =
                                      await authManager.signInWithApple(
                                          context);
                                  if (user == null) return;
                                  await _afterAuth();
                                }),
                                onForgot: () => context
                                    .pushNamed(ForgotPasswordWidget.routeName),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
    required this.email,
    required this.password,
    required this.obscure,
    required this.busy,
    required this.onToggleObscure,
    required this.onSignUp,
    required this.onGoogle,
    required this.onApple,
  });

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
    return _AuthFormScroll(
      children: [
        Text(
          'Create your account. You\'ll set gender and start date on the next screen.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: password,
          obscureText: obscure,
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
    );
  }
}

class _SignInForm extends StatelessWidget {
  const _SignInForm({
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
    return _AuthFormScroll(
      children: [
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: password,
          obscureText: obscure,
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
          child: TextButton(onPressed: onForgot, child: const Text('Forgot?')),
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
