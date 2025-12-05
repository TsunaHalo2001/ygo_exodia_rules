import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';

import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'api_service.dart';
part 'file_helper.dart';
part 'myapp.dart';
part 'myappstate.dart';
part 'myhomepage.dart';
part 'screens/main_menu.dart';
part 'screens/loading_app.dart';
part 'game/overlays/game_overlay.dart';
part 'game/overlays/deck_menu_overlay.dart';
part 'game/overlays/extra_menu_overlay.dart';
part 'game/overlays/deck_overlay.dart';
part 'game/overlays/extra_overlay.dart';
part 'game/overlays/card_info_overlay.dart';
part 'game/models/player_data.dart';
part 'game/components/ygocard.dart';
part 'game/components/zone_component.dart';
part 'game/components/game_field.dart';
part 'game/components/card_component.dart';
part 'game/components/hand_component.dart';
part 'game/duel_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  runApp(const MyApp());
}