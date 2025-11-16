import 'dart:collection';
import 'package:kagemuwa_umzug_common/data/model/rating.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageWrapper {
  bool initialized = false;
  HashMap localStorageContent = HashMap();
  SharedPreferences? prefs;
  String campaign = "";

  LocalStorageWrapper();

  Future<void> load(String campaign) async {
    this.campaign = campaign;
    prefs = await SharedPreferences.getInstance();
    initialized = true;
  }

  bool isInitialized() {
    return initialized;
  }

  void getRating(Rating rating) {
    String key = _getKey(rating.paradeNumberNumber);
    String? storedRating = prefs?.getString(key);

    if(storedRating == '' || storedRating == null) {
      // nothing to do
    } else {
      _decodeRating(rating, storedRating);
    }
  }

  void removeRating(Rating rating) {
    String key = _getKey(rating.paradeNumberNumber);
    prefs?.remove(key);
  }

  void setRating(Rating rating) {
    String key = _getKey(rating.paradeNumberNumber);

    prefs?.setString(key, _encodeRatingForStorage(rating));
  }

  void _decodeRating(Rating rating, String storedRating) {
    final split = storedRating.split(',');
    final Map<int, String> values = {
      for (int i = 0; i < split.length; i++)
        i: split[i]
    };
    rating.ratingOpticOriginality = int.parse(values[0]!);
    rating.ratingHumor = int.parse(values[1]!);
    rating.ratingDistanceVolume = int.parse(values[2]!);
  }

  String _getKey(int number) {
    return 'kagemuwaID_${campaign}_$number';
  }

  String _encodeRatingForStorage(Rating rating) {
    return "${rating.ratingOpticOriginality},${rating.ratingHumor},${rating.ratingDistanceVolume}";
  }
}