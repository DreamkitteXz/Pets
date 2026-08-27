import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:pet_app/design/design.dart';
import 'package:pet_app/models/medication_model.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/repositories/medication_repository.dart';
import 'package:pet_app/screens/deworming/pet_dewormings_screen.dart';
import 'package:pet_app/screens/medications/pet_medications_screen.dart';
import 'package:pet_app/screens/pets/weight/pet_weight_tracker.dart';
import 'package:pet_app/screens/vaccines/pets_vaccines_screen.dart';
import 'package:pet_app/services/pet_assets_service.dart';
import 'package:pet_app/utils/firestore_date.dart';
import 'package:pet_app/utils/gender_utils.dart';
import 'package:pet_app/utils/image_upload_utils.dart';
import 'package:pet_app/utils/species_utils.dart';

/// Hub do pet: capa, identidade, atalhos de cuidado (com contagem real de
/// registros e pendências), próximos vencimentos e ficha detalhada.
class PetInformation extends StatefulWidget {
  final Pets pet;

  const PetInformation({super.key, required this.pet});

  @override
  State<PetInformation> createState() => _PetInformationState();
}

class _PetInformationState extends State<PetInformation> {
  Pets get pet => widget.pet;

  /// Upload/remoção de foto em andamento — trava o botão da capa e mostra o
  /// spinner no lugar do ícone.
  bool _uploadingPhoto = false;

  /// Etapa atual do envio, exibida sobre a capa. Existe porque o console do
  /// Flutter nem sempre está à mão (log do dispositivo filtrado, build sem
  /// debugger): sem isso, uma falha de upload vira spinner mudo.
  String? _photoStatus;

  void _setPhotoStatus(String? status) {
    if (status != null) debugPrint('[foto do pet] $status');
    if (mounted) setState(() => _photoStatus = status);
  }

