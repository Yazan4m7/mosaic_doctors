import 'dart:convert';

import 'package:mosaic_doctors/models/implantStatementRowModel.dart';
import 'package:http/http.dart' as http;
import 'package:mosaic_doctors/models/nbDoctor.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/shared/Constants.dart';
import 'package:mosaic_doctors/shared/locator.dart';

class ImplantsDatabase {
  static const ROOT = Constants.ROOT;
  static List<ImplantStatementRowModel> implantsStatementEntries = [];
  static List<String> docImplantsOrdersIds = [];

  static isNobelClient(String doctorId) async {
    if (doctorId == null ){print("No doctor ID, returning false."); return false;}
    if (await getDoctorRecord(true) == null) {print("No doctor record, returning false.");return false;}

    print("Is Nobel client : Getting orders");
    var map = Map<String, dynamic>();
    String checkQuery = "SELECT * from `nb_orders` WHERE `doctor_id` = '$doctorId' limit 1";
    map['action'] = "GET";
    map['query'] = checkQuery;
    final response = await http.post(ROOT, body: map);
    print("NB orders body : ${response.body}");
    if(response.body.isNotEmpty)
      return true;
    return false;
  }

  static Future getDoctorImplantAccountStatement(String doctorId, bool forceReload) async {


    if (implantsStatementEntries.isNotEmpty && forceReload) {
      print("Statement already has data.");
      return implantsStatementEntries;
    }
    var queryResults = await postQueryToDB("select * from nb_account_statements where doctor_id = $doctorId order by created_at DESC");

    implantsStatementEntries.clear();

    for (int i = 0; i < queryResults.length; i++) {
      ImplantStatementRowModel implantStatementEntry =
      ImplantStatementRowModel.fromJson(queryResults[i]);
      if(implantStatementEntry.orderId != "N/A" )
        docImplantsOrdersIds.add(implantStatementEntry.orderId);
      implantsStatementEntries.add(implantStatementEntry);
    }

    implantsStatementEntries.sort((a, b) {
      return a.createdAt.compareTo(b.createdAt);
    });

    return implantsStatementEntries;
  }
  static Future getDoctorRecord(bool forceReload) async {
    if(getIt<SessionData>().nbDoctor != null && !forceReload) return  getIt<SessionData>().nbDoctor;
    var result = await postQueryToDB("SELECT * from `nb_doctors` WHERE `nb_doctors`.`id` = ${getIt<SessionData>().doctor.implantsRecordId} AND `phone` = '${getIt<SessionData>().doctor.phone}' ");
    if(result == null) {print("getDoc rec returning null");return null;}
    print("returning doc record");
    NbDoctor nbDoctor = NbDoctor.fromJson(result[0]);
    getIt<SessionData>().nbDoctor = nbDoctor;
    if(implantsStatementEntries.isEmpty) await getDoctorImplantAccountStatement(getIt<SessionData>().doctor.implantsRecordId, false);
    getIt<SessionData>().implantsFirstOrderDate = implantsStatementEntries.first.createdAt;
    return nbDoctor;
  }

  static Future postQueryToDB(String query) async{
    var map = Map<String, dynamic>();
    map['action'] = "GET";
    map['query'] = query;
    final response = await http.post(ROOT, body: map);
    if(response.body.isEmpty ) return null;
    var parsed = await json.decode(response.body);
    return parsed;
  }
}