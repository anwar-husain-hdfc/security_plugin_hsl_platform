library encrypted_shared_preferences;


import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';



class HslSecurityEncryptedPref {
  final String randomKeyKey = 'randomKey';
  final String randomKeyListKey = 'randomKeyList';
  final AESMode mode = AESMode.sic;

  static SharedPreferences? prefs;
  static HslSecurityEncryptedPref? _instance;

  /// Optional: Pass custom SharedPreferences instance
  /*HslSecurityEncryptedPref(
    this.prefs, {this.mode = AESMode.sic,
    this.randomKeyKey = 'randomKey',
    this.randomKeyListKey = 'randomKeyList',
  });*/

  static Future<HslSecurityEncryptedPref?> getInstance() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    if (_instance == null) {
      _instance = HslSecurityEncryptedPref();
    }
    return _instance;
  }

  Encrypter _getEncrypter(SharedPreferences prefs) {
    final String? randomKey = prefs.getString(randomKeyKey);

    Key key;

    if (randomKey == null) {
      key = Key.fromSecureRandom(32);
      prefs.setString(randomKeyKey, key.base64);
    } else {
      key = Key.fromBase64(randomKey);
    }

    return Encrypter(AES(key, mode: mode));
  }

  Future<bool> setString(String key, String value) async {
    try {
      if (value.isNotEmpty) {
        final Encrypter encrypter = _getEncrypter(prefs!);

        /// Generate random IV
        final IV iv = IV.fromSecureRandom(16);
        final String ivValue = iv.base64;

        /// Encrypt value
        final Encrypted encrypted = encrypter.encrypt(value, iv: iv);
        final String encryptedValue = encrypted.base64;

        /// Add generated random IV to a list
        final List<String> randomKeyList =
            prefs!.getStringList(randomKeyListKey) ?? <String>[];
        randomKeyList.add(ivValue);
        prefs!.setStringList(randomKeyListKey, randomKeyList);

        /// Save random key list index, We used encrypted value as key so we could use that to access it later
        final int index = randomKeyList.length - 1;
        prefs!.setString(encryptedValue, index.toString());

        /// Save encrypted value
        return prefs!.setString(key, encryptedValue);
      }

      /// Value is empty
      return false;
    } catch (e, s) {
      // debugPrint('HslSecurityEncryptedPref.setString', e, stackTraces: s);
      return false;
    }
  }

  String getString(String key) {
    try {
      String decrypted = '';

      /// Get encrypted value
      final String? encryptedValue = prefs!.getString(key);

      if (encryptedValue != null) {
        /// Get random key list index using the encrypted value as key
        final String indexString = prefs!.getString(encryptedValue)!;
        final int index = int.tryParse(indexString) ?? 0;

        /// Get random key from random key list using the index
        final List<String> randomKeyList = prefs!.getStringList(randomKeyListKey)!;
        final String ivValue = randomKeyList[index];

        final Encrypter encrypter = _getEncrypter(prefs!);

        final IV iv = IV.fromBase64(ivValue);
        final Encrypted encrypted = Encrypted.fromBase64(encryptedValue);

        decrypted = encrypter.decrypt(encrypted, iv: iv);
      }

      return decrypted;
    } catch (e, s) {
      // logger.error('HslSecurityEncryptedPref.getString', e, stackTraces: s);
      return '';
    }
  }

  Future<bool> setBool(String key, bool value) async {
    try {
      final Encrypter encrypter = _getEncrypter(prefs!);

      /// Generate random IV
      final IV iv = IV.fromSecureRandom(16);
      final String ivValue = iv.base64;

      /// Encrypt value
      final Encrypted encrypted = encrypter.encrypt(value.toString(), iv: iv);
      final String encryptedValue = encrypted.base64;

      /// Add generated random IV to a list
      final List<String> randomKeyList =
          prefs!.getStringList(randomKeyListKey) ?? <String>[];
      randomKeyList.add(ivValue);
      await prefs!.setStringList(randomKeyListKey, randomKeyList);

      /// Save random key list index, We used encrypted value as key so we could use that to access it later
      final int index = randomKeyList.length - 1;
      await prefs!.setString(encryptedValue, index.toString());

      /// Save encrypted value
      return await prefs!.setString(key, encryptedValue);
    } catch (e, s) {
      // logger.error('HslSecurityEncryptedPref.setBool', e, stackTraces: s);
      return false;
    }
  }

  bool? getBool(String key) {
    try {
      String decrypted = '';

      /// Get encrypted value
      //m.debugPrint('==============${prefs.getBool(key)}============');
      final String? encryptedValue = prefs!.getString(key);

      if (encryptedValue != null) {
        /// Get random key list index using the encrypted value as key
        final String indexString = prefs!.getString(encryptedValue)!;
        final int index = int.tryParse(indexString) ?? 0;

        /// Get random key from random key list using the index
        final List<String> randomKeyList = prefs!.getStringList(randomKeyListKey) ?? <String>[];
        final String? ivValue = randomKeyList.length > index ? randomKeyList[index] : null;

        final Encrypter encrypter = _getEncrypter(prefs!);
        if(ivValue == null){
        // logger.warn('HslSecurityEncryptedPref.getBool', 'ivValue is null');
          return false;
        }
        final IV iv = IV.fromBase64(ivValue);
        final Encrypted encrypted = Encrypted.fromBase64(encryptedValue);

        decrypted = encrypter.decrypt(encrypted, iv: iv);
      }

      return decrypted == 'true';
    } catch (e, s) {
    // logger.error('HslSecurityEncryptedPref.getBool', e, stackTraces: s);
      return false;
    }
  }

  Future<bool> setInt(String key, int? value) async {
    try {
      if (value != null) {
        final Encrypter encrypter = _getEncrypter(prefs!);

        /// Generate random IV
        final IV iv = IV.fromSecureRandom(16);
        final String ivValue = iv.base64;

        /// Encrypt value
        final Encrypted encrypted = encrypter.encrypt(value.toString(), iv: iv);
        final String encryptedValue = encrypted.base64;

        /// Add generated random IV to a list
        final List<String> randomKeyList =
            prefs!.getStringList(randomKeyListKey) ?? <String>[];
        randomKeyList.add(ivValue);
        await prefs!.setStringList(randomKeyListKey, randomKeyList);

        /// Save random key list index, We used encrypted value as key so we could use that to access it later
        final int index = randomKeyList.length - 1;
        await prefs!.setString(encryptedValue, index.toString());

        /// Save encrypted value
        return await prefs!.setString(key, encryptedValue);
      }

      /// Value is empty
      return false;
    } catch (e, s) {
    // logger.error('HslSecurityEncryptedPref.setInt', e, stackTraces: s);
      return false;
    }
  }

  int getInt(String key) {
    try {
      String decrypted = '';

      /// Get encrypted value
      final String? encryptedValue = prefs!.getString(key);

      if (encryptedValue != null) {
        /// Get random key list index using the encrypted value as key
        final String indexString = prefs!.getString(encryptedValue)!;
        final int index = int.tryParse(indexString) ?? 0;

        /// Get random key from random key list using the index
        final List<String> randomKeyList = prefs!.getStringList(randomKeyListKey)!;
        final String ivValue = randomKeyList[index];

        final Encrypter encrypter = _getEncrypter(prefs!);

        final IV iv = IV.fromBase64(ivValue);
        final Encrypted encrypted = Encrypted.fromBase64(encryptedValue);

        decrypted = encrypter.decrypt(encrypted, iv: iv);
      }
      return int.tryParse(decrypted) ?? 0;
    }  catch (e, s) {
    // logger.error('HslSecurityEncryptedPref.getInt', e, stackTraces: s);
      return 0;
    }
  }

  Future<bool> setStringList(String key, List<String> value) async {
    try {
      if (value.isNotEmpty) {
        final Encrypter encrypter = _getEncrypter(prefs!);

        /// Generate random IV
        final IV iv = IV.fromSecureRandom(16);
        final String ivValue = iv.base64;

        /// Encrypt value
        final Encrypted encrypted =
        encrypter.encrypt(value.join('<PrefStringListDelimiter>'), iv: iv);
        final String encryptedValue = encrypted.base64;

        /// Add generated random IV to a list
        final List<String> randomKeyList =
            prefs!.getStringList(randomKeyListKey) ?? <String>[];
        randomKeyList.add(ivValue);
        await prefs!.setStringList(randomKeyListKey, randomKeyList);

        /// Save random key list index, We used encrypted value as key so we could use that to access it later
        final int index = randomKeyList.length - 1;
        await prefs!.setString(encryptedValue, index.toString());

        /// Save encrypted value
        return await prefs!.setString(key, encryptedValue);
      }

      /// Value is empty
      return false;
    } catch (e, s) {
    // logger.error('HslSecurityEncryptedPref.setStringList', e, stackTraces: s);
      return false;
    }
  }

  List<String> getStringList(String key) {
    try{
      String decrypted = '';

      /// Get encrypted value
      final String? encryptedValue = prefs!.getString(key);

      if (encryptedValue != null) {
        /// Get random key list index using the encrypted value as key
        final String indexString = prefs!.getString(encryptedValue)!;
        final int index = int.tryParse(indexString) ?? 0;

        /// Get random key from random key list using the index
        final List<String> randomKeyList = prefs!.getStringList(randomKeyListKey)!;
        final String ivValue = randomKeyList[index];

        final Encrypter encrypter = _getEncrypter(prefs!);

        final IV iv = IV.fromBase64(ivValue);
        final Encrypted encrypted = Encrypted.fromBase64(encryptedValue);

        decrypted = encrypter.decrypt(encrypted, iv: iv);
      }

      return decrypted.isEmpty
          ? []
          : decrypted.split('<PrefStringListDelimiter>');
    } catch (e, s) {
    // logger.error('HslSecurityEncryptedPref.getStringList', e, stackTraces: s);
      return [];
    }
  }

  bool containsKey(String key) {
    /// Get encrypted value
    final String? encryptedValue = prefs!.getString(key);

    return encryptedValue != null;
  }

  Future<bool> remove(String key) async {
    try {
      /// Get encrypted value
      final String? encryptedValue = prefs!.getString(key);

      if (encryptedValue != null) {
        await prefs!.remove(key);

        /// Get random key list index using the encrypted value as key
        final String indexString = prefs!.getString(encryptedValue)!;
        final int index = int.tryParse(indexString) ?? 0;

        await prefs!.remove(encryptedValue);

        final List<String> randomKeyList = prefs!.getStringList(randomKeyListKey)!;
        randomKeyList.removeAt(index);
        return await prefs!.setStringList(randomKeyListKey, randomKeyList);
      }

      return false;
    } catch (e, s) {
    // logger.error('HslSecurityEncryptedPref.remove', e, stackTraces: s);
      return false;
    }
  }

  Future<bool> clear() async {
    /// Clear values
    return await prefs!.clear();
  }

  Future<void> reload() async {
    /// Reload
    return await prefs!.reload();
  }
}