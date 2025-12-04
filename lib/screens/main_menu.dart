part of 'package:ygo_exodia_rules/main.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  List<bool> _isPressed = [false, false];

  @override
  void initState() {
    super.initState();
    startBgm();
  }

  void startBgm() =>
    FlameAudio.bgm.play('BGM_MENU_01.ogg', volume: 0.5);

  @override
  void dispose() {
    FlameAudio.bgm.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final bool isLandscape = screenWidth > screenHeight;

    final logoWidth = isLandscape ? screenHeight * 0.8 : screenWidth * 0.8;
    final logoHeight = logoWidth * 0.348623853211009;
    final fontSize = isLandscape ? screenHeight * 0.07 : screenWidth * 0.07;
    final padding = isLandscape ? screenHeight * 0.01 : screenWidth * 0.01;

    final List<String> options = ['JUGAR', 'TESTEAR'];

    GestureTapCallback tapMainMenu(int index) =>
      () =>
        appState.setState(index + 2);

    void setPressState (int index, bool isPressed) =>
      setState(() => _isPressed[index] = isPressed);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/webp/main_menu.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: Container(
                      width: logoWidth,
                      height: logoHeight,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/png/main_logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  ...List.generate(
                    options.length,
                    (index) => mainMenuText(
                      options[index],
                      fontSize,
                      padding,
                      tapMainMenu(index),
                      _isPressed[index],
                      () {
                        setPressState(index, true);
                        FlameAudio.play('SE_MENU_DECIDE.ogg', volume: 0.7);
                      },
                      () => setPressState(index, false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mainMenuText(
    String text,
    double fontSize,
    double padding,
    GestureTapCallback tapMainMenu,
    bool isPressed,
    GestureTapCallback tapButton,
    GestureTapCallback unTapButton,
    ) =>
    GestureDetector(
      onTap: tapMainMenu,
      onTapDown: (_) => tapButton(),
      onTapUp: (_) => unTapButton(),
      onTapCancel: () => unTapButton(),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: AnimatedScale(
          scale: isPressed ? 0.9 : 1,
          duration: Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kafu Techno',
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withAlpha(95),
                  offset: const Offset(2.0, 2.0),
                  blurRadius: 3.0,
                ),
                Shadow(
                  color: Colors.white.withAlpha(5),
                  offset: const Offset(1.0, 1.0),
                  blurRadius: 1.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
}