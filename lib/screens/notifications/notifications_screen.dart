import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pet_app/design/design.dart';
import 'package:pet_app/models/vaccine_model.dart';
import 'package:pet_app/screens/vaccines/vaccine_screen.dart';
import 'package:pet_app/services/notifications_service.dart';

/// Caixa de notificações do tutor: `users/{uid}/notifications`, gravada pela
/// CF de validação do vet. Espelha o menu de notificações da web.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsService _service = NotificationsService.instance;
  late final Stream<List<AppNotification>> _stream = _service.stream();
  bool _opening = false;

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppNotification>>(
      stream: _stream,
      builder: (context, snapshot) {
        final items = snapshot.data;
        final unread = items == null ? 0 : items.where((n) => !n.read).length;

        return AppScaffold(
          title: 'Notificações',
          subtitle: unread > 0
              ? '$unread não lida${unread > 1 ? 's' : ''}'
              : 'Tudo em dia',
          showBack: true,
          bodyPadding: false,
          actions: [
            if (unread > 0)
              TextButton(
                onPressed: () => _markAll(items!),
                child: const Text('Marcar lidas'),
              ),
          ],
          body: _buildBody(context, snapshot),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context, AsyncSnapshot<List<AppNotification>> snapshot) {
    if (snapshot.hasError) {
      return const AppErrorState(
          message: 'Não foi possível carregar suas notificações.');
    }
    if (!snapshot.hasData) return const AppLoading();

    final items = snapshot.data!;
    if (items.isEmpty) {
      return const AppEmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'Nenhuma notificação',
        message: 'Você será avisado aqui quando o veterinário validar ou '
            'rejeitar um registro do seu pet.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxxl),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, i) => _NotificationCard(
        notification: items[i],
        onTap: () => _open(items[i]),
      ),
    );
  }

  Future<void> _markAll(List<AppNotification> items) async {
    try {
      await _service.markAllAsRead(items);
    } catch (e) {
      _toast('Não foi possível marcar como lidas: $e');
    }
  }

  Future<void> _open(AppNotification notification) async {
    if (_opening) return;
    _opening = true;
    try {
      if (!notification.read) {
        // Falha ao marcar como lida não deve impedir a navegação.
        try {
          await _service.markAsRead(notification.id);
        } catch (_) {}
      }

      if (!notification.isVaccineValidation || notification.vaccineId == null) {
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('vaccines')
          .doc(notification.vaccineId!)
          .get();

      if (!doc.exists) {
        _toast('Este registro de vacina não está mais disponível.');
        return;
      }

      final data = doc.data()!;
      data['id'] = doc.id;
      final vacina = Vacinas.fromMap(data);

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) =>
              VaccineScreen(vacina: vacina, petId: vacina.petId ?? ''),
        ),
      );
    } catch (e) {
      _toast('Não foi possível abrir a vacina: $e');
    } finally {
      _opening = false;
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final rejected = notification.status == 'rejected';

    Color accent;
    IconData icon;
    if (!notification.isVaccineValidation) {
      accent = c.accentBlue;
      icon = Icons.notifications_rounded;
    } else if (rejected) {
      accent = c.statusRejected;
      icon = Icons.cancel_rounded;
    } else {
      accent = c.statusApproved;
      icon = Icons.check_circle_rounded;
    }

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: c.tint(accent, 0.12),
              borderRadius:
                  const BorderRadius.all(Radius.circular(AppRadius.md)),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTypography.headline.copyWith(
                          color: c.textPrimary,
                          fontWeight: notification.read
                              ? FontWeight.w500
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!notification.read) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                            color: c.accentBlue, shape: BoxShape.circle),
                      ),
                    ],
                  ],
                ),
                if (notification.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(notification.subtitle,
                      style: AppTypography.footnote
                          .copyWith(color: c.textSecondary)),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text(_relativeTime(notification.createdAt),
                    style:
                        AppTypography.caption.copyWith(color: c.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _relativeTime(DateTime? date) {
    if (date == null) return 'Agora mesmo';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Agora mesmo';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) {
      return 'Há ${diff.inHours} h';
    }
    if (diff.inDays == 1) return 'Ontem, ${DateFormat('HH:mm').format(date)}';
    if (diff.inDays < 7) return 'Há ${diff.inDays} dias';
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
