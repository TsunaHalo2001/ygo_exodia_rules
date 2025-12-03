import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

part 'screens/main_menu.dart';
part 'myapp.dart';
part 'myappstate.dart';
part 'myhomepage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  runApp(const MyApp());
}