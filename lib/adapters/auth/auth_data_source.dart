import '../../models/app_user.dart';

/// Interface (alvo) do Adapter de autenticação.
///
/// [AuthProvider] depende desta abstração, não de nenhuma implementação
/// concreta (Firebase, mock, etc.).
abstract class AuthDataSource {
  /// Stream que emite o usuário atual sempre que o estado de autenticação muda.
  Stream<AppUser?> get authStateChanges;

  /// Retorna mensagem de erro localizada, ou `null` em caso de sucesso.
  Future<String?> signIn(String email, String password);

  Future<String?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<String?> resetPassword(String email);

  Future<void> signOut();
}
