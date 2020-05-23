import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../utils/rest_ds.dart';

class TicketsPage extends StatefulWidget {
  @override
  _TicketsPageState createState() => new _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  Map _data = {
    "ticketNumber": '',
    "plateNumber": '',
    "bookingDate": "",
    "ticketStatus": "",
    "isSortActionPerformed": false
  };

  bool isSortActionPerformed = false;
  int _sortColumnIndex = 0;
  bool isSort = true;

  List ticketsList = [];
  Future<List<String>> getTickets() async {
    String _ticketNumber = _data['ticketNumber'];
    String _plateNumber = _data['plateNumber'];
    String _bookingDate = _data['bookingDate'];
    String _ticketStatus = _data['ticketStatus'];
    _ticketStatus = (_ticketStatus == '') ? 'All' : _ticketStatus;

    String TICKETS_URL = API.TICKETS_URL +
        "&title=${_ticketNumber}&field_plate_no__value=${_plateNumber}&field_date_value=${_bookingDate}&field_payment_status_value=${_ticketStatus}";

    bool _isSortActionPerformed = _data['isSortActionPerformed'];
    if (_isSortActionPerformed) {
      if (_sortColumnIndex == 0) {
        TICKETS_URL += '&order=title';
      } else {
        TICKETS_URL += '&order=field_payment_status';
      }

      if (isSort) {
        TICKETS_URL += '&sort=asc';
      } else {
        TICKETS_URL += '&sort=desc';
      }
    }

    debugPrint("TICKETS_URL ${TICKETS_URL}");
    final Response response = await Dio().get(TICKETS_URL);
    //debugPrint("TICKETS_URL1 ${response}");
    ticketsList = response.data;
    //debugPrint("TICKETS_URL2 ${ticketsList}");
    return ticketsList;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text("Tickets"),
      ),
      body: FutureBuilder(
        future: getTickets(),
        builder: (context, AsyncSnapshot snapshot) {
          // here is where we can build UI based on what we have received
          // from getDogs. The below code should be fairly self explanatory,
          // feel free to print(snapshot) in this area and you can take a
          // peek at everything you have access to inside of the snapshot
          switch (snapshot.connectionState) {

            // for all of these cases, just show a spinner
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return Center(child: CircularProgressIndicator());

            // if we're complete
            case ConnectionState.done:
              return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child:
                          // return a ListView.builder, which is basically a fancy
                          // more efficient ListView
                          DataTable(
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: isSort,
                        columns: [
                          DataColumn(
                              label: Text('Ticket Number',
                                  style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 18.0)
                                      .copyWith(fontWeight: FontWeight.bold)),
                              onSort: (columnIndex, sortAscending) {
                                debugPrint("columnIndex ${columnIndex}");
                                debugPrint(
                                    "_sortColumnIndex ${_sortColumnIndex}");
                                debugPrint("isSort ${isSort}");
                                setState(() {
                                  if (columnIndex == _sortColumnIndex) {
                                    if (isSort) {
                                      isSort = false;
                                    } else {
                                      isSort = true;
                                    }
                                  } else {
                                    isSort = false;
                                  }
                                  _data['isSortActionPerformed'] = true;
                                  _sortColumnIndex = 0;
                                });
                              }),
                          DataColumn(
                              label: Text('Status',
                                  style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 18.0)
                                      .copyWith(fontWeight: FontWeight.bold)),
                              onSort: (columnIndex, sortAscending) {
                                debugPrint("columnIndex ${columnIndex}");
                                debugPrint(
                                    "_sortColumnIndex ${_sortColumnIndex}");
                                debugPrint("isSort ${isSort}");
                                setState(() {
                                  if (columnIndex == _sortColumnIndex) {
                                    if (isSort) {
                                      isSort = false;
                                    } else {
                                      isSort = true;
                                    }
                                  } else {
                                    isSort = false;
                                  }
                                  _data['isSortActionPerformed'] = true;
                                  _sortColumnIndex = 1;
                                });
                              }),
                        ],
                        rows: ticketsList
                            .map(
                              (ticketDetail) => DataRow(
                                cells: [
                                  DataCell(
                                    Text(ticketDetail['title'].toString(),
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 18.0,
                                        )),
                                    onTap: () {
                                      print("Tapped " +
                                          ticketDetail['title'].toString());
                                      // do whatever you want
                                      int index =
                                          ticketsList.indexOf(ticketDetail);
                                      /*setState(() {
                                _ticketNumber = "000112";
                              });*/
                                      showFancyCustomDialog(
                                          context, ticketsList[index]);
                                    },
                                  ),
                                  DataCell(
                                    Text(
                                        ticketDetail['field_payment_status']
                                            .toString(),
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 18.0,
                                          color: (ticketDetail[
                                                          'field_payment_status']
                                                      .toString() ==
                                                  'Paid')
                                              ? Colors.green
                                              : (ticketDetail['field_payment_status']
                                                          .toString() ==
                                                      'Unpaid')
                                                  ? Colors.red
                                                  : Colors.orange,
                                        )),
                                    onTap: () {
                                      print("Tapped " +
                                          ticketDetail['title'].toString());
                                      int index =
                                          ticketsList.indexOf(ticketDetail);
                                      showFancyCustomDialog(
                                          context, ticketsList[index]);
                                      //_showDialog(context, state);
                                      // do whatever you want
                                    },
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      )));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              child: new MyDialog(
                onValueChange: _onValueChange,
                initialValue: _data,
              ));
        },
        child: Icon(Icons.search),
      ),
    );
  }

  void _onValueChange(Map data) {
    debugPrint("_onValueChange ${data}");
    //void _onValueChange(String ticketNumber, String plateNumber, String bookingDate, String ticketStatus) {
    setState(() {
      _data = data;
    });
  }

  void showFancyCustomDialog(BuildContext context, Map ticketDetail) {
    debugPrint("sdasdf ${ticketDetail['title'].toString()}");
    Dialog simpleDialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        //height: 400.0,
        //width: 400.0,
        child: Stack(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Ticket Details',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: DataTable(
                      headingRowHeight: 0,
                      columns: [
                        DataColumn(label: Text('')),
                        DataColumn(label: Text('')),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(
                            Text('Ticket Number',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14.0,
                                )),
                          ),
                          DataCell(
                            Text(ticketDetail['title'].toString(),
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14.0,
                                )),
                          ),
                        ]),
                        DataRow(cells: [
                          DataCell(
                            Text('Plate No.',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14.0,
                                )),
                          ),
                          DataCell(
                            Text(ticketDetail['field_plate_no_'].toString(),
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14.0,
                                )),
                          ),
                        ]),
                        DataRow(cells: [
                          DataCell(
                            Text('Created date',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14.0,
                                )),
                          ),
                          DataCell(
                            Text(ticketDetail['field_date'].toString(),
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14.0,
                                )),
                          ),
                        ]),
                        DataRow(cells: [
                          DataCell(
                            Text('Price',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14.0,
                                )),
                          ),
                          DataCell(
                            Text(ticketDetail['field_price'].toString(),
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14.0,
                                )),
                          ),
                        ]),
                        DataRow(cells: [
                          DataCell(
                            Text('Status',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14.0,
                                )),
                          ),
                          DataCell(
                            Text(
                                ticketDetail['field_payment_status'].toString(),
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14.0,
                                  color: (ticketDetail['field_payment_status']
                                              .toString() ==
                                          'Paid')
                                      ? Colors.green
                                      : (ticketDetail['field_payment_status']
                                                  .toString() ==
                                              'Unpaid')
                                          ? Colors.red
                                          : Colors.orange,
                                )),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    radius: 14.0,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.close, color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }
}

