import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:arlticketsystem/models/tickets.models.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/tickets.models.dart';
import 'dart:convert';

class API {
  static final BASE_URL = "https://dev-ticketsystem.pantheonsite.io";
  static final SESSION_TOKEN_URL = BASE_URL + "/session/token";
  static final LOGIN_URL = BASE_URL + "/user/login?_format=json";
  static final TICKET_DETAILS = BASE_URL + "/api/ticket-details/%?_format=json";

  /// Query Parameters
  /// String title
  /// String field_plate_no__value
  /// String field_date_value
  /// String field_payment_status_value
  static final TICKETS_URL = BASE_URL + "/api/tickets?_format=json";
}

class ApiService {
  static Future<List<dynamic>> userLogin(body) async {
    // RESPONSE JSON :
    /*{
      "current_user": {
        "uid": "1",
        "roles": [
          "authenticated",
          "administrator"
        ],
        "name": "admin"
      },
      "csrf_token": "dBnDtiETl0mDUslgY2Srdi7XBqEJG7HpNsg--yO1OMU",
      "logout_token": "tDl4Coum3u325i0Nzm7ECPbdyJzA6ugtCXrQHTuv3KI"
    }*/
    try {
      Response sessionTokenResponse = await Dio().get(API.SESSION_TOKEN_URL);
      try {
        Response response = await Dio().post(API.LOGIN_URL,
            data: body,
            options: Options(
              headers: {
                "Content-Type": "application/json",
                'X-CSRF-Token': sessionTokenResponse,
              },
            ));

        Fluttertoast.showToast(
            msg: "Login Successful",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        print('statuscode ${ response. statusCode}');
        print(response);
      }catch (e) {
        print(e);
        print(e.message);
        Fluttertoast.showToast(
            msg: e.message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    } catch (e) {
      print(e);
      print(e.message);
      Fluttertoast.showToast(
          msg: e.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  static Future<List<String>> getTickets() async {
    // RESPONSE JSON :
    /*
    [
      {
        "title":"000113",
        "field_plate_no_":"US0001",
        "field_date":"23\/11\/2017",
        "field_price":"$17",
        "field_payment_status":"Paid",
        "edit_node":"\u003Ca href=\u0022\/node\/70\/edit?destination=\/api\/tickets%3F_format%3Djson%26title%3D000113\u0022 class=\u0022btn-primary btn form-submit\u0022 hreflang=\u0022en\u0022\u003Eview\u003C\/a\u003E"
      }
    ]
    */
    //Response sessionTokenResponse = await Dio().get(API.SESSION_TOKEN_URL);
    // a variable named dogs which will contain a List of Strings
    final List<String> tickets = List<String>();
    try {
      Response response = await Dio().get('https://dog.ceo/api/breeds/image/random/20',
          options: Options(
            headers: {
              "Content-Type": "application/json",
              //'X-CSRF-Token': sessionTokenResponse,
            },
          ));
      print('statuscode ${ response. statusCode}');
      print('response ${ response}');
      print('responseString ${ response.toString()}');
      print('responseData ${ response.data}');
      //return Tickets.fromJSON(json.decode(response.toString()));
      //final Future<Tickets> tickets =
      //return response.data.expand((data) => (data as List))
       //   .map((data) => Tickets.fromJSON(data));

      // use json.decode from the dart:convert library to turn a raw json
      // response into a dart Map (object) which expects keys of strings
      // which can contain values of any type (dynamic)
      final Map<String, dynamic> jsonResponse = json.decode(response.data);
     // print('jsonResponse ${ jsonResponse}');
      // for this specific dog api, our data lives within 'message' so we're
      // going to loop over that and populate the List that we created earlier
      jsonResponse['message'].forEach((dogImageUrl) => tickets.add(dogImageUrl));

      /*json.decode(response.data).expand((data) => (data as List))
        .map((data) =>  tickets.add(data));*/
      // and return the data, this will fulfil the Future as complete
      return tickets;
    }catch (e) {
      print(e);
      print(e.message);
      Fluttertoast.showToast(
          msg: e.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }
}