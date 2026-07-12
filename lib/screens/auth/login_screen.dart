import 'package:flutter/material.dart';
import 'package:pet_app/controllers/user_controller.dart';
import 'package:pet_app/models/user_model.dart';
import 'package:pet_app/screens/auth/signup_screen.dart';
import 'package:pet_app/screens/components/logo.dart';
import 'package:pet_app/design/design.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _userController = UserController();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    await _userController.loginUser(
      Users(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
      context,
    );
    // Em caso de sucesso, o RoteadorTelas (authStateChanges) navega sozinho.
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.surfaceGrouped,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Logo(),
                const SizedBox(height: AppSpacing.xxxl),
                Text('Entrar',
                    style: AppTypography.largeTitle
                        .copyWith(color: c.textPrimary)),
                const SizedBox(height: AppSpacing.xs),
                Text('Bem-vindo(a) de volta. Preencha seus dados.',
                    style:
                        AppTypography.callout.copyWith(color: c.textSecondary)),
                const SizedBox(height: AppSpacing.xxl),
                AppTextField(
                  controller: _emailController,
                  label: 'E-mail',
                  hint: 'voce@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe seu e-mail'
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _passwordController,
                  label: 'Senha',
                  hint: '••••••',
                  obscureText: _obscure,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 20,
                      color: c.textTertiary,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Informe sua senha' : null,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: 'Entrar',
                  loading: _loading,
                  onPressed: _loading ? null : _login,
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Não tem uma conta? ',
                          style: AppTypography.callout
                              .copyWith(color: c.textSecondary)),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignUpPage()),
                        ),
                        child: Text('Criar',
                            style: AppTypography.callout.copyWith(
                                color: c.accentBlue,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
