import 'package:firebase_auth/firebase_auth.dart';
import '../../models/app_user.dart';
import 'auth_data_source.dart';

/// Adapter concreto que traduz a interface do [FirebaseAuth] (adaptee)
/// para a interface [AuthDataSource] (alvo) esperada pelo [AuthProvider].
///
/// Toda dependência do Firebase Auth fica confinada aqui.
class FirebaseAuthAdapter implements AuthDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthAdapter({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<AppUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_toAppUser);

  /// Converte o [User] do Firebase no modelo de domínio [AppUser].
  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
    );
  }

  @override
  Future<String?> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    }
  }

  @override
  Future<String?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    }
  }

  @override
  Future<String?> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    }
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  /// Mapeia códigos de erro do Firebase para mensagens em português.
  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Nenhuma conta encontrada com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'invalid-email':
        return 'O e-mail informado é inválido.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um momento e tente novamente.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';
      case 'invalid-credential':
        return 'E-mail ou senha inválidos.';
      default:
        return 'Ocorreu um erro. Tente novamente.';
    }
  }
}
