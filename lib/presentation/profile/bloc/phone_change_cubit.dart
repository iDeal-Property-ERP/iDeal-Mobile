import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/confirm_phone_change.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/get_phone_change_otp_methods.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/request_phone_change_otp.dart';

enum PhoneChangeStep { number, channel, code }

class PhoneChangeState extends Equatable {
  const PhoneChangeState({
    this.step = PhoneChangeStep.number,
    this.phone,
    this.channels = const [],
    this.channel,
    this.resendAfter = 0,
    this.isLoading = false,
    this.isConfirming = false,
    this.noChannelsAvailable = false,
    this.errorMessage,
    this.updatedProfile,
  });

  final PhoneChangeStep step;
  final String? phone;
  final List<String> channels;
  final String? channel;
  final int resendAfter;
  final bool isLoading;
  final bool isConfirming;
  final bool noChannelsAvailable;
  final String? errorMessage;
  final MobileUserProfile? updatedProfile;

  PhoneChangeState copyWith({
    PhoneChangeStep? step,
    String? phone,
    List<String>? channels,
    String? channel,
    int? resendAfter,
    bool? isLoading,
    bool? isConfirming,
    bool? noChannelsAvailable,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PhoneChangeState(
      step: step ?? this.step,
      phone: phone ?? this.phone,
      channels: channels ?? this.channels,
      channel: channel ?? this.channel,
      resendAfter: resendAfter ?? this.resendAfter,
      isLoading: isLoading ?? this.isLoading,
      isConfirming: isConfirming ?? this.isConfirming,
      noChannelsAvailable: noChannelsAvailable ?? this.noChannelsAvailable,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      updatedProfile: updatedProfile,
    );
  }

  @override
  List<Object?> get props => [
    step,
    phone,
    channels,
    channel,
    resendAfter,
    isLoading,
    isConfirming,
    noChannelsAvailable,
    errorMessage,
    updatedProfile,
  ];
}

class PhoneChangeCubit extends Cubit<PhoneChangeState> {
  PhoneChangeCubit({
    GetPhoneChangeOtpMethods? getOtpMethods,
    RequestPhoneChangeOtp? requestOtp,
    ConfirmPhoneChange? confirmPhoneChange,
  }) : _getOtpMethodsOverride = getOtpMethods,
       _requestOtpOverride = requestOtp,
       _confirmPhoneChangeOverride = confirmPhoneChange,
       super(const PhoneChangeState());

  final GetPhoneChangeOtpMethods? _getOtpMethodsOverride;
  final RequestPhoneChangeOtp? _requestOtpOverride;
  final ConfirmPhoneChange? _confirmPhoneChangeOverride;

  GetPhoneChangeOtpMethods get _getOtpMethods =>
      _getOtpMethodsOverride ?? sl<GetPhoneChangeOtpMethods>();
  RequestPhoneChangeOtp get _requestOtp =>
      _requestOtpOverride ?? sl<RequestPhoneChangeOtp>();
  ConfirmPhoneChange get _confirmPhoneChange =>
      _confirmPhoneChangeOverride ?? sl<ConfirmPhoneChange>();

  Future<void> start(String phone) async {
    emit(
      state.copyWith(
        isLoading: true,
        noChannelsAvailable: false,
        clearError: true,
      ),
    );
    final methods = await _getOtpMethods();
    methods.fold((failure) => _emitMethodsFailure(failure), (channels) {
      if (channels.isEmpty) {
        emit(state.copyWith(isLoading: false, noChannelsAvailable: true));
      } else if (channels.length == 1) {
        requestOtp(phone, channels.single);
      } else {
        emit(
          state.copyWith(
            step: PhoneChangeStep.channel,
            phone: phone,
            channels: channels,
            isLoading: false,
            clearError: true,
          ),
        );
      }
    });
  }

  Future<void> requestOtp(String phone, String channel) async {
    emit(
      state.copyWith(
        phone: phone,
        channel: channel,
        isLoading: true,
        noChannelsAvailable: false,
        clearError: true,
      ),
    );
    final result = await _requestOtp(
      RequestPhoneChangeOtpParams(phone: phone, channel: channel),
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (challenge) => emit(
        state.copyWith(
          step: PhoneChangeStep.code,
          channel: challenge.channel,
          resendAfter: challenge.resendAfter,
          isLoading: false,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> confirm(String code) async {
    final phone = state.phone;
    if (phone == null || code.length != 6 || state.isConfirming) return;

    emit(state.copyWith(isConfirming: true, clearError: true));
    final result = await _confirmPhoneChange(
      ConfirmPhoneChangeParams(phone: phone, code: code),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isConfirming: false, errorMessage: failure.message),
      ),
      (profile) => emit(
        PhoneChangeState(
          step: PhoneChangeStep.code,
          phone: phone,
          channel: state.channel,
          resendAfter: state.resendAfter,
          updatedProfile: profile,
        ),
      ),
    );
  }

  void editNumber() => emit(const PhoneChangeState());

  void _emitMethodsFailure(Failure failure) {
    emit(state.copyWith(isLoading: false, errorMessage: failure.message));
  }
}
