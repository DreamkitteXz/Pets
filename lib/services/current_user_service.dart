import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:pet_app/models/user_model.dart';

/// Em que pé está o carregamento do usuário logado.
///
/// [loading] existe como estado próprio para a UI conseguir mostrar
/// placeholder em vez de um nome genérico: sem ele, "sem nome ainda" e "sem
/// nome mesmo" ficam indistinguíveis e a tela pisca "Usuário" antes do dado
/// real chegar.
enum CurrentUserStatus { loading, ready, signedOut }

/// Ponto ÚNICO de leitura do usuário logado (`users/{uid}`).
///
/// **Por que existe:** antes cada tela instanciava `UserController()` e fazia
/// a própria leitura. A home lia em `initState` do main_screen e, enquanto a
/// resposta não chegava, renderizava `userData?.name ?? 'Usuário'` — o nome
/// genérico aparecia em todo primeiro frame.
///
/// **Fonte de verdade é o Firestore, não o Auth.** O cadastro
/// (`UserController.createUser`) grava `name` em `users/{uid}` e NUNCA chama
/// `updateDisplayName`; logo após entrar, `currentUser.displayName` é nulo. O
/// único `updateDisplayName` do app copia do Firestore para o Auth, depois.
///
/// Assina `authStateChanges` + o snapshot do documento: uma assinatura para o
/// app inteiro, nenhuma leitura por rebuild, e o nome se atualiza sozinho se o
/// tutor editar o perfil.
class CurrentUserService extends ChangeNotifier {
  CurrentUserService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _docSub;

  CurrentUserStatus _status = CurrentUserStatus.loading;
  Users? _user;
  String? _uid;
  User? _authUser;
  Object? _error;

  CurrentUserStatus get status => _status;
  Users? get user => _user;
  String? get uid => _uid;

  /// Usuário do Auth. `null` quando deslogado.
  User? get authUser => _authUser;

  /// Falha da última leitura de `users/{uid}`, se houve. Distingue "documento
  /// não existe" (null) de "não consegui ler" — a tela de erro diz coisas
  /// diferentes para cada caso.
  Object? get error => _error;

  bool get isLoading => _status == CurrentUserStatus.loading;

  /// Autenticado mas sem documento em `users/{uid}`.
  ///
  /// Estado inválido de verdade: o cadastro deveria ter gravado. O roteador
  /// mostra erro em vez de seguir para a home com dados pela metade.
  bool get isMissingProfile =>
      _status == CurrentUserStatus.ready && _user == null;

  /// Primeiro nome do tutor, ou `null` quando não há nome utilizável.
  ///
  /// `null` cobre três casos que a UI trata igual (saudação sem nome):
  /// carregando, deslogado, e documento sem `name`. Quem precisa distinguir
  /// olha [status].
  String? get firstName => firstNameOf(_user?.name);

  /// Primeiro token não vazio do nome completo.
  ///
  /// Separado e estático para ser testável sem Firebase. Trata os casos reais
  /// da base: `null`, string vazia, só espaços, espaços no meio.
  static String? firstNameOf(String? fullName) {
    if (fullName == null) return null;
    for (final part in fullName.trim().split(RegExp(r'\s+'))) {
      if (part.isNotEmpty) return part;
    }
    return null;
  }

  void _onAuthChanged(User? authUser) {
    _authUser = authUser;

    if (authUser == null) {
      _docSub?.cancel();
      _docSub = null;
      _uid = null;
      _user = null;
      _error = null;
      _setStatus(CurrentUserStatus.signedOut);
      return;
    }

    // Mesmo uid: a assinatura em vigor já cobre. Reassinar aqui jogaria a tela
    // de volta para o loading a cada refresh de token.
    if (authUser.uid == _uid && _docSub != null) {
      notifyListeners();
      return;
    }

    _subscribeToDocument(authUser.uid);
  }

  void _subscribeToDocument(String uid) {
    _uid = uid;
    _user = null;
    _error = null;
    _setStatus(CurrentUserStatus.loading);

    _docSub?.cancel();
    _docSub =
        _firestore.collection('users').doc(uid).snapshots().listen(_onDocument,
            onError: (Object error) {
      debugPrint('[usuário] falha ao ler users/$uid: $error');
      _user = null;
      _error = error;
      _setStatus(CurrentUserStatus.ready);
    });
  }

  /// Reassina o documento. Usado pelo botão "Tentar novamente" da tela de erro.
  void retry() {
    final uid = _uid ?? _authUser?.uid;
    if (uid == null) return;
    _subscribeToDocument(uid);
  }

  void _onDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    _user = (doc.exists && data != null) ? Users.fromMap(data) : null;
    _error = null;
    _setStatus(CurrentUserStatus.ready);
  }

  void _setStatus(CurrentUserStatus status) {
    _status = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _docSub?.cancel();
    super.dispose();
  }
}
