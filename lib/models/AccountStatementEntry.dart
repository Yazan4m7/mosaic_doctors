import 'job.dart';

class AccountStatementEntry {
  String id;
  String patientName;
  String credit;
  String debit;
  String balance;
  String createdAt;
  String orderId;
  List<Job> caseDetails ;

  AccountStatementEntry({this.id, this.patientName, this.credit, this.debit,
      this.balance, this.createdAt, this.orderId,this.caseDetails});


  @override
  String toString() {
    return 'AccountStatementEntry{id: $id, patient_name: $patientName, credit: $credit, debit: $debit, balance: $balance, createdAt: $createdAt, orderId: $orderId}';
  }

  factory AccountStatementEntry.fromJson(Map<String, dynamic> json) {
    return AccountStatementEntry(
        id : json['id']==null? "N/A":json['id'],
        patientName : json['patient_name']==null? "N/A":json['patient_name'],
        balance : json['balance']==null? "N/A":json['balance'],
        credit : json['credit']==null? "N/A":json['credit'],
      debit : json['debit']==null? "N/A":json['debit'],
      createdAt : json['created_at']==null? "N/A":json['created_at'],
      orderId : json['order_id']==null? "N/A":json['order_id'],
    );
  }
}