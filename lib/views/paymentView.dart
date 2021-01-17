import 'package:flutter/material.dart';
import 'package:mosaic_doctors/models/creditCard.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/services/DatabaseAPI.dart';
import 'package:mosaic_doctors/services/payment.dart';
import 'package:mosaic_doctors/shared/locator.dart';

class PaymentView extends StatefulWidget {

  @override
  _PaymentViewState createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  CreditCard  cardInfo;
  TextEditingController amountTC = TextEditingController();
  double cardHeight = 250;
  double cardWidth = 520;
  getCard() async {
    cardInfo = await  DatabaseAPI.getCreditCardInfo();
    print("Card = ${cardInfo.toString()}");
    setState(() {

    });
  }
  @override
  void initState() {
    // TODO: implement initState
   getCard();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return cardInfo == null ? SizedBox() : Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottom),
        reverse: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0,12.0,12.0,0),
            child:
     Column(
        children: <Widget>[
          Card(
            child: Stack(
              children: <Widget>[
                Image.asset("assets/images/GTP_card.png",width: cardWidth,height: cardHeight,),
                Positioned(
                  bottom : cardHeight/2.8,
                  left:cardHeight/6,
                  child: Text(
                    cardInfo.cardNumber,
                    style: TextStyle(
                        fontSize: 25.0,
                        color: Colors.white
                    ),
                  ),
                ),

                Positioned(
                  bottom: cardHeight/4.3,
                  left:cardHeight/1.5,
                  child: Text(
                    cardInfo.expiryDate,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),

                Positioned(
                  bottom: cardHeight/10,
                  left: cardHeight/10,
                  child: Text(
                    getIt<SessionData>().doctor.name,
                    style: TextStyle(
                      fontFamily: "Droid",
                        color: Colors.white,
                        fontSize: 25.0
                    ),
                    textAlign: TextAlign.end,

                  ),
                ),
              ],
            ),
            elevation: 5.0,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            semanticContainer: true,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child:Column(
                children: <Widget>[
                  TextFormField(
                    controller: TextEditingController()..text =  cardInfo.cardNumber,
                    style: TextStyle(
                        fontSize: 20.0
                    ),
                    readOnly: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(),
                        ),
                        labelText: "Credit Card Number",
                        labelStyle: TextStyle(
                            fontSize: 18.0
                        ),

                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    controller: TextEditingController()..text =  cardInfo.expiryDate,
                    style: TextStyle(
                        fontSize: 20.0
                    ),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(),
                        ),
                        labelText: "Credit Card Expiry Date",
                        labelStyle: TextStyle(
                            fontSize: 18.0
                        )
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    controller: amountTC,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(),
                        ),
                        labelText: "Amount",
                        labelStyle: TextStyle(
                            fontSize: 18.0
                        )
                    ),
                  ),

                  SizedBox(
                    height: 20.0,
                  ),
                  FlatButton(
                    color: Colors.pink,
                    onPressed: (){Payment.initializePayment(double.parse(amountTC.text.trim()),cardInfo.cardNumber , cardInfo.expiryDate);},
                    shape: StadiumBorder(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 12.0),
                      child: Text(
                        "Pay",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.0
                        ),

                      ),
                    ),
                  )
                ],
              )
          )
        ],
      )


          ),
        ),
      ),
    );
  }
}