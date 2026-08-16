import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final DateFormat _brDate = DateFormat('dd/MM/yyyy');

/// Lê um campo de data do Firestore tolerando os formatos que já existem na
/// base.
///
/// O canônico é `Timestamp`, mas o cadastro de vacina do app gravou
/// `administrationDate` / `nextDueDate` / `expirationDate` como String
/// "dd/MM/yyyy" (às vezes sem zero à esquerda, "5/3/2026") até o fix do
/// wizard. Um cast direto `as Timestamp?` estoura nesses documentos antigos e
/// derruba o stream inteiro — por isso a leitura precisa ser defensiva.
///
/// Retorna `null` para ausente ou ilegível, nunca lança.
DateTime? readFirestoreDate(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) {
    final text = value.trim();
    if (text.isEmpty) return null;
    try {
      return _brDate.parse(text);
    } catch (_) {
      // Pode ser ISO-8601 (toIso8601String em algum caminho antigo).
      return DateTime.tryParse(text);
    }
  }
  return null;
}
