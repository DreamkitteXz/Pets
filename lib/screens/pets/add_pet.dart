import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pet_app/controllers/id_controller.dart';
import 'package:pet_app/controllers/pets/pet_controller.dart';
import 'package:pet_app/design/design.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/utils/breed_utils.dart';
import 'package:pet_app/utils/gender_utils.dart';
import 'package:pet_app/utils/species_utils.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _colorController = TextEditingController();
  final _chipController = TextEditingController();
  final _breedController = TextEditingController();

  String? _species; // 'Cachorro' | 'Gato'
  String? _gender; // 'Macho' | 'Fêmea'
  bool _isNeutered = false;
  DateTime? _birthDate;
  bool _saving = false;

  List<String> _dogBreeds = const [];
  List<String> _catBreeds = const [];

  @override
  void initState() {
    super.initState();
    _prefetchBreeds();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    _chipController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  Future<void> _prefetchBreeds() async {
    try {
      final dogs = await BreedUtils.fetchDogBreeds();
      final cats = await BreedUtils.fetchCatBreeds();
      if (!mounted) return;
      setState(() {
        _dogBreeds = dogs;
        _catBreeds = cats;
      });
    } catch (_) {
      // Sem catálogo de raças o campo segue utilizável: a busca aceita texto
      // livre e a raça é só um rótulo.
    }
  }

  List<String> get _breedOptions {
    if (_species == 'Cachorro') return _dogBreeds;
    if (_species == 'Gato') return _catBreeds;
    return const [];
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AppScaffold(
      title: 'Novo pet',
      subtitle: 'Preencha os dados para abrir a carteira dele',
      showBack: true,
      bodyPadding: false,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxxl),
          children: [
            AppCard(
              child: Column(
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: 'Nome',
                    hint: 'Como você chama seu pet',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe o nome do pet'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _Labeled(
                    label: 'Espécie',
                    child: DropdownButtonFormField<String>(
                      initialValue: _species,
                      hint: const Text('Selecione'),
                      items: const [
                        DropdownMenuItem(
                            value: 'Cachorro', child: Text('Cachorro')),
                        DropdownMenuItem(value: 'Gato', child: Text('Gato')),
                      ],
                      onChanged: (value) => setState(() {
                        _species = value;
                        // Raças mudam com a espécie: limpa a seleção anterior.
                        _breedController.clear();
                      }),
                      validator: (v) => v == null ? 'Selecione a espécie' : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _Labeled(
                    label: 'Raça',
                    child: DropdownSearch<String>(
                      key: ValueKey(_species),
                      items: _breedOptions,
                      enabled: _species != null,
                      selectedItem: _breedController.text.isNotEmpty
                          ? _breedController.text
                          : null,
                      onChanged: (value) => _breedController.text = value ?? '',
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: _species == null
                              ? 'Escolha a espécie primeiro'
                              : 'Selecione a raça',
                        ),
                      ),
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration:
                              InputDecoration(hintText: 'Buscar raça...'),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Selecione a raça'
                          : null,
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _colorController,
                    label: 'Cor',
                    hint: 'Ex.: caramelo',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe a cor do pet'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                children: [
                  _Labeled(
                    label: 'Sexo',
                    child: DropdownButtonFormField<String>(
                      initialValue: _gender,
                      hint: const Text('Selecione'),
                      items: const [
                        DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                        DropdownMenuItem(value: 'Fêmea', child: Text('Fêmea')),
                      ],
                      onChanged: (value) => setState(() => _gender = value),
                      validator: (v) => v == null ? 'Selecione o sexo' : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _Labeled(
                    label: 'Data de nascimento',
                    child: InkWell(
                      borderRadius: AppRadius.button_,
                      onTap: _pickBirthDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _birthDate == null
                                    ? 'Selecione a data'
                                    : DateFormat('dd/MM/yyyy')
                                        .format(_birthDate!),
                                style: AppTypography.callout.copyWith(
                                  color: _birthDate == null
                                      ? c.textTertiary
                                      : c.textPrimary,
                                ),
                              ),
                            ),
                            Icon(Icons.calendar_today_rounded,
                                size: 18, color: c.textTertiary),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Antes era um dropdown Inteiro/Castrado cujo texto nunca
                  // batia com a checagem `== 'true'` — isNeutered gravava
                  // sempre false. Um switch elimina a conversão.
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Castrado',
                                style: AppTypography.callout
                                    .copyWith(color: c.textPrimary)),
                            const SizedBox(height: 2),
                            Text('Marque se o pet já foi castrado',
                                style: AppTypography.footnote
                                    .copyWith(color: c.textSecondary)),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isNeutered,
                        onChanged: (v) => setState(() => _isNeutered = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Divider(height: 1, thickness: 1, color: c.separator),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _chipController,
                    label: 'Microchip (opcional)',
                    hint: 'Número do chip, se houver',
                    keyboardType: TextInputType.text,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Adicionar pet',
              icon: Icons.pets_rounded,
              loading: _saving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 1, now.month, now.day),
      firstDate: DateTime(now.year - 40),
      lastDate: now,
      helpText: 'Data de nascimento',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_birthDate == null) {
      _toast('Informe a data de nascimento.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _toast('Sessão expirada. Entre novamente.');
      return;
    }

    setState(() => _saving = true);
    try {
      final pet = Pets(
        id: gerarPetsID(),
        name: _nameController.text.trim(),
        species: SpeciesUtils.toFirestore(_species!),
        breed: _breedController.text.trim(),
        gender: GenderUtils.toFirestore(_gender!),
        color: _colorController.text.trim(),
        birthDate: _birthDate,
        isNeutered: _isNeutered,
        chipNumber: _chipController.text.trim(),
        ownerId: user.uid,
        ownerName: user.displayName ?? '',
        status: 'active',
        veterinarians: const [],
      );

      await PetController().createPet(pet);
      if (!mounted) return;
      Navigator.pop(context);
      _toast('${pet.name} foi adicionado.');
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      _toast('Não foi possível adicionar o pet: $e');
    }
  }
}

/// Rótulo acima do campo, no mesmo ritmo do [AppTextField].
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
