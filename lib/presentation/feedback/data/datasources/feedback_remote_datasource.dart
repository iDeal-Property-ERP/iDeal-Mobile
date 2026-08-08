import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/feedback/constants/feedback_constants.dart';
import 'package:ideal_mobile/presentation/feedback/data/models/feedback_model.dart';
import 'package:ideal_mobile/services/firestore_service.dart';

mixin FeedbackRemoteDatasource {
  Future<void> submitFeedback(FeedbackModel feedback);
}

class FeedbackRemoteDatasourceImpl with FeedbackRemoteDatasource {
  FeedbackRemoteDatasourceImpl(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<void> submitFeedback(FeedbackModel feedback) async {
    try {
      await _firestoreService.addDocument(
        collection: kFeedbackCollection,
        data: feedback.toMap(),
      );
    } on APIException {
      rethrow;
    } catch (e) {
      throw APIException(message: e.toString(), statusCode: 505);
    }
  }
}
