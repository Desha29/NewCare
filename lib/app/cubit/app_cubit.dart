import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:convert';

import 'package:crypt/crypt.dart';

import '../../core/storage/string_store.dart';
import '../navigation/app_page.dart';

class AppState {
  AppState({
    this.page = AppPage.activeShift,
    this.locale = const Locale('ar'),
    this.managerUnlocked = false,
    this.staffId = 'n1',
    this.caseId,
    this.messageKey,
    this.range,
    this.returnPage,
    this.navigationLabels = const {},
    this.customPassword = false,
  });
  final AppPage page;
  final Locale locale;
  final bool managerUnlocked;
  final String staffId;
  final String? caseId, messageKey;
  final DateTimeRange? range;
  final AppPage? returnPage;
  final Map<String, String> navigationLabels;
  final bool customPassword;
  AppState copyWith({
    AppPage? page,
    Locale? locale,
    bool? managerUnlocked,
    String? staffId,
    String? caseId,
    String? messageKey,
    DateTimeRange? range,
    AppPage? returnPage,
    Map<String, String>? navigationLabels,
    bool? customPassword,
  }) => AppState(
    page: page ?? this.page,
    locale: locale ?? this.locale,
    managerUnlocked: managerUnlocked ?? this.managerUnlocked,
    staffId: staffId ?? this.staffId,
    caseId: caseId ?? this.caseId,
    messageKey: messageKey,
    range: range ?? this.range,
    returnPage: returnPage ?? this.returnPage,
    navigationLabels: navigationLabels ?? this.navigationLabels,
    customPassword: customPassword ?? this.customPassword,
  );
}

class AppCubit extends Cubit<AppState> {
  AppCubit(this.store, {bool configured = true})
    : _configured = configured,
      super(AppState(page: configured ? AppPage.activeShift : AppPage.setup));
  bool _configured;
  final StringStore store;
  String? _passwordHash;
  bool _settingsReady = false;
  Future<void> loadLocale() async {
    final locale = await store.read('newcare.locale');
    final passwordHash = await store.read('newcare.managerPassword');
    final rawLabels = await store.read('newcare.navigationLabels');
    Map<String, String> labels = {};
    try {
      if (rawLabels != null) {
        labels = Map<String, String>.from(jsonDecode(rawLabels) as Map);
      }
    } on FormatException {
      labels = {};
    } on TypeError {
      labels = {};
    }
    _passwordHash = passwordHash;
    _settingsReady = true;
    if (!isClosed) {
      emit(
        state.copyWith(
          locale: ['en', 'ar'].contains(locale)
              ? Locale(locale!)
              : state.locale,
          navigationLabels: Map.unmodifiable(labels),
          customPassword: passwordHash != null,
        ),
      );
    }
  }

  String? navigationLabel(AppPage page) =>
      state.navigationLabels['${state.locale.languageCode}.${page.name}'];

  Future<void> saveNavigationLabels(Map<AppPage, String> values) async {
    if (!state.managerUnlocked) throw StateError('managerRequired');
    final labels = Map<String, String>.from(state.navigationLabels);
    for (final entry in values.entries) {
      final key = '${state.locale.languageCode}.${entry.key.name}';
      final value = entry.value.trim();
      if (value.length > 40) throw ArgumentError('navigationLabelTooLong');
      if (value.isEmpty) {
        labels.remove(key);
      } else {
        labels[key] = value;
      }
    }
    await store.write('newcare.navigationLabels', jsonEncode(labels));
    if (!isClosed) {
      emit(state.copyWith(navigationLabels: Map.unmodifiable(labels)));
    }
  }

  bool checkPassword(String password) {
    if (!_settingsReady) return false;
    if (_passwordHash == null) return password == 'newcare-demo';
    try {
      return Crypt(_passwordHash!).match(password);
    } on FormatException {
      return false;
    }
  }

  Future<String?> changePassword(String current, String next) async {
    if (!state.managerUnlocked || !checkPassword(current)) {
      return 'wrongPassword';
    }
    if (next.length < 8) return 'passwordTooShort';
    Crypt.cryptographicallySecureSalts = true;
    final hash = Crypt.sha512(next, rounds: 10000).toString();
    await store.write('newcare.managerPassword', hash);
    _passwordHash = hash;
    if (!isClosed) emit(state.copyWith(customPassword: true));
    return null;
  }

  Future<void> toggleLocale() async {
    final code = state.locale.languageCode == 'ar' ? 'en' : 'ar';
    await store.write('newcare.locale', code);
    if (!isClosed) emit(state.copyWith(locale: Locale(code)));
  }

  void navigate(AppPage page) {
    if ([
      AppPage.startShift,
      AppPage.endShift,
      AppPage.joinShift,
      AppPage.handover,
      AppPage.matched,
      AppPage.offline,
    ].contains(page)) {
      page = AppPage.activeShift;
    }
    final setupPage = [
      AppPage.setup,
      AppPage.setupNursing,
      AppPage.setupCatalogue,
      AppPage.ready,
    ].contains(page);
    if ((page.needsManager || (_configured && setupPage)) &&
        !state.managerUnlocked) {
      emit(state.copyWith(page: AppPage.login, returnPage: page));
    } else {
      emit(state.copyWith(page: page));
    }
  }

  void selectStaff(String id) => emit(state.copyWith(staffId: id));
  void selectCase(String id) =>
      emit(state.copyWith(caseId: id, page: AppPage.caseDetails));
  void setRange(DateTimeRange range) => emit(state.copyWith(range: range));
  bool unlock(String password) {
    if (!checkPassword(password)) return false;
    emit(
      state.copyWith(
        managerUnlocked: true,
        page: state.returnPage ?? AppPage.overview,
      ),
    );
    return true;
  }

  void lock() => emit(
    state.copyWith(
      managerUnlocked: false,
      page: AppPage.activeShift,
      returnPage: AppPage.overview,
    ),
  );
  void showSaved() => emit(state.copyWith(page: AppPage.saved));
  void completeSetup() {
    _configured = true;
    emit(state.copyWith(managerUnlocked: true, page: AppPage.ready));
  }
}
