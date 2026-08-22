// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get common_keys => '================ Общие ключи ================';

  @override
  String get add => 'Добавить';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String get next => 'Далее';

  @override
  String get or => 'Или';

  @override
  String get remove => 'Удалить';

  @override
  String get search => 'Поиск';

  @override
  String get opps_something_went_wrong => 'Упс, что-то пошло не так';

  @override
  String get time_date_keys =>
      '================ Ключи времени и даты ================';

  @override
  String daysAgo(int count) {
    return '$count дн. назад';
  }

  @override
  String hoursAgo(int count) {
    return '$count ч. назад';
  }

  @override
  String get justNow => 'Только что';

  @override
  String get lastMonth => 'В прошлом месяце';

  @override
  String get lastYear => 'В прошлом году';

  @override
  String minutesAgo(int count) {
    return '$count мин. назад';
  }

  @override
  String monthsAgo(int count) {
    return '$count мес. назад';
  }

  @override
  String get oneHourAgo => '1 ч. назад';

  @override
  String get oneMinuteAgo => '1 мин. назад';

  @override
  String get today => 'Сегодня';

  @override
  String yearsAgo(int count) {
    return '$count лет назад';
  }

  @override
  String get yesterday => 'Вчера';

  @override
  String get login_keys => '================ Ключи входа ================';

  @override
  String get ask_forgot_password => 'Забыли пароль?';

  @override
  String get check_your_email => 'Проверьте свою электронную почту';

  @override
  String get resend => 'Отправить повторно';

  @override
  String get login_continue => 'Продолжать';

  @override
  String get continue_with_apple => 'Продолжить с Apple';

  @override
  String get continue_with_email => 'Продолжить с электронной почтой';

  @override
  String get continue_with_google => 'Продолжить с Google';

  @override
  String get continue_with_number => 'Продолжить с номером телефона';

  @override
  String get enter_otp => 'Введите одноразовый пароль';

  @override
  String get enter_phone_number => 'Введите номер телефона';

  @override
  String get enter_your_registered_phone_number =>
      'Введите зарегистрированный номер телефона';

  @override
  String get forgot_password => 'Забыли пароль';

  @override
  String get invalid_mobile_number => 'Неверный номер мобильного телефона';

  @override
  String link_send_info(String email) {
    return 'Ссылка для сброса была отправлена на $email. Пожалуйста, проверьте почту и перейдите по ссылке, чтобы сбросить пароль.';
  }

  @override
  String get login => 'Войти';

  @override
  String get log_in => 'Войти';

  @override
  String get sign_in => 'Войти';

  @override
  String get login_terms_notice => 'Продолжая, вы соглашаетесь с';

  @override
  String get sign_in_required_title => 'Получите больше с iDeal';

  @override
  String get sign_in_required_message =>
      'Войдите, чтобы сохранять жильё, безопасно общаться и управлять бронированиями в одном месте.';

  @override
  String get guest_access_sign_in => 'Войти по номеру телефона';

  @override
  String get guest_access_keep_browsing => 'Продолжить просмотр';

  @override
  String get login_with_email => 'Войти по электронной почте';

  @override
  String get send_otp => 'Отправить OTP';

  @override
  String get otp_channel_confirmation => 'Номер правильный?';

  @override
  String get otp_channel_telegram => 'Через Telegram (рекомендуется)';

  @override
  String get otp_channel_sms => 'Через СМС';

  @override
  String get otp_channel_edit => 'Редактировать';

  @override
  String get send_reset_link => 'Отправить ссылку для сброса';

  @override
  String get sent_code_info => 'Мы отправили 6-значный код на';

  @override
  String get welcome_back => 'Добро пожаловать!';

  @override
  String get signup_keys =>
      '================ Ключи регистрации ================';

  @override
  String get already_have_account => 'У вас уже есть аккаунт?';

  @override
  String get back_to_login => 'Вернуться к входу';

  @override
  String get confirm_password => 'Подтвердите пароль';

  @override
  String get confirm_password_hint => 'Введите пароль для подтверждения';

  @override
  String get change_email => 'Изменить адрес электронной почты';

  @override
  String get create_your_password => 'Создайте свой пароль';

  @override
  String get email => 'Электронная почта';

  @override
  String get first_name => 'Имя';

  @override
  String get last_name => 'Фамилия';

  @override
  String get patronymic => 'Отчество';

  @override
  String get nationality => 'Гражданство';

  @override
  String get email_cant_be_empty => 'Электронная почта не может быть пустой';

  @override
  String get email_hint => 'Введите адрес электронной почты';

  @override
  String get email_id => 'Идентификатор электронной почты';

  @override
  String get enter_your_email_id => 'Введите свой адрес электронной почты';

  @override
  String get enter_your_name => 'Введите свое имя';

  @override
  String get entered_wrong_email =>
      'Ввели неправильный адрес электронной почты?';

  @override
  String get error_enter_confirm_password =>
      'Пожалуйста, введите подтверждение пароля';

  @override
  String get error_retrieving_email =>
      'Ошибка при получении вашей электронной почты';

  @override
  String get error_retrieving_phone_number =>
      'Ошибка при получении вашего номера телефона.';

  @override
  String get invalid_email =>
      'Пожалуйста, введите действительный адрес электронной почты';

  @override
  String get lets_get_started => 'Давайте начнем';

  @override
  String get lets_get_started_info =>
      'Введите свой номер телефона, мы вышлем вам код подтверждения';

  @override
  String link_verify_info(String email) {
    return 'Ссылка для подтверждения была отправлена на $email. Нажмите на неё, чтобы подтвердить аккаунт.';
  }

  @override
  String get mobile_number => 'Номер мобильного телефона';

  @override
  String get name => 'Имя';

  @override
  String get name_cannot_be_empty => 'Имя не может быть пустым';

  @override
  String get no_account => 'У вас нет учетной записи?';

  @override
  String get password => 'Пароль';

  @override
  String get password_cant_be_empty => 'Пароль не может быть пустым';

  @override
  String get password_hint => 'Введите пароль';

  @override
  String get password_requirements =>
      'Ваш пароль должен содержать как минимум:';

  @override
  String get password_requirements_length => '8 символов или более';

  @override
  String get password_requirements_letter_number => '1 буква и цифра';

  @override
  String get password_requirements_special_char =>
      '1 специальный символ (пример: # ?! \$ & @)';

  @override
  String get password_strength => 'Надежность пароля:';

  @override
  String get passwords_do_not_match => 'Пароли не совпадают';

  @override
  String get phone_no_verified => 'Номер телефона подтвержден!';

  @override
  String get phone_no_verified_info =>
      'Ваш номер телефона успешно подтвержден. Теперь вы можете заполнить свой профиль.';

  @override
  String get poor => 'Плохо';

  @override
  String get sign_up => 'Зарегистрироваться';

  @override
  String get sign_up_with_apple => 'Зарегистрируйтесь через Apple';

  @override
  String get sign_up_with_email => 'Зарегистрируйтесь по электронной почте';

  @override
  String get sign_up_with_google => 'Зарегистрируйтесь через Google';

  @override
  String get strong => 'Сильный';

  @override
  String get terms_and_conditions => 'Условия и положения';

  @override
  String get user_info_not_retrieved =>
      'Не удалось получить информацию о пользователе.';

  @override
  String get weak => 'Слабый';

  @override
  String get verify => 'Подтвердить';

  @override
  String get verify_email_keys =>
      '================ Ключи подтверждения email ================';

  @override
  String get resend_verification_email =>
      'Повторно отправить письмо с подтверждением';

  @override
  String get verify_your_email => 'Подтвердите свой адрес электронной почты';

  @override
  String get profile_keys => '================ Ключи профиля ================';

  @override
  String get account => 'Счет';

  @override
  String get add_a_profile_picture => 'Добавить изображение профиля';

  @override
  String get personal_details => 'Личные данные';

  @override
  String get profile => 'Профиль';

  @override
  String get help_and_support => 'Помощь и поддержка';

  @override
  String get edit => 'Редактировать';

  @override
  String get rotate => 'Повернуть';

  @override
  String get retry => 'Повторить';

  @override
  String get sign_out => 'Выйти';

  @override
  String get sign_out_confirmation_message => 'Вы уверены, что хотите выйти?';

  @override
  String get skip => 'Пропустить';

  @override
  String get preferences => 'Предпочтения';

  @override
  String get appearance => 'Оформление';

  @override
  String get version => 'Версия';

  @override
  String get activity => 'Активность';

  @override
  String get my_orders => 'Мои заказы';

  @override
  String get done => 'Готово';

  @override
  String get feedback_and_ratings => 'Обратная связь и рейтинги';

  @override
  String get notifications => 'Уведомления';

  @override
  String get delete_account_keys =>
      '================ Ключи удаления аккаунта ================';

  @override
  String get delete => 'Удалить';

  @override
  String get delete_account => 'Удалить аккаунт';

  @override
  String get delete_account_alert_title =>
      'Вы уверены, что хотите удалить аккаунт?';

  @override
  String get delete_account_confirmation_message =>
      'Это действие необратимо. Аккаунт и повторно используемые персональные данные будут удалены. Записи, которые необходимо сохранить для закона, сервиса или споров, будут обезличены. Продолжить?';

  @override
  String get delete_reason_dislike_app =>
      'Мне не нравится быть в этом приложении';

  @override
  String get delete_reason_do_not_need_anymore => 'мне это больше не нужно';

  @override
  String get delete_reason_other => 'Другой';

  @override
  String get delete_reason_product_no_more_relevant =>
      'Товары для меня больше не актуальны';

  @override
  String get delete_reason_title => 'Почему вы удаляете аккаунт?';

  @override
  String get delete_warning_account_info =>
      'Удалите всю информацию вашего аккаунта';

  @override
  String get delete_warning_products_chats =>
      'Сохраненные товары, чаты будут удалены';

  @override
  String get delete_warning_title =>
      'Удаление учетной записи приведет к следующему:';

  @override
  String get please_select_at_least_one_reason =>
      'Пожалуйста, выберите хотя бы одну причину';

  @override
  String get please_specify_your_reason => 'Пожалуйста, укажите причину';

  @override
  String get specify_reason => 'Пожалуйста, укажите причину';

  @override
  String get cancel => 'Отмена';

  @override
  String get account_delete_success_keys =>
      '================ Ключи успешного удаления аккаунта ================';

  @override
  String get account_deleted => 'Аккаунт удален!';

  @override
  String get creating_new_account => 'Создаете новую учетную запись?';

  @override
  String get coupons_keys => '================ Ключи купонов ================';

  @override
  String get apply => 'Применить';

  @override
  String get apply_coupon => 'Применить купон';

  @override
  String get available_coupons => 'Доступные купоны';

  @override
  String coupon_message(int coupon_count) {
    String _temp0 = intl.Intl.pluralLogic(
      coupon_count,
      locale: localeName,
      other: '$coupon_count купона доступны',
      many: '$coupon_count купонов доступно',
      few: '$coupon_count купона доступны',
      one: '$coupon_count купон доступен',
      zero: 'Нет доступных купонов',
    );
    return 'Доступные купоны: $_temp0';
  }

  @override
  String get search_by_name_or_code => 'Поиск по имени или коду';

  @override
  String get home_keys =>
      '================ Ключи главного экрана ================';

  @override
  String get home => 'Главная';

  @override
  String get selected => 'Избранное';

  @override
  String get rating => 'Рейтинг';

  @override
  String get reviews => 'Отзывы';

  @override
  String get see_all => 'Посмотреть все';

  @override
  String get star => 'Звезда';

  @override
  String get top_products => 'Лучшие продукты';

  @override
  String no_result_for(Object searchText) {
    return 'Нет результатов по запросу \"$searchText\"';
  }

  @override
  String get no_search_result_message =>
      'Мы не смогли найти ни одного результата, соответствующего вашему запросу. Попробуйте поискать что-нибудь другое.';

  @override
  String get microphone_permission_permanently_denied =>
      'Разрешение на использование микрофона запрещено навсегда. Пожалуйста, зайдите в настройки и включите его.';

  @override
  String get chat_keys => '================ Ключи чата ================';

  @override
  String get chat => 'Чат';

  @override
  String get you => 'Ты';

  @override
  String get message => 'Сообщение';

  @override
  String messageTooLong(int maxLength) {
    return 'Ваше сообщение слишком длинное (максимум $maxLength символов)';
  }

  @override
  String get message_cannot_be_empty => 'Сообщение не может быть пустым';

  @override
  String get message_description => 'Напишите описание...';

  @override
  String get no_messages_yet => 'Сообщений пока нет';

  @override
  String get failed_to_load_chats => 'Не удалось загрузить чаты';

  @override
  String get send_a_new_message => 'Отправить новое сообщение';

  @override
  String get chats_keys => '================ Ключи чатов ================';

  @override
  String get chats => 'Чаты';

  @override
  String get chats_empty_title => 'Чатов пока нет';

  @override
  String get chats_empty_subtitle =>
      'Напишите нам по поводу объявления, и ваш диалог появится здесь';

  @override
  String get chats_active => 'Активные';

  @override
  String get chats_archived => 'Архив';

  @override
  String get chats_archived_empty_title => 'Нет архивных чатов';

  @override
  String get chats_archived_empty_subtitle =>
      'Архивированные чаты появятся здесь';

  @override
  String get chats_loading_more => 'Загружаем ещё чаты';

  @override
  String get chats_load_error =>
      'Не удалось загрузить чаты. Попробуйте ещё раз.';

  @override
  String get chats_retry => 'Повторить';

  @override
  String get chat_archive => 'Архивировать';

  @override
  String get chat_unarchive => 'Разархивировать';

  @override
  String get chat_mute => 'Отключить уведомления';

  @override
  String get chat_unmute => 'Включить уведомления';

  @override
  String get chat_delete => 'Удалить чат';

  @override
  String get chat_report => 'Пожаловаться';

  @override
  String get chat_delete_title => 'Удалить этот чат?';

  @override
  String get chat_delete_message =>
      'Этот чат будет удален из вашего списка, и вы не сможете открыть его снова.';

  @override
  String get chat_delete_confirm => 'Удалить';

  @override
  String get chat_cancel => 'Отмена';

  @override
  String get chat_conversation_keys =>
      '================ Ключи переписки ================';

  @override
  String get chat_message_hint => 'Сообщение';

  @override
  String get chat_message_too_long =>
      'Сообщения могут содержать не более 1024 символов';

  @override
  String get chat_send_failed => 'Не отправлено. Нажмите, чтобы повторить.';

  @override
  String get chat_retry => 'Повторить';

  @override
  String get chat_photo => 'Фото';

  @override
  String get chat_read_only_blocked =>
      'Вы больше не можете отправлять сообщения в этом чате.';

  @override
  String get chat_listing_unavailable => 'Это объявление больше недоступно.';

  @override
  String get chat_attach_photo => 'Добавить фото';

  @override
  String get chat_attach_camera => 'Камера';

  @override
  String get chat_attach_gallery => 'Галерея';

  @override
  String get chat_image_too_large =>
      'Размер изображения не должен превышать 5 МБ';

  @override
  String get chat_image_unsupported_format =>
      'Неподдерживаемый формат изображения';

  @override
  String get chat_today => 'Сегодня';

  @override
  String get chat_yesterday => 'Вчера';

  @override
  String get chat_report_keys =>
      '================ Ключи жалоб на чат ================';

  @override
  String get chat_report_title => 'Пожаловаться на этот чат';

  @override
  String get chat_report_reason_spam => 'Спам';

  @override
  String get chat_report_reason_abuse => 'Оскорбления';

  @override
  String get chat_report_reason_scam => 'Мошенничество';

  @override
  String get chat_report_reason_other => 'Другое';

  @override
  String get chat_report_note_hint => 'Добавьте подробности (необязательно)';

  @override
  String get chat_report_submit => 'Отправить жалобу';

  @override
  String get chat_report_submitted => 'Жалоба отправлена';

  @override
  String get contact_us_keys =>
      '================ Ключи связи с нами ================';

  @override
  String get attachment => 'Вложения (до 5)';

  @override
  String get alright => 'Хорошо !';

  @override
  String get choose_a_file => 'Выберите файл или перетащите сюда';

  @override
  String get contact_us => 'Связаться с нами';

  @override
  String get submit => 'Отправить';

  @override
  String get contact_us_message =>
      'Давайте свяжемся, если у вас есть какие-либо вопросы. Мы рады помочь вам в любое время.';

  @override
  String get file_cannot_be_empty => 'Пожалуйста, выберите хотя бы один файл';

  @override
  String get file_empty_error =>
      'Выбранный PDF-файл пуст. Пожалуйста, выберите действительный файл.';

  @override
  String get file_too_large_error =>
      'Размер одного или нескольких выбранных файлов превышает ограничение в 5 МБ.';

  @override
  String get pick_file_error =>
      'Что-то пошло не так при выборе файлов. Пожалуйста, попробуйте еще раз.';

  @override
  String get pick_image_error =>
      'Что-то пошло не так при выборе изображений. Пожалуйста, попробуйте еще раз.';

  @override
  String get pick_pdf_error =>
      'Что-то пошло не так при выборе PDF-файлов. Пожалуйста, попробуйте еще раз.';

  @override
  String get response_received =>
      'Мы получили ваш ответ и свяжемся с вами как можно скорее.';

  @override
  String get support => 'Поддержка';

  @override
  String get supported_format =>
      'Поддерживается JPG, PNG, PDF. Максимальный размер файла 10 МБ';

  @override
  String get take_a_photo => 'Сделать фото';

  @override
  String get unsupported_file_format_error =>
      'Выбранный файл не является допустимым PDF-файлом. Пожалуйста, выберите правильный PDF-файл, чтобы продолжить.';

  @override
  String get upload_from_files => 'Загрузить из файлов';

  @override
  String get upload_from_gallery => 'Загрузить из галереи';

  @override
  String get notifications_keys =>
      '================ Ключи уведомлений ================';

  @override
  String get empty_notifications_title => 'Уведомлений пока нет';

  @override
  String get notifications_mark_all_read => 'Отметить все прочитанными';

  @override
  String get notifications_push_enabled => 'Push-уведомления';

  @override
  String get notifications_push_description =>
      'Получайте уведомления об активности в iDeal.';

  @override
  String get notifications_messages => 'Сообщения';

  @override
  String get notifications_payments => 'Платежи';

  @override
  String get notifications_bookings => 'Бронирования';

  @override
  String get notifications_maintenance => 'Обслуживание';

  @override
  String get notifications_leases => 'Аренда';

  @override
  String get notifications_general => 'Общие';

  @override
  String get notifications_permission_denied =>
      'Уведомления отключены в настройках устройства.';

  @override
  String get notifications_open_settings => 'Открыть настройки';

  @override
  String get settings_keys =>
      '================ Ключи настроек ================';

  @override
  String get settings => 'Настройки';

  @override
  String get notification_settings => 'Настройки уведомлений';

  @override
  String get choose_app_theme => 'Выберите тему приложения';

  @override
  String get biometric_authentication => 'Биометрическая аутентификация';

  @override
  String get privacy_policy => 'Политика конфиденциальности';

  @override
  String get saved_cards_keys =>
      '================ Ключи сохранённых карт ================';

  @override
  String get empty_cards_list_message => 'На данный момент карты нет.';

  @override
  String get explore_products => 'Изучите продукты';

  @override
  String get save => 'Сохранить';

  @override
  String get empty_screens_keys =>
      '================ Ключи пустых экранов ================';

  @override
  String get force_update_keys =>
      '================ Ключи обязательного обновления ================';

  @override
  String get could_not_launch_store_link =>
      'Не удалось запустить ссылку на магазин.';

  @override
  String get its_time_to_update => 'Пришло время обновления!';

  @override
  String get skip_update => 'Пропустить обновление';

  @override
  String get update_app => 'Обновить приложение';

  @override
  String get update_now => 'Обновить сейчас';

  @override
  String get update_required_description =>
      'Версия, которую вы используете, устарела. Чтобы продолжить использование, вам необходимо обновить последнюю версию, чтобы получить доступ к новым функциям.';

  @override
  String get under_maintenance_keys =>
      '================ Ключи технических работ ================';

  @override
  String get under_maintenance => 'Приложение находится на обслуживании';

  @override
  String get under_maintenance_message =>
      'Приложение в настоящее время находится на обслуживании. Мы сообщим вам, как только закончим. Повторите попытку позже.';

  @override
  String get no_internet_keys =>
      '================ Ключи отсутствия интернета ================';

  @override
  String get lost_connection => 'Вы потеряли соединение';

  @override
  String get lost_connection_message =>
      'Похоже, у вас пропало подключение к Интернету';

  @override
  String get no_internet_connection =>
      'Пожалуйста, проверьте подключение к Интернету';

  @override
  String get server_error_keys =>
      '================ Ключи ошибки сервера ================';

  @override
  String get server_error => 'Ошибка сервера';

  @override
  String get server_error_description =>
      'На данный момент произошла ошибка сервера, пожалуйста, зайдите позже.';

  @override
  String get server_error_title => 'Ошибка сервера';

  @override
  String get back_to_home => 'Вернуться домой';

  @override
  String get ssl_pinning_keys =>
      '================ Ssl Pinning Keys ================';

  @override
  String get platform_not_supported => 'Платформа не поддерживается';

  @override
  String get secure_connection_failed_message =>
      'Нам не удалось безопасно подключиться к нашему серверу. Повторите попытку позже или проверьте, доступно ли обновление приложения.';

  @override
  String get secure_connection_failed_title =>
      'Безопасное соединение не удалось!';

  @override
  String get try_again => 'Попробуйте еще раз';

  @override
  String get reminder_keys =>
      '================ Ключи напоминаний ================';

  @override
  String get reminder => 'Напоминание';

  @override
  String get reminder_title => 'Заголовок';

  @override
  String get reminder_description => 'Описание (необязательно)';

  @override
  String get reminder_title_hint => 'Введите название напоминания';

  @override
  String get reminder_description_hint => 'Введите описание';

  @override
  String get date_and_time => 'Дата и время';

  @override
  String get schedule_reminder => 'Запланировать напоминание';

  @override
  String get reminder_title_required => 'Пожалуйста, введите название';

  @override
  String get reminder_future_date_required =>
      'Пожалуйста, выберите будущую дату и время';

  @override
  String get reminder_scheduled_successfully =>
      'Напоминание успешно запланировано!';

  @override
  String get reminder_schedule_failed =>
      'Не удалось запланировать напоминание.';

  @override
  String get share_product_subject => 'Продукт на iDeal Mobile';

  @override
  String share_product_message(String url) {
    return 'Я нашёл этот товар на iDeal Mobile и подумал, что он вам понравится.\n\nПосмотрите его здесь: $url';
  }

  @override
  String get app_tour_keys =>
      '================ Ключи тура по приложению ================';

  @override
  String get tour_search_title => 'Поиск продуктов';

  @override
  String get tour_search_description =>
      'Используйте строку поиска, чтобы быстро найти нужные вам продукты. Просто введите то, что вам нужно!';

  @override
  String get tour_nav_title => 'Навигация по приложению';

  @override
  String get tour_nav_description =>
      'Используйте нижнюю навигацию для переключения между разделами «Домой», «Поиск», «Корзина» и «Профиль».';

  @override
  String get got_it => 'Понятно!';

  @override
  String get search_bar_identify => 'search_bar';

  @override
  String get bottom_nav__bar_identify => 'bottom_nav_bar';

  @override
  String get biometric_auth_keys =>
      '================ Ключи биометрической аутентификации ================';

  @override
  String get biometric_auth_desc_for_enrollment =>
      'На вашем устройстве не настроена биометрическая аутентификация. Пожалуйста, включите Touch ID или Face ID на вашем телефоне.';

  @override
  String get go_to_settings => 'Перейти в настройки';

  @override
  String get biometric_auth_reason_access_app =>
      'Пожалуйста, авторизуйтесь, чтобы получить доступ к приложению';

  @override
  String get biometric_auth_not_setup =>
      'На вашем устройстве не настроена биометрическая аутентификация.';

  @override
  String get biometric_setup_enable_instruction =>
      'На вашем устройстве не настроена биометрическая аутентификация. Пожалуйста, включите Touch ID или Face ID (iPhone) или разблокировку по отпечатку пальца/лицу (Android), чтобы продолжить.';

  @override
  String get ok => 'ХОРОШО';

  @override
  String get enable_or_disable => 'Включить/Отключить';

  @override
  String get biometric_auth_description =>
      'Используйте переключатель, чтобы активировать или деактивировать биометрическую проверку.';

  @override
  String get biometric_auth_enabled_success =>
      'Биометрическая аутентификация успешно включена';

  @override
  String get biometric_auth_disabled =>
      'Биометрическая аутентификация отключена';

  @override
  String get auth_failed => 'Аутентификация не удалась';

  @override
  String get biometric_auth_not_available =>
      'Биометрическая аутентификация недоступна на этом устройстве.';

  @override
  String get biometric_auth_too_many_attempts =>
      'Слишком много попыток. Пожалуйста, повторите попытку позже.';

  @override
  String get invoice_keys =>
      '================ Ключи счёта-фактуры ================';

  @override
  String get share_invoice => 'Поделиться';

  @override
  String get download => 'Скачать';

  @override
  String get invoice_saved_success => 'Счет успешно сохранен';

  @override
  String get invoice_generation_failed =>
      'Не удалось создать счет. Пожалуйста, попробуйте еще раз.';

  @override
  String get storage_permission_required =>
      'Для сохранения счета-фактуры требуется разрешение на хранение';

  @override
  String get online_payment_method => 'Онлайн оплата';

  @override
  String get generate_invoice => 'Создать счет';

  @override
  String get invoice => 'СЧЕТ';

  @override
  String get invoice_details => 'Детали счета:';

  @override
  String get invoice_number => 'Номер счета';

  @override
  String get invoice_date => 'Дата счета';

  @override
  String get bill_to => 'Получатель:';

  @override
  String get product => 'Продукт';

  @override
  String get quantity => 'Количество';

  @override
  String get total => 'Общий';

  @override
  String get subtotal => 'Итого';

  @override
  String get payment_method => 'Способ оплаты';

  @override
  String get download_invoice => 'Скачать счет';

  @override
  String get invoice_share_failed =>
      'Не удалось поделиться счетом. Пожалуйста, попробуйте еще раз';

  @override
  String get feedback_keys =>
      '================ Ключи обратной связи ================';

  @override
  String get feedback => 'Обратная связь';

  @override
  String get please_share_your_thoughts =>
      'Пожалуйста, поделитесь своими мыслями перед отправкой.';

  @override
  String get rate_your_experience => 'Оцените свой опыт';

  @override
  String get your_feedback => 'Ваш отзыв';

  @override
  String get feedback_hint => 'Расскажите нам, что вы думаете...';

  @override
  String get submit_feedback => 'Отправить отзыв';

  @override
  String get feedback_submitted_success => 'Спасибо! Ваш отзыв отправлен.';

  @override
  String get please_select_a_rating =>
      'Пожалуйста, выберите рейтинг, чтобы продолжить.';

  @override
  String get feedback_category_label => 'Выберите категорию';

  @override
  String get feedback_category_required =>
      'Пожалуйста, выберите категорию, чтобы продолжить.';

  @override
  String get feedback_category_bug => 'Ошибка';

  @override
  String get feedback_category_suggestion => 'Предположение';

  @override
  String get feedback_category_content => 'Содержание';

  @override
  String get feedback_category_compliment => 'Комплимент';

  @override
  String get feedback_category_other => 'Другой';

  @override
  String get feedback_description =>
      'Поделитесь своим опытом и помогите нам стать лучше. Мы ценим каждое слово, которым вы делитесь с нами.';

  @override
  String get ai_chat_keys => '================ Ключи AI-чата ================';

  @override
  String get ai_assistant => 'ИИ-помощник';

  @override
  String get ai_chat_how_can_i_help => 'Могу я чем-нибудь помочь?';

  @override
  String get ai_chat_ask_me_anything => 'Спроси меня о чём угодно...';

  @override
  String get ai_chat_description =>
      'Спросите меня об объявлениях, аренде или навигации в приложении.';

  @override
  String get ai_chat_error_no_response =>
      'Ответа не получено. Пожалуйста, попробуйте еще раз.';

  @override
  String get ai_chat_error_quota =>
      'AI-помощник временно недоступен из-за высокой загрузки. Пожалуйста, повторите попытку через минуту.';

  @override
  String get ai_chat_error_timeout =>
      'Ответ занял слишком много времени. Пожалуйста, попробуйте еще раз.';

  @override
  String get ai_chat_error_network =>
      'Нет подключения к Интернету. Пожалуйста, проверьте свою сеть и повторите попытку.';

  @override
  String get ai_chat_error_generic =>
      'Что-то пошло не так. Пожалуйста, попробуйте еще раз.';

  @override
  String get listings_keys => '======== LISTINGS KEYS ========';

  @override
  String get listings_per_month => '/мес';

  @override
  String listings_rooms_count(num count) {
    return '$count комн.';
  }

  @override
  String listings_area_sqm(num area) {
    return '$area м²';
  }

  @override
  String listings_floor_only(num floor) {
    return 'Этаж $floor';
  }

  @override
  String listings_floor_of(num floor, num total) {
    return 'Этаж $floor из $total';
  }

  @override
  String get listings_save => 'Сохранить';

  @override
  String get selected_empty_title => 'Пока нет избранных объектов';

  @override
  String get selected_empty_subtitle =>
      'Нажмите на сердце у любого жилья, чтобы сохранить его здесь.';

  @override
  String get selected_error_title => 'Не удалось загрузить избранные объекты';

  @override
  String get selected_load_error =>
      'Не удалось загрузить избранные объекты. Повторите попытку.';

  @override
  String get selected_mutation_error =>
      'Не удалось обновить избранные объекты. Повторите попытку.';

  @override
  String get selected_unknown_error =>
      'Что-то пошло не так с избранными объектами. Повторите попытку.';

  @override
  String get selected_retry => 'Повторить';

  @override
  String get selected_page_out_of_date =>
      'Список избранного изменился. Повторите попытку.';

  @override
  String get selected_loading_more => 'Загружаем ещё избранные объекты';

  @override
  String selected_result_count(num count) {
    return '$count избранных объектов';
  }

  @override
  String get selected_sort => 'Сортировка';

  @override
  String get selected_sort_recent => 'Недавно добавленные';

  @override
  String get selected_sort_price_asc => 'Цена: по возрастанию';

  @override
  String get selected_sort_price_desc => 'Цена: по убыванию';

  @override
  String get selected_no_matches_title =>
      'Нет избранных объектов по этим условиям';

  @override
  String get selected_no_matches_subtitle =>
      'Попробуйте расширить поиск или сбросить фильтры.';

  @override
  String get selected_clear_filters => 'Сбросить фильтры';

  @override
  String get selected_removed => 'Удалено из избранного';

  @override
  String get selected_undo => 'Отменить';

  @override
  String get listings_verified => 'Проверено';

  @override
  String get listings_tariff_standard => 'Стандарт';

  @override
  String get listings_tariff_comfort => 'Комфорт';

  @override
  String get listings_tariff_premium => 'Премиум';

  @override
  String get listings_furnishing_furnished => 'С мебелью';

  @override
  String get listings_furnishing_semi_furnished => 'Частично';

  @override
  String get listings_furnishing_unfurnished => 'Без мебели';

  @override
  String get listings_all_filters => 'Все фильтры';

  @override
  String get listings_apply => 'Применить';

  @override
  String get listings_clear_all => 'Сбросить всё';

  @override
  String get listings_clear_filters => 'Сбросить фильтры';

  @override
  String get listings_filter_district => 'Район';

  @override
  String get listings_filter_property_type => 'Тип жилья';

  @override
  String get listings_filter_price => 'Диапазон цен';

  @override
  String get listings_filter_rooms => 'Комнаты';

  @override
  String get listings_filter_furnishing => 'Мебель';

  @override
  String get listings_filter_tariff => 'Тариф';

  @override
  String get listings_range_min => 'Мин';

  @override
  String get listings_range_max => 'Макс';

  @override
  String get listings_chip_verified => 'Только проверенные';

  @override
  String get listings_chip_furnished => 'С мебелью';

  @override
  String get listings_chip_comfort => 'Комфорт';

  @override
  String get listings_chip_premium => 'Премиум';

  @override
  String get listings_search_placeholder => 'Поиск аренды';

  @override
  String get home_heading => 'Найдите свой следующий дом';

  @override
  String get home_recommended_heading => 'Рекомендуем для вас';

  @override
  String get home_recent_search_heading => 'На основе недавних поисков';

  @override
  String home_recent_search_context(String query) {
    return 'На основе запроса «$query» и ваших фильтров';
  }

  @override
  String get home_selected_heading => 'Из избранного';

  @override
  String get home_selected_context => 'Похожие на сохраненные вами дома';

  @override
  String get home_highly_rated_heading => 'Дома с высоким рейтингом';

  @override
  String get home_search_sheet_title => 'Поиск жилья';

  @override
  String get home_search_sheet_placeholder => 'Например, Юнусабад';

  @override
  String get home_search_sheet_field_label => 'Район, адрес или ориентир';

  @override
  String get home_search_sheet_example_recent => 'Примеры недавних поисков';

  @override
  String get home_search_sheet_action => 'Показать подходящие дома';

  @override
  String get home_tariff_sheet_subtitle =>
      'Выберите уровень сервиса, подходящий для вашего поиска.';

  @override
  String get home_tariff_sheet_clear_hint =>
      'Нажмите на выбранный тариф еще раз, чтобы сбросить его.';

  @override
  String get home_feed_status_loading => 'Загрузка жилья с высоким рейтингом';

  @override
  String get home_quick_filter_district => 'Район';

  @override
  String get home_quick_filter_rooms => 'Комнаты';

  @override
  String get home_quick_filter_price => 'Цена';

  @override
  String get home_quick_filter_tariff => 'Тариф';

  @override
  String get recent_searches => 'Недавние поиски';

  @override
  String get listings_view_map => 'Карта';

  @override
  String get listing_map_search_hint => 'Поиск жилья';

  @override
  String get listing_map_full_filters => 'Все фильтры';

  @override
  String get listing_map_search_this_area => 'Искать в этой области';

  @override
  String get listing_map_list => 'Список';

  @override
  String get listing_map_zoom_in =>
      'Приблизьте карту, чтобы увидеть все объекты';

  @override
  String get listing_map_no_results => 'В этой области нет объектов';

  @override
  String get listing_map_loading => 'Загрузка объектов';

  @override
  String get listing_map_full_info => 'Подробнее';

  @override
  String get listing_map_call => 'Позвонить';

  @override
  String get listing_map_call_failed =>
      'Не удалось начать звонок. Проверьте настройки телефона и повторите.';

  @override
  String get listing_map_error_title => 'Не удалось загрузить эту область';

  @override
  String get listing_map_retry => 'Повторить';

  @override
  String get listing_map_near_me => 'Рядом со мной';

  @override
  String get listing_map_location_unavailable =>
      'Не удалось определить ваше местоположение';

  @override
  String listings_result_count(num count) {
    return '$count проверенных объектов';
  }

  @override
  String get listings_empty_title => 'Нет объектов по этим фильтрам';

  @override
  String get listings_empty_subtitle =>
      'Попробуйте расширить поиск или сбросить фильтры.';

  @override
  String get listings_error_title => 'Не удалось загрузить';

  @override
  String get listings_error_subtitle => 'Проверьте соединение и повторите.';

  @override
  String get listings_retry => 'Повторить';

  @override
  String get listings_showing_saved =>
      'Показаны сохраненные объявления. Потяните, чтобы повторить.';

  @override
  String get listings_anywhere => 'Везде';

  @override
  String get listings_any => 'Любой';

  @override
  String get listing_detail_keys => '======== LISTING DETAIL KEYS ========';

  @override
  String listing_detail_reviews_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отзыва',
      many: '$count отзывов',
      few: '$count отзыва',
      one: '1 отзыв',
      zero: 'Нет отзывов',
    );
    return '$_temp0';
  }

  @override
  String get listing_detail_verified => 'Проверено';

  @override
  String get listing_detail_trust_heading =>
      'Проверено iDeal и подкреплено договором';

  @override
  String get listing_detail_about => 'Об этом объекте';

  @override
  String get listing_detail_amenities => 'Что есть в этом жилье';

  @override
  String get listing_detail_neighborhood => 'Район';

  @override
  String get listing_detail_location => 'Расположение';

  @override
  String get listing_detail_map_open => 'Открыть карту';

  @override
  String get listing_detail_map_unavailable => 'Карта недоступна';

  @override
  String get listing_detail_read_more => 'Читать далее';

  @override
  String get listing_detail_show_less => 'Свернуть';

  @override
  String get listing_detail_message => 'Написать';

  @override
  String get listing_detail_message_unavailable =>
      'Обмен сообщениями для этого объявления недоступен';

  @override
  String get listing_detail_call => 'Позвонить';

  @override
  String get listing_detail_share => 'Поделиться';

  @override
  String listing_detail_photo_counter(int current, int total) {
    return '$current / $total';
  }

  @override
  String listing_detail_more_photos(int count) {
    return '+$count';
  }

  @override
  String get listing_detail_no_obligation => 'Без обязательства арендовать';

  @override
  String listing_detail_deposit(String amount) {
    return 'Депозит: $amount';
  }

  @override
  String listing_detail_minimum_stay(int count) {
    return 'Минимальный срок: $count мес.';
  }

  @override
  String get listing_detail_error_title => 'Не удалось загрузить объект';

  @override
  String get listing_detail_error_subtitle =>
      'Проверьте соединение и повторите попытку.';

  @override
  String get listing_detail_not_found => 'Этот объект больше недоступен.';

  @override
  String get listing_detail_retry => 'Повторить';

  @override
  String get empty_views_keys =>
      '================ Ключи пустых представлений ================';

  @override
  String get empty_views => 'Пустые представления';

  @override
  String get empty_states => 'Пустые состояния';

  @override
  String get error_states => 'Состояния ошибок';

  @override
  String get utilities => 'Утилиты';

  @override
  String get ai_chat_suggestion_listings => 'Найти квартиру';

  @override
  String get ai_chat_suggestion_renting => 'Как работает аренда?';

  @override
  String get ai_chat_suggestion_support => 'Связаться с поддержкой';

  @override
  String get booking_keys => '======== КЛЮЧИ БРОНИРОВАНИЯ ========';

  @override
  String get booking_book_and_pay => 'Забронировать и оплатить';

  @override
  String get booking_title => 'Забронировать жильё';

  @override
  String get booking_status_title => 'Статус бронирования';

  @override
  String get booking_status_requested => 'Запрошено';

  @override
  String get booking_status_approved => 'Одобрено';

  @override
  String get booking_status_rejected => 'Отклонено';

  @override
  String get booking_status_cancelled => 'Отменено';

  @override
  String get booking_status_payment_pending => 'Ожидает оплаты';

  @override
  String get booking_status_confirmed => 'Подтверждено';

  @override
  String get booking_status_payment_failed => 'Платёж не прошёл';

  @override
  String get booking_status_payment_expired => 'Срок оплаты истёк';

  @override
  String get booking_status_reconciliation_required => 'На проверке';

  @override
  String get no_bookings_yet => 'У вас пока нет бронирований';

  @override
  String get booking_choose_dates => 'Выберите даты проживания';

  @override
  String get booking_dates_inclusive =>
      'Даты заезда и выезда включены в период.';

  @override
  String get booking_select_dates => 'Выбрать даты';

  @override
  String get booking_choose_start_date => 'Выберите дату начала';

  @override
  String get booking_choose_end_date => 'Выберите дату окончания';

  @override
  String booking_months(int count) {
    return '$count мес.';
  }

  @override
  String get booking_range_unavailable =>
      'Этот период недоступен. Выберите другие даты.';

  @override
  String get booking_get_quote => 'Рассчитать стоимость';

  @override
  String get booking_price_summary => 'Расчёт стоимости';

  @override
  String get booking_deposit => 'Депозит';

  @override
  String get booking_rent => 'Аренда';

  @override
  String get booking_total_due_now => 'К оплате сейчас';

  @override
  String get booking_pay_full_stay => 'Оплатить аренду за весь период';

  @override
  String get booking_pay_full_stay_note =>
      'По умолчанию выключено. Иначе сейчас оплачивается только первый период аренды.';

  @override
  String get booking_payment_method => 'Способ оплаты';

  @override
  String get booking_continue_to_payment => 'Перейти к безопасной оплате';

  @override
  String get booking_preparing_checkout => 'Подготавливаем оплату…';

  @override
  String get booking_hosted_payment_note =>
      'Оплата безопасно откроется в браузере. Вернитесь сюда, чтобы проверить подтверждённый результат.';

  @override
  String get booking_checkout_launch_failed =>
      'Не удалось открыть безопасную страницу оплаты.';

  @override
  String get booking_check_status => 'Проверить статус оплаты';

  @override
  String get booking_pending_title => 'Проверяем оплату';

  @override
  String get booking_pending_message =>
      'Провайдер ещё обрабатывает платёж. Мы подтвердим его только после проверки сервером.';

  @override
  String get booking_confirmed_title => 'Бронирование подтверждено';

  @override
  String get booking_confirmed_message =>
      'Даты закреплены за вами. Договор готов к следующему этапу подписания.';

  @override
  String get booking_failed_title => 'Оплата не прошла';

  @override
  String get booking_failed_message =>
      'Жильё не забронировано. Вернитесь и начните новую оплату.';

  @override
  String get booking_expired_title => 'Время оплаты истекло';

  @override
  String get booking_expired_message =>
      'Временная бронь снята. Выберите даты снова.';

  @override
  String get booking_review_title => 'Платёж требует проверки';

  @override
  String get booking_review_message =>
      'Финансовая команда должна проверить платёж. Не платите повторно до связи с поддержкой.';

  @override
  String get booking_unavailable => 'Онлайн-бронирование недоступно';

  @override
  String get booking_return_unverified =>
      'Не удалось сопоставить ссылку с активной оплатой. Сама ссылка не подтверждает платёж.';

  @override
  String get booking_back_home => 'На главную';
}
