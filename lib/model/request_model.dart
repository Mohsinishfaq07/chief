class RequestModel {
  final String itemName;
  final String date;
  final String arrivalTime;
  final String eventTime;
  final String totalPerson;
  final String fare;
  final String ingredients;
  final String clientId;
  final List<Map<String, dynamic>> chefResponses; // Array of maps
  final String acceptedChiefId;

  RequestModel({
    required this.itemName,
    required this.date,
    required this.arrivalTime,
    required this.eventTime,
    required this.totalPerson,
    required this.fare,
    required this.ingredients,
    required this.clientId,
    required this.chefResponses,
    required this.acceptedChiefId,
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
      chefResponses: List<Map<String, dynamic>>.from(
        json['chefResponses'] ?? [], // Parse the array of maps
      ),
      acceptedChiefId: json['acceptedChiefId'],
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
      'chefResponses': chefResponses, // Include the array of maps in JSON
      'acceptedChiefId': acceptedChiefId,
    };
  }
}
