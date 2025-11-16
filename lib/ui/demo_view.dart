import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:kagemuwa_umzug_common/data/model/rating_sync_state.dart';
import 'package:kagemuwa_umzug_web/ui/thankyou_view.dart';
import 'package:kagemuwa_umzug_common/data/model/rater.dart';
import 'package:kagemuwa_umzug_common/data/model/rating.dart';
import 'package:emojis/emoji.dart';
import 'package:kagemuwa_umzug_common/data/model/parade_number.dart';
import 'package:kagemuwa_umzug_common/helper/kagemuwa_colors.dart';
import 'package:kagemuwa_umzug_common/helper/kagemuwa_styles.dart';

class DemoView extends StatefulWidget {
  const DemoView({super.key});

  @override
  State<DemoView> createState() => _DemoViewState();
}

class _DemoViewState extends State<DemoView> {
  Rater? rater;
  List<ParadeNumber> paradeNumbers = [];
  List<Rating> ratings = [];
  ParadeNumber? currentParadeNumber;
  late FixedExtentScrollController scrollControllerOpticOriginality;
  late FixedExtentScrollController scrollControllerHumor;
  late FixedExtentScrollController scrollControllerDistanceVolume;

  dynamic dataLoaded;
  bool initialized = false;
  List<Text> ratePickerTexts = [
    const Text('1', style: KAGEMUWAStyles.ratingItemTextStyle,),
    const Text('2', style: KAGEMUWAStyles.ratingItemTextStyle,),
    const Text('3', style: KAGEMUWAStyles.ratingItemTextStyle,),
    const Text('4', style: KAGEMUWAStyles.ratingItemTextStyle,),
    const Text('5', style: KAGEMUWAStyles.ratingItemTextStyle,),
    const Text('6', style: KAGEMUWAStyles.ratingItemTextStyle,),
    const Text('7', style: KAGEMUWAStyles.ratingItemTextStyle,),
    const Text('8', style: KAGEMUWAStyles.ratingItemTextStyle,),
    const Text('9', style: KAGEMUWAStyles.ratingItemTextStyle,),
    const Text('10', style: KAGEMUWAStyles.ratingItemTextStyle,),
    const Text('11', style: KAGEMUWAStyles.ratingItemTextStyle,),];
  double eyeScale = 2.2;
  double sizeHumor = 0.9;
  double sizeOptic = 0.9;
  double sizeDistance = 0.9;

  @override
  void initState() {
    super.initState();

    scrollControllerOpticOriginality = FixedExtentScrollController(initialItem: 0);
    scrollControllerHumor = FixedExtentScrollController(initialItem: 0);
    scrollControllerDistanceVolume = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    scrollControllerDistanceVolume.dispose();
    scrollControllerHumor.dispose();
    scrollControllerOpticOriginality.dispose();

    super.dispose();
  }

