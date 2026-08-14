import 'package:flutter/material.dart';
import 'package:pet_app/controllers/user_controller.dart';
import 'package:pet_app/models/user_model.dart';
import 'package:pet_app/design/design.dart';
import 'package:pet_app/utils/input_formatters_utils.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _streetController = TextEditingController();
  final _neighbourhoodController = TextEditingController();
  final _numberController = TextEditingController();
  final _stateController = TextEditingController();
  final _cepController = TextEditingController();
  final _addressInfoController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _emergencyRelationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _userController = UserController();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _emailController,
      _cpfController,
      _phoneController,
      _passwordController,
      _streetController,
      _neighbourhoodController,
      _numberController,
      _stateController,
      _cepController,
      _addressInfoController,
      _emergencyNameController,
      _emergencyPhoneController,
      _emergencyRelationController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _signup() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    await _userController.createUser(
      Users(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        cpf: _cpfController.text,
        phone: _phoneController.text,
        street: _streetController.text,
        neighbourhood: _neighbourhoodController.text,
        number: _numberController.text,
        state: _stateController.text,
        cep: _cepController.text,
        addressDetails: _addressInfoController.text,
        emergencyContact: {
          'name': _emergencyNameController.text,
          'phone': _emergencyPhoneController.text,
          'relationship': _emergencyRelationController.text,
        },
      ),
      context,
    );
    // Em caso de sucesso, o createUser autentica e o RoteadorTelas navega.
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Criar conta',
      subtitle: 'Preencha seus dados para começar.',
      showBack: true,
      bodyPadding: false,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxxl),
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Nome',
              prefixIcon: Icons.person_outline_rounded,
              validator: _required('Nome é obrigatório'),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _emailController,
              label: 'E-mail',
              hint: 'voce@email.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.mail_outline_rounded,
              validator: (v) {
                if (v == null || v.isEmpty) return 'E-mail é obrigatório';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                  return 'E-mail inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _cpfController,
              label: 'CPF',
              keyboardType: TextInputType.number,
              inputFormatters: [InputFormatters.cpfFormatter],
              validator: (v) => (v == null || v.length < 14)
                  ? 'CPF inválido'
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _phoneController,
              label: 'Telefone',
              keyboardType: TextInputType.phone,
              inputFormatters: [InputFormatters.phoneFormatter],
              validator: (v) => (v == null || v.length < 15)
                  ? 'Telefone inválido'
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _passwordController,
              label: 'Senha',
              hint: 'Mínimo 6 caracteres',
              obscureText: _obscure,
              prefixIcon: Icons.lock_outline_rounded,
              suffix: IconButton(
                icon: Icon(
                    _obscure
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 20,
                    color: context.colors.textTertiary),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) => (v == null || v.length < 6)
                  ? 'Senha deve ter no mínimo 6 caracteres'
                  : null,
            ),

            _sectionHeader(context, 'Endereço'),
            AppTextField(controller: _streetController, label: 'Rua'),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
                controller: _neighbourhoodController, label: 'Bairro'),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
                controller: _numberController,
                label: 'Número',
                keyboardType: TextInputType.number),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(controller: _stateController, label: 'Estado'),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _cepController,
              label: 'CEP',
              keyboardType: TextInputType.number,
              inputFormatters: [InputFormatters.cepFormatter],
              validator: (v) =>
                  (v == null || v.length < 9) ? 'CEP inválido' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
                controller: _addressInfoController, label: 'Complemento'),

            _sectionHeader(context, 'Contato de emergência'),
            AppTextField(
                controller: _emergencyNameController, label: 'Nome do contato'),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _emergencyPhoneController,
              label: 'Telefone do contato',
              keyboardType: TextInputType.phone,
              inputFormatters: [InputFormatters.phoneFormatter],
              validator: (v) => (v == null || v.length < 15)
                  ? 'Telefone inválido'
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
                controller: _emergencyRelationController,
                label: 'Relação com o contato'),

            const SizedBox(height: AppSpacing.xxl),
            AppButton(
                label: 'Criar conta',
                loading: _loading,
                onPressed: _loading ? null : _signup),
          ],
        ),
      ),
    );
  }

  String? Function(String?) _required(String msg) =>
      (v) => (v == null || v.trim().isEmpty) ? msg : null;

  Widget _sectionHeader(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs, AppSpacing.xxl, AppSpacing.xs, AppSpacing.md),
        child: Text(title,
            style: AppTypography.title2
                .copyWith(color: context.colors.textPrimary)),
      );
}
