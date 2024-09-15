import 'package:flutter_test/flutter_test.dart';
import 'package:security_plugin_hsl_platform/util/encrypt_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HslSecurityEncryptedPref', () {
    late HslSecurityEncryptedPref encryptedPref;

    setUp(() async {
      // Set mock initial values for SharedPreferences
      SharedPreferences.setMockInitialValues({});
      encryptedPref = await HslSecurityEncryptedPref.getInstance();
    });

    test('setString and getString', () async {
      const String key = 'testStringKey';
      const String value = 'testStringValue';

      final bool isSet = await encryptedPref.setString(key, value);
      expect(isSet, true);

      final String retrievedValue = encryptedPref.getString(key);
      expect(retrievedValue, value);
    });

    test('setBool and getBool', () async {
      const String key = 'testBoolKey';
      const bool value = true;

      final bool isSet = await encryptedPref.setBool(key, value);
      expect(isSet, true);

      final bool? retrievedValue = encryptedPref.getBool(key);
      expect(retrievedValue, value);
    });

    test('setInt and getInt', () async {
      const String key = 'testIntKey';
      const int value = 12345;

      final bool isSet = await encryptedPref.setInt(key, value);
      expect(isSet, true);

      final int retrievedValue = encryptedPref.getInt(key);
      expect(retrievedValue, value);
    });

    test('setStringList and getStringList', () async {
      const String key = 'testStringListKey';
      final List<String> value = ['item1', 'item2', 'item3'];

      final bool isSet = await encryptedPref.setStringList(key, value);
      expect(isSet, true);

      final List<String> retrievedValue = encryptedPref.getStringList(key);
      expect(retrievedValue, value);
    });

    test('containsKey', () async {
      const String key = 'testContainsKey';
      const String value = 'value';

      await encryptedPref.setString(key, value);

      final bool contains = encryptedPref.containsKey(key);
      expect(contains, true);
    });

    test('remove', () async {
      const String key = 'testRemoveKey';
      const String value = 'value';

      await encryptedPref.setString(key, value);

      final bool removed = await encryptedPref.remove(key);
      expect(removed, true);

      final String retrievedValue = encryptedPref.getString(key);
      expect(retrievedValue, '');
    });

    test('clear', () async {
      const String key1 = 'testClearKey1';
      const String value1 = 'value1';

      const String key2 = 'testClearKey2';
      const String value2 = 'value2';

      await encryptedPref.setString(key1, value1);
      await encryptedPref.setString(key2, value2);

      await encryptedPref.clear();

      final String retrievedValue1 = encryptedPref.getString(key1);
      final String retrievedValue2 = encryptedPref.getString(key2);

      expect(retrievedValue1, '');
      expect(retrievedValue2, '');
    });


    test('setString with empty value', () async {
      const String key = 'testEmptyStringKey';
      const String value = '';

      final bool isSet = await encryptedPref.setString(key, value);
      expect(isSet, false); // Expecting false since the value is empty

      final String retrievedValue = encryptedPref.getString(key);
      expect(retrievedValue, ''); // Should return an empty string
    });

    test('setString with null value', () async {
      // Since the method doesn't accept null directly, we test with the absence of a value
      const String key = 'testNullStringKey';

      // Directly attempt to get a value that was never set
      final String retrievedValue = encryptedPref.getString(key);
      expect(retrievedValue, ''); // Should return an empty string as nothing was set
    });

    test('getString with non-existent key', () async {
      const String key = 'nonExistentKey';

      final String retrievedValue = encryptedPref.getString(key);
      expect(retrievedValue, ''); // Should return an empty string as the key does not exist
    });

    test('getBool with non-existent key', () async {
      const String key = 'nonExistentBoolKey';

      final bool? retrievedValue = encryptedPref.getBool(key);
      expect(retrievedValue, false); // Should return false as the key does not exist
    });

    test('setInt with null value', () async {
      // Since the method doesn't accept null directly, we simulate a null by not setting a value
      const String key = 'testNullIntKey';

      final int retrievedValue = encryptedPref.getInt(key);
      expect(retrievedValue, 0); // Should return 0 as no value was set
    });

    test('getInt with non-existent key', () async {
      const String key = 'nonExistentIntKey';

      final int retrievedValue = encryptedPref.getInt(key);
      expect(retrievedValue, 0); // Should return 0 as the key does not exist
    });

    test('setStringList with empty list', () async {
      const String key = 'testEmptyStringListKey';
      final List<String> value = [];

      final bool isSet = await encryptedPref.setStringList(key, value);
      expect(isSet, false); // Expecting false since the list is empty

      final List<String> retrievedValue = encryptedPref.getStringList(key);
      expect(retrievedValue, []); // Should return an empty list
    });

    test('getStringList with non-existent key', () async {
      const String key = 'nonExistentStringListKey';

      final List<String> retrievedValue = encryptedPref.getStringList(key);
      expect(retrievedValue, []); // Should return an empty list as the key does not exist
    });

    test('remove with non-existent key', () async {
      const String key = 'nonExistentRemoveKey';

      final bool removed = await encryptedPref.remove(key);
      expect(removed, false); // Expecting false since the key does not exist
    });

    test('clear on empty SharedPreferences', () async {
      await encryptedPref.clear();

      const String key = 'testClearNonExistentKey';
      final String retrievedValue = encryptedPref.getString(key);
      expect(retrievedValue, ''); // Should return an empty string since nothing was set
    });

    test('handle corrupted data gracefully', () async {
      const String key = 'corruptedDataKey';

      // Manually setting a corrupted value in SharedPreferences
      SharedPreferences.setMockInitialValues({key: 'corruptedValue'});

      final String retrievedValue = encryptedPref.getString(key);
      expect(retrievedValue, ''); // Should handle gracefully and return an empty string
    });

    test('handle invalid encrypted format', () async {
      const String key = 'invalidEncryptedFormatKey';

      // Manually setting an invalid encrypted value
      SharedPreferences.setMockInitialValues({
        key: 'invalidEncryptedValue',
        'invalidEncryptedValue': '0', // Index in the list
        // HslSecurityEncryptedPref._randomKeyListKey: ['invalidIV']
      });

      final String retrievedValue = encryptedPref.getString(key);
      expect(retrievedValue, ''); // Should handle gracefully and return an empty string
    });
  });
}