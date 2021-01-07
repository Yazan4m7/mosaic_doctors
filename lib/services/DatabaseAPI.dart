import 'dart:convert';
import 'package:jiffy/jiffy.dart';
import 'package:mosaic_doctors/models/AccountStatementEntry.dart';
import 'package:mosaic_doctors/models/case.dart';
import 'package:mosaic_doctors/models/discount.dart';
import 'package:mosaic_doctors/models/job.dart';
import 'package:mosaic_doctors/models/doctor.dart';
import 'package:mosaic_doctors/models/jobType.dart';
import 'package:mosaic_doctors/models/material.dart';
import 'package:mosaic_doctors/models/payment.dart';
import 'package:mosaic_doctors/models/previousMonthBalance.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/models/statementTotals.dart';
import 'package:mosaic_doctors/services/auth_service.dart';
import 'package:mosaic_doctors/shared/Constants.dart';
import 'package:http/http.dart' as http;
import 'package:mosaic_doctors/shared/locator.dart';

class DatabaseAPI {
  static const ROOT = Constants.ROOT;
  static List<AccountStatementEntry> accountStatementEntrys = List<AccountStatementEntry>();
  static List<AccountStatementEntry> singleMonthAccountStatementEntrys = List<AccountStatementEntry>();
  static List<dynamic> currentAccountStatementEntries = List<dynamic>();
  static List<Job> caseJobsList = List<Job>();
  static List<String> docCasesIds = List<String>();
  static List<Job> allCaseJobsList = List<Job>();
  static List<PreviousMonthBalance> previousMonthsBalances =  List<PreviousMonthBalance>();
  static Map<int, JobType> jobTypes = Map<int, JobType>();
  static Map<int, Material> materials = Map<int, Material>();
  static StatementTotals totals = StatementTotals();
  static StatementTotals singleMonthTotals = StatementTotals();
  static String currentYearMonth = Jiffy().format("yy-MM");
  static List<dynamic> entries = List<dynamic>();
  static String firstEntryDate;
  static bool drHasTransactionsThisMonth = true;
  static Future get30sepBalance(String doctorId) async{

    var map = Map<String, dynamic>();
    String getOpeningBalanceQuery =
        "SELECT * FROM account_statements where doctor_id = $doctorId AND patient_name= 'رصيد افتتاحي'";

    map['action'] = "GET";
    map['query'] = getOpeningBalanceQuery;
    final response = await http.post(ROOT, body: map);
    print("Opening balance: $response");
    var parsed = await json.decode(response.body);
    print("Opening balance: $parsed");
    AccountStatementEntry openingBalance = new AccountStatementEntry();
    openingBalance.debit = parsed[0]['debit'];
    openingBalance.credit = parsed[0]['credit'];
    openingBalance.patientName=parsed[0]['patient_name'];
    openingBalance.doctorId=parsed[0]['doctor_id'];
    openingBalance.createdAt=parsed[0]['created_at'];
    accountStatementEntrys.add(openingBalance);
  print("addded opening balance $openingBalance");
  }

  static Future getMonthlyStatement(String doctorId, String month) async {
    if (accountStatementEntrys.isEmpty){
      print("ASE empty, loading it.");
      await getDoctorAccountStatement(doctorId, false);
    }

    print("Requested month : $month");
   // print(accountStatementEntrys.first.createdAt.substring(2, 7));
    List<dynamic> singleMonthAccountStatementEntrys= accountStatementEntrys
        .where((element) => element.createdAt.substring(2, 7) == month)
        .toList();
    double balance=0;
    singleMonthTotals = new StatementTotals();
    for (int j = 0; j < singleMonthAccountStatementEntrys.length; j++) {

      if (singleMonthAccountStatementEntrys[j] is AccountStatementEntry) {

        singleMonthTotals.totalDebit =
            singleMonthTotals.totalDebit + double.parse(singleMonthAccountStatementEntrys[j].amount);
        singleMonthTotals.totalCases = singleMonthTotals.totalCases + 1;

        balance = balance + int.parse(singleMonthAccountStatementEntrys[j].amount);


      } else {

        singleMonthAccountStatementEntrys[j].balance = balance.toString();
        singleMonthTotals.totalCredit =
            singleMonthTotals.totalCredit + double.parse(singleMonthAccountStatementEntrys[j].amount);
        balance = balance - int.parse(singleMonthAccountStatementEntrys[j].amount);

      }
    }
    return singleMonthAccountStatementEntrys;

  }

