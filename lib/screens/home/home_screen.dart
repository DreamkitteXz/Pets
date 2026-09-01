import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pet_app/controllers/pets/pet_controller.dart';
import 'package:pet_app/controllers/home/home_controller.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/screens/components/pet_avatar.dart';
import 'package:pet_app/screens/home/greeting.dart';
import 'package:pet_app/services/current_user_service.dart';
import 'package:pet_app/screens/deworming/add_deworming_screen.dart';
import 'package:pet_app/screens/medications/add_medication_screen.dart';
import 'package:pet_app/screens/pets/add_pet.dart';
import 'package:pet_app/screens/notifications/notifications_screen.dart';
import 'package:pet_app/screens/pets/pet_information.dart' as pet_info;
import 'package:pet_app/screens/pets/weight/pet_weight_tracker.dart';
import 'package:pet_app/screens/vaccines/add_vaccine_screen.dart';
import 'package:pet_app/services/notifications_service.dart';
import 'package:pet_app/design/design.dart';

/// Quantos cards de ação rápida cabem na largura visível.
///
/// A fração é proposital: a meia coluna cortada na borda é o que sinaliza que
/// a lista rola. Um número inteiro faria a fileira terminar exatamente na
/// margem e pareceria completa.
const double kActionCardsPerScreen = 3.5;

/// Largura de um card de ação rápida para uma [available] disponível.
///
/// Era o literal `86`. Fixo, o card ocupava proporções diferentes conforme o
/// aparelho: apertado numa tela estreita (e "Medicamento" era cortado em
/// "Medicam…") e sobrando numa larga. Aqui ele acompanha o viewport.
///
/// O piso e o teto existem porque proporção pura degenera nos extremos: num
/// aparelho minúsculo o card viraria um selo com o ícone espremido, e num
/// tablet uma placa com muito vazio em volta do ícone de 40px.
double actionCardWidth(double available) {
  // Cada "coluna" é o card mais o respiro que o separa do próximo, então o
  // espaçamento sai da conta antes de virar largura de card.
  final slot = available / kActionCardsPerScreen;
  return (slot - AppSpacing.md).clamp(84.0, 120.0);
}

/// Aba principal (dashboard) do tutor — repaginada sobre o design system.
///
/// Não recebe mais `userData`: o nome do tutor vem do [CurrentUserService]
/// (ver [HomeGreeting]). Passar o usuário por parâmetro obrigava o main_screen
/// a montar a home antes da leitura terminar, e o fallback do caminho
/// (`?? 'Usuário'`) era o que aparecia no primeiro frame.
class HomeScreenMainTab extends StatelessWidget {
  final TabController Function(TabController) tabControllerBuilder;
  final void Function(List<Pets> pets)? onShowAllPets;

  /// Incrementado pelo main_screen ao voltar para a aba Home — reanima a
  /// saudação.
  final ValueListenable<int>? greetingReplayTrigger;

  HomeScreenMainTab({
    required this.tabControllerBuilder,
    this.onShowAllPets,
    this.greetingReplayTrigger,
    super.key,
  });

