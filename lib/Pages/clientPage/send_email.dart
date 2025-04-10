import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_bite/localization/app_localizations.dart';

class HelpCenterPage extends StatelessWidget {
  final String email;

  const HelpCenterPage({
    Key? key, 
    required this.email,
  }) : super(key: key);

  // Function to launch email
  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        // If email app can't be launched, show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('email_app_not_found')
            ),
          ),
        );
      }
    } catch (e) {
      // Handle any exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context).translate('error_occurred')}: $e'
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 40.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF9EAE6),
                  border: Border.all(
                    color: const Color(0xFF2A3E5F),
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF2A3E5F),
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).translate('help_center'),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A3E5F),
              ),
            ),
            const SizedBox(height: 30),
            Icon(
              Icons.support_agent, 
              size: 120, 
              color: const Color(0xFF2A3E5F)
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).translate('need_help'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: Color(0xFF2A3E5F)
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context).translate('contact_via_email'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16, 
                color: Colors.grey[600]
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _launchEmail(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A3E5F),
                padding: const EdgeInsets.symmetric(
                  horizontal: 150,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).translate('send_email'),
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 18
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}