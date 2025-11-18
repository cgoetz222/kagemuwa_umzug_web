import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:kagemuwa_umzug_common/data/model/rating_sync_state.dart';
import 'package:kagemuwa_umzug_web/provider/rater_provider.dart';
import 'package:kagemuwa_umzug_web/ui/rater_settings_view.dart';
import 'package:kagemuwa_umzug_web/ui/thankyou_view.dart';
import 'package:kagemuwa_umzug_common/data/model/rater.dart';
import 'package:kagemuwa_umzug_web/ui/widgets/custom_alert_dialog.dart';
import 'package:provider/provider.dart';
import 'package:emojis/emoji.dart';
import 'package:kagemuwa_umzug_common/data/model/parade_number.dart';
import 'package:kagemuwa_umzug_common/helper/kagemuwa_colors.dart';
import 'package:kagemuwa_umzug_common/helper/kagemuwa_styles.dart';
import 'package:kagemuwa_umzug_common/data/provider/parade_provider.dart';

class RatingView extends StatefulWidget {
  const RatingView({super.key});
//  const RatingView({Key? key}) : super(key: key);

  @override
  State<RatingView> createState() => _RatingViewState();
}

class _RatingViewState extends State<RatingView> {
  ParadeProvider? paradeProvider;
  RaterProvider? raterProvider;
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
    paradeProvider = Provider.of<ParadeProvider>(context, listen: true);
    raterProvider = Provider.of<RaterProvider>(context, listen: false);
    await paradeProvider!.load();
    await raterProvider!.loadRatings();

