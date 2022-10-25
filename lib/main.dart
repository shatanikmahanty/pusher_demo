import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pusher_demo/blocs/channel_bloc.dart';
import 'package:pusher_demo/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureApp();

  runApp(const MyApp());
}

Future configureApp() async {
  ///Initialising firebase app
  ///so that all firebase services can be used
  if (Firebase.apps.isEmpty) await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChannelBloc>(
          create: (context) => ChannelBloc(),
        ),
      ],
      child: const MaterialApp(
        title: 'Spaces',
        home: HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
