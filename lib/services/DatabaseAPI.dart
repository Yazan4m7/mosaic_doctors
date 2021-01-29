import 'dart:convert';
import 'package:jiffy/jiffy.dart';
import 'package:mosaic_doctors/models/AccountStatementEntry.dart';
import 'package:mosaic_doctors/models/case.dart';
import 'package:mosaic_doctors/models/creditCard.dart';
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
import 'package:mosaic_doctors/shared/globalVariables.dart';
import 'package:mosaic_doctors/shared/locator.dart';

class DatabaseAPI {
  static const ROOT = Constants.ROOT;
  static List<AccountStatementEntry> accountStatementEntrys = [];
  static List<AccountStatementEntry> singleMonthAccountStatementEntrys = [];
  static List<dynamic> currentAccountStatementEntries = [];
  static List<Job> caseJobsList =[];
  static List<String> docCasesIds = [];
  static List<Job> allCaseJobsList = [];
  static List<Payment> docPayments = [];
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
    String getOpeningBalanceQuery = "SELECT * FROM account_statements where doctor_id = $doctorId AND patient_name= 'رصيد افتتاحي'";
    map['action'] = "GET";
    map['query'] = getOpeningBalanceQuery;
    final response = await http.post(ROOT, body: map);
    var parsed = await json.decode(response.body);
    AccountStatementEntry openingBalance = new AccountStatementEntry();
    openingBalance.debit = parsed[0]['debit'];
    openingBalance.credit = parsed[0]['credit'];
    openingBalance.patientName=parsed[0]['patient_name'];
    openingBalance.doctorId=parsed[0]['doctor_id'];
    openingBalance.createdAt=parsed[0]['created_at'];
    accountStatementEntrys.add(openingBalance);
  }
  static Future getDocPayments(String doctorId) async{

    var map = Map<String, dynamic>();
    String getPaymentsQuery = "SELECT * FROM `payment_logs` where doctor_id = $doctorId";
    map['action'] = "GET";
    map['query'] = getPaymentsQuery;
    final response = await http.post(ROOT, body: map);
    var parsed = await json.decode(response.body);
    for (int i = 0; i < parsed.length; i++) {
      Payment payment =
      Payment.fromJson(parsed[i]);
      docPayments.add(payment);
    }
  }
  static Future getDoctorAccountStatement( String doctorId, bool forceReload) async {
    drHasTransactionsThisMonth=true;
    if (entries.isNotEmpty && forceReload) {
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
    if(response.body.isEmpty ) return null;
    //print(response.body);
    var parsed = await json.decode(response.body);

    await getDocPayments(doctorId);

    accountStatementEntrys.clear();
    for (int i = 0; i < parsed.length; i++) {
      AccountStatementEntry accountStatementEntry =
          AccountStatementEntry.fromJson(parsed[i]);
      firstEntryDate = accountStatementEntry.createdAt;
      //   if (entryMonth == currentYearMonth) {
      // if payment fix the balance
      if(accountStatementEntry.credit !="N/A") accountStatementEntry.balance = (double.parse(accountStatementEntry.balance)- double.parse(accountStatementEntry.credit)).toString();
      if(accountStatementEntry.createdAt.substring(2, 7) == currentYearMonth)

      if(accountStatementEntry.caseId !="N/A")
      docCasesIds.add(accountStatementEntry.caseId);

      if(accountStatementEntry.paymentId !="N/A"){
        String paymentNote = docPayments.where((element) => element.id == accountStatementEntry.paymentId).first.notes;
        if(paymentNote != "N/A")
          accountStatementEntry.patientName = paymentNote;
         }

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

  static Future getDoctorInfo(String phoneNumber) async {
    var map = Map<String, dynamic>();

    if(phoneNumber == null){
      getIt<SessionData>().loginWelcomeMessage = "Something went wrong, please log in again. err code : 0";
      AuthService.signOut();}
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
    if(response.body.isNotEmpty){
    var parsed = json.decode(response.body);
    for (int i = 0; i < parsed.length; i++) {
      Discount discount = Discount.fromJson(parsed[i]);
      doctor.discounts[int.parse(discount.materialId)] = discount;
    }
    }
    getIt<SessionData>().doctor = doctor;

  }

  static Future getCaseJobs(String caseId) async {
    AccountStatementEntry requestedEntry = accountStatementEntrys
        .where((element) => element.caseId == caseId)
        .first;


    // حالة عكس حركة
    if (requestedEntry.patientName.contains("عكس ح") )
      return await getReversedCaseJobs(requestedEntry);

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

  static Future getAccountStatementTotals(Jiffy currentMonth) async{
    if (accountStatementEntrys.isEmpty) await getDoctorAccountStatement(getIt<SessionData>().doctor.id, false);

    totals = StatementTotals();
    AccountStatementEntry firstEntryOfTheMonth = accountStatementEntrys.where((element) => element.createdAt.substring(2, 7) == currentMonth.format("yy-MM")).first;
    if (firstEntryOfTheMonth.credit != "N/A")
    totals.openingBalance= double.parse(firstEntryOfTheMonth.balance) ;
    else
      totals.openingBalance= double.parse(firstEntryOfTheMonth.balance) - double.parse(firstEntryOfTheMonth.debit);


    accountStatementEntrys.where((element) => element.createdAt.substring(2, 7) == currentMonth.format("yy-MM")).forEach((entry) {
      if (entry.credit != "N/A" ){
        totals.totalCredit += double.parse(entry.credit);}
      else if (entry.debit != "N/A") {

        totals.totalDebit += double.parse(entry.debit);}
    });
    return totals;
  }

  static Future<List<Job>> getReversedCaseJobs(AccountStatementEntry requestedEntry) async{
    print("getting reversed case jobs of ${requestedEntry.caseId}");
     List<Job> reversedCaseJobs = [];
    var map = Map<String, dynamic>();
    String getCaseDetailsQuery =
        "SELECT * from `rejected_jobs` WHERE `rejected_jobs`.`order_id`  = ${requestedEntry.caseId}";
    map['action'] = "GET";
    map['query'] = getCaseDetailsQuery;
    var response = await http.post(ROOT, body: map);
    var parsed = json.decode(response.body);
    print(parsed);
    for (int j = 0; j < parsed.length; j++) {
      Job job = Job.fromJson(parsed[j]);
      reversedCaseJobs.add(job);
    }


    await getJobStyles();
    await getMaterials();
    return reversedCaseJobs;

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


    await getJobStyles();
    await getMaterials();

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

    return caseItem;
  }

  static getJobStyles() async {
    if (jobTypes.isNotEmpty) return;
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
    if (materials.isNotEmpty) return;
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

//  static getCreditCardInfo() async {
//
//    var map = Map<String, dynamic>();
//    map['action'] = 'GET';
//    map['query'] = "SELECT * from credit_cards where doctor_id = ${getIt<SessionData>().doctor.id};";
//    print("get card  query : ${map['query'] }");
//    final getCardResponse = await http.post(Constants.LOCAL_ROOT, body: map);
//    print("get card info before parsing : ${getCardResponse.body}");
//    var parsed = json.decode(getCardResponse.body);
//    print("Card : $parsed");
//    CreditCard card = CreditCard.fromJson(parsed[0]);
//    return card;
//
//  }
}
