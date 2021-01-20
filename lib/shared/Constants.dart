import 'package:flutter_screenutil/flutter_screenutil.dart';
double dateCellWidthFactor = 5.0;
double entryCellWidthFactor = 3.2;
double creditCellWidthFactor = 6.1;
double debitCellWidthFactor =7;
double balanceCellWidthFactor = 5.6;

double cellsLeftPadding = 25.w;

double patientNameRightPadding = 35.w;

class Constants{
  //static const ROOT = 'http://10.0.2.2/flutter_api.php';
  static const USER_AUTH = 'http://manshore.com/mosaic_system_api.php';
  //static const ROOT = 'http://10.0.2.2/mosaic_db_api.php';
  static const ROOT = 'http://lab.manshore.com/mosaic_db_api.php';

  static final  String g2pGetCardsListAPI = "https://cms.gatetopay.com/G2P.OPENAPI/api/Broker/GetCardList";
  static final String g2pDepositAPI = "https://cms.gatetopay.com/G2P.OPENAPI/api/Broker/Deposit";
  static final String g2pInquireTransAPI = "https://cms.gatetopay.com/G2P.OPENAPI/api/Inquire/InquireTransaction";
  static final String g2pAppID = "fb1b2515-aa7a-4963-a4ce-48dd32e28705";
  static final String encryptionKey ="MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5GBry4XDrucIKnt/nKSL"
  +"pByknQK+eEsWxVyktZgCtzGSGCQrALjLpDoY9PC1QYlp2Y/yc+2KFD9m5ecWIAIW"
  +"HMvjGImHk8Ec3J+Dj7a28w+r+hUlJrtyi2MgnqOIc5OYUtYdYSEcKk0hHflSZHat"
  +"QgoyNIqZQz38GO2t+x7XNa+cUNmtJIw/AhQQx3OLuM5LYSCgDVubmKNevltA+4eY"
  +"1JsIOEinT5iWbsol36zfkiFnHpj/nQBPejkgnpOBHtN2PIh7VSnkadaiUPgWBfqW"
  +"dKGuf+KyrE18Q2qKTx4yP0vjACLoEORk1GvHKyUKS5WUCqlijB1ck1Rro6XnhxAN"
  +"qQIDAQAB";

  static final debuggers = ['+962788160099','+962788160098','+962795054504','+9620795054504'];
//10.0.2.2
}