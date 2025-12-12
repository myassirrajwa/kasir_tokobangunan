import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kasir_toko_bangunan/pages/splash.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:kasir_toko_bangunan/pages/loginPage.dart';
import 'package:kasir_toko_bangunan/pages/homePage.dart';
import 'package:kasir_toko_bangunan/pages/registrasi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      
      initialRoute: '/splash',

    
      getPages: [
        GetPage(name: '/splash', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/home', page: () =>  HomePage()),
      ],
    );
  }
}
