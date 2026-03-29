import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'adapters/auth/firebase_auth_adapter.dart';
import 'adapters/book/local_book_adapter.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SendMyBookApp());
}

class SendMyBookApp extends StatelessWidget {
  const SendMyBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Injeção dos adapters concretos nos providers.
        // Para trocar Firebase por outra solução de auth, basta
        // substituir FirebaseAuthAdapter por outro AuthDataSource.
        ChangeNotifierProvider(
          create: (_) => AuthProvider(FirebaseAuthAdapter()),
        ),
        // Para usar Firestore ou SQLite, basta trocar LocalBookAdapter
        // por outro BookDataSource sem alterar BookProvider.
        ChangeNotifierProvider(
          create: (_) => BookProvider(LocalBookAdapter()),
        ),
      ],
      child: MaterialApp(
        title: 'Send My Book',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isAuthenticated) {
      return const HomeScreen();
    }
    return const LoginScreen();
  }
}