    currentParadeNumber = paradeProvider!.paradeNumbers!.elementAt(raterProvider!.rater!.currentParadeNumber - 1);
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
      currentParadeNumber = paradeProvider!.paradeNumbers!.elementAt(raterProvider!.rater!.currentParadeNumber - 1);
      // call this callback function after the UI ist built to jump to the right value of the cupertino picker
      // https://stackoverflow.com/questions/51216448/is-there-any-callback-to-tell-me-when-build-function-is-done-in-flutter
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollControllerOpticOriginality.jumpToItem(raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.ratingOpticOriginality - 1);
        scrollControllerHumor.jumpToItem(raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.ratingHumor - 1);
        scrollControllerDistanceVolume.jumpToItem(raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.ratingDistanceVolume - 1);
      });
    }
    //int nummm = currentParadeNumber!.number;
    //RatingSyncState syncState = raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.syncState;
    //debugPrint("number: $nummm status: $syncState");

    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text('Großer Odenwälder Rosenmontagsumzug', textScaler: TextScaler.linear(width / 500.0), textAlign: TextAlign.center,),
        actions: [
          PopupMenuButton(
              onSelected: (value) {
                if(value == 1) {
                  //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => RaterSettingsView(raterProvider: raterProvider!,)));
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RaterSettingsView(raterProvider: raterProvider!,))).then((_){setState(() {});});
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 1,
                  child: Text("Einstellungen"),
                ),
              ]
          )
        ],
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
                                child: Row(
                                  children: [
                                    (raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.syncState == RatingSyncState.synced) ?
                                    Text(Emoji.byName("check mark button")
                                        .toString(),
                                      textScaler: TextScaler.linear(sizeOptic),) :
                                      Text(Emoji.byName("name badge")
                                        .toString(),
                                      textScaler: TextScaler.linear(sizeOptic),),
                                    SizedBox(width: 5,),
                                    Text(raterProvider!.rater!.name),
                                    SizedBox(width: 5,),
                                    (raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.syncState == RatingSyncState.synced) ?
                                    Text(Emoji.byName("check mark button")
                                        .toString(),
                                      textScaler: TextScaler.linear(sizeOptic),) :
                                    Text(Emoji.byName("name badge")
                                        .toString(),
                                      textScaler: TextScaler.linear(sizeOptic),),
                                  ],
                                ),
                              ),
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
                                  Text("${currentParadeNumber!.number}/${paradeProvider!.paradeNumbers!.length}", style: KAGEMUWAStyles.cardBrightHeaderStyle, textScaler: TextScaler.linear(width / 500.0)),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing,),
                            Container(
                              padding: EdgeInsets.only(left: spacing, right: spacing),
                              height: 90,
                              child: LayoutGrid(
                                columnSizes: const [auto, auto],
                                rowSizes: const [auto, auto, auto],
                                rowGap: 5,
                                columnGap: 5,
                                children: [
                                  const Text("Titel", style: KAGEMUWAStyles.cardBrightBodyStyle),
                                  Text(currentParadeNumber!.name, style: KAGEMUWAStyles.cardBrightBodyStyle),
                                  const Text("Verein", style: KAGEMUWAStyles.cardBrightBodyStyle),
                                  Text(currentParadeNumber!.club, style: KAGEMUWAStyles.cardBrightBodyStyle),

                                  // check whether it is a parade number which gates rated
                                  (currentParadeNumber!.type == "G" || currentParadeNumber!.type == "K" || currentParadeNumber!.type == "W") ?
                                    // then show the status
                                    const Text("Status", style: KAGEMUWAStyles.cardBrightBodyStyle) :
                                    // else show an empty container
                                    Container(),
                                  // check whether it is a parade number which gates rated
                                  (currentParadeNumber!.type == "G" || currentParadeNumber!.type == "K" || currentParadeNumber!.type == "W") ?
                                    // then check whether the Firebase status is synced
                                    (raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.syncState == RatingSyncState.synced) ?
                                      // show text in green
                                      Text("synchronisiert", style: KAGEMUWAStyles.cardBrightBodyGreenStyle) :
                                      // or if it is locally pending
                                      (raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.syncState == RatingSyncState.localPending) ?
                                        // show text in orange
                                        Text("nur lokal gespeichert", style: KAGEMUWAStyles.cardBrightBodyOrangeStyle) :
                                        // show text in red
                                        Text("Fehler beim Speichern", style: KAGEMUWAStyles.cardBrightBodyRedStyle) :
                                    // else show an empty container
                                    Container(),
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
                              if(raterProvider!.rater!.ratingMethod == Rater.RATING_METHOD_PICKER) ... [  /// use the picker as rating method
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
                                              raterProvider!.getCurrentRating(
                                                  raterProvider!.rater!
                                                      .currentParadeNumber)!
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
                                              Text(raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.ratingOpticOriginality.toString(),
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
                                  label: '${raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.ratingOpticOriginality}',
                                  value: raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.ratingOpticOriginality.toDouble(),
                                  onChanged: (value) {
                                    setState(() {
                                      sizeOptic = 0.9 + (value/1.7 - 1) * 0.1;
                                      raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.ratingOpticOriginality = value.toInt();
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
                              if(raterProvider!.rater!.ratingMethod == Rater.RATING_METHOD_PICKER) ... [  /// use the picker as rating method
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
                                              raterProvider!.getCurrentRating(
                                                  raterProvider!.rater!
                                                      .currentParadeNumber)!
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
                                              Text(raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.ratingHumor.toString(),
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
                                  label: '${raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.ratingHumor}',
                                  value: raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.ratingHumor.toDouble(),
                                  onChanged: (value) {
                                    setState(() {
                                      sizeHumor = 0.9 + (value/1.7 - 1) * 0.1;
                                      raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.ratingHumor = value.toInt();
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
                              if(raterProvider!.rater!.ratingMethod == Rater.RATING_METHOD_PICKER) ... [  /// use the picker as rating method
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
                                              SizedBox(width: 3 * spacing),
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
                                              raterProvider!.getCurrentRating(
                                                  raterProvider!.rater!
                                                      .currentParadeNumber)!
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
                                                  //textScaleFactor: width / 500.0,
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
                                              Text(raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.ratingDistanceVolume.toString(),
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
                                  label: '${raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.ratingDistanceVolume}',
                                  value: raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.ratingDistanceVolume.toDouble(),
                                  onChanged: (value) {
                                    setState(() {
                                      sizeDistance = 0.9 + (value/1.7 - 1) * 0.1;
                                      raterProvider!.getCurrentRating(raterProvider!.rater!.currentParadeNumber)!.ratingDistanceVolume = value.toInt();
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
    if(raterProvider!.rater!.currentParadeNumber < paradeProvider!.paradeNumbers!.length) {
      /// update the rating only if the current parade number is rated
      if(currentParadeNumber!.type == "G" || currentParadeNumber!.type == "K" || currentParadeNumber!.type == "W") {
        raterProvider!.updateRating();
      }
      raterProvider!.rater!.currentParadeNumber++;
      raterProvider!.updateRater();
      ParadeNumber number = paradeProvider!.paradeNumbers!.elementAt(raterProvider!.rater!.currentParadeNumber - 1);
      if(number.type == ParadeNumber.ZUGNUMMER_RESERVE) {
        gotoNextParadeNumber();
      } else {
        setState(() {

        });
      }
    } else {  /// if the rater rated all parade numbers -
      /// check if all ratings have been saved to firebase
      if(raterProvider!.allRatingsSaved()) {
        /// ask if he wants to end the rating
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
          raterProvider!.rater!.status = Rater.STATUS_FINISHED;
          raterProvider!.updateRater();
          if(mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const ThankYouView()));
        } else {
          setState(() {});
        }
      } else { /// not all ratings have been saved
        await showDialog(context: context, builder: (BuildContext context) {return CustomAlertDialog();});
        /*await AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.rightSlide,
            title: 'Achtung!',
            desc: 'Achtung - Deine Daten wurden nicht korrekt gesendet!\nMöglicherweise hast Du keine Internetverbindung!\nBitte gehe an einen Ort, wo Du eine Internetverbindung hast.\nDie Daten werden dann automatisch gespeichert.\nBitte schließe den Browser nicht, danke.',
            btnCancelOnPress: () {},
            btnOkOnPress: () {},
        ).show();*/
        /*await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Fehler beim Speichern!'),
              content: const Text('Achtung - Deine Daten wurden nicht korrekt gesendet!\nMöglicherweise hast Du keine Internetverbindung!\nBitte gehe an einen Ort, wo Du eine Internetverbindung hast.\nDie Daten werden dann automatisch gespeichert.\nBitte schließe den Browser nicht, danke.'),
              actions: <Widget>[
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('OK'),
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true)
                        .pop(true); // dismisses only the dialog and returns true
                  },
                ),
              ],
            );
          },
        );*/
      }
    }
  }

  void gotoPreviousParadeNumber() {
    if(raterProvider!.rater!.currentParadeNumber > 1) {
      /// update the rating only if the current parade number is rated
      if(currentParadeNumber!.type == "G" || currentParadeNumber!.type == "K" || currentParadeNumber!.type == "W") {
        raterProvider!.updateRating();
      }
      raterProvider!.rater!.currentParadeNumber--;
      raterProvider!.updateRater();
    }
    ParadeNumber number = paradeProvider!.paradeNumbers!.elementAt(raterProvider!.rater!.currentParadeNumber - 1);
    if(number.type == ParadeNumber.ZUGNUMMER_RESERVE) {
      gotoPreviousParadeNumber();
    } else {
      setState(() {

      });
    }
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