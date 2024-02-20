// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestData extends ChangeNotifier {
  List<DocumentSnapshot> _requests = [];

  List<DocumentSnapshot> get requests => _requests;

  void updateRequests(List<DocumentSnapshot> newRequests) {
    _requests = newRequests;
    notifyListeners();
  }

  Future<void> rejectRequest(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('request_form').doc(documentId).delete();
      // Remove the rejected request from the local list
      _requests.removeWhere((request) => request.id == documentId);
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error rejecting request: $error');
      }
    }
  }
}
