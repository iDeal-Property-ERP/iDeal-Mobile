import 'package:ideal_mobile/presentation/feedback/enum/feedback_category.dart';
import 'package:ideal_mobile/utils/typedef.dart';

mixin FeedbackRepository {
  ResultVoid submitFeedback({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
    required double rating,
    required FeedbackCategory category,
    required String message,
  });
}
