
class Payment {
  String id;
  String amount;
  String doctorId;
  String paymentId;
  String caseId;
  String createdAt;
  String balance;

  Payment({this.id, this.amount,  this.doctorId, this.paymentId,this.caseId,this.createdAt});



  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
        id : json['id']==null? "N/A":json['id'],
        amount : json['credit']==null? "N/A":json['credit'],
        doctorId : json['doctor_id']==null? "N/A":json['doctor_id'],
        paymentId : json['payment_id']==null? "N/A":json['payment_id'],
        caseId : json['case_id']==null? "N/A":json['case_id'],
        createdAt : json['created_at']==null? "N/A":json['created_at']);
  }
}