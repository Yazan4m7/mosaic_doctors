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
  static List<dynamic> accountStatementEntrys = List<dynamic>();
  static List<AccountStatementEntry> singleMonthAccountStatementEntrys = List<AccountStatementEntry>();
  static List<dynamic> currentAccountStatementEntries = List<dynamic>();
  static List<Job> caseJobsList = List<Job>();
  static List<String> docCasesIds = List<String>();
  static List<Job> allCaseJobsList = List<Job>();
  static List<PreviousMonthBalance> previousMonthsBalances =
      List<PreviousMonthBalance>();
  static Map<int, JobType> jobTypes = Map<int, JobType>();
  static Map<int, Material> materials = Map<int, Material>();
  static StatementTotals totals = StatementTotals();
  static StatementTotals singleMonthTotals = StatementTotals();
  static String currentYearMonth = Jiffy().format("yy-MM");
  static List<dynamic> entries = List<dynamic>();
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

  static Future getDoctorAccountStatement(
      String doctorId, bool forceReload) async {
    // if already filled return it
    if (entries.isNotEmpty || forceReload) {
      print("Statement already has data.");
      return entries;
    }

    var map = Map<String, dynamic>();
    String getAccountStatementQuery =
        " SELECT invoices.id, orders.patient_name, invoices.amount, "
        " invoices.created_at, invoices.order_id, invoices.doctor_id FROM invoices  "
        "INNER JOIN orders ON invoices.order_id=orders.id WHERE invoices.doctor_id=$doctorId "
        "AND orders.current_status=6 order by invoices.created_at";

    map['action'] = "GET";
    map['query'] = getAccountStatementQuery;
    print(getAccountStatementQuery);
    final response = await http.post(ROOT, body: map);
    print(response.body);
    var parsed = await json.decode(response.body);

    accountStatementEntrys.clear();
    // totals -> total debit,credit and balance
    // balance increases with invoice and decreases with payment.
    totals = StatementTotals();
    int balance = 0;

    for (int i = 0; i < parsed.length; i++) {
      AccountStatementEntry accountStatementEntry =
          AccountStatementEntry.fromJson(parsed[i]);

      //   if (entryMonth == currentYearMonth) {

      accountStatementEntrys.add(accountStatementEntry);
      docCasesIds.add(accountStatementEntry.orderId);
      //   }
      print("ASE added");
      // else {
      //    addPreviousBalanceEntry(accountStatementEntry,entryMonth);

      //   }
    }

    map['query'] = "SELECT * from payment_logs where doctor_id=$doctorId";
    final paymentsResponse = await http.post(ROOT, body: map);
    if (!paymentsResponse.body.isEmpty) {
      var paymentsParsed = await json.decode(paymentsResponse.body);

      for (int i = 0; i < paymentsParsed.length; i++) {
        print("payment added");
        Payment payment = Payment.fromJson(paymentsParsed[i]);

        accountStatementEntrys.add(payment);
      }
    }
    sortAndCalculateBalance();

    entries = List.from(previousMonthsBalances)
      ..addAll(currentAccountStatementEntries);
    return entries;
  }

  static sortAndCalculateBalance() {
    accountStatementEntrys.sort((a, b) {
      return a.createdAt.compareTo(b.createdAt);
    });
    totals = StatementTotals();
    int balance = 0;
    for (int j = 0; j < accountStatementEntrys.length; j++) {
      if (accountStatementEntrys[j] is AccountStatementEntry) {
        totals.totalDebit =
            totals.totalDebit + double.parse(accountStatementEntrys[j].amount);
        totals.totalCases = totals.totalCases + 1;

        balance = balance + int.parse(accountStatementEntrys[j].amount);

        accountStatementEntrys[j].balance = balance.toString();
        String entryMonth = accountStatementEntrys[j].createdAt.substring(2, 7);

        if (entryMonth != currentYearMonth)
          addToPreviousBalance(accountStatementEntrys[j], entryMonth);
        else
          currentAccountStatementEntries.add(accountStatementEntrys[j]);
      } else {
        balance = balance - int.parse(accountStatementEntrys[j].amount);

        accountStatementEntrys[j].balance = balance.toString();
        totals.totalCredit =
            totals.totalCredit + double.parse(accountStatementEntrys[j].amount);

        String entryMonth = accountStatementEntrys[j].createdAt.substring(2, 7);
        if (entryMonth != currentYearMonth)
          addToPreviousBalance(accountStatementEntrys[j], entryMonth);
        else
          currentAccountStatementEntries.add(accountStatementEntrys[j]);
      }
    }
  }

  static addToPreviousBalance(dynamic entry, String entryMonth) {
    if (previousMonthsBalances
        .where((element) => element.date == entryMonth)
        .isEmpty) {
      previousMonthsBalances.add(PreviousMonthBalance(
        date: entryMonth,
        amount: entry.balance,
      ));
    } else {
      PreviousMonthBalance temp = previousMonthsBalances
          .where((element) => element.date == entryMonth)
          .first;
      if (entry is AccountStatementEntry)
        temp.amount =
            (double.parse(temp.amount) + double.parse(entry.amount)).toString();
      if (entry is Payment)
        temp.amount =
            (double.parse(temp.amount) - double.parse(entry.amount)).toString();
    }
  }

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
    AccountStatementEntry requestedEntry = accountStatementEntrys
        .where((element) => element.orderId == caseId)
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
