import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lembra que o tutor dispensou um update opcional, para não perguntar de novo
/// no mesmo dia.
///
/// A chave inclui o buildNumber: dispensar a 15 não pode calar o aviso da 16.
/// E vale só para update OPCIONAL — o obrigatório ignora isto por completo.
class UpdatePreferences {
  UpdatePreferences({SharedPreferences? prefs}) : _injected = prefs;

  final SharedPreferences? _injected;

  static const String _keyPrefix = 'update_dismissed_build_';

  Future<SharedPreferences> get _prefs async =>
      _injected ?? await SharedPreferences.getInstance();

  /// `yyyy-mm-dd` — comparação por DIA, não por instante: "não perguntar de
  /// novo hoje" tem que valer até a virada do dia, não por 24h corridas.
  static String dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> dismissForToday(int buildNumber, {DateTime? now}) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(
          '$_keyPrefix$buildNumber', dayKey(now ?? DateTime.now()));
    } catch (e) {
      // Falhar em lembrar é aceitável: o pior caso é perguntar de novo.
      debugPrint('[update] não consegui salvar a dispensa: $e');
    }
  }

  Future<bool> wasDismissedToday(int buildNumber, {DateTime? now}) async {
    try {
      final prefs = await _prefs;
      final saved = prefs.getString('$_keyPrefix$buildNumber');
      if (saved == null) return false;
      return saved == dayKey(now ?? DateTime.now());
    } catch (e) {
      debugPrint('[update] não consegui ler a dispensa: $e');
      return false;
    }
  }

  /// Limpa dispensas de builds já superados, para o SharedPreferences não
  /// acumular uma chave por versão ao longo do tempo.
  Future<void> clearOlderThan(int buildNumber) async {
    try {
      final prefs = await _prefs;
      for (final key in prefs.getKeys().toList()) {
        if (!key.startsWith(_keyPrefix)) continue;
        final build = int.tryParse(key.substring(_keyPrefix.length));
        if (build != null && build < buildNumber) await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('[update] não consegui limpar dispensas antigas: $e');
    }
  }
}
