import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:pet_app/design/design.dart';
import 'package:pet_app/services/current_user_service.dart';

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

    // Mesma fonte da saudação da home: `users/{uid}.name`, não o displayName do
    // Auth. O cadastro grava o nome no Firestore e nunca chama
    // updateDisplayName, então o displayName é nulo até algo copiar — e aqui
    // caía em "Tutor", um genérico com a mesma cara do "Usuário" da home.
    final session = context.watch<CurrentUserService>();
    final fullName = session.user?.name?.trim();
    final hasName = fullName != null && fullName.isNotEmpty;

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
                      // Sem nome, um ícone neutro em vez de inicial inventada.
                      child: (photo != null && photo.isNotEmpty)
                          ? null
                          : (hasName
                              ? Text(fullName[0].toUpperCase(),
                                  style: AppTypography.largeTitle
                                      .copyWith(color: c.accentBlue))
                              : Icon(Icons.person_rounded,
                                  size: 40, color: c.accentBlue)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Enquanto carrega, placeholder — nunca um nome genérico
                  // piscando antes do real.
                  if (session.isLoading)
                    Container(
                      width: 160,
                      height: (AppTypography.title1.fontSize ?? 22) * 0.8,
                      decoration: BoxDecoration(
                        color: c.surfaceSecondary,
                        borderRadius: AppRadius.pill_,
                      ),
                    )
                  else
                    Text(hasName ? fullName : 'Meu perfil',
                        style:
                            AppTypography.title1.copyWith(color: c.textPrimary)),
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
