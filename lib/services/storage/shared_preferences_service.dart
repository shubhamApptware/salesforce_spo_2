import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  /// Set value in storage using key
  void setKey({required String key, required String value}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  /// Set user auth token
  void setUserToken({required String authToken}) {
    setKey(key: 'token', value: authToken);
  }

  /// Get user auth token
  Future<String?> getUserToken({required key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Clear shared preferences
  void clearStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}