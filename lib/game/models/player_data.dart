part of '../../main.dart';

enum PlayerType {
  human,
  ai,
}

class PlayerData {
  int lifePoints;
  PlayerType playerType;
  List<int> deck = [];
  List<int> hand = [];
  List<int> graveyard = [];
  List<int> field = [];
  List<int> availableExtraDeck = [];

  PlayerData({
    required this.playerType,
    this.lifePoints = 8000
  });

  void genDeck(Map<int, YGOCard> cards) {
    Map<int, int> mapDeck = {
      33396948: 1,
      7902349: 1,
      44519536: 1,
      70903634: 1,
      8124921: 1,
    };

    List<int> preShuffleDeck = [];

    preShuffleDeck.add(33396948);
    preShuffleDeck.add(7902349);
    preShuffleDeck.add(44519536);
    preShuffleDeck.add(70903634);
    preShuffleDeck.add(8124921);

    for (int i = 0; i < 55; i++) {
      final randomIndex = Random().nextInt(cards.length);
      final card = cards.values.elementAt(randomIndex);

      if (mapDeck.containsKey(card.id)) {
        if (mapDeck[card.id]! > 3) {
          i--;
          continue;
        }
        mapDeck[card.id] = mapDeck[card.id]! + 1;
        preShuffleDeck.add(card.id);
      }
      else {
        mapDeck[card.id] = 1;
        preShuffleDeck.add(card.id);
      }
    }

    deck = preShuffleDeck;
    deck.shuffle();
  }
}