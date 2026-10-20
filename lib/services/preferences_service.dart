import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  SharedPreferences? _prefs;

  static const String _keyFavorites = 'kairo_favorite_event_ids';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<String> get favoriteIds {
    return _prefs?.getStringList(_keyFavorites) ?? [];
  }

  Future<void> toggleFavorite(String eventId) async {
    final ids = favoriteIds.toList();
    if (ids.contains(eventId)) {
      ids.remove(eventId);
    } else {
      ids.add(eventId);
    }
    await _prefs?.setStringList(_keyFavorites, ids);
  }

  bool isFavorite(String eventId) => favoriteIds.contains(eventId);

  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) => _prefs?.getString(key);
}
