/// Modelo de usuário do domínio da aplicação.
/// Desacopla o restante do app do tipo [User] do Firebase.
class AppUser {
  final String uid;
  final String? displayName;
  final String? email;

  const AppUser({
    required this.uid,
    this.displayName,
    this.email,
  });
}
