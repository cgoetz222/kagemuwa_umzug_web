import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kagemuwa_umzug_web/ui/widgets/card_menu_item.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:kagemuwa_umzug_common/data/provider/parade_provider.dart';
import 'package:kagemuwa_umzug_common/helper/kagemuwa_colors.dart';
import 'package:kagemuwa_umzug_common/helper/kagemuwa_styles.dart';
import 'package:kagemuwa_umzug_web/provider/rater_provider.dart';
import 'package:kagemuwa_umzug_web/ui/demo_view.dart';
import 'package:kagemuwa_umzug_web/ui/login_view.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/repository/firebase_options.dart';
import 'package:package_info_plus/package_info_plus.dart';

/*void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KaGeMuWa Umzug',
      theme: ThemeData(
          primarySwatch: KAGEMUWAColors.kagemuwaColor,
          scaffoldBackgroundColor: KAGEMUWAColors.kagemuwaBackgroundColor
      ),
      home: const MyHomePage(title: 'Großer Odenwälder Rosenmontagsumzug'),
    );
  }
}*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ParadeProvider()),
        ChangeNotifierProvider(create: (context) => RaterProvider()),
      ],
      child: MaterialApp(
        title: 'KaGeMuWa Umzug',
        theme: ThemeData(
            primarySwatch: KAGEMUWAColors.kagemuwaColor,
            scaffoldBackgroundColor: KAGEMUWAColors.kagemuwaBackgroundColor
        ),
        home: const MyHomePage(title: 'Großer Odenwälder Rosenmontagsumzug',),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final double RATIO = 733.0 / 1100.0;
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer? timer;
  int imageIndex = 0;
  bool connected = false;
  final images = [
    Image.asset("assets/kagemuwa_romo_00.jpg", key: const Key('1'),),
    Image.asset("assets/kagemuwa_romo_01.jpg", key: const Key('2'),),
    Image.asset("assets/kagemuwa_romo_02.jpg", key: const Key('3'),),
    Image.asset("assets/kagemuwa_romo_03.jpg", key: const Key('4'),),
    Image.asset("assets/kagemuwa_romo_04.jpg", key: const Key('5'),),
    Image.asset("assets/kagemuwa_romo_05.jpg", key: const Key('6'),),
    Image.asset("assets/kagemuwa_romo_06.jpg", key: const Key('7'),),
    Image.asset("assets/kagemuwa_romo_07.jpg", key: const Key('8'),),
    Image.asset("assets/kagemuwa_romo_08.jpg", key: const Key('9'),),
    Image.asset("assets/kagemuwa_romo_09.jpg", key: const Key('10'),),
    Image.asset("assets/kagemuwa_romo_10.jpg", key: const Key('11'),),
  ];

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      final isLastIndex = imageIndex == images.length - 1;

      setState(() => imageIndex = isLastIndex ? 0 : imageIndex + 1);
    });

    super.initState();
  }

  @override void dispose() {
    timer?.cancel();

    super.dispose();
  }

  Future<bool> load() async {
    connected = await InternetConnection().hasInternetAccess;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    const double spacing = 10.0;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double picWidth = width;
    double picHeight;
    if(height >= 600) {
      picHeight = width * widget.RATIO;
    } else {
      picWidth -= 20;
      picHeight = picWidth * widget.RATIO;
    }

    double buttonSize = (height - width - 2.0 * spacing) * 7.0 / 10.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, textScaler: TextScaler.linear(width / 500.0), textAlign: TextAlign.center,),
      ),
      drawer: Drawer(
        backgroundColor: KAGEMUWAColors.menuBackgroundColor,
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: KAGEMUWAColors.menuBackgroundColor,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset("assets/WassersucherLogo.png"),
              ),
            ),
            ListTile(
              title: const Text('Login'),
              leading: const Icon(Icons.login_outlined),
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginView()));
              },
            ),
            ListTile(
              title: const Text('Testzugang'),
              leading: const Icon(Icons.explore_outlined),
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DemoView()));
              },
            ),
            ListTile(
              title: const Text('Über'),
              leading: const Icon(Icons.info_outline),
              onTap: () {
                showAlertDialogAbout(context);
              },
            ),
            ListTile(
              title: const Text('Datenschutz'),
              leading: const Icon(Icons.policy_outlined),
              onTap: () {
                showAlertDialogPolicy(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text("Mudi HAJO\nGroßer Odenwälder\nRosenmontagsumzug", style: KAGEMUWAStyles.startPageTextFieldStyle, textAlign: TextAlign.center, textScaler: TextScaler.linear(height / 750.0)),
            const Spacer(flex: 1,),
            SizedBox(width: buttonSize, height: buttonSize,
                child: FutureBuilder<bool>(
                    future: load(),
                    builder: (context, AsyncSnapshot<bool> snapshot) {
                      Widget widget;
                      if(connected) {
                        widget = InkWell(
                            child: CardMenuItemWidget(size: buttonSize,
                                description: 'Login',
                                iconData: Icons.login_outlined,
                                color: KAGEMUWAColors.menuCardGrey),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (
                                      context) => const LoginView()));
                            },
                          );
                      } else {
                        debugPrint("kein Internet");
                        widget = Container(
                          color: KAGEMUWAColors.menuCardGrey,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              SizedBox(
                                height: 300,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 30,),
                                      Text("Achtung", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                      SizedBox(height: 5,),
                                      Text("Keine Internetverbindung!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      SizedBox(height: 20,),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -10,
                                child: CircleAvatar(
                                  backgroundColor: Colors.redAccent,
                                  radius: 50,
                                  child: Icon(Icons.wifi_off, size: 80, color: Colors.white,),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return widget;
                    }
                ),
            ),

            const Spacer(flex: 1,),
            SizedBox(width: picWidth, height: picHeight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 2000),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: images[imageIndex],
              ),
            )
                /*: Container(),*/
          ],
        ),
        //)
      ),
      //),
    );
  }
  /*
    Widget build(BuildContext context) {
    const double spacing = 10.0;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double picWidth = width;
    double picHeight;
    if(height >= 600) {
      picHeight = width * widget.RATIO;
    } else {
      picWidth -= 20;
      picHeight = picWidth * widget.RATIO;
    }

    double buttonSize = (height - width - 2.0 * spacing) * 7.0 / 10.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, textScaler: TextScaler.linear(width / 500.0), textAlign: TextAlign.center,),
      ),
      drawer: Drawer(
        backgroundColor: KAGEMUWAColors.menuBackgroundColor,
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: KAGEMUWAColors.menuBackgroundColor,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset("assets/WassersucherLogo.png"),
              ),
            ),
            ListTile(
              title: const Text('Login'),
              leading: const Icon(Icons.login_outlined),
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginView()));
              },
            ),
            ListTile(
              title: const Text('Testzugang'),
              leading: const Icon(Icons.explore_outlined),
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DemoView()));
              },
            ),
            ListTile(
              title: const Text('Über'),
              leading: const Icon(Icons.info_outline),
              onTap: () {
                showAlertDialogAbout(context);
              },
            ),
            ListTile(
              title: const Text('Datenschutz'),
              leading: const Icon(Icons.policy_outlined),
              onTap: () {
                showAlertDialogPolicy(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        //child: SingleChildScrollView(
        //child: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text("Mudi HAJO\nGroßer Odenwälder\nRosenmontagsumzug", style: KAGEMUWAStyles.startPageTextFieldStyle, textAlign: TextAlign.center, textScaler: TextScaler.linear(height / 750.0)),
            const Spacer(flex: 1,),
            SizedBox(width: buttonSize, height: buttonSize,
                child: InkWell(
                  child: CardMenuItemWidget(size: buttonSize, description: 'Login', iconData: Icons.login_outlined, color: KAGEMUWAColors.menuCardGrey),
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginView()));
                  },
                )
            ),

            const Spacer(flex: 1,),
            //height > 500 ?
            SizedBox(width: picWidth, height: picHeight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 2000),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: images[imageIndex],
              ),
            )
                /*: Container(),*/
          ],
        ),
        //)
      ),
      //),
    );
  }
   */
  void showAlertDialogAbout(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Über"),
      content: Column(
        children: [
          const Text("Diese App dient zur Bewertung der Teilnehmer des Großen Odenwälder Rosenmontagsumzugs der KG Mudemer Wassersucher e.V..\n\nSie wurde geschrieben von:\n\n     Carlo Götz (© 2023)"),
          const SizedBox(height: 10,),
          Text("Version: ${packageInfo.version}  Build: ${packageInfo.buildNumber}"),
        ],
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showAlertDialogPolicy(BuildContext context) async {
    Widget html = Html(
        data: """
        <html>
          <body>
            <h2>Datenschutzhinweis</h2>
            <p>Die KG Mudemer Wassersucher e.V. legt großen Wert auf den Schutz Deiner personenbezogenen Daten.<br>
            Wir behandeln Deine personenbezogenen Daten vertraulich und entsprechend der gesetzlichen Datenschutzvorschriften sowie dieser Datenschutzerklärung. Personenbezogene Daten sind Daten, mit denen Du persönlich identifiziert werden kannst.<br>
            Die vorliegende Datenschutzerklärung erläutert, welche Daten wir erheben und wofür wir sie nutzen. Sie erläutert auch, wie und zu welchem Zweck das geschieht. Ausführliche Informationen zum Thema Datenschutz findest Du auf unserer unserer Homepage www.kagemuwa.de</p>
            <h2>Datenerfassung innerhalb unserer App</h2>
            <h3>Wer ist verantwortlich für die Datenerfassung innerhalb der App?</h3>
            <p>Die verantwortliche Stelle für die Datenverarbeitung in dieser App ist die Karnevalsgesellschaft Mudemer Wassersucher e. V. vertreten durch<br>
            1. Vorstand Helmut Korger jun.<br>
            E-Mail: Hajo@KaGeMuWa.de</p>
            <h3>Wie erfassen wir Deine Daten?</h3>
            <p>Deine Daten werden dadurch erhoben, dass Du uns diese mitteilst.<br>
            Wenn Du diese App benutzt, wird nur Dein Vorname oder ein Nickname von Dir erfasst, den Du selbst eingeben und ändern kannst. Dieser Name wird in der Online Datenbank von Goolge (Firebase) gespeichert.
            Ebenso speichern wir die ID Deines Smartphones.</p>
            <h3>Wofür nutzen wir Deine Daten?</h3>
            <p>Der Name dient ausschließlich dazu, dass wir Dich als Bewerter oder Bewerterin unseres Rosenmontagsumzugs innerhalb der App mit Namen ansprechen können.<br>
            Er wird nicht an Dritte weitergegeben.<br>
            Die ID Deines Smartphones dient dazu, dass sich nicht zwei Personen mit dem gleichen QR-Code auf zwei unterschiedlichen Endgeräten einloggen.
            Nach der Bewertung werden alle Namen und IDs in der Google-Datenbank gelöscht.</p>
          </body>
        </html>"""
    );

    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Datenschutz"),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: html,
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

/*class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}*/