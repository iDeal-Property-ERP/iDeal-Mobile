import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chat_badge_cubit.dart';
import 'package:ideal_mobile/presentation/chat/data/datasources/chat_remote_data_source.dart';
import 'package:ideal_mobile/presentation/chat/data/repositories/listing_chat_repository_impl.dart';
import 'package:ideal_mobile/presentation/chat/domain/repositories/listing_chat_repository.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/delete_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/get_chat_summary.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/get_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/get_conversations.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/get_messages.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/mark_conversation_read.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/open_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/report_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/send_image_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/send_text_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/set_conversation_archived.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/set_conversation_muted.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:ideal_mobile/utils/image_picker_util.dart';

void registerChatDependencies(GetIt sl) {
  if (!sl.isRegistered<ImagePickerUtil>()) {
    sl.registerLazySingleton<ImagePickerUtil>(ImagePickerUtil.new);
  }
  sl
    ..registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(sl<Dio>(), sl<CacheManager>()),
    )
    ..registerLazySingleton<ListingChatRepository>(
      () => ListingChatRepositoryImpl(sl<ChatRemoteDataSource>()),
    )
    ..registerLazySingleton(() => OpenConversation(sl<ListingChatRepository>()))
    ..registerLazySingleton(() => GetConversations(sl<ListingChatRepository>()))
    ..registerLazySingleton(() => GetChatSummary(sl<ListingChatRepository>()))
    ..registerLazySingleton(() => GetConversation(sl<ListingChatRepository>()))
    ..registerLazySingleton(() => GetMessages(sl<ListingChatRepository>()))
    ..registerLazySingleton(() => SendTextMessage(sl<ListingChatRepository>()))
    ..registerLazySingleton(() => SendImageMessage(sl<ListingChatRepository>()))
    ..registerLazySingleton(
      () => MarkConversationRead(sl<ListingChatRepository>()),
    )
    ..registerLazySingleton(
      () => SetConversationArchived(sl<ListingChatRepository>()),
    )
    ..registerLazySingleton(
      () => SetConversationMuted(sl<ListingChatRepository>()),
    )
    ..registerLazySingleton(
      () => ReportConversation(sl<ListingChatRepository>()),
    )
    ..registerLazySingleton(
      () => DeleteConversation(sl<ListingChatRepository>()),
    )
    ..registerLazySingleton<ChatBadgeCubit>(ChatBadgeCubit.new);
}