class MyDialog extends StatefulWidget {
  const MyDialog({this.onValueChange, this.initialValue});

  final Map initialValue;
  final void Function(Map) onValueChange;

  @override
  State createState() => new MyDialogState();
}

class MyDialogState extends State<MyDialog> {
  String _ticketNumber = '';
  String _plateNumber = '';
  String _bookingDate = '';
  String _ticketStatus = '';

  Future<void> _selectDate(context) async {
    final DateTime d = await showDatePicker(
      //we wait for the dialog to return
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    debugPrint("DateTime ${d}");
    if (d != null) //if the user has selected a date
      setState(() {
        // we format the selected date and assign it to the state variable
        _bookingDate = new DateFormat.yMd("en_US").format(d);
        debugPrint("_bookingDate ${_bookingDate}");
      });
  }

  @override
  void initState() {
    super.initState();
    Map data = widget.initialValue;
    debugPrint("data ${data}");
    _ticketNumber = data["ticketNumber"];
    _plateNumber = data["plateNumber"];
    _bookingDate = data["bookingDate"];
    _ticketStatus = data["ticketStatus"];
  }

  Widget build(BuildContext context) {
    debugPrint("exe");
    return new SimpleDialog(
      //title: new Text("Search Tickets"),
      children: <Widget>[
        Align(
          // These values are based on trial & error method
          alignment: Alignment(1.0, 1.0),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              transform: Matrix4.translationValues(0.0, -10.0, 0.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.close,
                color: Colors.red,
              ),
            ),
          ),
        ),
        new Container(
          padding:
              const EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 0),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                // These values are based on trial & error method
                alignment: Alignment(0, 0),
                child: InkWell(
                  child: Container(
                    transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                    child: Text('Search Tickets',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 20.0,
                        )),
                  ),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(5.0),
                child: new TextFormField(
                  decoration: new InputDecoration(
                    hintText: 'Ticket Number',
                  ),
                  initialValue: _ticketNumber,
                  onChanged: (String val) {
                    setState(() {
                      _ticketNumber = val;
                    });
                  },
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(5.0),
                child: new TextFormField(
                    decoration: new InputDecoration(
                      hintText: 'Plate No.',
                    ),
                    initialValue: _plateNumber,
                    onChanged: (String val) {
                      setState(() {
                        _plateNumber = val;
                      });
                    }),
              ),
              new Padding(
                padding: const EdgeInsets.all(5.0),
                child: new TextFormField(
                  readOnly: true,
                  decoration: new InputDecoration(
                    hintText: (_bookingDate == '')
                        ? 'Select Booking Date'
                        : _bookingDate,
                  ),
                  onTap: () {
                    _selectDate(context);
                  },
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(5.0),
                child: new DropdownButton(
                  items: <String>['Paid', 'Unpaid', 'Canceled']
                      .map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  hint: _ticketStatus == ''
                      ? Text('Ticket Status')
                      : Text(
                          _ticketStatus,
                        ),
                  //value: _ticketStatus,
                  onChanged: (newValue) {
                    setState(() {
                      _ticketStatus = newValue;
                    });
                  },
                ),
              ),
              new Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ListTile(
                    //contentPadding: EdgeInsets.all(5),//change for side padding
                    title: Row(
                      children: <Widget>[
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: RaisedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Map filterOptions = {};
                                    filterOptions['ticketNumber'] = '';
                                    filterOptions['plateNumber'] = '';
                                    filterOptions['bookingDate'] = '';
                                    filterOptions['ticketStatus'] = '';
                                    filterOptions['isSortActionPerformed'] =
                                        false;
                                    debugPrint(
                                        "filterOptions ${filterOptions}");
                                    widget.onValueChange(filterOptions);
                                  },
                                  child: Text("Clear"),
                                  color: Colors.red,
                                  textColor: Colors.white,
                                ))),
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: RaisedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Map filterOptions = {};
                                    filterOptions['ticketNumber'] =
                                        _ticketNumber;
                                    filterOptions['plateNumber'] = _plateNumber;
                                    filterOptions['bookingDate'] = _bookingDate;
                                    filterOptions['ticketStatus'] =
                                        _ticketStatus;
                                    filterOptions['isSortActionPerformed'] =
                                        false;
                                    debugPrint(
                                        "filterOptions ${filterOptions}");
                                    widget.onValueChange(filterOptions);
                                  },
                                  child: Text("Filter"),
                                  color: Colors.blue,
                                  textColor: Colors.white,
                                ))),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
