
class CreditCard {
  String id;
  String doctorId;
  String cardNumber;
  String expiryDate;


  @override
  String toString() {
    return 'CreditCard{id: $id, doctorId: $doctorId, cardNumber: $cardNumber, expiryDate: $expiryDate}';
  }

  CreditCard({this.id, this.doctorId, this.cardNumber, this.expiryDate});


  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      id : json['id']==null? "N/A":json['id'],
      doctorId : json['doctor_id']==null? "N/A":json['doctor_id'],
      cardNumber : json['card_number']==null? "N/A":json['card_number'],
      expiryDate : json['expiry_date']==null? "N/A":json['expiry_date'],

    );
  }

}