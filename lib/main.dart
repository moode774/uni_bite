import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_bite/Pages/AdminPage/AdminAccountSetting.dart';
import 'package:uni_bite/Pages/AdminPage/AdminHome.dart';
import 'package:uni_bite/Pages/AdminPage/AdminProfile.dart';
import 'package:uni_bite/Pages/AdminPage/Adminlogin.dart';
import 'package:uni_bite/Pages/AdminPage/viewClient.dart';
import 'package:uni_bite/Pages/FacilityPage/FacilityHome.dart';
import 'package:uni_bite/Pages/FacilityPage/Facilitylogin.dart';
import 'package:uni_bite/Pages/SelectRole.dart';
import 'package:uni_bite/Pages/forgate_pass.dart';
import 'package:uni_bite/Pages/home.dart';
import 'package:uni_bite/Pages/signup.dart';
import 'package:uni_bite/Pages/welcom.dart';
import 'Pages/login.dart';
import 'package:uni_bite/Pages/clientPage/order_edit_timer_page.dart';
import 'localization/app_localizations.dart';
import 'Pages/Languge.dart'; 

import 'Pages/SplashScreen.dart';
import 'Pages/FacilityPage/FacilitySignup.dart';



// مفتاح لتخزين اللغة المفضلة في Shared Preferences
const String LANGUAGE_CODE = 'languageCode';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // تحميل اللغة المفضلة عند بدء التطبيق
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString(LANGUAGE_CODE);
  
  runApp(MyApp(locale: languageCode != null ? Locale(languageCode) : null));
}

class MyApp extends StatefulWidget {
  final Locale? locale;
  
  const MyApp({super.key, this.locale});

  @override
  State<MyApp> createState() => _MyAppState();
  
  // تعريف الـ static لاستخدامه في أي مكان في التطبيق
  static void setLocale(BuildContext context, Locale locale) async {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    
    // حفظ اختيار اللغة في Shared Preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(LANGUAGE_CODE, locale.languageCode);
    
    state?.setLocale(locale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en'); // اللغة الافتراضية

  @override
  void initState() {
    super.initState();
    // إذا تم تمرير لغة محددة، استخدمها
    if (widget.locale != null) {
      _locale = widget.locale!;
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // إعدادات اللغة
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => Home(),
        "/login": (context) => const LoginForm(),
        "/signup": (context) => const Signup(),
        "/Welcome": (context) => const Welcome(),
        "/SelectRolePage": (context) => const SelectRolePage(),
        "/AdminLogin": (context) => const AdminLogin(),
        "/Facilitylogin": (context) => const FacilityLogin(),
        "/FacilitySignup": (context) => const FacilitySignup(),
        "/Facilityhome": (context) => const Facilityhome(facilityId: '',),
        "/AdminHome": (context) => const AdminHome(),
        "/AdminProfilePage": (context) => const AdminProfilePage(),
        "/AccountSettingsPage": (context) => const AccountSettingsPage(),
        "/ViewClientsPage": (context) => const ViewClientsPage(),
        "/ForgotPasswordPage": (context) => const ForgotPasswordPage(),
        "/orderEditTimer": (context) => const EditCancelOrderPage(),
        "/language": (context) => const LanguagePage(), // إضافة مسار صفحة اللغة
      },
    );
  }
}