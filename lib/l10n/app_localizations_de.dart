// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get login_title => 'Anmelden';

  @override
  String get login_subtitle => 'Melde dich bei deinem Konto an';

  @override
  String get login_method_email => 'E-Mail';

  @override
  String get login_method_vtalk_id => 'V-Talk ID';

  @override
  String get login_method_nickname => 'Spitzname';

  @override
  String get login_label => 'Login';

  @override
  String get login_hint_email => 'E-Mail eingeben';

  @override
  String get login_hint_vtalk_id => 'V-Talk ID eingeben';

  @override
  String get login_hint_nickname => 'Spitznamen eingeben';

  @override
  String get login_primary_button => 'Los geht\'s';

  @override
  String get login_divider_or => 'oder';

  @override
  String get login_google => 'Mit Google anmelden';

  @override
  String get login_apple => 'Mit Apple anmelden';

  @override
  String get login_no_account => 'Kein Konto? ';

  @override
  String get login_register => 'Registrieren';

  @override
  String get login_password_label => 'Passwort';

  @override
  String get login_password_hint => 'Passwort eingeben';

  @override
  String get login_button_submit => 'Anmelden';

  @override
  String get login_forgot_password => 'Passwort vergessen?';

  @override
  String get login_change_identifier => 'Ändern';

  @override
  String get login_error_empty => 'E-Mail, VT-ID oder Nutzername eingeben';

  @override
  String get login_error_empty_password => 'Bitte Passwort eingeben';

  @override
  String get login_error_network => 'Netzwerkfehler';
}