  static Future getDoctorAccountStatement( String doctorId, bool forceReload) async {
    drHasTransactionsThisMonth=true;
    // if already filled return it
    if (entries.isNotEmpty || forceReload) {
      print("Statement already has data.");
      return entries;
    }


    var map = Map<String, dynamic>();
//    String getAccountStatementQuery =
//        " SELECT invoices.id, orders.patient_name, invoices.amount, "
//        " invoices.created_at, invoices.order_id, invoices.doctor_id FROM invoices  "
//        "INNER JOIN orders ON invoices.order_id=orders.id WHERE invoices.doctor_id=$doctorId "
//        "AND orders.current_status=6 order by invoices.created_at";
    String getAccountStatementQuery ="select * from account_statements where doctor_id = $doctorId order by created_at DESC";
    map['action'] = "GET";
    map['query'] = getAccountStatementQuery;
    print(getAccountStatementQuery);
    final response = await http.post(ROOT, body: map);
    //print(response.body);
    var parsed = await json.decode(response.body);

    accountStatementEntrys.clear();
    //await get30sepBalance(doctorId);
    // totals -> total debit,credit and balance
    // balance increases with invoice and decreases with payment.
    totals = StatementTotals();


    for (int i = 0; i < parsed.length; i++) {
      AccountStatementEntry accountStatementEntry =
          AccountStatementEntry.fromJson(parsed[i]);
      firstEntryDate = accountStatementEntry.createdAt;
      //   if (entryMonth == currentYearMonth) {
      // if payment fix the balance
      if(accountStatementEntry.credit !="N/A") accountStatementEntry.balance = (int.parse(accountStatementEntry.balance)- int.parse(accountStatementEntry.credit)).toString();
      if(accountStatementEntry.createdAt.substring(2, 7) == currentYearMonth)
      if (accountStatementEntry.debit!="N/A") {
        totals.totalDebit =
            totals.totalDebit + double.parse(accountStatementEntry.debit);

      } else {
        totals.totalCredit =
            totals.totalCredit + double.parse(accountStatementEntry.credit);
      }
      if(accountStatementEntry.caseId !="N/A")
      docCasesIds.add(accountStatementEntry.caseId);
      accountStatementEntrys.add(accountStatementEntry);

      //   }
      //print("ASE added");
      // else {
      //    addPreviousBalanceEntry(accountStatementEntry,entryMonth);

      //   }
    }

    accountStatementEntrys.sort((a, b) {
      return a.createdAt.compareTo(b.createdAt);
    });
    if (accountStatementEntrys.where((element) => element.createdAt.substring(2, 7) == currentYearMonth).isEmpty) {drHasTransactionsThisMonth = false;}
    print("Doctor current month trans : ${currentYearMonth}");
    return accountStatementEntrys;
  }


//  static addToPreviousBalance(dynamic entry, String entryMonth) {
//    print("Entry month is : ${entryMonth.substring(3,5)}");
//
//    int monthsAgo  = int.parse(currentYearMonth.substring(3,5)) -int.parse(entryMonth.substring(3,5));
//    if (previousMonthsBalances
//        .where((element) => element.date == entryMonth)
//        .isEmpty) {
//      previousMonthsBalances.add(PreviousMonthBalance(
//        date: entryMonth,
//        amount: entry.balance,
//        isPrevMonth: monthsAgo > 1 ? false : true));
//    } else {
//      PreviousMonthBalance temp = previousMonthsBalances
//          .where((element) => element.date == entryMonth)
//          .first;
//      if (entry is AccountStatementEntry)
//        temp.amount =
//            (double.parse(temp.amount) + double.parse(entry.amount)).toString();
//      if (entry is Payment)
//        temp.amount =
//            (double.parse(temp.amount) - double.parse(entry.amount)).toString();
//    }
//  }

  static Future getDoctorInfo(String phoneNumber) async {
    var map = Map<String, dynamic>();

    String getDocInfoQuery =
        "SELECT * from `doctors` WHERE `doctors`.`phone` LIKE '%${phoneNumber.substring(phoneNumber.length - 9)}%'";

    map['action'] = "GET";
    map['query'] = getDocInfoQuery;
    String responseText = "N/A";
    print("getting doc info");

      final response = await http.post(ROOT, body: map);

    print("finished posting");
    // If doctor was not found sign user out
    print(response.body);
    if (response.body.isEmpty) {
      return null;
    } else {
      print(map);
      print(response.body);
      var parsed = json.decode(response.body);
      Doctor doctor = Doctor.fromJson(parsed[0]);
      getIt<SessionData>().doctor = doctor;
      await getDoctorDiscounts();
      return doctor;
    }



  }

