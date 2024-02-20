// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRequsetQueue extends ChangeNotifier {
  List<DocumentSnapshot> _requestqueue = [];

  List<DocumentSnapshot> get requests => _requestqueue;

  void updateRequests(List<DocumentSnapshot> newOrders) {
    _requestqueue = newOrders;
    notifyListeners();
  }

  Future<void> rejectRequest(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('new_requestform').doc(documentId).delete();
      // Remove the rejected request from the local list
      _requestqueue.removeWhere((request) => request.id == documentId);
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error rejecting request: $error');
      }
    }
  }
}
