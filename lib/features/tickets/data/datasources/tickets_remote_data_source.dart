import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ticket_model.dart';
import '../../domain/entities/ticket.dart';

abstract class TicketsRemoteDataSource {
  Future<List<TicketModel>> fetchTicketsFromApi();
}

class TicketsRemoteDataSourceImpl implements TicketsRemoteDataSource {
  final FirebaseFirestore firestore;

  TicketsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<TicketModel>> fetchTicketsFromApi() async {
    try {
      // Collection "tickets" f Firestore
      final querySnapshot = await firestore.collection('tickets').get();

      final docs = querySnapshot.docs;

      return docs.map((doc) {
        final data = doc.data();

        // status string -> enum
        final String statusString = (data['status'] as String?) ?? 'open';

        TicketStatus status;
        switch (statusString) {
          case 'inProgress':
            status = TicketStatus.inProgress;
            break;
          case 'resolved':
            status = TicketStatus.resolved;
            break;
          case 'open':
          default:
            status = TicketStatus.open;
        }

        // createdAt: Timestamp -> DateTime
        DateTime createdAt;
        final createdAtField = data['createdAt'];
        if (createdAtField is Timestamp) {
          createdAt = createdAtField.toDate();
        } else {
          createdAt = DateTime.now();
        }

        return TicketModel(
          id: doc.id, // id dyal Firestore
          title: (data['title'] as String?) ?? 'Untitled ticket',
          description: (data['description'] as String?) ?? 'No description',
          status: status,
          createdAt: createdAt,
        );
      }).toList();
    } catch (e) {
      throw Exception('Firestore error while fetching tickets: $e');
    }
  }
}
