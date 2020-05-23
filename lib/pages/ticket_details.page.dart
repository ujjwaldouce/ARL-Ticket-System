import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:http/http.dart' as http;

class TicketDetailsPage extends StatefulWidget {
  final List tickets;
  TicketDetailsPage({Key key, @required this.tickets}) : super(key: key);

  @override
  _TicketDetailsPage createState() => new _TicketDetailsPage();
}

class _TicketDetailsPage extends State<TicketDetailsPage> {
  TextEditingController creditCardController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  TextEditingController expirationController = TextEditingController();

  String ticketID;
  String ticketNumber;
  String ticketPrice;
  String ticketStatus;
  String _error;

  /*final CreditCard testCard = CreditCard(
    number: '4242424242424242',
    expMonth: 12,
    expYear: 23,
  );*/

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  initState() {
    super.initState();

    StripePayment.setOptions(StripeOptions(
        publishableKey: "pk_test_xp2iNdxA2sbWB2ScNEGxo1rN00N4TklLWJ",
        merchantId: "sk_test_1Ggs34F7qx3ntEjciEhWwDDs00x9prwjRt",
        androidPayMode: 'test'));
  }

  void setError(dynamic error) {
    setState(() {
      _error = error.toString();
      debugPrint("_error ${_error}");
    });
  }

  void _submit() {
    debugPrint("submitted");

    StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then(
      (PaymentMethod paymentMethod) {
        debugPrint("paymentMethodId ${paymentMethod.id}");
        createCharge(paymentMethod.id, ticketPrice)
            .then((paymentIntentConfirmationJson) {
          String paymentIntentConfirmationStatus =
              paymentIntentConfirmationJson['status'];
          if (paymentIntentConfirmationStatus == 'succeeded') {
            String url = 'https://dev-ticketsystem.pantheonsite.io/api/updateticketpaymentstatus?_format=json';
            Map<String, String> headers = {
              'Content-type' : 'application/json',
              'Accept': 'application/json'
            };
            Map data = {
              'ticketId': ticketID
            };
            var body = json.encode(data);

            http.post(url, headers: headers, body: body).then((nodeUpdateResponse) {
              debugPrint("response ${nodeUpdateResponse.body}");
              Map<String, dynamic> responseJson = json.decode(nodeUpdateResponse.body);
              int status = responseJson['status'];
              String message = responseJson['message'];
              if(status == 1) {
                Fluttertoast.showToast(
                    msg: message,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0
                );

                setState(() {
                  widget.tickets[0]['field_payment_status'] = 'Paid';
                });
              }else {
                Fluttertoast.showToast(
                    msg: message,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
              }
            });
          }
        });
      },
    ).catchError(setError);
  }

  Future<Map<String, dynamic>> createCharge(
      String paymentMethod, String ticketPrice) async {
    try {
      Map<String, dynamic> body = {
        'amount': "${int.parse(ticketPrice) * 100}",
        'currency': 'usd',
        'description': 'My Third try',
        'payment_method': paymentMethod,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(
          'https://api.stripe.com/v1/payment_intents',
          body: body,
          headers: {
            'Authorization':
                'Bearer sk_test_1Ggs34F7qx3ntEjciEhWwDDs00x9prwjRt',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      //debugPrint("response ${response.body}");

      Map<String, dynamic> paymentIntentResponseJson =
          json.decode(response.body);
      String paymentIntentId = paymentIntentResponseJson['id'];

      Map<String, dynamic> paymentIntentBody = {
        'payment_method': paymentMethod,
      };

      var paymentIntentConfirmationResponse = await http.post(
          'https://api.stripe.com/v1/payment_intents/${paymentIntentId}/confirm',
          body: paymentIntentBody,
          headers: {
            'Authorization':
                'Bearer sk_test_1Ggs34F7qx3ntEjciEhWwDDs00x9prwjRt',
            'Content-Type': 'application/x-www-form-urlencoded'
          });

      //debugPrint("response ${paymentIntentConfirmationResponse.body}");

      return json.decode(paymentIntentConfirmationResponse.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("response ${widget.tickets}");
    ticketID = widget.tickets[0]['nid'];
    ticketNumber = widget.tickets[0]['title'];
    ticketPrice = widget.tickets[0]['field_price'];
    ticketStatus = widget.tickets[0]['field_payment_status'];
    debugPrint("ticketID ${ticketID}");

    final payButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: 200,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: _submit,
        child: Text("Pay Now",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
        body: Center(
            child: Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20, bottom: 5),
              child: new Text(
                'TICKET NUMBER: ${ticketNumber}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Aleo',
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                    color: Colors.black),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: new Text(
                'TICKET PRICE: \$${ticketPrice}',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontFamily: 'Aleo',
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                    color: Colors.black),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5, bottom: 40),
              child: new Text(
                'TICKET STATUS: ${ticketStatus}',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontFamily: 'Aleo',
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                    color: Colors.black),
              ),
            ),
            (ticketStatus == 'Unpaid') ? payButton : Container(),
          ],
        ),
      ),
    )));
  }
}
