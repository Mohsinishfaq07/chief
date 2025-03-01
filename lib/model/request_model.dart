class RequestModel {
  final String itemName;
  final String date;
  final String arrivalTime;
  final String eventTime;
  final String totalPerson;
  final String fare;
  final String ingredients;
  final String clientId;
  final String acceptedChiefId;
  final List<String> declinedChiefIds;
  final List<String> acceptedChiefIds;

  RequestModel({
    required this.itemName,
    required this.date,
    required this.arrivalTime,
    required this.eventTime,
    required this.totalPerson,
    required this.fare,
    required this.ingredients,
    required this.clientId,
    required this.acceptedChiefId,
    required this.declinedChiefIds,
    required this.acceptedChiefIds,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      itemName: json['itemName'],
      date: json['date'],
      arrivalTime: json['arrivalTime'],
      eventTime: json['eventTime'],
      totalPerson: json['totalPerson'],
      fare: json['fare'],
      ingredients: json['ingredients'],
      clientId: json['clientId'],
      acceptedChiefId: json['acceptedChiefId'],
      declinedChiefIds: List<String>.from(json['declinedChiefIds']),
      acceptedChiefIds: List<String>.from(json['acceptedChiefIds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'date': date,
      'arrivalTime': arrivalTime,
      'eventTime': eventTime,
      'totalPerson': totalPerson,
      'fare': fare,
      'ingredients': ingredients,
      'clientId': clientId,
      'acceptedChiefId': acceptedChiefId,
      'declinedChiefIds': declinedChiefIds,
      'acceptedChiefIds': acceptedChiefIds,
    };
  }
}
