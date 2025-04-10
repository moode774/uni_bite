import 'package:flutter/material.dart';
import 'package:uni_bite/localization/app_localizations.dart';
import 'package:uni_bite/main.dart'; 

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  Locale? _locale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = Localizations.localeOf(context);
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
      MyApp.setLocale(context, locale);
      
      String message = locale.languageCode == 'ar' 
          ? 'تم تغيير اللغة إلى العربية' 
          : 'Language changed to English';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: locale.languageCode == 'ar' ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontFamily: locale.languageCode == 'ar' ? 'Cairo' : null,
            ),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _locale ?? Localizations.localeOf(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF2EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: const Color(0xFFFDF2EC),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context).translate('language'),
              style: TextStyle(
                color: Color(0xFF2A3E5F),
                fontSize: 40,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                _changeLanguage(const Locale('en'));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, 
                  border: Border.all(
                    color: currentLocale.languageCode == 'en'
                        ? Colors.black
                        : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: const Row(
                  children: [
                    Text(
                      '🇬🇧',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'English',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                _changeLanguage(const Locale('ar'));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, 
                  border: Border.all(
                    color: currentLocale.languageCode == 'ar'
                        ? Colors.black
                        : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: const Row(
                  children: [
                    Text(
                      '🇸🇦',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Arabic',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      currentLocale.languageCode == 'ar'
                          ? 'اللغة الحالية: العربية'
                          : 'Current language: English',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}