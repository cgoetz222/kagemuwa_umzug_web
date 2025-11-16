import 'package:flutter/material.dart';
import 'package:kagemuwa_umzug_common/helper/kagemuwa_colors.dart';
import 'package:kagemuwa_umzug_common/helper/kagemuwa_styles.dart';

class ThankYouView extends StatefulWidget {
  const ThankYouView({super.key});

  @override
  State<ThankYouView> createState() => _ThankYouViewState();
}

class _ThankYouViewState extends State<ThankYouView> {
  @override
  Widget build(BuildContext context) {
    double spacing = 10.0;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text('Großer Odenwälder Rosenmontagsumzug', textScaler: TextScaler.linear(width / 500.0), textAlign: TextAlign.center,),
      ),
      body: Card(
        color: KAGEMUWAColors.cardBrightBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text("Die KaGeMuWa dankt Dir ganz herzlich für Deine Bewertung beim Rosenmontagsumzug.\n\nWir freuen uns, Dich bei der Prämierung in der Odenwaldhalle begrüßen zu dürfen.\n\nAuf Deine Bewertung ein\n3x Mudi Hajo!",
                  textAlign: TextAlign.center, style: KAGEMUWAStyles.thankYouPageTextFieldStyle, textScaler: TextScaler.linear(width / 500.0)),
            ),
            SizedBox(height: 2 * spacing,),
            Image.asset("assets/kagemuwakasperblack.webp"),
            SizedBox(height: spacing,),
          ],
        ),
      ),
    );
  }
}