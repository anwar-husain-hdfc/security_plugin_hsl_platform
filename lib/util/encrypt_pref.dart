import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HslSecurityEncryptedPref {
  static const String _randomKeyKey = 'randomKey';
  static const String _randomKeyListKey = 'randomKeyList';
  static const AESMode _mode = AESMode.sic;

  static late final SharedPreferences prefs;
  static HslSecurityEncryptedPref? _instance;

  HslSecurityEncryptedPref._();

  static Future<HslSecurityEncryptedPref> getInstance() async {
    if (_instance == null) {
      prefs = await SharedPreferences.getInstance();
      _instance = HslSecurityEncryptedPref._();
    }
    return _instance!;
  }

  Encrypter _getEncrypter() {
    final String? randomKey = prefs.getString(_randomKeyKey);
    Key key;

    if (randomKey == null) {
      key = Key.fromSecureRandom(32);
      prefs.setString(_randomKeyKey, key.base64);
    } else {
      key = Key.fromBase64(randomKey);
    }

    return Encrypter(AES(key, mode: _mode));
  }

  Future<bool> _setEncryptedValue(String key, String value) async {
    try {
      final Encrypter encrypter = _getEncrypter();
      final IV iv = IV.fromSecureRandom(16);
      final String ivValue = iv.base64;

      final Encrypted encrypted = encrypter.encrypt(value, iv: iv);
      final String encryptedValue = encrypted.base64;

      final List<String> randomKeyList = prefs.getStringList(_randomKeyListKey) ?? <String>[];
      randomKeyList.add(ivValue);
      await prefs.setStringList(_randomKeyListKey, randomKeyList);

      final int index = randomKeyList.length - 1;
      await prefs.setString(encryptedValue, index.toString());

      return await prefs.setString(key, encryptedValue);
    } catch (e) {
      // Log or handle the error appropriately
      return false;
    }
  }

  String? _getDecryptedValue(String key) {
    try {
      final String? encryptedValue = prefs.getString(key);
      if (encryptedValue != null) {
        final String indexString = prefs.getString(encryptedValue) ?? '';
        final int index = int.tryParse(indexString) ?? -1;

        final List<String> randomKeyList = prefs.getStringList(_randomKeyListKey) ?? [];
        if (index >= 0 && index < randomKeyList.length) {
          final String ivValue = randomKeyList[index];
          final Encrypter encrypter = _getEncrypter();

          final IV iv = IV.fromBase64(ivValue);
          final Encrypted encrypted = Encrypted.fromBase64(encryptedValue);

          return encrypter.decrypt(encrypted, iv: iv);
        }
      }
      return null;
    } catch (e) {
      // Log or handle the error appropriately
      return null;
    }
  }

  Future<bool> setString(String key, String value) async {
    return await _setEncryptedValue(key, value);
  }

  String getString(String key) {
    return _getDecryptedValue(key) ?? '';
  }

  Future<bool> setBool(String key, bool value) async {
    return await _setEncryptedValue(key, value.toString());
  }

  bool getBool(String key) {
    return _getDecryptedValue(key) == 'true';
  }

  Future<bool> setInt(String key, int value) async {
    return await _setEncryptedValue(key, value.toString());
  }

  int getInt(String key) {
    return int.tryParse(_getDecryptedValue(key) ?? '0') ?? 0;
  }

  Future<bool> setStringList(String key, List<String> value) async {
    final String joinedValue = value.join('<PrefStringListDelimiter>');
    return await _setEncryptedValue(key, joinedValue);
  }

  List<String> getStringList(String key) {
    final String? decryptedValue = _getDecryptedValue(key);
    return decryptedValue?.split('<PrefStringListDelimiter>') ?? [];
  }

  bool containsKey(String key) {
    return prefs.containsKey(key);
  }

  Future<bool> remove(String key) async {
    try {
      final String? encryptedValue = prefs.getString(key);
      if (encryptedValue != null) {
        await prefs.remove(key);
        final String indexString = prefs.getString(encryptedValue) ?? '';
        final int index = int.tryParse(indexString) ?? -1;

        final List<String> randomKeyList = prefs.getStringList(_randomKeyListKey) ?? [];
        if (index >= 0 && index < randomKeyList.length) {
          randomKeyList.removeAt(index);
          await prefs.setStringList(_randomKeyListKey, randomKeyList);
        }
        return true;
      }
      return false;
    } catch (e) {
      // Log or handle the error appropriately
      return false;
    }
  }

  Future<bool> clear() async {
    return await prefs.clear();
  }

  Future<void> reload() async {
    return await prefs.reload();
  }
}