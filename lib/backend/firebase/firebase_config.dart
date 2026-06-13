import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyAG0Q65Y9INmCe4EofaOfTVQpnOE8JTcCI",
            authDomain: "paedia-fqv6h9.firebaseapp.com",
            projectId: "paedia-fqv6h9",
            storageBucket: "paedia-fqv6h9.firebasestorage.app",
            messagingSenderId: "839529528030",
            appId: "1:839529528030:web:fba5043c2e38c2a8c5a04f"));
  } else {
    await Firebase.initializeApp();
  }
}