  // O filtro por ownerId é o que torna a consulta aceitável para a rule:
  // `vaccines`/`deworming` liberam leitura com `isVet() || isOwner()`, e o
  // Firestore valida rules de query contra a QUERY. Só com `petId` a consulta
  // inteira é recusada (PERMISSION_DENIED). Duas igualdades não pedem índice
  // composto.
  late final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _vaccinesStream =
      FirebaseFirestore.instance
          .collection('vaccines')
          .where('ownerId', isEqualTo: _uid)
          .where('petId', isEqualTo: pet.id)
          .snapshots();

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _dewormingStream =
      FirebaseFirestore.instance
          .collection('deworming')
          .where('ownerId', isEqualTo: _uid)
          .where('petId', isEqualTo: pet.id)
          .snapshots();

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.surfaceGrouped,
      body: CustomScrollView(
        slivers: [
          _buildCover(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxxl),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildIdentityCard(context),
                const SizedBox(height: AppSpacing.xxl),
                _CareSection(
                  pet: pet,
                  vaccinesStream: _vaccinesStream,
                  dewormingStream: _dewormingStream,
                  // O tracker pode alterar o peso informado pelo tutor; ao
                  // voltar, o card de stats precisa refletir o novo valor.
                  onReturn: () {
                    if (mounted) setState(() {});
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                _UpcomingSection(
                  vaccinesStream: _vaccinesStream,
                  dewormingStream: _dewormingStream,
                ),
                const SizedBox(height: AppSpacing.xxl),
                _buildDetailsSection(context),
                if (_hasHealthNotes) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  _buildHealthSection(context),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- capa

  Widget _buildCover(BuildContext context) {
    final c = context.colors;
    final hasPhoto = pet.imageUrl != null && pet.imageUrl!.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      stretch: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: c.surfaceGrouped,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 56 + AppSpacing.sm,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.sm),
        child: _CircleAction(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
      ),
      actions: [
        _CircleAction(
          icon: Icons.photo_camera_rounded,
          busy: _uploadingPhoto,
          onTap: _onChangePhoto,
        ),
        const SizedBox(width: AppSpacing.sm),
        _CircleAction(
          icon: Icons.edit_rounded,
          onTap: () => _toast('Edição do pet estará disponível em breve.'),
        ),
        const SizedBox(width: AppSpacing.lg),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            hasPhoto
                ? Image.network(
                    pet.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackImage(),
                  )
                : _fallbackImage(),
            // Véu superior: garante contraste dos botões circulares sobre
            // fotos claras.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45],
                ),
              ),
            ),
            // Estado do envio NA TELA. O mesmo texto vai para o console, mas
            // aqui não depende de conseguir ler o log do Flutter.
            if (_photoStatus != null)
              Align(
                alignment: Alignment.center,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: AppRadius.card_,
                  ),
                  child: Text(
                    _photoStatus!,
                    textAlign: TextAlign.center,
                    style: AppTypography.footnote
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            // Fade para o fundo agrupado: a capa "derrete" no conteúdo.
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 96,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        c.surfaceGrouped.withValues(alpha: 0.0),
                        c.surfaceGrouped,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackImage() => Image.asset(
        PetAssetsService.getImagePath(pet.species, pet.breed, pet.gender),
        fit: BoxFit.cover,
      );

  // ----------------------------------------------------------- identidade

  Widget _buildIdentityCard(BuildContext context) {
    final c = context.colors;
    final isMale = pet.gender?.toLowerCase() == 'male';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pet.name ?? 'Sem nome',
            style: AppTypography.largeTitle.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            pet.breed ?? 'Raça não informada',
            style: AppTypography.callout.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _Tag(
                label: GenderUtils.toDisplay(pet.gender ?? 'Desconhecido'),
                icon: isMale ? Icons.male_rounded : Icons.female_rounded,
                color: isMale ? c.accentBlue : c.accentPink,
              ),
              _Tag(
                label: pet.isNeutered ?? false ? 'Castrado' : 'Não castrado',
                icon: pet.isNeutered ?? false
                    ? Icons.check_circle_rounded
                    : Icons.remove_circle_outline_rounded,
                color: pet.isNeutered ?? false ? c.accentTeal : c.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(height: 1, thickness: 1, color: c.separator),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  icon: Icons.cake_rounded,
                  value: pet.birthDate != null
                      ? _formatAge(pet.birthDate!)
                      : '—',
                  label: 'Idade',
                ),
              ),
              _statDivider(c),
              Expanded(
                child: _Stat(
                  icon: Icons.monitor_weight_rounded,
                  value: pet.weightValue == null
                      ? '—'
                      : '${pet.weightValue!.toStringAsFixed(1)
                          .replaceAll('.', ',')} kg',
                  label: 'Peso',
                ),
              ),
              _statDivider(c),
              Expanded(
                child: _Stat(
                  icon: Icons.pets_rounded,
                  value: SpeciesUtils.toDisplay(pet.species ?? 'Desconhecido'),
                  label: 'Espécie',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statDivider(AppColors c) => Container(
        width: 1,
        height: 36,
        color: c.separator,
      );

  // -------------------------------------------------------------- ficha

  Widget _buildDetailsSection(BuildContext context) {
    return AppListSection(
      header: 'Ficha',
      children: [
        _detail('Cor', pet.color, Icons.palette_rounded),
        _detail('Raça', pet.breed, Icons.pets_rounded),
        _detail(
          'Espécie',
          SpeciesUtils.toDisplay(pet.species ?? 'Desconhecido'),
          Icons.category_rounded,
        ),
        _detail(
          'Sexo',
          GenderUtils.toDisplay(pet.gender ?? 'Desconhecido'),
          Icons.wc_rounded,
        ),
        _detail(
          'Castrado',
          pet.isNeutered ?? false ? 'Sim' : 'Não',
          Icons.medical_information_rounded,
        ),
        _detail('Microchip', pet.chipNumber, Icons.memory_rounded),
        _detail(
          'Nascimento',
          pet.birthDate != null
              ? DateFormat('dd/MM/yyyy').format(pet.birthDate!)
              : null,
          Icons.event_rounded,
        ),
      ],
    );
  }

  Widget _detail(String label, String? value, IconData icon) {
    return _DetailRow(
      label: label,
      value: (value == null || value.isEmpty) ? 'Não informado' : value,
      icon: icon,
      empty: value == null || value.isEmpty,
    );
  }

  bool get _hasHealthNotes =>
      (pet.medicalNotes != null && pet.medicalNotes!.isNotEmpty) ||
      (pet.chronicConditions != null && pet.chronicConditions!.isNotEmpty) ||
      (pet.allergies != null && pet.allergies!.isNotEmpty);

  Widget _buildHealthSection(BuildContext context) {
    final c = context.colors;
    final blocks = <Widget>[];

    void add(String title, String body) {
      if (blocks.isNotEmpty) {
        blocks.add(const SizedBox(height: AppSpacing.md));
      }
      blocks.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTypography.subhead.copyWith(color: c.textSecondary)),
          const SizedBox(height: 2),
          Text(body,
              style: AppTypography.callout.copyWith(color: c.textPrimary)),
        ],
      ));
    }

    if (pet.allergies != null && pet.allergies!.isNotEmpty) {
      add('Alergias', pet.allergies!.join(', '));
    }
    if (pet.chronicConditions != null && pet.chronicConditions!.isNotEmpty) {
      add('Condições crônicas', pet.chronicConditions!);
    }
    if (pet.medicalNotes != null && pet.medicalNotes!.isNotEmpty) {
      add('Observações do veterinário', pet.medicalNotes!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Saúde'),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: blocks,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------- foto

  void _onChangePhoto() {
    if (_uploadingPhoto) return;
    final hasPhoto = pet.imageUrl != null && pet.imageUrl!.isNotEmpty;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.sm),
              AppListTile(
                leadingIcon: Icons.photo_camera_rounded,
                title: 'Tirar foto',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickAndUpload(ImageSource.camera);
                },
              ),
              AppListTile(
                leadingIcon: Icons.photo_library_rounded,
                title: 'Escolher da galeria',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickAndUpload(ImageSource.gallery);
                },
              ),
              if (hasPhoto)
                AppListTile(
                  leadingIcon: Icons.delete_outline_rounded,
                  leadingColor: context.colors.accentRed,
                  title: 'Remover foto',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _removePhoto();
                  },
                ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    // Redimensiona e recomprime no dispositivo: a rule do Storage recusa acima
    // de 5 MB, e foto de celular passa disso com folga. 1600px cobre a capa em
    // qualquer tela.
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;
    await _uploadPetImage(picked);
  }

