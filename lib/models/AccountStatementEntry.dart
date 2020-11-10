import 'job.dart';

class AccountStatementEntry {
  String id;
  String patientName;
  String amount;
  String balance;
  String createdAt;
  String orderId;
  String doctorId;
  List<Job> caseDetails ;

  AccountStatementEntry({this.id, this.patientName, this.amount, this.doctorId,
      this.balance, this.createdAt, this.orderId,this.caseDetails});


  @override
  String toString() {
    return 'AccountStatementEntry{id: $id, patientName: $patientName, amount: $amount, balance: $balance, createdAt: $createdAt, orderId: $orderId, doctorId: $doctorId, caseDetails: $caseDetails}';
  }

  factory AccountStatementEntry.fromJson(Map<String, dynamic> json) {
    return AccountStatementEntry(
        id : json['id']==null? "N/A":json['id'],
        patientName : json['patient_name']==null? "N/A":json['patient_name'],
        balance : json['balance']==null? "N/A":json['balance'],
      amount : json['amount']==null? "N/A":json['amount'],
      doctorId : json['doctor_id']==null? "N/A":json['doctor_id'],
      createdAt : json['created_at']==null? "N/A":json['created_at'],
      orderId : json['order_id']==null? "N/A":json['order_id'],
    );
  }
}