import 'package:mosaic_doctors/models/discount.dart';

class Payment {
  String id;
  String amount;
  String notes;
  String doctorId;
  String collector;
  String createdAt;
  String balance;

  Payment({this.id, this.amount, this.notes, this.doctorId, this.collector,
      this.createdAt});


  @override
  String toString() {
    return 'Payment{id: $id, amount: $amount, notes: $notes, doctorId: $doctorId, collector: $collector, createdAt: $createdAt}';
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
        id : json['id']==null? "N/A":json['id'],
        amount : json['amount']==null? "N/A":json['amount'],
        notes : json['notes']==null? "N/A":json['notes'],
        doctorId : json['doctor_id']==null? "N/A":json['doctor_id'],
        collector : json['collector']==null? "N/A":json['collector'],
        createdAt : json['created_at']==null? "N/A":json['created_at']);
  }
}