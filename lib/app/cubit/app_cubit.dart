import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  });
  final AppPage page;
  final Locale locale;
  final bool managerUnlocked;
  final String staffId;
  final String? caseId, messageKey;
  final DateTimeRange? range;
  final AppPage? returnPage;
  AppState copyWith({
    AppPage? page,
    Locale? locale,
    bool? managerUnlocked,
    String? staffId,
    String? caseId,
    String? messageKey,
    DateTimeRange? range,
    AppPage? returnPage,
  }) => AppState(
    page: page ?? this.page,
    locale: locale ?? this.locale,
    managerUnlocked: managerUnlocked ?? this.managerUnlocked,
    staffId: staffId ?? this.staffId,
    caseId: caseId ?? this.caseId,
    messageKey: messageKey,
    range: range ?? this.range,
    returnPage: returnPage ?? this.returnPage,
  );
}

class AppCubit extends Cubit<AppState> {
  AppCubit(this.store) : super(AppState());
  final StringStore store;
  Future<void> loadLocale() async {
    final locale = await store.read('newcare.locale');
    if (!isClosed && ['en', 'ar'].contains(locale))
      emit(state.copyWith(locale: Locale(locale!)));
  }

  Future<void> toggleLocale() async {
    final code = state.locale.languageCode == 'ar' ? 'en' : 'ar';
    await store.write('newcare.locale', code);
    if (!isClosed) emit(state.copyWith(locale: Locale(code)));
  }

  void navigate(AppPage page) {
    if (page.needsManager && !state.managerUnlocked) {
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
    if (password != 'newcare-demo') return false;
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
}
