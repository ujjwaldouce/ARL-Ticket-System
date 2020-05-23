import 'dart:convert';

import 'package:arlticketsystem/utils/rest_ds.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:credit_card_field/credit_card_field.dart';
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

    StripePayment.setOptions(
        StripeOptions(
            publishableKey: "pk_test_xp2iNdxA2sbWB2ScNEGxo1rN00N4TklLWJ",
            merchantId: "sk_test_1Ggs34F7qx3ntEjciEhWwDDs00x9prwjRt",
            androidPayMode: 'test'
        )
    );
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
            createCharge(paymentMethod.id, ticketPrice);

      },
    ).catchError(setError);

    /*CreditCard testCard = CreditCard(
      number: creditCardController.text,
      expMonth: int.tryParse(expirationController.text.substring(0, 2)),
      expYear: int.tryParse(expirationController.text.substring(3, 5)),
    );*/

    /*StripePayment.createTokenWithCard(testCard).then((token) {
      debugPrint("token ${token.tokenId}");
      createCharge(token.tokenId, ticketPrice);
    });*/
  }

  static Future<Map<String, dynamic>> createCharge(String tokenId, String ticketPrice) async {
    try {
      Map<String, dynamic> customerBody = {
        'email': 'ujjwal.drupalchamp@gmail.com',
        'name': 'Ujjwal Jha',
        //'source': tokenId,
        'description': 'Test Customer',
        'payment_method': tokenId,
        'invoice_settings[default_payment_method]': tokenId
      };

      var customerResponse = await http.post(
          'https://api.stripe.com/v1/customers',
          body: customerBody,
          headers: { 'Authorization': 'Bearer sk_test_1Ggs34F7qx3ntEjciEhWwDDs00x9prwjRt','Content-Type': 'application/x-www-form-urlencoded'}
      );

      Map<String, dynamic> responseJson = json.decode(customerResponse.body);
      String customerId = responseJson['id'];

      debugPrint("customerId ${customerId}");
      debugPrint("customerResponse ${customerResponse.body}");

      /*Map<String, dynamic> customerPaymentBody = {
        'customer' : customerId,
      };
      var customerPaymentAttachResponse = await http.post(
          'https://api.stripe.com/v1/payment_methods/${tokenId}/attach',
          body: customerPaymentBody,
          headers: { 'Authorization': 'Bearer sk_test_1Ggs34F7qx3ntEjciEhWwDDs00x9prwjRt','Content-Type': 'application/x-www-form-urlencoded'}
      );
      debugPrint("customerResponse ${customerPaymentAttachResponse.body}");*/

      Map<String, dynamic> body = {
        'customer' : customerId,
        'amount': "${int.parse(ticketPrice)*100}",
        'currency': 'usd',
        //'source': tokenId,
        'description': 'My Third try',
        'payment_method' : tokenId,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(
          //'https://api.stripe.com/v1/charges',
          'https://api.stripe.com/v1/payment_intents',
          body: body,
          headers: { 'Authorization': 'Bearer sk_test_1Ggs34F7qx3ntEjciEhWwDDs00x9prwjRt','Content-Type': 'application/x-www-form-urlencoded'}
      );
      debugPrint("response ${response.body}");

      Map<String, dynamic> paymentIntentResponseJson = json.decode(response.body);
      String paymentIntentId = paymentIntentResponseJson['id'];

      Map<String, dynamic> paymentIntentBody = {
        'payment_method' : tokenId,
      };

      var paymentIntentConfirmationResponse = await http.post(
          'https://api.stripe.com/v1/payment_intents/${paymentIntentId}/confirm',
          body: paymentIntentBody,
          headers: { 'Authorization': 'Bearer sk_test_1Ggs34F7qx3ntEjciEhWwDDs00x9prwjRt','Content-Type': 'application/x-www-form-urlencoded'}
      );
      debugPrint("response ${paymentIntentConfirmationResponse.body}");

      /*var responseNew = await http.post(
          //'https://api.stripe.com/v1/charges',
          body: body,
          headers: { 'Authorization': 'Bearer sk_test_1Ggs34F7qx3ntEjciEhWwDDs00x9prwjRt','Content-Type': 'application/x-www-form-urlencoded'}
      );
      debugPrint("responseNew ${responseNew.body}");*/
      return jsonDecode(response.body);
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
              padding: const EdgeInsets.only(top:20, bottom: 5),
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
              padding: const EdgeInsets.only(top:5, bottom: 40),
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
            SizedBox(height: 8),
            TextFormField(
              initialValue: "t",
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (String value) {
                if (value.trim().isEmpty) {
                  return 'Name is required';
                }
              },
            ),
            SizedBox(height: 8),
            TextFormField(
              initialValue: "t@t.com",
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (String value) {
                if (value.trim().isEmpty) {
                  return 'Email is required';
                }
              },
            ),
            SizedBox(height: 8),
            CreditCardFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Credit Card Number",
              ),
              controller: creditCardController,
            ),
            SizedBox(height: 8),
            ExpirationFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Card Expiration",
                hintText: "MM/YY",
              ),
              controller: expirationController,
            ),
            SizedBox(height: 8),
            CVVFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "CVV",
              ),
              controller: cvvController,
            ),
            SizedBox(height: 20.0),
        Material(
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
        )
          ],
        ),
      ),
    )
    )
    );
  }
}
