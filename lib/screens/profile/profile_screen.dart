import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:pet_app/design/design.dart';

/// Perfil do tutor — repaginado sobre o design system.
/// Inclui o toggle de tema real (ThemeController). Removidos os "stats"
/// estáticos falsos (3 pets / 12 vacinas / 127 dias) do layout antigo.
class ProfileScreen extends StatelessWidget {
  final User user;
  final Future<void> Function() onLogout;

  const ProfileScreen({
    Key? key,
    required this.user,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = context.watch<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = (user.displayName != null && user.displayName!.isNotEmpty)
        ? user.displayName!
        : 'Tutor';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final photo = user.photoURL;

    return Scaffold(
      backgroundColor: c.surfaceGrouped,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxxl),
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Hero(
                    tag: 'profile-${user.uid}',
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: c.tint(c.accentBlue, 0.15),
                      backgroundImage: (photo != null && photo.isNotEmpty)
                          ? NetworkImage(photo)
                          : null,
                      child: (photo == null || photo.isEmpty)
                          ? Text(initial,
                              style: AppTypography.largeTitle
                                  .copyWith(color: c.accentBlue))
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(name,
                      style: AppTypography.title1.copyWith(color: c.textPrimary)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(user.email ?? '',
                      style:
                          AppTypography.callout.copyWith(color: c.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Preferências (tema) ──────────────────────────────────────────
            AppListSection(
              header: 'Preferências',
              children: [
                AppListTile(
                  leadingIcon: Icons.dark_mode_rounded,
                  leadingColor: c.accentIndigo,
                  title: 'Tema escuro',
                  subtitle: 'Segue o sistema por padrão',
                  trailing: Switch(
                    value: isDark,
                    onChanged: (_) => theme.toggle(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Conta ────────────────────────────────────────────────────────
            AppListSection(
              header: 'Conta',
              children: [
                AppListTile(
                  leadingIcon: Icons.person_outline_rounded,
                  title: 'Editar perfil',
                  subtitle: 'Alterar seus dados',
                  onTap: () => _soon(context),
                ),
                AppListTile(
                  leadingIcon: Icons.notifications_outlined,
                  leadingColor: c.accentOrange,
                  title: 'Notificações',
                  subtitle: 'Preferências de aviso',
                  onTap: () => _soon(context),
                ),
                AppListTile(
                  leadingIcon: Icons.help_outline_rounded,
                  leadingColor: c.accentGreen,
                  title: 'Ajuda e suporte',
                  onTap: () => _soon(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            AppButton(
              label: 'Sair',
              icon: Icons.logout_rounded,
              variant: AppButtonVariant.destructive,
              onPressed: () => onLogout(),
            ),
          ],
        ),
      ),
    );
  }

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Em breve.')),
    );
  }
}
