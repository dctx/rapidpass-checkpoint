import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rapidpass_checkpoint/screens/main_menu.dart';
import 'package:rapidpass_checkpoint/screens/scan_result_screen.dart';
import 'package:rapidpass_checkpoint/screens/welcome_screen.dart';
import 'package:rapidpass_checkpoint/viewmodel/device_info_model.dart';

void main() => runApp(RapidPassCheckpointApp());

class RapidPassCheckpointApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide the model here
        ChangeNotifierProvider(
          create: (_) => DeviceInfoModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          appBarTheme: AppBarTheme(
            textTheme: GoogleFonts.workSansTextTheme(
              Theme.of(context).textTheme,
            ).copyWith(
              title: GoogleFonts.workSans(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          textTheme: GoogleFonts.workSansTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        initialRoute: "/",
        routes: {'/': (_) => WelcomeScreen()},
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/menu':
              return CupertinoPageRoute(
                  builder: (_) => MainMenuScreen('Camp Aguinaldo'),
                  settings: settings);
            case '/passOk':
              return CupertinoPageRoute(
                  builder: (_) => ScanResultScreen(settings.arguments),
                  settings: settings);
            case '/passInvalid':
              return CupertinoPageRoute(
                  builder: (_) => ScanResultScreen(settings.arguments),
                  settings: settings);
          }
          return null;
        },
      ),
    );
  }
}
