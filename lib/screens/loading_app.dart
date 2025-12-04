part of '../main.dart';

class LoadingApp extends StatefulWidget{
  const LoadingApp({super.key});

  @override
  State<LoadingApp> createState() => _LoadingAppState();
}

class _LoadingAppState extends State<LoadingApp> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _startAppProcess();
  }

  Future<void> _startAppProcess() async {
    final appState = context.read<MyAppState>();
    await appState.loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              appState.setState(1);
            }
          });
        }

        return Scaffold(
          body: CircularProgressIndicator()
        );
      }
    );
  }
}