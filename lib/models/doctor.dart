class Doctor {
  String id;
  String name;
  String balance;
  String phone;
  Doctor(
      {this.id,this.name,this.balance,this.phone});

  @override
  String toString() {
    return 'Doctor{id: $id, name: $name, balance: $balance, phone: $phone}';
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
        id : json['id']==null? "N/A":json['id'],
        name : json['name']==null? "N/A":json['name'],
        balance : json['balance']==null? "N/A":json['balance'],
        phone : json['phone']==null? "N/A":json['phone'] );
  }
}