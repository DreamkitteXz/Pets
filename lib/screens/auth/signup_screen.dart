import 'package:flutter/material.dart';
import 'package:pet_app/controllers/user_controller.dart';
import 'package:pet_app/models/user_model.dart';
import 'package:pet_app/design/design.dart';
import 'package:pet_app/utils/cep_utils.dart';
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
  final _cityController = TextEditingController();
  final _cepController = TextEditingController();
  final _addressInfoController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _emergencyRelationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _userController = UserController();

  bool _obscure = true;
  bool _loading = false;

  /// UF escolhida na lista. Era campo livre: 'MG', 'Minas' e 'minas gerais'
  /// viravam tres estados diferentes para o mesmo lugar.
  String? _uf;

  /// Consulta de CEP em andamento — evita disparar duas de uma vez e mostra
  /// ao usuario que algo esta acontecendo.
  bool _buscandoCep = false;

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
      _cityController,
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

  /// Busca o endereço assim que o CEP fica completo.
  ///
  /// Dispara no `onChanged` e não num botão: o formatter já aplica a máscara,
  /// então o momento em que os 8 dígitos existem é conhecido e pedir um toque
  /// extra para algo automático seria trabalho à toa.
  Future<void> _onCepChanged(String valor) async {
    if (!CepUtils.estaCompleto(valor) || _buscandoCep) return;

    setState(() => _buscandoCep = true);
    final endereco = await CepUtils.buscar(valor);
    if (!mounted) return;

    setState(() {
      _buscandoCep = false;
      // CEP inexistente ou rede fora: não mexe em nada. O usuário digita à
      // mão e o cadastro segue — preencher com vazio apagaria o que ele já
      // tivesse escrito e pareceria que a busca "funcionou".
      if (endereco == null) return;

      _streetController.text = endereco.street;
      _neighbourhoodController.text = endereco.neighborhood;
      _cityController.text = endereco.city;
      if (CepUtils.ufs.contains(endereco.state)) _uf = endereco.state;
    });
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
        state: _uf ?? '',
        city: _cityController.text.trim(),
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
              validator: (v) =>
                  (v == null || v.length < 14) ? 'CPF inválido' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _phoneController,
              label: 'Telefone',
              keyboardType: TextInputType.phone,
              inputFormatters: [InputFormatters.phoneFormatter],
              validator: (v) =>
                  (v == null || v.length < 15) ? 'Telefone inválido' : null,
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
            // CEP ABRE a seção, ao contrário da ordem em que os campos eram
            // lidos antes. É ele que preenche rua, bairro, cidade e estado —
            // deixá-lo por último obrigaria a digitar tudo à mão e só depois
            // ver o formulário se sobrescrever.
            AppTextField(
              controller: _cepController,
              label: 'CEP',
              hint: 'Preenche o endereço automaticamente',
              keyboardType: TextInputType.number,
              inputFormatters: [InputFormatters.cepFormatter],
              suffix: _buscandoCep
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : null,
              onChanged: _onCepChanged,
              validator: (v) =>
                  (v == null || v.length < 9) ? 'CEP inválido' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(controller: _streetController, label: 'Rua'),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
                controller: _numberController,
                label: 'Número',
                keyboardType: TextInputType.number),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(controller: _neighbourhoodController, label: 'Bairro'),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(controller: _cityController, label: 'Cidade'),
            const SizedBox(height: AppSpacing.lg),
            _Labeled(
              label: 'Estado',
              child: DropdownButtonFormField<String>(
                initialValue: _uf,
                hint: const Text('UF'),
                items: CepUtils.ufs
                    .map((uf) => DropdownMenuItem(value: uf, child: Text(uf)))
                    .toList(),
                onChanged: (v) => setState(() => _uf = v),
                validator: (v) => v == null ? 'Selecione o estado' : null,
              ),
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
              validator: (v) =>
                  (v == null || v.length < 15) ? 'Telefone inválido' : null,
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

/// Rótulo acima do campo, no mesmo ritmo do [AppTextField].
///
/// O dropdown de UF não é um AppTextField, então não herda o rótulo dele.
class _Labeled extends StatelessWidget {
  final String label;
  final Widget child;
  const _Labeled({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.subhead
                .copyWith(color: context.colors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}
