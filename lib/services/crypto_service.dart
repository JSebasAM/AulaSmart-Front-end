import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;

class RsaHelper {
  static String encryptAesKey(Uint8List aesKey, String nHex, String eHex) {
    final n = BigInt.parse(nHex, radix: 16);
    final e = BigInt.parse(eHex, radix: 16);
    final message = _bytesToBigInt(aesKey);
    final cipher = message.modPow(e, n);
    return cipher.toRadixString(16);
  }

  static BigInt _bytesToBigInt(Uint8List bytes) {
    BigInt result = BigInt.zero;
    for (var byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }
}

class AesHelper {
  final enc.Encrypter _encrypter;

  AesHelper(Uint8List key)
      : _encrypter = enc.Encrypter(
          enc.AES(enc.Key(key), mode: enc.AESMode.ecb, padding: 'PKCS7'),
        );

  String encryptText(String plaintext) {
    final iv = enc.IV.fromLength(16);
    return _encrypter.encrypt(plaintext, iv: iv).base64;
  }

  String decryptText(String base64Cipher) {
    final iv = enc.IV.fromLength(16);
    return _encrypter.decrypt64(base64Cipher, iv: iv);
  }
}
