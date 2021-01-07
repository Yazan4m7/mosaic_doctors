import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import "package:pointycastle/export.dart";
import 'package:mosaic_doctors/shared/Constants.dart';
main() async {
  Payment.initializePayment();
}
class Payment {

      static initializePayment() async{
        DateTime date1900ago =  DateTime.parse('1900-01-01 00:00:00');
        int minsSince1900 =  DateTime.now().difference(date1900ago).inMinutes;


        final plainText = 'L';

        final publicKey = await parseKeyFromFile<RSAPublicKey>("assets/publicKey.pem");


        List<int> list = plainText.codeUnits;
        Uint8List bytes1 = Uint8List.fromList(list);
        var encrypted = rsaEncrypt(publicKey,bytes1);
        print(encrypted);


    }
     static  Uint8List rsaEncrypt(RSAPublicKey myPublic, Uint8List dataToEncrypt) {
        final encryptor = OAEPEncoding(RSAEngine())
          ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic)); // true=encrypt

        return _processInBlocks(encryptor, dataToEncrypt);
      }
      static Uint8List _processInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
        final numBlocks = input.length ~/ engine.inputBlockSize +
            ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

        final output = Uint8List(numBlocks * engine.outputBlockSize);

        var inputOffset = 0;
        var outputOffset = 0;
        while (inputOffset < input.length) {
          final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
              ? engine.inputBlockSize
              : input.length - inputOffset;

          outputOffset += engine.processBlock(
              input, inputOffset, chunkSize, output, outputOffset);

          inputOffset += chunkSize;
        }

        return (output.length == outputOffset)
            ? output
            : output.sublist(0, outputOffset);
      }
}