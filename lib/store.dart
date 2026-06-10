import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// お気に入り・閲覧履歴の永続化
class AppStore extends ChangeNotifier {
  static const _kFavorites = 'favorites';
  static const _kRecents = 'recents';
  static const _maxRecents = 10;

  final SharedPreferences _prefs;
  final Set<String> _favorites;
  final List<String> _recents;

  AppStore._(this._prefs)
      : _favorites = (_prefs.getStringList(_kFavorites) ?? []).toSet(),
        _recents = _prefs.getStringList(_kRecents) ?? [];

  static Future<AppStore> load() async =>
      AppStore._(await SharedPreferences.getInstance());

  bool isFavorite(String id) => _favorites.contains(id);
  List<String> get recents => List.unmodifiable(_recents);

  void toggleFavorite(String id) {
    if (!_favorites.remove(id)) _favorites.add(id);
    _prefs.setStringList(_kFavorites, _favorites.toList());
    notifyListeners();
  }

  void addRecent(String id) {
    _recents.remove(id);
    _recents.insert(0, id);
    if (_recents.length > _maxRecents) {
      _recents.removeRange(_maxRecents, _recents.length);
    }
    _prefs.setStringList(_kRecents, _recents);
    notifyListeners();
  }
}
