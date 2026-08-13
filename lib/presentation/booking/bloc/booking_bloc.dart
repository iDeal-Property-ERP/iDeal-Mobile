import 'package:bloc/bloc.dart';
import 'package:ideal_mobile/presentation/booking/bloc/booking_event.dart';
import 'package:ideal_mobile/presentation/booking/bloc/booking_state.dart';
import 'package:ideal_mobile/presentation/booking/data/active_checkout_store.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/presentation/booking/domain/repositories/booking_repository.dart';
import 'package:uuid/uuid.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc({
    required BookingRepository repository,
    required ActiveCheckoutStore activeCheckoutStore,
    Uuid uuid = const Uuid(),
    BookingState initialState = const BookingState(),
  }) : _repository = repository,
       _activeCheckoutStore = activeCheckoutStore,
       _uuid = uuid,
       super(initialState) {
    on<BookingStarted>(_onStarted);
    on<BookingRangeChanged>(_onRangeChanged);
    on<BookingPaymentChoiceChanged>(_onPaymentChoiceChanged);
    on<BookingProviderChanged>(_onProviderChanged);
    on<BookingQuoteRequested>(_onQuoteRequested);
    on<BookingCheckoutRequested>(_onCheckoutRequested);
    on<BookingStatusRequested>(_onStatusRequested);
  }

  final BookingRepository _repository;
  final ActiveCheckoutStore _activeCheckoutStore;
  final Uuid _uuid;

  Future<void> _onStarted(
    BookingStarted event,
    Emitter<BookingState> emit,
  ) async {
    final seed = event.initialOptions;
    final usableSeed = seed != null && seed.listingId == event.listingId;
    emit(
      state.copyWith(
        status: usableSeed
            ? BookingFlowStatus.ready
            : BookingFlowStatus.loading,
        listingId: event.listingId,
        options: usableSeed ? seed : null,
        optionsConfirmed: false,
        provider: usableSeed ? seed.eligibility.providers.firstOrNull : null,
        clearError: true,
      ),
    );
    final result = await _repository.getOptions(event.listingId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: usableSeed
              ? BookingFlowStatus.ready
              : BookingFlowStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (options) => emit(
        state.copyWith(
          status: BookingFlowStatus.ready,
          listingId: event.listingId,
          options: options,
          optionsConfirmed: true,
          provider: options.eligibility.providers.firstOrNull,
          clearError: true,
        ),
      ),
    );
  }

  void _onRangeChanged(BookingRangeChanged event, Emitter<BookingState> emit) {
    emit(
      state.copyWith(
        status: BookingFlowStatus.ready,
        range: event.range,
        clearQuote: true,
        clearError: true,
      ),
    );
  }

  void _onPaymentChoiceChanged(
    BookingPaymentChoiceChanged event,
    Emitter<BookingState> emit,
  ) => emit(state.copyWith(paymentChoice: event.choice));

  void _onProviderChanged(
    BookingProviderChanged event,
    Emitter<BookingState> emit,
  ) => emit(state.copyWith(provider: event.provider));

  Future<void> _onQuoteRequested(
    BookingQuoteRequested event,
    Emitter<BookingState> emit,
  ) async {
    final listingId = state.listingId;
    final range = state.range;
    if (listingId == null || range == null || !state.optionsConfirmed) return;
    emit(state.copyWith(status: BookingFlowStatus.quoting, clearError: true));
    final result = await _repository.createQuote(
      listingId: listingId,
      startDate: range.startDate,
      endDate: range.endDate,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BookingFlowStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (quote) => emit(
        state.copyWith(
          status: BookingFlowStatus.quoted,
          quote: quote,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onCheckoutRequested(
    BookingCheckoutRequested event,
    Emitter<BookingState> emit,
  ) async {
    final quote = state.quote;
    final provider = state.provider;
    if (quote == null || provider == null || !state.optionsConfirmed) return;
    emit(
      state.copyWith(
        status: BookingFlowStatus.creatingCheckout,
        clearError: true,
      ),
    );
    final result = await _repository.createCheckout(
      quoteId: quote.id,
      provider: provider,
      payFullStay: state.paymentChoice == BookingPaymentChoice.fullStay,
      idempotencyKey: _uuid.v4(),
    );
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: BookingFlowStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (checkout) async {
        await _activeCheckoutStore.save(checkout);
        emit(
          state.copyWith(
            status: BookingFlowStatus.checkoutReady,
            checkout: checkout,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onStatusRequested(
    BookingStatusRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(status: BookingFlowStatus.polling, clearError: true));
    final result = await _repository.getBooking(event.bookingId);
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: BookingFlowStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (booking) async {
        final status = switch (booking.status) {
          BookingStatus.confirmed => BookingFlowStatus.confirmed,
          BookingStatus.paymentFailed => BookingFlowStatus.failed,
          BookingStatus.paymentExpired => BookingFlowStatus.expired,
          BookingStatus.reconciliationRequired =>
            BookingFlowStatus.reconciliationRequired,
          _ => BookingFlowStatus.checkoutReady,
        };
        if (status != BookingFlowStatus.checkoutReady) {
          await _activeCheckoutStore.clear();
        }
        emit(state.copyWith(status: status, booking: booking));
      },
    );
  }
}
