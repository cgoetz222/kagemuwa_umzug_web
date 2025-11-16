import 'package:kagemuwa_umzug_common/data/model/rating_sync_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:kagemuwa_umzug_common/data/model/rating.dart';
import 'package:kagemuwa_umzug_common/data/model/rater.dart';
import 'package:kagemuwa_umzug_common/data/repository/firebase_repository.dart';

class RaterProvider with ChangeNotifier {
  bool loaded = false;
  String? campaignYear;
  Rater? rater;
  List<Rating> ratings = [];

  RaterProvider();

  Future<bool> load(String raterNumber, String campaignYear) async {
    rater = await FirebaseRepository().getRaterByNumber(raterNumber, campaignYear);
    if(rater!.deviceID == "") {
      rater!.deviceID = await getUniqueRaterId();
      await FirebaseRepository().updateRater(rater!, campaignYear);
    }

    debugPrint("device: ${rater!.deviceID}");

    loaded = true;

    return true;
  }

  Future<bool> signIn(String raterNumber, String campaignYear) async {
    rater!.login = true;
    rater!.status = Rater.STATUS_NOT_REGISTERED;

    await FirebaseRepository().updateRater(rater!, campaignYear);

    return true;
  }

  Future<void> loadRatings() async {
    ratings = await FirebaseRepository().getRatings(rater!);
    ratings.sort();
  }

  Rating? getCurrentRating(int paradeNumberNumber) {
    return ratings.elementAt(paradeNumberNumber - 1);
  }

  Future<String> getUniqueRaterId() async {
    String? uniqueRaterId = '';

    final prefs = await SharedPreferences.getInstance();
    uniqueRaterId = prefs.getString('kagemuwaID');

    if(uniqueRaterId == '' || uniqueRaterId == null) {
      uniqueRaterId = Uuid().v1();
      prefs.setString('kagemuwaID', uniqueRaterId);
    }

    debugPrint('unique rater ID $uniqueRaterId');
    //uniqueRaterId = '1';
    return uniqueRaterId;
  }

/*  void registerRater(raterID, campaignYear) async {
    this.raterID = raterID;
    this.campaignYear = campaignYear;

    // get the rater from
    rater = await FirebaseRepository().getRater(raterID!, campaignYear!);

    rater!.deviceID = await getUniqueDeviceId();
    rater!.status = Rater.STATUS_REGISTERED;
    await FirebaseRepository().updateRater(rater!);

    notifyListeners();
  }*/

  Future<void> updateRater() async {
    await FirebaseRepository().updateRater(rater!, campaignYear!);

    notifyListeners();
  }

  Future<void> updateRating() async {
    await FirebaseRepository().updateRating(rater!, getCurrentRating(rater!.currentParadeNumber)!);

    notifyListeners();
  }

  bool allRatingsSaved() {
    bool everythingSaved = true;
    for(Rating rating in ratings) {
      if(rating.syncState != RatingSyncState.synced) {
        everythingSaved = false;
      }
    }
    return everythingSaved;
  }
}