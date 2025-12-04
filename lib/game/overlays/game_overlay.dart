part of '../../main.dart';

class GameOverlay extends StatelessWidget {
  final DuelGame game;

  const GameOverlay({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final bool isLandscape = screenWidth > screenHeight;

    final lpWidth = isLandscape ? screenHeight * 0.35 : screenWidth * 0.35;
    final lpHeight = lpWidth * 0.350943396226415;
    final lpFont = isLandscape ? screenHeight * 0.05 : screenWidth * 0.05;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: lpWidth,
            height: lpHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/png/GUI_LP_Red.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.005, screenHeight * 0.003, 0, 0),
                      child: Text(
                        'P1',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: lpFont / 1.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kafu Techno',
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${game.player1.lifePoints}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: lpFont,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kafu Techno',
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: lpWidth,
            height: lpHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/png/GUI_LP_Blue.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, screenHeight * 0.003, screenWidth * 0.005, 0),
                      child: Text(
                        'P2',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: lpFont / 1.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kafu Techno',
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${game.player2.lifePoints}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: lpFont,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kafu Techno',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}