  Future<void> _uploadPetImage(XFile pickedFile) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _toast('Sessão expirada — entre novamente para enviar a foto.');
      return;
    }

    setState(() => _uploadingPhoto = true);
    final previousUrl = pet.imageUrl;

    try {
      final file = File(pickedFile.path);
      final extension = ImageUploadUtils.extensionOf(pickedFile.name);

      // Path DENTRO da pasta do usuário: a rule exige
      // `pet-photos/{uid}/...` com uid == request.auth.uid.
      final storageRef = FirebaseStorage.instance.ref().child(
          'pet-photos/$uid/${pet.id}_${DateTime.now().millisecondsSinceEpoch}'
          '.$extension');

      final bytes = await file.length();
      _setPhotoStatus('Enviando ${(bytes / 1024).round()} KB\n'
          '${storageRef.fullPath}\n'
          'bucket: ${FirebaseStorage.instance.bucket}');

      // contentType explícito: a rule exige `image/*`, e o putFile nem sempre
      // infere o tipo pelo arquivo (vem como application/octet-stream e o
      // upload é recusado).
      final task = storageRef.putFile(
        file,
        SettableMetadata(
            contentType: ImageUploadUtils.contentTypeFor(extension)),
      );

      // Progresso: separa "travou sem sair do lugar" (rede/rule) de "está
      // subindo devagar". Sem isto, os dois casos parecem o mesmo spinner.
      final progressSub = task.snapshotEvents.listen((snapshot) {
        final total = snapshot.totalBytes;
        final pct = total > 0
            ? ((snapshot.bytesTransferred / total) * 100).round()
            : 0;
        _setPhotoStatus('${snapshot.state.name} · $pct%\n'
            '${snapshot.bytesTransferred}/$total bytes');
      }, onError: (Object e) => _setPhotoStatus('Erro na task: $e'));

      try {
        // Rede de segurança: se nem o retry encurtado devolver, o usuário
        // recebe uma mensagem em vez de spinner infinito.
        await task.timeout(
          const Duration(seconds: 90),
          onTimeout: () {
            task.cancel();
            throw TimeoutException(
                'O envio passou de 90s sem concluir.');
          },
        );
      } finally {
        await progressSub.cancel();
      }

      _setPhotoStatus('Upload concluído — obtendo URL...');
      final downloadUrl = await storageRef
          .getDownloadURL()
          .timeout(const Duration(seconds: 30));

      _setPhotoStatus('Gravando no Firestore...');
      await FirebaseFirestore.instance
          .collection('pets')
          .doc(pet.id)
          .update({
        'imageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 30));
      debugPrint('[foto do pet] pronto');

      if (!mounted) return;
      setState(() {
        pet.imageUrl = downloadUrl;
        _uploadingPhoto = false;
        _photoStatus = null;
      });
      _toast('Foto atualizada.');

      // Só depois do novo estar gravado: apagar antes deixaria o pet sem foto
      // se o upload falhasse no meio.
      await _deleteStoredPhoto(previousUrl);
    } catch (e, stack) {
      if (mounted) {
        setState(() {
          _uploadingPhoto = false;
          _photoStatus = null;
        });
      }
      _reportPhotoError('enviar', e, stack);
    }
  }

  Future<void> _removePhoto() async {
    final previousUrl = pet.imageUrl;
    setState(() => _uploadingPhoto = true);
    try {
      await FirebaseFirestore.instance
          .collection('pets')
          .doc(pet.id)
          .update({
        'imageUrl': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      setState(() {
        pet.imageUrl = null;
        _uploadingPhoto = false;
      });
      _toast('Foto removida.');
      await _deleteStoredPhoto(previousUrl);
    } catch (e, stack) {
      if (mounted) setState(() => _uploadingPhoto = false);
      _reportPhotoError('remover', e, stack);
    }
  }

  /// Traduz a falha para algo acionável e joga o detalhe cru no console.
  ///
  /// O `$e` direto num SnackBar de uma linha corta justamente o código do
  /// erro, que é a única parte que diz o que fazer.
  void _reportPhotoError(String action, Object error, StackTrace stack) {
    debugPrint('[foto do pet] falha ao $action: $error');
    debugPrintStack(stackTrace: stack, label: 'foto do pet');

    String message;
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unauthorized':
          message = 'Sem permissão no Storage. As regras de '
              '`pet-photos/` precisam ser publicadas '
              '(firebase deploy --only storage).';
          break;
        case 'unauthenticated':
          message = 'Sessão expirada. Entre novamente e tente de novo.';
          break;
        case 'retry-limit-exceeded':
          message = 'A conexão caiu durante o envio. Tente de novo.';
          break;
        case 'quota-exceeded':
          message = 'A cota do Storage do projeto foi excedida.';
          break;
        case 'object-not-found':
          message = 'Arquivo não encontrado no Storage.';
          break;
        default:
          message = 'Falha no Storage (${error.code}): '
              '${error.message ?? 'sem detalhe'}';
      }
    } else if (error is TimeoutException) {
      message = 'O envio não respondeu a tempo. Verifique a conexão e veja '
          'o console: as linhas "[foto do pet]" mostram onde parou.';
    } else {
      message = 'Não foi possível $action a foto: $error';
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 8),
      action: SnackBarAction(
        label: 'Copiar',
        onPressed: () =>
            Clipboard.setData(ClipboardData(text: '$error')),
      ),
    ));
  }

  /// Apaga o arquivo antigo do Storage para não acumular órfão a cada troca.
  /// Falha aqui é silenciosa de propósito: o pet já está com a foto certa, e
  /// URL de outra origem (ou já apagada) não é erro que interesse ao tutor.
  Future<void> _deleteStoredPhoto(String? url) async {
    if (url == null || url.isEmpty) return;
    if (!url.contains('/pet-photos%2F') && !url.contains('/pet-photos/')) {
      return; // não é arquivo nosso — não mexe
    }
    try {
      await FirebaseStorage.instance.refFromURL(url).delete();
    } catch (_) {
      // ignora: arquivo já removido, URL malformada ou sem permissão.
    }
  }

  String _formatAge(DateTime birthDate) {
    final today = DateTime.now();
    int years = today.year - birthDate.year;
    int months = today.month - birthDate.month;
    int days = today.day - birthDate.day;

    if (days < 0) {
      months--;
      days += DateTime(today.year, today.month, 0).day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    if (years > 0) return years == 1 ? '1 ano' : '$years anos';
    if (months > 0) return months == 1 ? '1 mês' : '$months meses';
    return days == 1 ? '1 dia' : '$days dias';
  }
}

