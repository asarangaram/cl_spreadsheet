import 'package:minimal_mvn/minimal_mvn.dart';

enum NavPage { home, spreadSheet }

class NavPagesNotifier extends MMNotifier<NavPage> {
  NavPagesNotifier() : super(NavPage.home);

  void goto(NavPage page) => notify(page);
}

final MMManager<NavPagesNotifier> navPagesManager = MMManager(
  NavPagesNotifier.new,
);
