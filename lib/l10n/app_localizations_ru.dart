// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get login_title => 'Вход';

  @override
  String get login_subtitle => 'Войдите в свой аккаунт';

  @override
  String get login_method_email => 'Email';

  @override
  String get login_method_vtalk_id => 'V-Talk ID';

  @override
  String get login_method_nickname => 'Никнейм';

  @override
  String get login_label => 'Логин';

  @override
  String get login_hint_email => 'Введите email';

  @override
  String get login_hint_vtalk_id => 'Введите V-Talk ID';

  @override
  String get login_hint_nickname => 'Введите никнейм';

  @override
  String get login_primary_button => 'Поехали';

  @override
  String get login_divider_or => 'или';

  @override
  String get login_google => 'Войти через Google';

  @override
  String get login_apple => 'Войти через Apple';

  @override
  String get login_no_account => 'Нет аккаунта? ';

  @override
  String get login_register => 'Зарегистрироваться';
}
