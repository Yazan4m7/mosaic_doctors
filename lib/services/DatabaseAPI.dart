
import 'dart:convert';

import 'package:mosaic_doctors/models/AccountStatementEntry.dart';
import 'package:mosaic_doctors/models/case.dart';
import 'package:mosaic_doctors/models/job.dart';
import 'package:mosaic_doctors/models/doctor.dart';
import 'package:mosaic_doctors/models/jobType.dart';
import 'package:mosaic_doctors/models/material.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/models/statementTotals.dart';
import 'package:mosaic_doctors/shared/Constants.dart';
import 'package:http/http.dart' as http;
import 'package:mosaic_doctors/shared/locator.dart';

class DatabaseAPI {
  static const ROOT = Constants.ROOT;
  static List<AccountStatementEntry> accountStatementEntrys= List<AccountStatementEntry>();
  static List<Job> caseJobsList= List<Job>();

  static Map<int, JobType> jobTypes = Map<int, JobType>();
  static Map<int, Material> materials = Map<int, Material>();
  static StatementTotals totals = StatementTotals();
  static Future getDoctorAccountStatement(String doctorId) async {
    var map = Map<String, dynamic>();

    String getAccountStatementQuery = "SELECT account_statements.id,"
        " account_statements.patient_name,"
        " account_statements.credit,"
        " account_statements.debit,"
        " account_statements.balance,"
        " account_statements.created_at,"
        " orders.id as 'order_id'"
        " FROM account_statements"

        " INNER JOIN orders ON account_statements.patient_name=orders.patient_name"
        " WHERE account_statements.doctor_id=$doctorId";

    print("get AE queyr : $getAccountStatementQuery");
    map['action'] = "GET";
    map['query'] = getAccountStatementQuery;
    print("posting");
    final response = await http.post(ROOT, body: map);
    print("finished posting : ${response.body}");
    var parsed = await json.decode(response.body);
    print("finished decoding : $parsed");
    accountStatementEntrys.clear();
    totals = StatementTotals();
    for(int i=0;i<parsed.length;i++){
      print("adding entry");
      AccountStatementEntry accountStatementEntry =AccountStatementEntry.fromJson(parsed[i]);
      //accountStatementEntry.caseDetails = await getCaseDetails(accountStatementEntry.orderId);
      accountStatementEntrys.add(accountStatementEntry);
      if (accountStatementEntry.debit != "N/A"){
        totals.totalDebit =  totals.totalDebit+ double.parse(accountStatementEntry.debit);
        totals.totalCases = totals.totalCases+1;
      }
      else{
        totals.totalCredit =  totals.totalCredit+ double.parse(accountStatementEntry.credit);}
    }
//    RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
//    Function mathFunc = (Match match) => '${match[1]},';
//    totals.totalCredit = totals.totalCredit.toString().replaceAllMapped(reg, mathFunc);

        print("Totals ${totals.totalDebit }${totals.totalCredit }");
        print("statement length : ${accountStatementEntrys.length}");

  return accountStatementEntrys;
  }


  static Future getDoctorInfo(String phoneNumber) async {
    var map = Map<String, dynamic>();

    String getDocInfoQuery =
        "SELECT * from `doctors` WHERE `doctors`.`phone` LIKE '%${phoneNumber.substring(phoneNumber.length - 9)}%'";
    print(getDocInfoQuery);
    map['action'] = "GET";
    map['query'] = getDocInfoQuery;
    String responseText = "N/A";
    final response = await http.post(ROOT, body: map);
    var parsed = json.decode(response.body);
    Doctor doctor = Doctor.fromJson(parsed[0]);
    getIt<SessionData>().doctor = doctor;
    return doctor;
  }

  static Future getCaseJobs(String caseId) async {
    var map = Map<String, dynamic>();

    String getCaseDetailsQuery =
        "SELECT * from `jobs` WHERE `jobs`.`order_id` = $caseId";
    print(getCaseDetailsQuery);
    map['action'] = "GET";
    map['query'] = getCaseDetailsQuery;

    final response = await http.post(ROOT, body: map);
    var parsed = json.decode(response.body);
    caseJobsList.clear();
    for(int i=0;i<parsed.length;i++){
      print("adding entry");
      Job caseDetails = Job.fromJson(parsed[i]);
      //accountStatementEntry.caseDetails = await getCaseDetails(accountStatementEntry.orderId);
      caseJobsList.add(caseDetails);
    }

    print("jobs : ${caseJobsList.length}");
    await getJobStyles();
    await getMaterials();
    return caseJobsList;
  }
  static Future getCase(String caseId) async {
    var map = Map<String, dynamic>();

    String getCaseQuery =
        "SELECT * from `orders` WHERE `orders`.`id` = $caseId";
    print(getCaseQuery);
    map['action'] = "GET";
    map['query'] = getCaseQuery;

    final response = await http.post(ROOT, body: map);
    var parsed = json.decode(response.body);

      Case caseItem = Case.fromJson(parsed[0]);


    print("case : ${caseItem.toString()}");
    return caseItem;
  }

  static getJobStyles() async {
    print("fetching job types");
    var map = Map<String, dynamic>();
    map['action'] = 'GET';
    map['query'] = "SELECT * from job_types;";

    final getJobTypesResponse = await http.post(ROOT, body: map);

    var parsed = json.decode(getJobTypesResponse.body);

    for (int i = 0; i < parsed.length; i++) {
      JobType jobType = JobType.fromJson(parsed[i]);
      jobTypes[i] = (jobType);
      print('JobType added');
    }
  }
  static getMaterials() async {
    print("fetching Materials");
    var map = Map<String, dynamic>();
    map['action'] = 'GET';
    map['query'] = "SELECT * from materials;";

    final getMaterialsResponse = await http.post(ROOT, body: map);

    var parsed = json.decode(getMaterialsResponse.body);

    for (int i = 0; i < parsed.length; i++) {
      Material material = Material.fromJson(parsed[i]);
      materials[i] = (material);
      print('material added');
    }
  }
}
