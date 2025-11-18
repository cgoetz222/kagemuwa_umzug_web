import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5)
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        //overflow: Overflow.visible,
        children: [
          SizedBox(
            height: 300,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Achtung"),
                  SizedBox(height: 5,),
                  Text("Deine Daten wurden nicht korrekt gesendet!\nMöglicherweise hast Du keine Internetverbindung!\nBitte gehe an einen Ort, wo Du eine Internetverbindung hast.\nDie Daten werden dann automatisch gespeichert.\nBitte schließe den Browser nicht, danke."),
                  SizedBox(height: 20,),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('OK'),
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true)
                          .pop(true); // dismisses only the dialog and returns true
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -60,
            child: CircleAvatar(
              backgroundColor: Colors.redAccent,
              radius: 60,
              child: Icon(Icons.warning, size: 80, color: Colors.white,),
            ),
          ),
        ],
      ),
    );
  }
}