import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SharedPrefsHelper {
  // 通知機能付きシングルトンインスタンス
  static final _notifier = SharedPrefsChangeNotifier._internal();
  static SharedPrefsChangeNotifier get notifier => _notifier;
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // 通知機能付きの保存メソッド
  static Future<void> saveStringWithNotify(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    _notifier._notify(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // キャッシュから即座に取得（通知機能付き保存で保存されたもののみ）
  static String? getCachedString(String key) {
    return _notifier._cache[key];
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  static Future<void> loadAndSetString(
    String key,
    void Function(String) setter,
  ) async {
    final value = await getString(key);
    if (value != null) {
      setter(value);
    }
  }

  // 通知機能付き保存での一括保存（blockInfoやprocessingConditions用）
  static Future<void> saveMapWithNotify(String prefix, Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      if (entry.value is List) {
        final list = entry.value as List;
        for (int i = 0; i < list.length; i++) {
          final key = '${prefix}_${entry.key}_$i';
          final value = list[i]?.toString() ?? '';
          await saveStringWithNotify(key, value);
        }
        await saveStringWithNotify(
          '${prefix}_${entry.key}_length',
          list.length.toString(),
        );
      } else {
        await saveStringWithNotify(
          '${prefix}_${entry.key}',
          entry.value?.toString() ?? '',
        );
      }
    }

    // 一括保存完了を通知
    await saveStringWithNotify('${prefix}_save_completed', DateTime.now().millisecondsSinceEpoch.toString());
  }

  // キーの変更通知を強制送信（フォーカス制御用）
  static void notifyKeyChanged(String key) {
    final currentValue = _notifier._cache[key] ?? '';
    _notifier._notify(key, currentValue);
  }
}

// SharedPreferences変更通知クラス
class SharedPrefsChangeNotifier extends ChangeNotifier {
  final Map<String, String> _cache = {};
  final Map<String, List<_KeyListener>> _keyListeners = {};

  // プライベートコンストラクタ（シングルトン用）
  SharedPrefsChangeNotifier._internal();

  void _notify(String key, String value) {
    final oldValue = _cache[key];
    _cache[key] = value;
    
    // キー固有のリスナーを呼び出し
    if (oldValue != value && _keyListeners.containsKey(key)) {
      for (final listener in _keyListeners[key]!) {
        listener.callback();
      }
    }
    
    notifyListeners();
  }

  // 特定のキーの変更を監視するためのヘルパー（修正版）
  void addKeyListener(String key, VoidCallback callback) {
    _keyListeners.putIfAbsent(key, () => []);
    _keyListeners[key]!.add(_KeyListener(callback));
  }

  // リスナーの削除（メモリリーク防止）
  void removeKeyListener(String key, VoidCallback callback) {
    if (_keyListeners.containsKey(key)) {
      _keyListeners[key]!.removeWhere((listener) => listener.callback == callback);
      if (_keyListeners[key]!.isEmpty) {
        _keyListeners.remove(key);
      }
    }
  }

  // 複数キーの変更を監視
  void addKeysListener(List<String> keys, VoidCallback callback) {
    Map<String, String?> previousValues = {};
    for (String key in keys) {
      previousValues[key] = _cache[key];
    }
    
    addListener(() {
      bool hasChanged = false;
      for (String key in keys) {
        final currentValue = _cache[key];
        if (currentValue != previousValues[key]) {
          previousValues[key] = currentValue;
          hasChanged = true;
        }
      }
      if (hasChanged) {
        callback();
      }
    });
  }

  // デバッグ用：現在のキャッシュ状態を取得
  Map<String, String> get cache => Map.unmodifiable(_cache);

  @override
  void dispose() {
    _cache.clear();
    _keyListeners.clear();
    super.dispose();
  }
}

// キーリスナーのヘルパークラス
class _KeyListener {
  final VoidCallback callback;
  
  _KeyListener(this.callback);
}