// ====================================================================
// Cuidados — atalhos com contagem real de registros e pendências.
// ====================================================================

class _CareSection extends StatelessWidget {
  final Pets pet;
  final Stream<QuerySnapshot<Map<String, dynamic>>> vaccinesStream;
  final Stream<QuerySnapshot<Map<String, dynamic>>> dewormingStream;
  final VoidCallback onReturn;

  const _CareSection({
    required this.pet,
    required this.vaccinesStream,
    required this.dewormingStream,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Cuidados'),
        const SizedBox(height: AppSpacing.sm),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _CountedCareCard(
                  stream: vaccinesStream,
                  icon: Icons.vaccines_rounded,
                  color: c.accentBlue,
                  title: 'Vacinas',
                  singular: 'vacina',
                  plural: 'vacinas',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => PetsVaccinesScreen(pet: pet),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _CountedCareCard(
                  stream: dewormingStream,
                  icon: Icons.medication_rounded,
                  color: c.accentOrange,
                  title: 'Vermífugos',
                  singular: 'registro',
                  plural: 'registros',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => VermifugosPage(pet: pet),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _CareCard(
                  icon: Icons.monitor_weight_rounded,
                  color: c.accentPurple,
                  title: 'Peso',
                  subtitle: 'Histórico e curva',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => PetWeightTrackingPage(pet: pet),
                      ),
                    );
                    onReturn();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _MedicationsCareCard(
                  pet: pet,
                  color: c.accentTeal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => MedicamentosPage(pet: pet),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Medicamentos vivem num array do doc do pet (ver [MedicationRepository]),
/// não numa coleção — por isso não dá para reusar o [_CountedCareCard], que
/// conta documentos de um QuerySnapshot. O destaque aqui também é outro: não
/// há "pendente de validação", e sim quantos estão em uso hoje.
class _MedicationsCareCard extends StatelessWidget {
  final Pets pet;
  final Color color;
  final VoidCallback onTap;

  const _MedicationsCareCard({
    required this.pet,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Medicamento>>(
      stream: MedicationRepository().medicationsStream(pet.id),
      builder: (context, snapshot) {
        final medications = snapshot.data;
        String subtitle;
        int ongoing = 0;

        if (medications == null) {
          subtitle = '—';
        } else {
          ongoing = medications
              .where((m) => m.stage == MedicationStage.ongoing)
              .length;
          subtitle = medications.isEmpty
              ? 'Nenhum registro'
              : '${medications.length} '
                  '${medications.length == 1 ? 'medicamento' : 'medicamentos'}';
        }

        return _CareCard(
          icon: Icons.medication_liquid_rounded,
          color: color,
          title: 'Medicamentos',
          subtitle: subtitle,
          badge: ongoing > 0 ? '$ongoing em uso' : null,
          badgeColor: color,
          badgeIcon: Icons.play_circle_fill_rounded,
          onTap: onTap,
        );
      },
    );
  }
}

/// Card de cuidado que assina uma coleção e mostra total + pendências.
class _CountedCareCard extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final IconData icon;
  final Color color;
  final String title;
  final String singular;
  final String plural;
  final VoidCallback onTap;

  const _CountedCareCard({
    required this.stream,
    required this.icon,
    required this.color,
    required this.title,
    required this.singular,
    required this.plural,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs;
        String subtitle;
        int pending = 0;

        if (docs == null) {
          subtitle = '—';
        } else {
          pending = docs
              .where((d) =>
                  appStatusFromString(d.data()['status'] as String?) ==
                  AppStatus.pending)
              .length;
          subtitle = docs.isEmpty
              ? 'Nenhum registro'
              : '${docs.length} ${docs.length == 1 ? singular : plural}';
        }

        return _CareCard(
          icon: icon,
          color: color,
          title: title,
          subtitle: subtitle,
          badge: pending > 0 ? '$pending pendente${pending > 1 ? 's' : ''}' : null,
          onTap: onTap,
        );
      },
    );
  }
}

class _CareCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? badge;

  /// Cor e ícone do badge. Sem valor, ficam no laranja de "pendente" — que é
  /// o sentido do badge nos cards de vacina/vermífugo.
  final Color? badgeColor;
  final IconData? badgeIcon;
  final VoidCallback onTap;

  const _CareCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.badgeColor,
    this.badgeIcon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final badgeTint = badgeColor ?? c.statusPending;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c.tint(color, 0.12),
                  borderRadius:
                      const BorderRadius.all(Radius.circular(AppRadius.md)),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: c.textTertiary, size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title,
              style: AppTypography.headline.copyWith(color: c.textPrimary)),
          const SizedBox(height: 2),
          Text(subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.footnote.copyWith(color: c.textSecondary)),
          if (badge != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm,
                  vertical: 3),
              decoration: BoxDecoration(
                color: c.tint(badgeTint, 0.12),
                borderRadius: AppRadius.pill_,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badgeIcon ?? Icons.schedule_rounded,
                      size: 12, color: badgeTint),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(badge!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                            color: badgeTint,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ====================================================================
// Próximos cuidados — vencimentos reais das coleções (sem dado fabricado).
// ====================================================================

class _DueItem {
  final String title;
  final DateTime date;
  final IconData icon;
  final bool isVaccine;
  _DueItem(this.title, this.date, this.icon, this.isVaccine);
}

class _UpcomingSection extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> vaccinesStream;
  final Stream<QuerySnapshot<Map<String, dynamic>>> dewormingStream;

  const _UpcomingSection({
    required this.vaccinesStream,
    required this.dewormingStream,
  });

  static DateTime? _readDate(Map<String, dynamic> data, String field) =>
      readFirestoreDate(data[field]);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: vaccinesStream,
      builder: (context, vaccinesSnapshot) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: dewormingStream,
          builder: (context, dewormingSnapshot) {
            if (!vaccinesSnapshot.hasData || !dewormingSnapshot.hasData) {
              return const SizedBox.shrink();
            }

            final now = DateTime.now();
            final items = <_DueItem>[];

            for (final doc in vaccinesSnapshot.data!.docs) {
              final data = doc.data();
              final due = _readDate(data, 'nextDueDate');
              if (due == null || due.isBefore(now)) continue;
              items.add(_DueItem(
                (data['name'] as String?) ?? 'Vacina',
                due,
                Icons.vaccines_rounded,
                true,
              ));
            }
            for (final doc in dewormingSnapshot.data!.docs) {
              final data = doc.data();
              final due = _readDate(data, 'nextDueDate') ??
                  _readDate(data, 'reinforcementDate');
              if (due == null || due.isBefore(now)) continue;
              items.add(_DueItem(
                (data['name'] as String?) ?? 'Vermífugo',
                due,
                Icons.medication_rounded,
                false,
              ));
            }

            items.sort((a, b) => a.date.compareTo(b.date));
            final visible = items.take(4).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(title: 'Próximos cuidados'),
                const SizedBox(height: AppSpacing.sm),
                if (visible.isEmpty)
                  AppCard(
                    child: Row(
                      children: [
                        Icon(Icons.event_available_rounded,
                            size: 20, color: c.textTertiary),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Nenhum vencimento agendado para este pet.',
                            style: AppTypography.callout
                                .copyWith(color: c.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < visible.length; i++) ...[
                          if (i > 0)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: AppSpacing.lg),
                              child: Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: c.separator),
                            ),
                          _DueRow(item: visible[i], now: now),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _DueRow extends StatelessWidget {
  final _DueItem item;
  final DateTime now;
  const _DueRow({required this.item, required this.now});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final days = item.date.difference(now).inDays;
    final urgent = days <= 7;
    final accent = urgent ? c.statusPending : c.accentGreen;
    final tone = item.isVaccine ? c.accentBlue : c.accentOrange;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: c.tint(tone, 0.12),
              borderRadius: const BorderRadius.all(Radius.circular(AppRadius.sm)),
            ),
            child: Icon(item.icon, size: 18, color: tone),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        AppTypography.callout.copyWith(color: c.textPrimary)),
                const SizedBox(height: 2),
                Text(DateFormat('dd/MM/yyyy').format(item.date),
                    style: AppTypography.footnote
                        .copyWith(color: c.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 3),
            decoration: BoxDecoration(
              color: c.tint(accent, 0.12),
              borderRadius: AppRadius.pill_,
            ),
            child: Text(
              days == 0 ? 'hoje' : (days == 1 ? 'em 1 dia' : 'em $days dias'),
              style: AppTypography.caption
                  .copyWith(color: accent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// Peças pequenas
// ====================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.caption
            .copyWith(color: context.colors.textTertiary, letterSpacing: 0.5),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  /// Troca o ícone por um spinner e desabilita o toque (upload em curso).
  final bool busy;

  const _CircleAction({
    required this.icon,
    required this.onTap,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Material(
        color: c.surfaceGroupedSecondary.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: busy ? null : onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: busy
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: c.accentBlue),
                  )
                : Icon(icon, size: 17, color: c.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _Tag({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: c.tint(color, 0.12),
        borderRadius: AppRadius.pill_,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: AppTypography.caption
                  .copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        Icon(icon, size: 18, color: c.textTertiary),
        const SizedBox(height: AppSpacing.sm),
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.subhead.copyWith(color: c.textPrimary)),
        const SizedBox(height: 1),
        Text(label,
            style: AppTypography.caption.copyWith(color: c.textTertiary)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool empty;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.empty,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c.textTertiary),
          const SizedBox(width: AppSpacing.md),
          Text(label,
              style: AppTypography.callout.copyWith(color: c.textSecondary)),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.callout
                  .copyWith(color: empty ? c.textTertiary : c.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
