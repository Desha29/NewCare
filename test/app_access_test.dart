import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/core/storage/string_store.dart';

void main() {
  test('configured workspace never exposes setup while manager is locked', () {
    final app = AppCubit(MemoryStringStore());
    app.navigate(AppPage.setup);
    expect(app.state.page, AppPage.login);
    expect(app.unlock('wrong'), isFalse);
    expect(app.state.managerUnlocked, isFalse);
    expect(app.unlock('newcare-demo'), isTrue);
    expect(app.state.page, AppPage.setup);
    app.lock();
    app.navigate(AppPage.setupNursing);
    expect(app.state.page, AppPage.login);
    app.close();
  });
}
