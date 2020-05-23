class Tickets {
  final String ticket_number;
  final String plate_no;
  final String created;
  final String price;
  final String payment_status;

  Tickets.fromJSON(Map<String, dynamic> jsonMap) :
        ticket_number = jsonMap['title'],
        plate_no = jsonMap['field_plate_no_'],
        created = jsonMap['field_date'],
        price = jsonMap['field_price'],
        payment_status = jsonMap['field_payment_status'];
}