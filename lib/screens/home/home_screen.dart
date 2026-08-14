import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_app/controllers/pets/pet_controller.dart';
import 'package:pet_app/controllers/home/home_controller.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/models/user_model.dart';
import 'package:pet_app/screens/pets/add_pet.dart';
import 'package:pet_app/screens/notifications/notifications_screen.dart';
import 'package:pet_app/screens/pets/pet_information.dart' as pet_info;
import 'package:pet_app/services/notifications_service.dart';
import 'package:pet_app/services/pet_assets_service.dart';
import 'package:pet_app/design/design.dart';

/// Aba principal (dashboard) do tutor — repaginada sobre o design system.
/// Preserva a API pública (usada pelo main_screen): [tabControllerBuilder],
/// [onShowAllPets], [userData].
class HomeScreenMainTab extends StatelessWidget {
  final Users? userData;
  final TabController Function(TabController) tabControllerBuilder;
  final void Function(List<Pets> pets)? onShowAllPets;

  HomeScreenMainTab({
    required this.tabControllerBuilder,
    this.onShowAllPets,
    this.userData,
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
          CustomAppBar(username: userData?.name ?? 'Usuário'),
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
        SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _actionCard(context, 'Novo pet', Icons.pets_rounded, c.accentBlue,
                  () => _open(context, const AddPetScreen())),
              const SizedBox(width: AppSpacing.md),
              _actionCard(context, 'Vacina', Icons.vaccines_rounded,
                  c.accentGreen, () => _open(context, const AddPetScreen())),
              const SizedBox(width: AppSpacing.md),
              _actionCard(context, 'Vermífugo', Icons.medication_rounded,
                  c.accentOrange, () => _open(context, const AddPetScreen())),
              const SizedBox(width: AppSpacing.md),
              _actionCard(context, 'Peso', Icons.monitor_weight_rounded,
                  c.accentPink, () => _open(context, const AddPetScreen())),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionCard(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onTap) {
    final c = context.colors;
    return SizedBox(
      width: 86,
      child: AppCard(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration:
                  BoxDecoration(color: c.tint(color, 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 1,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Próximas atividades'),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _controller.getUpcomingActivities(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppCard(child: SizedBox(height: 72, child: AppLoading()));
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
            decoration:
                BoxDecoration(color: c.tint(color, 0.12), shape: BoxShape.circle),
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
                    style:
                        AppTypography.footnote.copyWith(color: c.textSecondary)),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
              return const AppCard(child: SizedBox(height: 72, child: AppLoading()));
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
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: c.surfaceSecondary,
              borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              PetAssetsService.getImagePath(pet.species, pet.breed, pet.gender),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.pets_rounded, color: c.textTertiary, size: 24),
            ),
          ),
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
                    style:
                        AppTypography.footnote.copyWith(color: c.textSecondary)),
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
/// Mantém a API antiga (usada como cabeçalho da aba Home).
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final String? profileImageUrl;

  const CustomAppBar({
    super.key,
    required this.username,
    this.onNotificationTap,
    this.onProfileTap,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final formattedDate = DateFormat('EEE, d MMM').format(DateTime.now());
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

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
                    style:
                        AppTypography.footnote.copyWith(color: c.textSecondary)),
                const SizedBox(height: 2),
                Text('Olá, $username',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.largeTitle
                        .copyWith(color: c.textPrimary)),
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
              backgroundImage: (profileImageUrl != null &&
                      profileImageUrl!.isNotEmpty)
                  ? NetworkImage(profileImageUrl!)
                  : null,
              child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                  ? Text(initial,
                      style: AppTypography.headline
                          .copyWith(color: c.accentBlue))
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
