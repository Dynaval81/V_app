// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login_title => 'Sign in';

  @override
  String get login_subtitle => 'Sign in to your account';

  @override
  String get login_method_email => 'Email';

  @override
  String get login_method_vtalk_id => 'V-Talk ID';

  @override
  String get login_method_nickname => 'Nickname';

  @override
  String get login_label => 'Login';

  @override
  String get login_hint_email => 'Enter your email';

  @override
  String get login_hint_vtalk_id => 'Enter your V-Talk ID';

  @override
  String get login_hint_nickname => 'Enter your nickname';

  @override
  String get login_primary_button => 'Let\'s Start';

  @override
  String get login_divider_or => 'or';

  @override
  String get login_google => 'Sign in with Google';

  @override
  String get login_apple => 'Sign in with Apple';

  @override
  String get login_no_account => 'Don\'t have an account? ';

  @override
  String get login_register => 'Sign Up';

  @override
  String get login_password_label => 'Password';

  @override
  String get login_password_hint => 'Enter your password';

  @override
  String get login_button_submit => 'Sign in';

  @override
  String get login_forgot_password => 'Forgot password?';

  @override
  String get login_change_identifier => 'Change';

  @override
  String get login_error_empty => 'Please enter your email, VT-ID or nickname';

  @override
  String get login_error_empty_password => 'Please enter your password';

  @override
  String get login_error_network => 'Network error';
}