  final HomeController _controller = HomeController();
  final PetController _petController = PetController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBar(greetingReplayTrigger: greetingReplayTrigger),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl),
                _quickActions(context),
                const SizedBox(height: AppSpacing.xxl),
                _activitySection(context),
                const SizedBox(height: AppSpacing.xxl),
                _petsSection(context),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title,
      {VoidCallback? onSeeAll}) {
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.title2.copyWith(color: c.textPrimary)),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('Ver todos')),
      ],
    );
  }

  // ── Ações rápidas ──────────────────────────────────────────────────────────
  Widget _quickActions(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Ações rápidas'),
        const SizedBox(height: AppSpacing.md),
        // Sem altura fixa: `IntrinsicHeight` mede o card mais alto e
        // `stretch` iguala os outros a ele. Antes eram 92px cravados, que
        // estouravam assim que o usuário aumentava a fonte do sistema.
        //
        // Row dentro de um scroll horizontal em vez de ListView porque o
        // ListView exige altura no eixo cruzado — era ele que obrigava o
        // número mágico. São 5 itens fixos, então nada se perde sem
        // reciclagem.
        LayoutBuilder(builder: (context, constraints) {
          final w = actionCardWidth(constraints.maxWidth);
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _actionCard(context, w, 'Novo pet', Icons.pets_rounded,
                      c.accentBlue, () => _open(context, const AddPetScreen())),
                  const SizedBox(width: AppSpacing.md),
                  // Os cards abaixo precisam de um pet: pedem qual antes de
                  // abrir o cadastro. Antes todos caíam em AddPetScreen —
                  // tocar em "Vacina" abria o cadastro de PET.
                  _actionCard(
                      context,
                      w,
                      'Vacina',
                      Icons.vaccines_rounded,
                      c.accentGreen,
                      () => _openForPet(context, 'Registrar vacina',
                          (pet) => AddVacPage(petId: pet.id))),
                  const SizedBox(width: AppSpacing.md),
                  _actionCard(
                      context,
                      w,
                      'Vermífugo',
                      Icons.medication_rounded,
                      c.accentOrange,
                      () => _openForPet(context, 'Registrar vermífugo',
                          (pet) => AddVermifugoPage(petId: pet.id))),
                  const SizedBox(width: AppSpacing.md),
                  _actionCard(
                      context,
                      w,
                      'Medicamento',
                      Icons.medication_liquid_rounded,
                      c.accentTeal,
                      () => _openForPet(context, 'Registrar medicamento',
                          (pet) => AddMedicamentoPage(pet: pet))),
                  const SizedBox(width: AppSpacing.md),
                  _actionCard(
                      context,
                      w,
                      'Peso',
                      Icons.monitor_weight_rounded,
                      c.accentPink,
                      () => _openForPet(context, 'Registrar peso',
                          (pet) => PetWeightTrackingPage(pet: pet))),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _actionCard(BuildContext context, double width, String label,
      IconData icon, Color color, VoidCallback onTap) {
    final c = context.colors;
    return SizedBox(
      width: width,
      child: AppCard(
        // Respiro horizontal apertado de propósito: o card é estreito e o
        // texto é o que sofre. Com `sm` dos dois lados sobravam ~70px para
        // "Medicamento", que mede ~75px — era essa a origem do "Medicam…".
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.xs),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: c.tint(color, 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Duas linhas: "Medicamento" não cabe em uma na largura mínima,
            // e virava "Medicam…". Com o card medido por IntrinsicHeight, a
            // segunda linha empurra a fileira toda em vez de estourar.
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(color: c.textSecondary)),
          ],
        ),
      ),
    );
  }

  // ── Próximas atividades ──────────────────────────────────────────────────────
  Widget _activitySection(BuildContext context) {
    return Column(
      // `stretch`, não `start`: com `start` o Column passa restrição frouxa
      // aos filhos e o card encolhe até a largura do próprio texto. Era por
      // isso que "Nenhuma atividade futura" e "Nenhum pet cadastrado" tinham
      // larguras diferentes entre si e sobrava um vão à direita — cada um
      // media o seu texto em vez de ocupar a coluna.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(context, 'Próximas atividades'),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _controller.getUpcomingActivities(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppCard(
                  child: SizedBox(height: 72, child: AppLoading()));
            }
            final activities = snapshot.data ?? const [];
            if (activities.isEmpty) {
              return _emptyCard(
                context,
                icon: Icons.event_note_rounded,
                title: 'Nenhuma atividade futura',
                message: 'Vacinas e vermífugos a vencer aparecem aqui.',
              );
            }
            final rows = <Widget>[];
            for (var i = 0; i < activities.length; i++) {
              rows.add(_activityRow(context, activities[i]));
              if (i != activities.length - 1) {
                rows.add(Padding(
                  padding: const EdgeInsets.only(left: 68),
                  child: Divider(
                      height: 1, thickness: 1, color: context.colors.separator),
                ));
              }
            }
            return AppCard(
                padding: EdgeInsets.zero, child: Column(children: rows));
          },
        ),
      ],
    );
  }

  Widget _activityRow(BuildContext context, Map<String, dynamic> a) {
    final c = context.colors;
    final type = a['type'] as String? ?? '';
    Color color;
    IconData icon;
    if (type == 'vaccine') {
      color = c.accentGreen;
      icon = Icons.vaccines_rounded;
    } else if (type == 'deworming') {
      color = c.accentOrange;
      icon = Icons.medication_rounded;
    } else {
      color = c.accentBlue;
      icon = Icons.event_rounded;
    }
    final time = a['time'] as DateTime?;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: c.tint(color, 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a['title'] as String? ?? 'Atividade',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        AppTypography.callout.copyWith(color: c.textPrimary)),
                const SizedBox(height: 2),
                Text(time == null ? '' : _formatDateTime(time),
                    style: AppTypography.footnote
                        .copyWith(color: c.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Seus pets ──────────────────────────────────────────────────────────────
  Widget _petsSection(BuildContext context) {
    return Column(
      // Ver a nota em _activitySection: `start` fazia o card medir o texto.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(context, 'Seus pets', onSeeAll: () async {
          final pets = await _controller.getUserPets(limit: 100).first;
          if (onShowAllPets != null) onShowAllPets!(pets);
        }),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<Pets>>(
          stream: _controller.getUserPets(limit: 3),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppCard(
                  child: SizedBox(height: 72, child: AppLoading()));
            }
            final pets = snapshot.data ?? const [];
            if (pets.isEmpty) {
              return _emptyCard(
                context,
                icon: Icons.pets_rounded,
                title: 'Nenhum pet cadastrado',
                message: 'Adicione seu primeiro pet para começar.',
                actionLabel: 'Adicionar pet',
                onAction: () => _open(context, const AddPetScreen()),
              );
            }
            return Column(
              children: [
                for (final pet in pets) ...[
                  _petRow(context, pet),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _petRow(BuildContext context, Pets pet) {
    final c = context.colors;
    final age = pet.birthDate != null
        ? _petController.calculateAgeString(pet.birthDate)
        : '—';
    return AppCard(
      onTap: () => _open(context, pet_info.PetInformation(pet: pet)),
      child: Row(
        children: [
          PetAvatar(pet: pet, size: 52),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pet.name ?? 'Sem nome',
                    style:
                        AppTypography.headline.copyWith(color: c.textPrimary)),
                const SizedBox(height: 2),
                Text('${pet.breed ?? 'Raça N/D'} · $age',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.footnote
                        .copyWith(color: c.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.textTertiary, size: 22),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  Widget _emptyCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final c = context.colors;
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
                color: c.tint(c.accentBlue, 0.10), shape: BoxShape.circle),
            child: Icon(icon, color: c.accentBlue, size: 26),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title,
              textAlign: TextAlign.center,
              style: AppTypography.headline.copyWith(color: c.textPrimary)),
          const SizedBox(height: AppSpacing.xs),
          Text(message,
              textAlign: TextAlign.center,
              style: AppTypography.footnote.copyWith(color: c.textSecondary)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(
                label: actionLabel, onPressed: onAction, fullWidth: false),
          ],
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  /// Ações que só existem no contexto de um pet (vacina, vermífugo,
  /// medicamento, peso). Sem pet cadastrado, oferece o cadastro; com um só,
  /// vai direto; com vários, pergunta qual.
  Future<void> _openForPet(
    BuildContext context,
    String title,
    Widget Function(Pets pet) builder,
  ) async {
    final pets = await _controller.getUserPets(limit: 100).first;
    if (!context.mounted) return;

    if (pets.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(
        content: const Text('Cadastre um pet antes de registrar cuidados.'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Novo pet',
          onPressed: () => _open(context, const AddPetScreen()),
        ),
      ));
      return;
    }

    final pet = pets.length == 1
        ? pets.first
        : await _pickPet(context, title: title, pets: pets);
    if (pet == null || !context.mounted) return;

    _open(context, builder(pet));
  }

  Future<Pets?> _pickPet(
    BuildContext context, {
    required String title,
    required List<Pets> pets,
  }) {
    return showModalBottomSheet<Pets>(
      context: context,
      backgroundColor: context.colors.surfaceGroupedSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) {
        final c = sheetContext.colors;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs),
                child: Text(title,
                    style: AppTypography.title2.copyWith(color: c.textPrimary)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
                child: Text('Para qual pet?',
                    style: AppTypography.footnote
                        .copyWith(color: c.textSecondary)),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pets.length,
                  itemBuilder: (_, i) {
                    final pet = pets[i];
                    return AppListTile(
                      title: pet.name ?? 'Sem nome',
                      subtitle: pet.breed ?? 'Raça N/D',
                      leadingIcon: Icons.pets_rounded,
                      onTap: () => Navigator.pop(sheetContext, pet),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final hm =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return 'Hoje, $hm';
    }
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}, $hm';
  }
}

/// Header do dashboard: data + saudação + sino de notificação + avatar.
///
/// A saudação NÃO recebe mais o nome por parâmetro: ela lê o
/// [CurrentUserService] direto (ver [HomeGreeting]). O caminho antigo
/// (`username` vindo do main_screen) obrigava a home a renderizar antes do
/// dado chegar, e o `?? 'Usuário'` do meio do caminho era o que aparecia no
/// primeiro frame.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final String? profileImageUrl;

  /// Repassado à saudação para reanimar ao voltar para a aba Home.
  final ValueListenable<int>? greetingReplayTrigger;

  const CustomAppBar({
    super.key,
    this.onNotificationTap,
    this.onProfileTap,
    this.profileImageUrl,
    this.greetingReplayTrigger,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final formattedDate = DateFormat('EEE, d MMM').format(DateTime.now());
    final initial = CurrentUserService.firstNameOf(
            context.watch<CurrentUserService>().user?.name)
        ?.substring(0, 1)
        .toUpperCase();

    return Container(
      color: c.surfaceGrouped,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDate,
                    style: AppTypography.footnote
                        .copyWith(color: c.textSecondary)),
                const SizedBox(height: 2),
                HomeGreeting(replayTrigger: greetingReplayTrigger),
              ],
            ),
          ),
          // Badge real: só aparece quando há notificação não lida em
          // users/{uid}/notifications.
          StreamBuilder<int>(
            stream: NotificationsService.instance.unreadCount(),
            builder: (context, snapshot) {
              final unread = snapshot.data ?? 0;
              return IconButton(
                onPressed: onNotificationTap ??
                    () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        ),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                        unread > 0
                            ? Icons.notifications_rounded
                            : Icons.notifications_none_rounded,
                        color: c.textPrimary),
                    if (unread > 0)
                      Positioned(
                        right: -1,
                        top: -1,
                        child: Container(
                          height: 9,
                          width: 9,
                          decoration: BoxDecoration(
                            color: c.accentRed,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: c.surfaceGrouped, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: c.tint(c.accentBlue, 0.15),
              backgroundImage:
                  (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                      ? NetworkImage(profileImageUrl!)
                      : null,
              // Sem nome ainda (ou sem nome nenhum) o avatar mostra um ícone
              // neutro — melhor que uma inicial inventada.
              child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                  ? (initial == null
                      ? Icon(Icons.person_rounded,
                          size: 20, color: c.accentBlue)
                      : Text(initial,
                          style: AppTypography.headline
                              .copyWith(color: c.accentBlue)))
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(88);
}
