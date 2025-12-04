import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

part 'screens/main_menu.dart';
part 'myapp.dart';
part 'myappstate.dart';
part 'myhomepage.dart';
part 'game/models/player_data.dart';
part 'game/components/zone_component.dart';
part 'game/components/game_field.dart';
part 'game/duel_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  runApp(const MyApp());
}