part of 'main.dart';

class MyAppState extends ChangeNotifier {
  int state = 0;

  void setState(int newState) {
    state = newState;
    notifyListeners();
  }
}