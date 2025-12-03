part of 'package:ygo_exodia_rules/main.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    final logoWidth = screenWidth * 0.5;
    final logoHeight = logoWidth * 0.348623853211009;
    final fontSize = screenHeight * 0.07;

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
                    padding: const EdgeInsets.all(8.0),
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
                  mainMenuText('JUGAR', fontSize),
                  mainMenuText('TESTEAR', fontSize),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mainMenuText(String text, double fontSize) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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