import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionHelper {
  static final _secureStorage = FlutterSecureStorage();
  static const _keyStorageKey = 'encryption_key';

  static Future<String> _getOrCreateKey() async {
    String? key = await _secureStorage.read(key: _keyStorageKey);
    if (key == null) {
      final keyBytes = Key.fromSecureRandom(32);
      key = base64UrlEncode(keyBytes.bytes);
      await _secureStorage.write(key: _keyStorageKey, value: key);
    }
    return key;
  }

  static Future<String> encrypt(String plainText) async {
    final key = Key(base64Url.decode(await _getOrCreateKey()));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  static Future<String> decrypt(String encryptedText) async {
    final key = Key(base64Url.decode(await _getOrCreateKey()));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt(Encrypted.fromBase64(encryptedText), iv: iv);
    return decrypted;
  }
}
