import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:kagemuwa_umzug_web/main.dart';
import 'package:kagemuwa_umzug_web/ui/demo_view.dart';
import 'package:kagemuwa_umzug_web/ui/rating_view.dart';
import 'package:kagemuwa_umzug_common/data/model/rater.dart';
import 'package:provider/provider.dart';
import 'package:kagemuwa_umzug_common/helper/kagemuwa_colors.dart';
import 'package:kagemuwa_umzug_common/helper/kagemuwa_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../provider/rater_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  static int statusLogin = 0;
  static int statusNew = 1;
  //static int statusWrongYear = 91;
  static int statusWrongUser = 92;
  static int statusWrongPassword = 93;
  static int statusUsedOnOtherDevice = 94;

  int status = 0;
  bool loggedIn = false;
  bool changingName = false;
  bool connected = false; // internet connection
  RaterProvider? raterProvider;
  //Barcode? _barcode;
  TextEditingController raterNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    raterNameController.dispose();
    super.dispose();
  }

  void changeName() {
    raterProvider!.rater?.name = raterNameController.text;
  }

  Future<bool> signIn() async {
    if(!changingName) {
      if(raterProvider!.loaded == false) {
        status = statusLogin;
      } else if(raterProvider!.rater!.name == "NEW") {
        status = statusNew;
        changingName = true;
      } else if(raterProvider!.rater!.deviceID != await raterProvider!.getUniqueRaterId()) {
        status = statusUsedOnOtherDevice;
      } else {
        if(mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const RatingView()));
      }
    }
    debugPrint("Status: $status");
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double spacing = 10.0;
    double width = MediaQuery.of(context).size.width;
    //double height = MediaQuery.of(context).size.height;

    raterProvider = Provider.of<RaterProvider>(context, listen: true);
    raterNameController.addListener(changeName);

    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text('Login', textScaler: TextScaler.linear(width / 500.0), textAlign: TextAlign.center,),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
        children: [
          SizedBox(height: spacing,),
          Card(
            margin: EdgeInsets.all(spacing),
            color: KAGEMUWAColors.cardBrightBackground,
            child: FutureBuilder<bool>(
                future: signIn(),
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  Column col;
                  if(snapshot.data == null || snapshot.data == false) {
                    col = const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                      ],
                    );
                  } else if(status == statusLogin) {
                    col = Column(
                      children: [
                        SizedBox(height: spacing,),
                        SizedBox(height: 200, width: 200, child:
                          MobileScanner(
                              //allowDuplicates: false,
                              //onDetect: (barcode, args) async {
                              onDetect: (BarcodeCapture barcodes) async {
                                Barcode? barcode = barcodes.barcodes.firstOrNull;
                                //if (barcode!.rawValue == null) {
                                if (barcode == null) {
                                  debugPrint('Failed to scan Barcode');
                                } else {
                                  final String code = barcode.rawValue!;
                                  debugPrint('Barcode found! $code');

                                  // login for the demo user required for the google playstore
                                  if(code.compareTo("DEMOUSER") == 0) {
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DemoView()));
                                    return;
                                  }

                                  // real user - try to login
                                  List<String> array = code.split(";");
                                  debugPrint(array[0]);
                                  debugPrint(array[1]);
                                  debugPrint(array[2]);
                                  debugPrint(array[3]);

                                  raterProvider!.campaignYear = array[3];
                                  FirebaseAuth auth = FirebaseAuth.instance;
                                  try {
                                    UserCredential userCredential = await auth.signInWithEmailAndPassword(
                                      email: array[0],
                                      password: array[1],
                                    );
                                    debugPrint("signed in user $userCredential");
                                    await raterProvider!.load(array[2], array[3]);
                                    debugPrint(raterProvider!.loaded.toString());
                                    setState(() {
                                      signIn();
                                    });
                                  } on FirebaseAuthException catch (e) {
                                    if (e.code == 'user-not-found') {
                                      status = statusWrongUser;
                                      debugPrint('No user found for that email.');
                                      if(mounted) {
                                        await showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text("Fehler"),
                                                titleTextStyle:
                                                const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: 20),
                                                actionsOverflowButtonSpacing: 20,
                                                actions: [
                                                  ElevatedButton(onPressed: () {
                                                    Navigator.of(context).pop();
                                                  }, child: const Text("Ok")),
                                                ],
                                                content: const Text(
                                                    "Der Benutzer ist unbekannt!"),
                                              );
                                            });
                                      }
                                      if(mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Großer Odenwälder Rosenmontagsumzug')));
                                    } else if (e.code == 'wrong-password') {
                                      status = statusWrongPassword;
                                      debugPrint('Wrong password provided for that user.');
                                      await showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text("Fehler"),
                                              titleTextStyle:
                                              const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 20),
                                              actionsOverflowButtonSpacing: 20,
                                              actions: [
                                                ElevatedButton(onPressed: () {
                                                  Navigator.of(context).pop();
                                                }, child: const Text("Ok")),
                                              ],
                                              content: const Text(
                                                  "Das Passwort ist falsch!"),
                                            );
                                          });
                                      if(mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Großer Odenwälder Rosenmontagsumzug')));
                                    }
                                  }
                                }
                              }),
                        ),

                        /*
                                                  MobileScanner(
                              allowDuplicates: false,
                              onDetect: (barcode, args) async {
                                if (barcode.rawValue == null) {
                                  debugPrint('Failed to scan Barcode');
                                } else {
                                  final String code = barcode.rawValue!;
                                  debugPrint('Barcode found! $code');

                                  // login for the demo user required for the google playstore
                                  if(code.compareTo("DEMOUSER") == 0) {
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DemoView()));
                                    return;
                                  }

                                  // real user - try to login
                                  List<String> array = code.split(";");
                                  debugPrint(array[0]);
                                  debugPrint(array[1]);
                                  debugPrint(array[2]);
                                  debugPrint(array[3]);

                                  raterProvider!.campaignYear = array[3];
                                  FirebaseAuth auth = FirebaseAuth.instance;
                                  try {
                                    UserCredential userCredential = await auth.signInWithEmailAndPassword(
                                      email: array[0],
                                      password: array[1],
                                    );
                                    debugPrint("signed in user");
                                    await raterProvider!.load(array[2], array[3]);
                                    debugPrint(raterProvider!.loaded.toString());
                                    setState(() {
                                      signIn();
                                    });
                                  } on FirebaseAuthException catch (e) {
                                    if (e.code == 'user-not-found') {
                                      status = statusWrongUser;
                                      debugPrint('No user found for that email.');
                                      await showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text("Fehler"),
                                              titleTextStyle:
                                              const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 20),
                                              actionsOverflowButtonSpacing: 20,
                                              actions: [
                                                ElevatedButton(onPressed: () {
                                                  Navigator.of(context).pop();
                                                }, child: const Text("Ok")),
                                              ],
                                              content: const Text(
                                                  "Der Benutzer ist unbekannt!"),
                                            );
                                          });
                                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Großer Odenwälder Rosenmontagsumzug')));
                                    } else if (e.code == 'wrong-password') {
                                      status = statusWrongPassword;
                                      debugPrint('Wrong password provided for that user.');
                                      await showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text("Fehler"),
                                              titleTextStyle:
                                              const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 20),
                                              actionsOverflowButtonSpacing: 20,
                                              actions: [
                                                ElevatedButton(onPressed: () {
                                                  Navigator.of(context).pop();
                                                }, child: const Text("Ok")),
                                              ],
                                              content: const Text(
                                                  "Das Passwort ist falsch!"),
                                            );
                                          });
                                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Großer Odenwälder Rosenmontagsumzug')));
                                    }
                                  }
                                }
                              }),
                         */
                        const SizedBox(height: 20,),
                      ],
                    );
                  } else if (status == statusNew){
                    col = Column(
                      children: [
                        SizedBox(height: spacing,),
                        Container(
                          padding: EdgeInsets.only(left: spacing, right: spacing),
                          height: 150,
                          child: LayoutGrid(
                            columnSizes: const [auto, auto],
                            rowSizes: const [auto, auto, auto, auto, auto],
                            rowGap: 5,
                            columnGap: 5,
                            children: [
                              const Text("Name", style: KAGEMUWAStyles.cardBrightBodyStyle),
                              SizedBox(
                                width: 200,
                                height: 20,
                                child: TextField(
                                    controller: raterNameController,
                                    style: KAGEMUWAStyles.cardDarkTextFieldStyle),
                              ),
                              const Text("ID", style: KAGEMUWAStyles.cardBrightBodyStyle),
                              Text(raterProvider!.rater!.id, style: KAGEMUWAStyles.cardBrightBodyStyle),
                              const Text("Device ID", style: KAGEMUWAStyles.cardBrightBodyStyle),
                              Text(raterProvider!.rater!.deviceID, style: KAGEMUWAStyles.cardBrightBodyStyle),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          children: [
                            const SizedBox(width: 15,),
                            raterProvider!.rater!.status == Rater.STATUS_NOT_REGISTERED ?
                            ElevatedButton.icon(
                              icon: const Icon(Icons.app_registration_outlined),
                              label: const Text('Login'),
                              onPressed: () async {
                                changingName = false;
                                raterProvider!.rater!.name = raterNameController.text;
                                raterProvider!.rater!.status = Rater.STATUS_REGISTERED;
                                await raterProvider!.updateRater();
                                if(mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const RatingView()));
                              },
                            ) :
                            ElevatedButton.icon(
                              icon: const Icon(Icons.app_registration_outlined),
                              label: const Text('Login'),
                              onPressed: () async {
                                changingName = false;
                                raterProvider!.rater!.name = raterNameController.text;
                                raterProvider!.rater!.status = Rater.STATUS_REGISTERED;
                                await raterProvider!.updateRater();
                                if(mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const RatingView()));
                              },
                            ),
                            const SizedBox(width: 15,),
                            raterProvider!.rater!.status == Rater.STATUS_NOT_REGISTERED ?
                            Container() :
                            ElevatedButton.icon(
                              icon: const Icon(Icons.edit),
                              label: const Text('Ändern'),
                              onPressed: () async {
                                raterProvider!.updateRater();
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  } else if (status == statusUsedOnOtherDevice){
                    col = Column(
                      children: [
                        Text("Jemand anderes ist mit diesen Daten bereits eingeloggt.\n Bitte nur auf einem Gerät einloggen, danke!"),
                      ],
                    );
                  } else {
                    col = Column(
                      children: [
                        Container(),
                      ],
                    );
                  }
                  return col;
                }
            ),
          ),
        ],
        ),
      ),
    );
  }

  Future<void> showDialog1() async {
    AlertDialog(
      title: Text("Fehler"),
      titleTextStyle:
      const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,fontSize: 20),
      actionsOverflowButtonSpacing: 20,
      actions: [
        ElevatedButton(onPressed: (){
          Navigator.of(context).pop();
        }, child: const Text("Ok")),
      ],
      content: const Text("Der Benutzer ist unbekannt!"),
    );
  }
}