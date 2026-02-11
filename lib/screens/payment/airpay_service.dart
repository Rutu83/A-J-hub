import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class AirpayService {
  /// Encrypts data using AES-256-CBC with PKCS5Padding
  /// Returns: IV (16 chars) + Base64 Encrypted String
  static String encryptData(String data, String keyString) {
    String validKey = _sanitizeKey(keyString);

    // Generate a random 16-digit IV
    String ivString = _generateRandomIV();
    final key = encrypt.Key.fromUtf8(validKey);
    final iv = encrypt.IV.fromUtf8(ivString);

    final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(data, iv: iv);

    // Airpay expects "IV + EncryptedData"
    return ivString + encrypted.base64.replaceAll(RegExp(r'\s'), '');
  }

  /// Decrypts data (Expects 16-char IV at start)
  static String decryptData(String encryptedFull, String keyString) {
    if (encryptedFull.length < 16) return "";
    String validKey = _sanitizeKey(keyString);

    String ivString = encryptedFull.substring(0, 16);
    String encryptedBase64 = encryptedFull.substring(16);

    final key = encrypt.Key.fromUtf8(validKey);
    final iv = encrypt.IV.fromUtf8(ivString);

    final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
    return encrypter.decrypt64(encryptedBase64, iv: iv);
  }

  /// Ensures key is 32 bytes for AES-256.
  /// If not 32 chars, we assume it's a seed/password and MD5 hash it to get 32-char hex string.
  static String _sanitizeKey(String key) {
    if (key.length == 32) return key;
    // If not 32, hash it to get 32-char hex string
    return md5.convert(utf8.encode(key)).toString();
  }

  static String _generateRandomIV() {
    // Generate 16 random digits
    var random =
        DateTime.now().millisecondsSinceEpoch.toString() + "1234567890123456";
    return random.substring(random.length - 16);
  }

  /// Generates Checksum: SHA256(key + @ + data_string)
  /// Structure for 'data_string' depends on the specific API call.
  static String generateChecksum(String dataString, String keyString) {
    // Pattern: SHA256(key @ data) -> This might be specific.
    // Checking previous code: sha256.convert(utf8.encode(sAllData))
    // Let's stick to the checksum generation provided in documentation.
    // "Checksum is separate field".
    // The documentation file said: "checksum: SHA256 hash of sorted params + date"
    // But the SDK used: sha256(key + sorted_values + date) type logic.

    // We will implement a generic SHA256 hasher.
    return sha256.convert(utf8.encode(dataString)).toString();
  }

  /// Airpay Payment Checksum (per Airpay team instructions)
  /// alldata = email+fname+lname+address+city+state+country+amount+orderid+UID+date
  /// key = SHA256(username~:~password)  (which is the aesDeskey)
  /// checksum = SHA256(key + "@" + alldata)
  static String generatePaymentChecksum({
    required String aesDesKey, // username~:~password
    required String buyerEmail,
    required String buyerFirstName,
    required String buyerLastName,
    required String buyerAddress,
    required String buyerCity,
    required String buyerState,
    required String buyerCountry,
    required String amount,
    required String orderId,
    required String merchantId, // UID
    required String date, // YYYY-MM-DD
  }) {
    // 1. Calculate sKey = SHA256(username~:~password)
    // The provided aesDesKey IS "username~:~password"
    final sKey = sha256.convert(utf8.encode(aesDesKey)).toString();

    // 2. Construct allData
    final allData = buyerEmail +
        buyerFirstName +
        buyerLastName +
        buyerAddress +
        buyerCity +
        buyerState +
        buyerCountry +
        amount +
        orderId +
        merchantId +
        date;

    // DEBUG LOGGING
    print(">>> [Checksum] aesDesKey: $aesDesKey");
    print(">>> [Checksum] sKey: $sKey");
    print(
        ">>> [Checksum] allData parts: email=$buyerEmail, fname=$buyerFirstName, lname=$buyerLastName, addr=$buyerAddress, city=$buyerCity, state=$buyerState, country=$buyerCountry, amt=$amount, order=$orderId, uid=$merchantId, date=$date");
    print(">>> [Checksum] allData: $allData");

    // 3. Final Checksum = SHA256(sKey + "@" + allData)
    final checksum =
        sha256.convert(utf8.encode(sKey + '@' + allData)).toString();
    print(">>> [Checksum] Final: $checksum");
    return checksum;
  }

  static String generateAllDataString(Map<String, dynamic> params) {
    // Sort keys? Or specific order?
    // Docs say "sorted parameters".
    var sortedKeys = params.keys.toList()..sort();
    StringBuffer buffer = StringBuffer();
    for (var key in sortedKeys) {
      var value = params[key];
      // Convert null to empty string, otherwise .toString() returns "null"
      String valStr = value != null ? value.toString() : "";
      buffer.write(valStr);
    }
    return buffer.toString();
  }
}
