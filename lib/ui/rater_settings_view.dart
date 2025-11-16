import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:kagemuwa_umzug_common/data/model/rater.dart';
import 'package:kagemuwa_umzug_common/helper/kagemuwa_colors.dart';
import 'package:kagemuwa_umzug_common/helper/kagemuwa_styles.dart';

import '../provider/rater_provider.dart';

enum RatingMethod { picker, slider }

class RaterSettingsView extends StatefulWidget {
  final RaterProvider raterProvider;
  const RaterSettingsView({super.key, required this.raterProvider});

  @override
  State<RaterSettingsView> createState() => _RaterSettingsViewState();
}

class _RaterSettingsViewState extends State<RaterSettingsView> {
  RaterProvider get raterProvider => widget.raterProvider;
  RatingMethod? _method;

  @override
  Widget build(BuildContext context) {
    double spacing = 10.0;
    double width = MediaQuery.of(context).size.width;

    if(raterProvider.rater!.ratingMethod == Rater.RATING_METHOD_PICKER) {
      _method= RatingMethod.picker;
    } else {
      _method= RatingMethod.slider;
    }

    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text('Großer Odenwälder Rosenmontagsumzug', textScaler: TextScaler.linear(width / 500.0), textAlign: TextAlign.center,),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Card(
            color: KAGEMUWAColors.cardBrightBackground,
            child: Column(
              children: [
                SizedBox(height: spacing,),
                Text("Bewertungsmethode", style: KAGEMUWAStyles.cardBrightHeaderStyle, textScaler: TextScaler.linear(width / 500.0)),
                RadioGroup<RatingMethod>(
                  groupValue: _method,
                  onChanged: (value) {
                    setState(() {
                      _method = value;
                      if (value == RatingMethod.picker) {
                        raterProvider.rater!.ratingMethod = Rater.RATING_METHOD_PICKER;
                      } else if (value == RatingMethod.slider) {
                        raterProvider.rater!.ratingMethod = Rater.RATING_METHOD_SLIDER;
                      }
                      raterProvider.updateRater();
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                    const ListTile(
                      title: Text("Picker"),
                      leading: Radio<RatingMethod>(value:RatingMethod.picker),
                    ),
                      const ListTile(
                      title: Text("Slider"),
                      leading: Radio<RatingMethod>(value:RatingMethod.slider),
                    ),
                    ],
                  ),
                ),
                  /*RadioListTile<RatingMethod>(
                  title: const Text('Picker'),
                  value: RatingMethod.picker,
                  groupValue: _method,
                  onChanged: (RatingMethod? value) {
                    setState(() {
                      _method = value;
                      raterProvider.rater!.ratingMethod = Rater.RATING_METHOD_PICKER;
                      raterProvider.updateRater();
                    });
                  },
                ),
                RadioListTile<RatingMethod>(
                  title: const Text('Slider'),
                  value: RatingMethod.slider,
                  groupValue: _method,
                  onChanged: (RatingMethod? value) {
                    setState(() {
                      _method = value;
                      raterProvider.rater!.ratingMethod = Rater.RATING_METHOD_SLIDER;
                      raterProvider.updateRater();
                    });
                  },
                ),*/
                SizedBox(height: spacing,),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Zurück'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: spacing,),
          Card(
            color: KAGEMUWAColors.cardBrightBackground,
            child: Column(
              children: [
                SizedBox(height: spacing,),
                Text("Benutzerdaten", style: KAGEMUWAStyles.cardBrightHeaderStyle, textScaler: TextScaler.linear(width / 500.0)),
                SizedBox(height: spacing,),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: LayoutGrid(
                    columnSizes: const [auto, auto],
                    rowSizes: const [auto, auto, auto, auto],
                    rowGap: 5,
                    columnGap: 5,
                    children: <Widget> [
                      const Text("Name: ", style: KAGEMUWAStyles.cardBrightBodyStyle,),
                      Text(raterProvider.rater!.name, style: KAGEMUWAStyles.cardBrightBodyStyle),
                      const Text("ID: ", style: KAGEMUWAStyles.cardBrightBodyStyle,),
                      Text(raterProvider.rater!.id, style: KAGEMUWAStyles.cardBrightBodyStyle),
                      const Text("rating ID: ", style: KAGEMUWAStyles.cardBrightBodyStyle,),
                      Text(raterProvider.rater!.ratingID, style: KAGEMUWAStyles.cardBrightBodyStyle),
                      const Text("device ID: ", style: KAGEMUWAStyles.cardBrightBodyStyle,),
                      Text(raterProvider.rater!.deviceID, style: KAGEMUWAStyles.cardBrightBodyStyle),
                    ],
                  ),
                ),

                SizedBox(height: spacing,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}