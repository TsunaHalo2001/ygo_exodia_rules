part of 'main.dart';

class MyAppState extends ChangeNotifier {
  final ApiService apiService = ApiService();
  final FileHelper fileHelper = FileHelper();

  int state = 0;

  static final String _lastUpdateKey = 'last_update';
  String actualDate = '';

  bool cacheValid = false;
  bool apiCalled = false;

  Map<String, dynamic> cardsAPI = {};
  Map<int, YGOCard> cards = {};
  Map<int, YGOCard> normalMonsters = {};
  Map<int, YGOCard> fusionMonsters = {};
  Map<int, Uint8List> images = {};
  Map<String, Image> attributeImages = {
    'DARK' :Image.asset(
      'assets/images/attributes/dark.webp',
      fit: BoxFit.cover,
    ),
    'EARTH' :Image.asset(
      'assets/images/attributes/earth.png',
      fit: BoxFit.cover,
    ),
    'FIRE' :Image.asset(
      'assets/images/attributes/fire.webp',
      fit: BoxFit.cover,
    ),
    'LIGHT' :Image.asset(
      'assets/images/attributes/light.png',
      fit: BoxFit.cover,
    ),
    'WATER' :Image.asset(
      'assets/images/attributes/water.png',
      fit: BoxFit.cover,
    ),
    'WIND' :Image.asset(
      'assets/images/attributes/wind.webp',
      fit: BoxFit.cover,
    ),
    'DIVINE' :Image.asset(
      'assets/images/attributes/divine.webp',
      fit: BoxFit.cover,
    ),
    'spell' :Image.asset(
      'assets/images/attributes/spell.webp',
      fit: BoxFit.cover,
    ),
    'trap' :Image.asset(
      'assets/images/attributes/trap.png',
      fit: BoxFit.cover,
    ),
    'level' :Image.asset(
      'assets/images/attributes/level.png',
      fit: BoxFit.cover,
    ),
    'rank' :Image.asset(
      'assets/images/attributes/rank.png',
      fit: BoxFit.cover,
    ),
    'Continuous' :Image.asset(
      'assets/images/attributes/continuous.png',
      fit: BoxFit.cover,
    ),
    'Equip' :Image.asset(
      'assets/images/attributes/equip.webp',
      fit: BoxFit.cover,
    ),
    'Field' :Image.asset(
      'assets/images/attributes/field.png',
      fit: BoxFit.cover,
    ),
    'Quick-Play' :Image.asset(
      'assets/images/attributes/quickplay.webp',
      fit: BoxFit.cover,
    ),
    'Ritual' :Image.asset(
      'assets/images/attributes/ritual.webp',
      fit: BoxFit.cover,
    ),
    'Counter' :Image.asset(
      'assets/images/attributes/counter.webp',
      fit: BoxFit.cover,
    ),
  };

  List<YGOCard> extraDeckList = [];

  void setState(int newState) {
    state = newState;
    notifyListeners();
  }

  Future<void> loadInitialData() async {
    if (await isCacheValid() || !(await _checkInternetConnection())) {
      await loadFromCache();
    } else {
      await fetchAndCache();
    }

    await loadImages();
    notifyListeners();
  }

  Future<void> loadFromCache() async {
    final data = await fileHelper.readDataCache();
    if (data != null) {
      cardsAPI = jsonDecode(data);

      cards = await YGOCard.genCards(cardsAPI['data']);
      normalMonsters = await YGOCard.genNormalMonsters(cardsAPI['data']);
      fusionMonsters = await YGOCard.genFusionMonsters(cardsAPI['data']);
      extraDeckList = fusionMonsters.values.toList();

      notifyListeners();
    }
  }

  Future<void> fetchAndCache() async {
    try {
      cardsAPI = await apiService.fetchData('');

      await fileHelper.writeDataCache(jsonEncode(cardsAPI));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
      actualDate = DateTime.now().toIso8601String();
    }
    catch (error) {
      print(error);
    }
    await loadFromCache();
    notifyListeners();
  }

  Future<void> loadCardImg(int id) async {
    if (images[id] == null) {
      images[id] = (await fileHelper.readImage(id))!;
    }
  }

  Future<void> loadImages() async {
    await loadCardImg(33396948);
    for (final card in normalMonsters.values) {
      await loadCardImg(card.id);
    }
    for (final card in fusionMonsters.values) {
      await loadCardImg(card.id);
    }
  }

  Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString(_lastUpdateKey);

    if (lastUpdate == null || await fileHelper.readDataCache() == null) return false;

    final lastUpdateDateTime = DateTime.parse(lastUpdate);
    final now = DateTime.now();

    if (lastUpdateDateTime.year == now.year &&
        lastUpdateDateTime.month == now.month &&
        lastUpdateDateTime.day == now.day) {
      apiCalled = false;
      return true;
    }
    else {
      apiCalled = true;
      return false;
    }
  }

  Future<bool> _checkInternetConnection() async {
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }

    return true;
  }
}