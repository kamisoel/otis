import 'dart:async';

import 'package:flutter/material.dart';

class AppLocalizations {

  final Locale locale;
  AppLocalizations(this.locale);

  static get delegate => AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'patient': 'patient',
      'new_patient': 'New patient',
      'no_patients': 'No patients found!',
      'userlist_title': 'Patient List',
      'logout_question': 'Do you really want to logout?',
      'logout_label': 'Logout',
      'login': 'Login',
      'username': 'User',
      'password': 'Password',
      'no_treatments': 'No treatments found!',
      'treatment_deleted': 'treatment deleted',
      'create_treatment': 'create treatment',
      'treatment': 'Treatment',
      'treatment_info': 'Anzahl Wiederholungen:\nAnzahl Sätze:\nAusführungsgeschwindigkeit:\nPausendauer:',
      'no_video': "No video found!",
      'no_report': "No report found!.",
      'show_pdf': "Show PDF",
      'no_pdf': "No Report found!",
      'edit': 'Edit',
      'delete': 'Delete',
      'undo': 'Undo',
      'date': 'Date',
      'information': "Information",
      'video': "Video(s)",
      'name': 'Name',
      'family_name': 'Family name',
      'email' : 'E-mail Address',
      'title': 'Title',
      'add' : 'add',
      'exercise' : 'exercise',
      'gait_analysis': 'gait analysis',
      'report': 'Report',
      'error': 'Something went wrong :(',
      'email_error': 'This E-mail Address is not valid!',
      'pw_error': 'Passwords have to be atleast 8 characters long!',
      'field_empty_error': 'This field cannot be empty!',
    },
    'de': {
      'patient': 'Patient',
      'new_patient': 'Neuer Patient',
      'no_patients': 'Keine Patienten gefunden!',
      'userlist_title': 'Patientenliste',
      'login': 'Einloggen',
      'username': 'Benutzer',
      'password': 'Passwort',
      'logout_question': 'Wollen Sie sich wirklich ausloggen?',
      'logout_label': 'Ausloggen',
      'no_treatments': 'Keine Einträge gefunden!',
      'treatment_deleted': 'Behandlung gelöscht',
      'create_treatment': 'Behandlung erstellen',
      'treatment': 'Behandlung',
      'treatment_info': 'Anzahl Wiederholungen:\nAnzahl Sätze:\nAusführungsgeschwindigkeit:\nPausendauer:',
      'no_video': "Kein Video gefunden.",
      'no_report': "Kein Bericht gefunden.",
      'no_pdf': "Kein Report vorhanden!",
      'show_pdf': "Zeige PDF",
      'edit': 'Bearbeiten',
      'delete': 'Löschen',
      'undo': 'Rückgängig',
      'date': 'Datum',
      'information': "Informationen",
      'video': "Video(s)",
      'name': 'Vorname',
      'family_name': 'Nachname',
      'email' : 'E-mail Addresse',
      'title': 'Titel',
      'add' : 'Hinzufügen',
      'exercise' : 'Eigenübung',
      'gait_analysis': 'Laufanalyse',
      'report': 'Bericht',
      'error': 'Da ist was schief gelaufen :(',
      'email_error': 'Die eingegebene E-mail Addresse ist ungültig!',
      'pw_error': 'Das Passwort muss min 8 Zeichen lang sein.',
      'field_empty_error': 'Das Feld darf nicht leer sein!',

    },
  };

  String get patient => _localizedValues[locale.languageCode]['patient'];
  String get newPatient => _localizedValues[locale.languageCode]['new_patient'];
  String get noPatients => _localizedValues[locale.languageCode]['no_patients'];
  String get userlistTitle => _localizedValues[locale.languageCode]['userlist_title'];
  String get login => _localizedValues[locale.languageCode]['login'];
  String get username => _localizedValues[locale.languageCode]['username'];
  String get password => _localizedValues[locale.languageCode]['password'];
  String get logoutLabel => _localizedValues[locale.languageCode]['logout_label'];
  String get logoutQuestion => _localizedValues[locale.languageCode]['logout_question'];
  String get treatment => _localizedValues[locale.languageCode]['treatment'];
  String get noTreatments => _localizedValues[locale.languageCode]['no_treatments'];
  String get treatmentInfo => _localizedValues[locale.languageCode]['treatment_info'];
  String get createTreatment => _localizedValues[locale.languageCode]['create_treatment'];
  String get treatmentDeleted => _localizedValues[locale.languageCode]['treatment_deleted'];
  String get noVideo => _localizedValues[locale.languageCode]['no_video'];
  String get noReport => _localizedValues[locale.languageCode]['no_report'];
  String get noPdf => _localizedValues[locale.languageCode]['no_pdf'];
  String get showPdf => _localizedValues[locale.languageCode]['show_pdf'];
  String get edit => _localizedValues[locale.languageCode]['edit'];
  String get delete => _localizedValues[locale.languageCode]['delete'];
  String get undo => _localizedValues[locale.languageCode]['undo'];
  String get date => _localizedValues[locale.languageCode]['date'];
  String get information => _localizedValues[locale.languageCode]['information'];
  String get video => _localizedValues[locale.languageCode]['video'];
  String get name => _localizedValues[locale.languageCode]['name'];
  String get familyName => _localizedValues[locale.languageCode]['family_name'];
  String get email => _localizedValues[locale.languageCode]['email'];
  String get title => _localizedValues[locale.languageCode]['title'];
  String get add => _localizedValues[locale.languageCode]['add'];
  String get exercise => _localizedValues[locale.languageCode]['exercise'];
  String get gaitAnalysis => _localizedValues[locale.languageCode]['gait_analysis'];
  String get report => _localizedValues[locale.languageCode]['report'];
  String get emailError => _localizedValues[locale.languageCode]['email_error'];
  String get pwError => _localizedValues[locale.languageCode]['pw_error'];
  String get fieldEmptyError => _localizedValues[locale.languageCode]['field_empty_error'];
  String get error => _localizedValues[locale.languageCode]['error'];
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  @override
  Future<AppLocalizations> load(Locale locale) =>
      Future(() => AppLocalizations(locale));

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;

  @override
  bool isSupported(Locale locale) =>
     ['en', 'de'].contains(locale.languageCode);
}