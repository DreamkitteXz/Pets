import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gerencia o [ThemeMode] do app: honra o tema do sistema por padrão e permite
/// override manual (claro/escuro), persistido localmente.
///
/// Persistência: `shared_preferences` (instantâneo, offline). A sincronização
/// cross-device em `users.darkMode` (permitida pela rule — é o doc do próprio
/// usuário) fica como evolução futura (seam já isolado em [setMode]).
class ThemeController extends ChangeNotifier {
  static const String _prefsKey = 'petto-theme-mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  /// Carrega a preferência salva (chamar no boot, antes do runApp ou via FutureBuilder).
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      _mode = _decode(saved);
      notifyListeners();
    } catch (_) {
      _mode = ThemeMode.system;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _encode(mode));
    } catch (_) {/* falha de persistência não deve quebrar a UI */}
    // TODO(seam): sincronizar em users/{uid}.darkMode quando logado (cross-device).
  }

  /// Alterna entre claro e escuro (resolvendo "system" pela plataforma atual).
  Future<void> toggle(BuildContext context) async {
    final effectiveDark = _mode == ThemeMode.system
        ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
        : _mode == ThemeMode.dark;
    await setMode(effectiveDark ? ThemeMode.light : ThemeMode.dark);
  }

  ThemeMode _decode(String? v) {
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _encode(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