  static Future getDoctorDiscounts() async {
    Doctor doctor = getIt<SessionData>().doctor;
    var map = Map<String, dynamic>();

    String getDocDiscountsQuery =
        "SELECT * from `discounts` WHERE `discounts`.`doctor_id` = '${doctor.id}'";

    map['action'] = "GET";
    map['query'] = getDocDiscountsQuery;
    final response = await http.post(ROOT, body: map);
    var parsed = json.decode(response.body);
    for (int i = 0; i < parsed.length; i++) {
      Discount discount = Discount.fromJson(parsed[i]);

      //accountStatementEntry.caseDetails = await getCaseDetails(accountStatementEntry.orderId);
      doctor.discounts[int.parse(discount.materialId)] = discount;
    }
    getIt<SessionData>().doctor = doctor;
    print("Discounts loaded");
  }

  static Future getCaseJobs(String caseId) async {
    print("Case IDs array size: $docCasesIds");
    AccountStatementEntry requestedEntry = accountStatementEntrys
        .where((element) => element.caseId == caseId)
        .first;

    if (allCaseJobsList.isNotEmpty) {
      print(requestedEntry.toString() + " Has details returning it");
      return allCaseJobsList
          .where((element) => element.orderId == caseId)
          .toList();
    } else {
      await getCaseJobsForAllCases();

      return allCaseJobsList
          .where((element) => element.orderId == caseId)
          .toList();
    }
  }

  static getCaseJobsForAllCases() async {
    var map = Map<String, dynamic>();
    String casesIds = docCasesIds.toString();
    casesIds = casesIds.replaceAll('[', '(');
    casesIds = casesIds.replaceAll(']', ')');
    String getCaseDetailsQuery =
        "SELECT * from `jobs` WHERE `jobs`.`order_id`  in $casesIds";
    map['action'] = "GET";
    map['query'] = getCaseDetailsQuery;
    var response = await http.post(ROOT, body: map);
    var parsed = json.decode(response.body);
    for (int j = 0; j < parsed.length; j++) {
      Job job = Job.fromJson(parsed[j]);
      allCaseJobsList.add(job);
    }
    print(allCaseJobsList);

    await getJobStyles();
    await getMaterials();

//    for (int i = 0; i < accountStatementEntrys.length; i++) {
//      AccountStatementEntry tempEntry = accountStatementEntrys[i];
//
//      String getCaseDetailsQuery =
//          "SELECT * from `jobs` WHERE `jobs`.`order_id` = ${tempEntry.orderId}";
//      print("get jobs query : $getCaseDetailsQuery");
//      map['action'] = "GET";
//      map['query'] = getCaseDetailsQuery;
//
//      var response = await http.post(ROOT, body: map);
//      var parsed = json.decode(response.body);
//      tempCaseJobsList.clear();
//      for (int j = 0; j < parsed.length; j++) {
//
//        Job caseDetails = Job.fromJson(parsed[j]);
//        tempCaseJobsList.add(caseDetails);
//      }
//      print("add to entry ${tempEntry.orderId} jobs: ${tempCaseJobsList}");
//      if(tempEntry.id == tempCaseJobsList[0].orderId)
//      tempEntry.caseDetails = tempCaseJobsList;
//
//      //accountStatementEntrys[i] = tempEntry;
//
//    }
  }

  static Future getCase(String caseId) async {
    var map = Map<String, dynamic>();

    String getCaseQuery =
        "SELECT * from `orders` WHERE `orders`.`id` = $caseId";

    map['action'] = "GET";
    map['query'] = getCaseQuery;

    final response = await http.post(ROOT, body: map);
    var parsed = json.decode(response.body);

    Case caseItem = Case.fromJson(parsed[0]);

    print("case : ${caseItem.toString()}");
    return caseItem;
  }

  static getJobStyles() async {
    var map = Map<String, dynamic>();
    map['action'] = 'GET';
    map['query'] = "SELECT * from job_types;";

    final getJobTypesResponse = await http.post(ROOT, body: map);

    var parsed = json.decode(getJobTypesResponse.body);

    for (int i = 0; i < parsed.length; i++) {
      JobType jobType = JobType.fromJson(parsed[i]);
      jobTypes[i] = (jobType);
    }
  }

  static getMaterials() async {
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
