import 'package:flutter/foundation.dart';
import '../adapters/auth/auth_data_source.dart';
import '../models/app_user.dart';

/// Gerencia o estado de autenticação.
///
/// Depende de [AuthDataSource] (não de Firebase diretamente),
/// seguindo o padrão Adapter para desacoplar infraestrutura do domínio.
class AuthProvider extends ChangeNotifier {
  final AuthDataSource _dataSource;

  AppUser? _user;
  bool _isLoading = false;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider(this._dataSource) {
    _dataSource.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Retorna mensagem de erro localizada ou `null` em caso de sucesso.
  Future<String?> signIn(String email, String password) async {
    _setLoading(true);
    final error = await _dataSource.signIn(email, password);
    _setLoading(false);
    return error;
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    final error = await _dataSource.signUp(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    _setLoading(false);
    return error;
  }

  Future<String?> resetPassword(String email) async {
    _setLoading(true);
    final error = await _dataSource.resetPassword(email);
    _setLoading(false);
    return error;
  }

  Future<void> signOut() => _dataSource.signOut();
}
