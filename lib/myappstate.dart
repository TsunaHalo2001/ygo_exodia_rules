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

    notifyListeners();
  }

  Future<void> loadFromCache() async {
    final data = await fileHelper.readDataCache();
    if (data != null) {
      cardsAPI = jsonDecode(data);

      cards = await YGOCard.genCards(cardsAPI['data']);
      normalMonsters = await YGOCard.genNormalMonsters(cardsAPI['data']);
      fusionMonsters = await YGOCard.genFusionMonsters(cardsAPI['data']);

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