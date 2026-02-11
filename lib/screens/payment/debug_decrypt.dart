import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

void main() {
  // Key from logs
  final keyRaw = "RUXTr63Eyk~:~Ym3CyK6r";

  // Encrypted response from user
  // Encrypted response from user (QR Test)
  final encryptedBase64 =
      "84eb4cd91f0b13bbVXnG00ltbKB0mYWLxDlPpLbNG3I0Z9KsPoA8EN5LNpVOi3bW8Y4TKrHaq9nqX76TacV4I9iK0OCxe334B6SKMjy3i6aut4x6BU0SpgtZPuHamGic/zOZZEUguHFY0BiuEu4RqSdgryWtx3Pledv0Ww==";

  print("Attempting to decrypt...");
  try {
    final decrypted = decryptData(encryptedBase64, keyRaw);
    print("DECRYPTED: " + decrypted);
  } catch (e) {
    print("ERROR: " + e.toString());
  }
}

/// Decrypts data (Expects 16-char IV at start)
String decryptData(String encryptedFull, String keyString) {
  if (encryptedFull.length < 16) return "";
  String validKey = _sanitizeKey(keyString);

  // Note: The user's response might be slightly different encoded
  // Sometimes it's IV + Base64(Cipher)
  // Or sometimes base64(IV + Cipher)

  // User response: "2e843719b7888fa3u5H5mG4..." looks like hex? No "u" "H" etc.
  // "2e843719b7888fa3" is 16 chars. Maybe IV.

  String ivString = encryptedFull.substring(0, 16);
  String encryptedBase64 = encryptedFull.substring(16);

  final key = encrypt.Key.fromUtf8(validKey);
  final iv = encrypt.IV.fromUtf8(ivString);

  final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
  return encrypter.decrypt64(encryptedBase64, iv: iv);
}

/// Ensures key is 32 bytes for AES-256.
String _sanitizeKey(String key) {
  if (key.length == 32) return key;
  return md5.convert(utf8.encode(key)).toString();
}
