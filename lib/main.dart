import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'adapters/auth/firebase_auth_adapter.dart';
import 'adapters/book/firestore_book_adapter.dart';
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
        ChangeNotifierProvider(
          create: (_) => AuthProvider(FirebaseAuthAdapter()),
        ),
        // Recria o data source do Firestore quando o uid do usuário muda.
        // Enquanto não autenticado, usa LocalBookAdapter (lista vazia).
        ChangeNotifierProxyProvider<AuthProvider, BookProvider>(
          create: (_) => BookProvider(LocalBookAdapter()),
          update: (_, auth, bookProvider) {
            final uid = auth.user?.uid;
            bookProvider!.switchDataSource(
              uid,
              uid != null ? FirestoreBookAdapter(uid) : LocalBookAdapter(),
            );
            return bookProvider;
          },
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
