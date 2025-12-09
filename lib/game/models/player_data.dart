part of '../../main.dart';

enum PlayerType {
  human,
  ai,
}

class PlayerData {
  ValueNotifier<int> lifePointsNotifier;
  bool hasNormalSummonedThisTurn = false;

  PlayerType playerType;
  List<int> deck = [];
  List<int> hand = [];
  List<int> graveyard = [];
  List<int> field = List.filled(5, -1); // 5 monster zones
  List<int> availableExtraDeck = [];

  PlayerData({
    required this.playerType,
    int initialLifePoints = 8000
  }) : lifePointsNotifier = ValueNotifier(initialLifePoints);

  set lifePoints(int value) {
    lifePointsNotifier.value = value;
  }

  int get lifePoints => lifePointsNotifier.value;

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

  int drawCard() {
    if (deck.isEmpty) {
      lifePoints = 0;
    }

    final cardId = deck.removeAt(0);
    hand.add(cardId);
    return cardId;
  }

  void genHand() {
    for (int i = 0; i < 5; i++) {
      drawCard();
    }
  }

  void normalSummon(YGOCard card, int zoneIndex) {
    hasNormalSummonedThisTurn = true;

    hand.remove(card.id);
    field[zoneIndex] = card.id;
  }

  void setCard(YGOCard card, int zoneIndex) {
    hasNormalSummonedThisTurn = true;

    hand.remove(card.id);
    field[zoneIndex] = card.id;
  }
}