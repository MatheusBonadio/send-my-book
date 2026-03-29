// ATENÇÃO: Este arquivo precisa ser configurado com suas credenciais do Firebase.
//
// Passos para configurar:
// 1. Acesse https://console.firebase.google.com e crie um projeto
// 2. Ative a autenticação por E-mail/Senha em Authentication > Sign-in method
// 3. Instale o FlutterFire CLI: dart pub global activate flutterfire_cli
// 4. Execute: flutterfire configure
//    Isso irá substituir este arquivo com suas credenciais reais.
//
// Alternativamente, substitua os valores "TODO" abaixo com os dados do seu projeto Firebase.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não suportado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'TODO-WEB-API-KEY',
    appId: 'TODO-WEB-APP-ID',
    messagingSenderId: 'TODO-SENDER-ID',
    projectId: 'TODO-PROJECT-ID',
    authDomain: 'TODO-PROJECT-ID.firebaseapp.com',
    storageBucket: 'TODO-PROJECT-ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TODO-ANDROID-API-KEY',
    appId: 'TODO-ANDROID-APP-ID',
    messagingSenderId: 'TODO-SENDER-ID',
    projectId: 'TODO-PROJECT-ID',
    storageBucket: 'TODO-PROJECT-ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TODO-IOS-API-KEY',
    appId: 'TODO-IOS-APP-ID',
    messagingSenderId: 'TODO-SENDER-ID',
    projectId: 'TODO-PROJECT-ID',
    storageBucket: 'TODO-PROJECT-ID.appspot.com',
    iosBundleId: 'com.example.sendMyBook',
  );
}
