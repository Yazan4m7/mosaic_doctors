import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:mosaic_doctors/shared/Constants.dart';
import 'package:pointycastle/asymmetric/api.dart';
main() async {
  Payment.initializePayment();
}
class Payment {



      static initializePayment() async{
        final publicKey = await parseKeyFromFile<RSAPublicKey>('assets/publicKey.pem');
        final privKey = await parseKeyFromFile<RSAPrivateKey>('assets/privateKey.pem');

        final plainText = 'EtrT3QH0BAh8GJckM7OlKNDbr65JZ8rm12633';
        final encrypter = Encrypter(RSA(publicKey: publicKey, privateKey: privKey,encoding:RSAEncoding.OAEP));

        final encrypted = encrypter.encrypt(plainText);
//        final decrypted = encrypter.decrypt(encrypted);
//        print(decrypted); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
        print(encrypted.base64);
//        String s = "Hi fellow";
//        Encrypted encryptedKeyHeader = await encrypt(s);
//        print(encryptedKeyHeader);
//        String dec = await decrypt(encryptedKeyHeader.base64);
//        print(dec);
//        DateTime date1900ago =  DateTime.parse('1900-01-01 00:00:00');
//        int minsSince1900 =  DateTime.now().difference(date1900ago).inMinutes;
//        String keyHeader =  Constants.g2pAppID +' '+ minsSince1900.toString();
//        print(keyHeader);
//        String encryptedKeyHeader = await encrypt(keyHeader);
//        print(encryptedKeyHeader);
//        Uri url = Uri.tryParse(Constants.g2pGetCardsListAPI);
//        http.Request request = new http.Request("post", url,);
//        request.headers.clear();
//
//        request.headers.addAll({"Key":encryptedKeyHeader, "AgentKey":Constants.g2pAppID});
//        request.body = "{'CustomerId'': 123}";
//        print(request.headers);
//        print(request.body);
//        var response = await request.send();
//        var response2 = await http.Response.fromStream(response);
//        print(response2.body);
//        print(response2.statusCode);
//        print(response2.bodyBytes);



    }
    static encrypt(String input) async{
        final  publicKey = await parseKeyFromFile<RSAPublicKey>("assets/publicKey.pem");
        final encrypter = Encrypter(RSA(publicKey: publicKey));
        final encrypted = encrypter.encrypt(input);
        return encrypted.base64;
    }
      static decrypt(Encrypted input) async{
        final  privateKey = await parseKeyFromFile<RSAPrivateKey>("assets/privateKey.pem");
        final decrypter = Encrypter(RSA(privateKey: privateKey));
        final decrypted = decrypter.decrypt(input);
        return decrypted;
      }

}