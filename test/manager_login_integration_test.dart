import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/core/localization/localization_extensions.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/auth/data/models/manager_identity.dart';
import 'package:newcare/features/auth/data/models/manager_choice.dart';
import 'package:newcare/features/auth/data/repositories/manager_auth_repository.dart';
import 'package:newcare/features/auth/data/repositories/manager_gateway.dart';
import 'package:newcare/features/auth/data/sources/password_verifier.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

class _Gateway implements ManagerGateway, ManagerDirectoryGateway {
  bool offline = false;
  @override
  Future<List<ManagerChoice>> listManagers() async => const [
    ManagerChoice(id: 'manager-b', username: 'manager_b', name: 'Manager B'),
  ];
  @override
  Future<ManagerIdentity> signIn(String username, String password) async {
    if (offline) throw const ManagerNetworkException();
    return ManagerIdentity(
      id: 'manager-b',
      centerId: 'center-1',
      username: username,
      name: 'Manager B',
      email: 'contact@example.invalid',
      manageAccounts: false,
      viewDiagnostics: false,
    );
  }

  @override
  Future<void> signOut() async {}
}

class _Verifier implements PasswordVerifier {
  @override
  Future<String> create(String password) async => 'verifier';
  @override
  Future<bool> matches(String password, String encoded) async =>
      password == 'test-password';
}

void main() {
  testWidgets(
    'username login projects manager before entry and supports bounded offline login',
    (tester) async {
      final store = MemoryStringStore();
      final repository = LocalWorkspaceRepository(store, seedDemo: false);
      await repository.initialize();
      final gateway = _Gateway();
      final authentication = ManagerAuthRepository(
        centerId: 'center-1',
        gateway: gateway,
        store: store,
        verifier: _Verifier(),
      );
      await tester.pumpWidget(
        NewCareApp(
          repository: repository,
          store: store,
          authentication: authentication,
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(Scaffold).first);
      final app = context.read<AppCubit>();
      final signInLabel = context.t('signIn');
      app.navigate(AppPage.overview);
      await tester.pumpAndSettle();
      expect(app.state.page, AppPage.login);
      expect(
        find.byKey(const ValueKey('manager-login-manager-b')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('manager-login-manager-b')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).at(0))
            .controller!
            .text,
        'manager_b',
      );
      expect(app.state.managerUnlocked, isFalse);
      await tester.enterText(find.byType(TextFormField).at(1), 'test-password');
      await tester.tap(find.text(signInLabel));
      await tester.pumpAndSettle();
      expect(app.state.managerUnlocked, isTrue);
      expect(app.state.staffId, 'manager-b');
      expect(repository.current.staff.single.id, 'manager-b');
      expect(repository.current.staff.single.isManager, isTrue);
      expect(app.unlock('newcare-demo'), isFalse);
      app.navigate(AppPage.developerDiagnostics);
      expect(app.state.page, AppPage.overview);
      app.lock();
      gateway.offline = true;
      app.navigate(AppPage.overview);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'manager_b');
      await tester.enterText(find.byType(TextFormField).at(1), 'test-password');
      await tester.tap(find.text(signInLabel));
      await tester.pumpAndSettle();
      expect(app.offlineManager, isTrue);
      expect(app.state.managerUnlocked, isTrue);
      expect(
        await app.changePassword('test-password', 'new-long-password'),
        'onlineAccountChangeRequired',
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await repository.dispose();
    },
  );
}
