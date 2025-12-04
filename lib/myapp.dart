part of 'main.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) =>
    ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        home: MyHomePage(),
      ),
    );
}