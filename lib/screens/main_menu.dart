part of 'package:ygo_exodia_rules/main.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  void initState() {
    super.initState();
    startBgm();
  }

  void startBgm() {
    FlameAudio.bgm.play('BGM_MENU_01.ogg', volume: 0.5);
  }

  @override
  void dispose() {
    FlameAudio.bgm.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    //final double screenWidth = screenSize.width;

    final logoWidth = screenHeight * 0.8;
    final logoHeight = logoWidth * 0.348623853211009;
    final fontSize = screenHeight * 0.07;
    final padding = screenHeight * 0.01;

    final List<String> options = ['JUGAR', 'TESTEAR'];

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

  Widget mainMenuText(String text, double fontSize, double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
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
    );
  }
}