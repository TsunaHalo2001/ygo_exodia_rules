part of 'main.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget page;
    var appState = context.watch<MyAppState>();

    final overlayMap = {
      'GameOverlay' : (BuildContext context, DuelGame game) {
        return Placeholder();
      }
    };

    switch (appState.state) {
      case 0:
        page = LoadingApp();
        break;
      case 1:
        page = MainMenu();
        break;
      case 2:
        page = Placeholder();
        break;
      case 3:
        page = GameWidget<DuelGame>(
          game: DuelGame(
            gameMode: GameMode.testing,
            normalMonsters: appState.normalMonsters,
          ),
          overlayBuilderMap: overlayMap,
          //initialActiveOverlays: const ['GameOverlay'],
        );
        break;
      default:
        throw UnimplementedError('no widget for state $appState');
    }

    return LayoutBuilder(
      builder: (context, constraints) =>
        Scaffold(
          body: SafeArea(child: page),
        ),
    );
  }
}