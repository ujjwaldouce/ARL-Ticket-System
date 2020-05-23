import 'package:arlticketsystem/pages/ticket_details.page.dart';
import 'package:arlticketsystem/utils/rest_ds.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PayTicketsPage extends StatefulWidget {
  @override
  _PayTicketsPageState createState() => new _PayTicketsPageState();
}

class _PayTicketsPageState extends State<PayTicketsPage> {
  //  _formKey and _autoValidate
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String _searchTicket;

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: Form(
            autovalidate: true,
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 45.0),
                  TextFormField(
                    obscureText: false,
                    style: style,
                    onSaved: (String val) {
                      _searchTicket = val;
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter ticket number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: 'Enter Ticket Number',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32.0))),
                  ),
                  SizedBox(
                    height: 35.0,
                  ),
                  Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(30.0),
                    color: Color(0xff01A0C7),
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      onPressed: _validateInputs,
                      child: Text("Search",
                          textAlign: TextAlign.center,
                          style: style.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _validateInputs() {
    if (_formKey.currentState.validate()) {
      // If all data are correct then save data to out variables
      _formKey.currentState.save();
      debugPrint('data:' + _searchTicket);

      //Map<String, dynamic> body = {'name': _email, 'pass': _password};
      String TICKET_DETAILS_URL = API.TICKET_DETAILS.replaceAll('%', _searchTicket);
      debugPrint("response ${TICKET_DETAILS_URL}");
      Future<void> ticketDetails() async {
        final Response response = await Dio().get(TICKET_DETAILS_URL);
        List tickets = response.data;
        if(tickets.isEmpty) {
          debugPrint("isEmpty");
          Fluttertoast.showToast(
              msg: 'Invalid Ticket Number',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TicketDetailsPage(tickets: tickets)),
          );
        }
      };
      ticketDetails();
    } else {
      // If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
  }
}