  Future<bool> init() async {
    rater = Rater("DEMO", "99", "DEMO_DEVICE", true, "DEMO", "DEMO_CAMPAIGN", "", Rater.STATUS_IN_PROGRESS, 1, Rater.RATING_METHOD_PICKER);

    paradeNumbers.add(ParadeNumber("ID1", 1, "De Zug kimmt", "KAGEMUWA", "KG", false));
    paradeNumbers.add(ParadeNumber("ID2", 2, "Wer do net nerd werd ...", "FG Die Nerde", "K", true));
    paradeNumbers.add(ParadeNumber("ID3", 3, "Mir senn die Helde", "CCC Groußebersdorf", "G", true));
    paradeNumbers.add(ParadeNumber("ID4", 4, "Kröten sind trumpf", "KV Die Kröter", "K", true));
    paradeNumbers.add(ParadeNumber("ID5", 5, "Wider die Robbenjagd", "Kalrobiche Kalroben", "G", true));
    paradeNumbers.add(ParadeNumber("ID6", 6, "Odenwälder Trachtenkapelle Mudau", "Musikverein Mudau", "M", false));
    paradeNumbers.add(ParadeNumber("ID7", 7, "Die Breuler", "KV Hinterdorf", "W", true));
    paradeNumbers.add(ParadeNumber("ID8", 8, "Hier steppt der Bär", "FG Schimmeldiwooch", "K", true));
    paradeNumbers.add(ParadeNumber("ID9", 9, "Vom Hinterdorf ins Vorderdorf", "FG Hinterdorf", "W", true));
    paradeNumbers.add(ParadeNumber("ID10", 10, "Andernorts geht's rund", "CCC Andernorts", "G", true));
    paradeNumbers.add(ParadeNumber("ID11", 11, "Die Heuler", "KV Vorderstadt", "W", true));

    currentParadeNumber = paradeNumbers.elementAt(rater!.currentParadeNumber - 1);

    for(int i = 1; i <= 11; i++) {
//      ratings.add(Rating(i, 1, 1, 1, 1));
      ratings.add(Rating(i, 1, 1, 1, RatingSyncState.synced));
    }
    initialized = true;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    double spacing = 10.0;
    double width = MediaQuery.of(context).size.width;
    double widthRatingPicker = width * 0.6 - 4.0 * spacing;

    if(!initialized) {
      dataLoaded = init();
    } else {
      currentParadeNumber = paradeNumbers.elementAt(rater!.currentParadeNumber - 1);
      // call this callback function after the UI ist built to jump to the right value of the cupertino picker
      // https://stackoverflow.com/questions/51216448/is-there-any-callback-to-tell-me-when-build-function-is-done-in-flutter
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollControllerOpticOriginality.jumpToItem(ratings.elementAt(currentParadeNumber!.number - 1).ratingOpticOriginality - 1);
        scrollControllerHumor.jumpToItem(ratings.elementAt(currentParadeNumber!.number - 1).ratingHumor - 1);
        scrollControllerDistanceVolume.jumpToItem(ratings.elementAt(currentParadeNumber!.number - 1).ratingDistanceVolume - 1);
      });
    }

    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text('Großer Odenwälder Rosenmontagsumzug', textScaler: TextScaler.linear(width / 500.0), textAlign: TextAlign.center,),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity! > 0) {
            gotoPreviousParadeNumber();
          } else if (details.primaryVelocity! < 0) {
            gotoNextParadeNumber();
          }
        },
        child: SingleChildScrollView(
          child: FutureBuilder<bool> (
              future: dataLoaded,
              builder: (context, AsyncSnapshot<bool> snapshot) {
                Column col;
                if (snapshot.data == null) {
                  col = const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 50,),
                      Center(
                        child:SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ],
                  );
                } else {
                  col = Column(
                    children: [
                      SizedBox(height: spacing,),
                      Stack(
                        children: [
                          SizedBox(
                            height: 80,
                            width: width,
                            child: Container(
                              padding: EdgeInsets.only(left: 2 * spacing, right: 2 * spacing),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: getBackgroundImage(currentParadeNumber!.type),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 5,
                            bottom: 5,
                            child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white70,
                                ),
                                child: Text(rater!.name)),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing/5,),
                      Card(
                        margin: EdgeInsets.all(spacing),
                        color: KAGEMUWAColors.cardBrightBackground,
                        child: Column(
                          children: [
                            SizedBox(height: spacing,),
                            Container(
                              padding: EdgeInsets.only(left: 2 * spacing, right: 2 * spacing),
                              child: Row(
                                children: [
                                  Text(currentParadeNumber!.getParadeTypeDescription(), style: KAGEMUWAStyles.cardBrightHeaderStyle, textScaler: TextScaler.linear(width / 500.0)),
                                  const Spacer(),
                                  Text("${currentParadeNumber!.number}/${paradeNumbers.length}", style: KAGEMUWAStyles.cardBrightHeaderStyle, textScaler: TextScaler.linear(width / 500.0)),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing,),
                            Container(
                              padding: EdgeInsets.only(left: spacing, right: spacing),
                              height: 50,
                              child: LayoutGrid(
                                columnSizes: const [auto, auto],
                                rowSizes: const [auto, auto],
                                rowGap: 5,
                                columnGap: 5,
                                children: [
                                  const Text("Titel", style: KAGEMUWAStyles.cardBrightBodyStyle),
                                  Text(currentParadeNumber!.name, style: KAGEMUWAStyles.cardBrightBodyStyle),
                                  const Text("Verein", style: KAGEMUWAStyles.cardBrightBodyStyle),
                                  Text(currentParadeNumber!.club, style: KAGEMUWAStyles.cardBrightBodyStyle),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: spacing/2,),

                      /// rating for the current parade number
                      if(currentParadeNumber!.type == "G" || currentParadeNumber!.type == "K" || currentParadeNumber!.type == "W") ...[
                        /// Optik / Originalität
                        Card(
                          color: KAGEMUWAColors.cardBrightBackground,
                          child: Column(
                            children: [
                              if(rater!.ratingMethod == Rater.RATING_METHOD_PICKER) ... [  /// use the picker as rating method
                                SizedBox(height: spacing,),
                                Row(
                                  children: [
                                    SizedBox(width: spacing / 2,),
                                    Container(
                                      height: 80,
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width * 0.4,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.orangeAccent
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(height: spacing,),
                                          Center(
                                            child: Text("Optik / Originalität",
                                              style: KAGEMUWAStyles
                                                  .cardBrightSubHeaderStyle,
                                              textScaler: TextScaler.linear(width / 500.0),
                                            ),
                                          ),
                                          SizedBox(height: spacing),
                                          Text(Emoji.byName("performing arts")
                                              .toString(),
                                            textScaler: TextScaler.linear(sizeOptic),),
                                          SizedBox(height: spacing),
                                        ],
                                      ),
                                    ),

                                    SizedBox(width: spacing,),
                                    Row(
                                      children: [
                                        Container(
                                          width: widthRatingPicker,
                                          height: 70,
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: KAGEMUWAColors
                                                  .ratingPickerBackgroundColor
                                          ),
                                          child: CupertinoPicker(
                                            looping: true,
                                            magnification: 1.22,
                                            squeeze: 1.2,
                                            useMagnifier: true,
                                            backgroundColor: KAGEMUWAColors
                                                .ratingPickerBackgroundColor,
                                            itemExtent: 20,
                                            scrollController: scrollControllerOpticOriginality,
                                            children: ratePickerTexts,
                                            onSelectedItemChanged: (value) {
                                              value++;
                                              eyeScale = 2.2 - value * 0.1;
                                              ratings.elementAt(currentParadeNumber!.number - 1)
                                                  .ratingOpticOriginality = value;
                                              sizeOptic = 0.9 + (value/1.7 - 1) * 0.1;
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        SizedBox(width: spacing,),
                                      ],
                                    ),
                                    SizedBox(height: spacing,),
                                  ],
                                ),
                                SizedBox(height: spacing,),
                              ] else ...[                               /// use the slider as rating method
                                SizedBox(height: spacing,),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 40,
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width - 2 * spacing,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: Colors.orangeAccent
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(width: spacing,),
                                              Center(
                                                child: Text("Optik / Originalität",
                                                  style: KAGEMUWAStyles
                                                      .cardBrightSubHeaderStyle,
                                                  textScaler: TextScaler.linear(width / 500.0),
                                                ),
                                              ),
                                              SizedBox(width: spacing),
                                              Text(Emoji.byName("performing arts")
                                                  .toString(),
                                                textScaler: TextScaler.linear(sizeOptic),),
                                              const Spacer(),
                                              Text(ratings.elementAt(currentParadeNumber!.number - 1).ratingOpticOriginality.toString(),
                                                style: KAGEMUWAStyles
                                                    .cardBrightSubHeaderStyle,
                                                textScaler: TextScaler.linear(width / 500.0),),
                                              SizedBox(width: 2 * spacing),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: spacing,),

                                Slider(
                                  min: 1.0,
                                  max: 11.0,
                                  divisions: 11,
                                  activeColor: Colors.orangeAccent,
                                  inactiveColor: Colors.orangeAccent.shade100,
                                  thumbColor: Colors.orangeAccent,
                                  label: '${ratings.elementAt(currentParadeNumber!.number - 1).ratingOpticOriginality}',
                                  value: ratings.elementAt(currentParadeNumber!.number - 1).ratingOpticOriginality.toDouble(),
                                  onChanged: (value) {
                                    setState(() {
                                      sizeOptic = 0.9 + (value/1.7 - 1) * 0.1;
                                      ratings.elementAt(currentParadeNumber!.number - 1).ratingOpticOriginality = value.toInt();
                                    });
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(height: spacing / 2,),

                        /// Stimmung
                        Card(
                          color: KAGEMUWAColors.cardBrightBackground,
                          child: Column(
                            children: [
                              if(rater!.ratingMethod == Rater.RATING_METHOD_PICKER) ... [  /// use the picker as rating method
                                SizedBox(height: spacing,),
                                Row(
                                  children: [
                                    SizedBox(width: spacing / 2,),
                                    Container(
                                      height: 80,
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width * 0.4,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.blueAccent
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(height: spacing,),
                                          Center(
                                            child: Text("Stimmung",
                                              style: KAGEMUWAStyles
                                                  .cardBrightSubHeaderStyle,
                                              textScaler: TextScaler.linear(width / 500.0),
                                            ),
                                          ),
                                          SizedBox(height: spacing),
                                          Text(
                                            Emoji.byName("party popper").toString(),
                                            textScaler: TextScaler.linear(sizeHumor),),
                                          SizedBox(height: spacing),
                                        ],
                                      ),
                                    ),

                                    SizedBox(width: spacing,),
                                    Row(
                                      children: [
                                        //SizedBox(width: spacing + 55/2,),
                                        Container(
                                          width: widthRatingPicker,
                                          height: 70,
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                  8),
                                              color: KAGEMUWAColors
                                                  .ratingPickerBackgroundColor
                                          ),
                                          child: CupertinoPicker(
                                            looping: true,
                                            magnification: 1.22,
                                            squeeze: 1.2,
                                            useMagnifier: true,
                                            backgroundColor: KAGEMUWAColors
                                                .ratingPickerBackgroundColor,
                                            itemExtent: 20,
                                            scrollController: scrollControllerHumor,
                                            children: ratePickerTexts,
                                            onSelectedItemChanged: (value) {
                                              value++;
                                              ratings.elementAt(currentParadeNumber!.number - 1)
                                                  .ratingHumor = value;
                                              sizeHumor = 0.9 + (value/1.7 - 1) * 0.1;
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        SizedBox(width: spacing,),
                                      ],
                                    ),
                                    SizedBox(height: spacing,),
                                  ],
                                ),
                                SizedBox(height: spacing,),
                              ] else ... [
                                SizedBox(height: spacing,),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 40,
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width - 2 * spacing,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: Colors.blueAccent
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(width: spacing,),
                                              Center(
                                                child: Text("Stimmung",
                                                  style: KAGEMUWAStyles
                                                      .cardBrightSubHeaderStyle,
                                                  textScaler: TextScaler.linear(width / 500.0),
                                                ),
                                              ),
                                              SizedBox(width: spacing),
                                              Text(Emoji.byName("party popper")
                                                  .toString(),
                                                textScaler: TextScaler.linear(sizeHumor),),
                                              const Spacer(),
                                              Text(ratings.elementAt(currentParadeNumber!.number - 1).ratingHumor.toString(),
                                                style: KAGEMUWAStyles
                                                    .cardBrightSubHeaderStyle,
                                                textScaler: TextScaler.linear(width / 500.0),),
                                              SizedBox(width: 2 * spacing),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: spacing,),

                                Slider(
                                  min: 1.0,
                                  max: 11.0,
                                  divisions: 11,
                                  activeColor: Colors.blueAccent,
                                  inactiveColor: Colors.blueAccent.shade100,
                                  thumbColor: Colors.blueAccent,
                                  label: '${ratings.elementAt(currentParadeNumber!.number - 1).ratingHumor}',
                                  value: ratings.elementAt(currentParadeNumber!.number - 1).ratingHumor.toDouble(),
                                  onChanged: (value) {
                                    setState(() {
                                      sizeHumor = 0.9 + (value/1.7 - 1) * 0.1;
                                      ratings.elementAt(currentParadeNumber!.number - 1).ratingHumor = value.toInt();
                                    });
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(height: spacing / 2,),

                        /// Abstand & Lautstärke
                        Card(
                          color: KAGEMUWAColors.cardBrightBackground,
                          child: Column(
                            children: [
                              if(rater!.ratingMethod == Rater.RATING_METHOD_PICKER) ... [  /// use the picker as rating method
                                SizedBox(height: spacing,),
                                Row(
                                  children: [
                                    SizedBox(width: spacing / 2,),
                                    Container(
                                      height: 80,
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width * 0.4,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.deepPurpleAccent
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(height: spacing,),
                                          Center(
                                            child: Text("Abstand / Lautstärke",
                                              style: KAGEMUWAStyles
                                                  .cardBrightSubHeaderStyle,
                                              textScaler: TextScaler.linear(width / 500.0),
                                            ),
                                          ),
                                          SizedBox(height: spacing),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .center,
                                            children: [
                                              Text(Emoji.byName("left-right arrow")
                                                  .toString(),
                                                textScaler: TextScaler.linear(sizeDistance),),
                                              SizedBox(width: 2 * spacing),
                                              Text(
                                                Emoji.byName("speaker high volume")
                                                    .toString(),
                                                textScaler: TextScaler.linear(sizeDistance),),
                                            ],
                                          ),
                                          SizedBox(height: spacing),
                                        ],
                                      ),
                                    ),

                                    SizedBox(width: spacing,),
                                    Row(
                                      children: [
                                        //SizedBox(width: spacing + 55/2,),
                                        Container(
                                          width: widthRatingPicker,
                                          height: 70,
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                  8),
                                              color: KAGEMUWAColors
                                                  .ratingPickerBackgroundColor
                                          ),
                                          child: CupertinoPicker(
                                            looping: true,
                                            magnification: 1.22,
                                            squeeze: 1.2,
                                            useMagnifier: true,
                                            backgroundColor: KAGEMUWAColors
                                                .ratingPickerBackgroundColor,
                                            itemExtent: 20,
                                            scrollController: scrollControllerDistanceVolume,
                                            children: ratePickerTexts,
                                            onSelectedItemChanged: (value) {
                                              value++;
                                              ratings.elementAt(currentParadeNumber!.number - 1)
                                                  .ratingDistanceVolume = value;
                                              sizeDistance = 0.9 + (value/1.7 - 1) * 0.1;
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        SizedBox(width: spacing,),
                                      ],
                                    ),
                                    SizedBox(height: spacing,),
                                  ],
                                ),
                                SizedBox(height: spacing,),
                              ] else ... [
                                SizedBox(height: spacing,),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 40,
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width - 2 * spacing,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: Colors.deepPurpleAccent
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(width: spacing,),
                                              Center(
                                                child: Text("Abstand / Lautstärke",
                                                  style: KAGEMUWAStyles
                                                      .cardBrightSubHeaderStyle,
                                                  textScaler: TextScaler.linear(width / 500.0),
                                                ),
                                              ),
                                              SizedBox(width: spacing),
                                              Text(Emoji.byName("left-right arrow")
                                                  .toString(),
                                                textScaler: TextScaler.linear(1.7),),
                                              SizedBox(width: 3 * spacing),
                                              Text(
                                                Emoji.byName("speaker high volume")
                                                    .toString(),
                                                textScaler: TextScaler.linear(2.0),),
                                              const Spacer(),
                                              Text(ratings.elementAt(currentParadeNumber!.number - 1).ratingDistanceVolume.toString(),
                                                style: KAGEMUWAStyles
                                                    .cardBrightSubHeaderStyle,
                                                textScaler: TextScaler.linear(width / 500.0),),
                                              SizedBox(width: 2 * spacing),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: spacing,),

                                Slider(
                                  min: 1.0,
                                  max: 11.0,
                                  divisions: 11,
                                  activeColor: Colors.deepPurpleAccent,
                                  inactiveColor: Colors.deepPurpleAccent.shade100,
                                  thumbColor: Colors.deepPurpleAccent,
                                  label: '${ratings.elementAt(currentParadeNumber!.number - 1).ratingDistanceVolume}',
                                  value: ratings.elementAt(currentParadeNumber!.number - 1).ratingDistanceVolume.toDouble(),
                                  onChanged: (value) {
                                    setState(() {
                                      sizeDistance = 0.9 + (value/1.7 - 1) * 0.1;
                                      ratings.elementAt(currentParadeNumber!.number - 1).ratingDistanceVolume = value.toInt();
                                    });
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),


                      ] else ...[ /// no rating for the current parade number
                        const Text("Keine Bewertung"),
                        SizedBox(height: spacing,),
                        Image.asset("assets/kagemuwakasperblack.webp"),
                        SizedBox(height: spacing,),
                        const Text("für diese Zugnummer"),
                      ],

                      SizedBox(height: spacing,),
                      Row(
                        children: [
                          SizedBox(width: 4 * spacing,),
                          IconButton(
                            onPressed: gotoPreviousParadeNumber,
                            icon: const Icon(Icons.navigate_before_outlined),
                          ),
                          const Spacer(),
                          IconButton(onPressed: gotoNextParadeNumber,
                            icon: const Icon(Icons.navigate_next_outlined),
                          ),
                          SizedBox(width: 4 * spacing,),
                        ],
                      ),
                    ],
                  );
                }
                return col;
              }
          ),
        ),
      ),
    );
  }

  void gotoNextParadeNumber() async {
    if(rater!.currentParadeNumber < paradeNumbers.length) {
      rater!.currentParadeNumber++;
      setState(() {});
    } else {  /// if the rater rated all parade numbers - ask if he wants to end the rating
      bool result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Bestätigung'),
            content: const Text('Möchtest Du die Zugbewertung beenden?'),
            actions: <Widget>[
              ElevatedButton.icon(
                icon: const Icon(Icons.stop_circle_rounded),
                label: const Text('Ja'),
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true)
                      .pop(true); // dismisses only the dialog and returns true
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Nein'),
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true)
                      .pop(false); // dismisses only the dialog and returns false
                },
              ),
            ],
          );
        },
      );
      if (result) {
        rater!.status = Rater.STATUS_FINISHED;
        if(mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const ThankYouView())); // dismisses the entire widget
      } else {
        setState(() {});
      }
    }
  }

  void gotoPreviousParadeNumber() {
    if(rater!.currentParadeNumber > 1) {
      rater!.currentParadeNumber--;
    }
    setState(() {

    });
  }

  AssetImage getBackgroundImage(String type) {
    switch(type) {
      case "W": return const AssetImage("assets/header_wagen.webp");
      case "G": return const AssetImage("assets/header_grossgruppe.webp");
      case "K": return const AssetImage("assets/header_kleingruppe.webp");
      case "R": return const AssetImage("assets/background.jpg");
      case "M": return const AssetImage("assets/header_musikverein.webp");
      case "KG": return const AssetImage("assets/background.jpg");
      default: return const AssetImage("assets/background.jpg");
    }
  }
}