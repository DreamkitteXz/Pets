import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Uma notificação de `users/{uid}/notifications`.
///
/// Formato gravado pela Cloud Function `updateVaccineStatus` (branch Website,
/// functions/index.js) e pelo notificationService da web:
/// `{ type: 'VACCINE_VALIDATION', vaccineId, status, read, createdAt }`.
/// Tipos novos que o backend passar a gravar caem no rótulo genérico.
class AppNotification {
  final String id;
  final String type;
  final String? vaccineId;
  final String? status; // 'approved' | 'rejected'
  final bool read;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.read,
    this.vaccineId,
    this.status,
    this.createdAt,
  });

  factory AppNotification.fromDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final ts = data['createdAt'];
    return AppNotification(
      id: doc.id,
      type: (data['type'] as String?) ?? 'UNKNOWN',
      vaccineId: data['vaccineId'] as String?,
      status: data['status'] as String?,
      read: data['read'] == true,
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }

  bool get isVaccineValidation => type == 'VACCINE_VALIDATION';

  /// Texto espelhando o do header da web (Header.jsx → notifText).
  String get title {
    if (isVaccineValidation) {
      return status == 'rejected'
          ? 'Uma vacina foi rejeitada'
          : 'Uma vacina foi validada';
    }
    return 'Notificação';
  }

  String get subtitle {
    if (isVaccineValidation) {
      return status == 'rejected'
          ? 'Toque para ver o motivo informado pelo veterinário.'
          : 'Toque para ver os detalhes da validação.';
    }
    return '';
  }
}

/// Acesso a `users/{uid}/notifications`.
///
/// A rule permite `read, write` ao próprio dono do documento de usuário, então
/// listar e marcar como lida funciona pelo app sem mudança de backend.
class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  CollectionReference<Map<String, dynamic>>? _ref() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications');
  }

  /// Todas as notificações, mais recentes primeiro. `orderBy` de campo único
  /// usa o índice automático — não precisa de índice composto.
  Stream<List<AppNotification>> stream({int limit = 50}) {
    final ref = _ref();
    if (ref == null) return Stream<List<AppNotification>>.value(const []);
    return ref
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(AppNotification.fromDoc).toList());
  }

  /// Contagem de não lidas, derivada da mesma consulta (filtro no cliente para
  /// não exigir índice composto `read` + `createdAt`).
  Stream<int> unreadCount() =>
      stream().map((list) => list.where((n) => !n.read).length);

  Future<void> markAsRead(String id) async {
    final ref = _ref();
    if (ref == null) return;
    await ref.doc(id).update({'read': true});
  }

  Future<void> markAllAsRead(List<AppNotification> notifications) async {
    final ref = _ref();
    if (ref == null) return;
    final unread = notifications.where((n) => !n.read).toList();
    if (unread.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final n in unread) {
      batch.update(ref.doc(n.id), {'read': true});
    }
    await batch.commit();
  }
}
