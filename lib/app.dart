import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:rapidpass_checkpoint/data/app_database.dart';
import 'package:rapidpass_checkpoint/helpers/local_notifications_helper.dart';
import 'package:rapidpass_checkpoint/models/app_state.dart';
import 'package:rapidpass_checkpoint/models/user_location.dart';
import 'package:rapidpass_checkpoint/repository/api_repository.dart';
import 'package:rapidpass_checkpoint/screens/about_screen.dart';
import 'package:rapidpass_checkpoint/screens/authenticating_screen.dart';
import 'package:rapidpass_checkpoint/screens/check_plate_or_control_results_screen.dart';
import 'package:rapidpass_checkpoint/screens/check_plate_or_control_screen.dart';
import 'package:rapidpass_checkpoint/screens/faqs_screen.dart';
import 'package:rapidpass_checkpoint/screens/feedback_screen.dart';
import 'package:rapidpass_checkpoint/screens/main_menu.dart';
import 'package:rapidpass_checkpoint/screens/need_help_screen.dart';
import 'package:rapidpass_checkpoint/screens/privacy_policy_screen.dart';
import 'package:rapidpass_checkpoint/screens/qr_scanner_screen.dart';
import 'package:rapidpass_checkpoint/screens/scan_result_screen.dart';
import 'package:rapidpass_checkpoint/screens/settings_screen.dart';
import 'package:rapidpass_checkpoint/screens/update_database_screen.dart';
import 'package:rapidpass_checkpoint/screens/usage_log_count_screen.dart';
import 'package:rapidpass_checkpoint/screens/usage_log_detail_screen.dart';
import 'package:rapidpass_checkpoint/screens/usage_log_screen.dart';
import 'package:rapidpass_checkpoint/screens/view_more_info_screen.dart';
import 'package:rapidpass_checkpoint/screens/welcome_screen.dart';
import 'package:rapidpass_checkpoint/services/api_service.dart';
import 'package:rapidpass_checkpoint/services/app_storage.dart';
import 'package:rapidpass_checkpoint/services/local_database_service.dart';
import 'package:rapidpass_checkpoint/services/location_service.dart';
import 'package:rapidpass_checkpoint/services/pass_validation_service.dart';
import 'package:rapidpass_checkpoint/viewmodel/device_info_model.dart';
import 'package:sqflite/sqflite.dart' show getDatabasesPath;

import 'flavor.dart';
import 'models/check_plate_or_control_args.dart';

class RapidPassCheckpointApp extends StatelessWidget {
  // Local
  static const String databaseName = 'rapid_pass.sqlite';

  final Flavor _flavor;

  RapidPassCheckpointApp(this._flavor) {
    debugPrint('apiBaseUrl: ${_flavor.apiBaseUrl}');
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide the model here
        ChangeNotifierProvider(
          create: (_) => DeviceInfoModel(),
        ),
        ChangeNotifierProvider(create: (_) {
          final appState = AppState();
          AppStorage.getLastSyncOn()
              .then((timestamp) => appState.databaseLastUpdated = timestamp);
          AppStorage.getDatabaseSyncLog().then((records) =>
              records.forEach((log) => appState.addDatabaseSyncLog(log)));
          return appState;
        }),
        FutureProvider<ApiRepository>(
          initialData: null,
          create: (_) => _buildApiRepository(),
        ),
        ProxyProvider<ApiRepository, PassValidationService>(
          update: (_, apiRepository, __) =>
              PassValidationService(apiRepository),
        ),
        StreamProvider<UserLocation>(
          create: (_) => LocationService().locationStream,
        ),
      ],
      child: MaterialApp(
        title: 'RapidPass Checkpoint',
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
                builder: (_) => MainMenuScreen(),
                settings: settings,
              );
            case '/scanResults':
              return CupertinoPageRoute(
                builder: (_) => ScanResultScreen(settings.arguments),
                settings: settings,
              );
            case '/checkPlateOrCodeResults':
              return CupertinoPageRoute(
                  builder: (_) =>
                      CheckPlateOrControlCodeResultsScreen(settings.arguments),
                  settings: settings);
            case '/checkPlateNumber':
              return CupertinoPageRoute(
                  builder: (_) => CheckPlateOrControlScreen(
                      CheckPlateOrControlScreenModeType.plate));
            case '/checkControlNumber':
              return CupertinoPageRoute(
                builder: (_) => CheckPlateOrControlScreen(
                    CheckPlateOrControlScreenModeType.control),
              );
            case '/scanQr':
              QrScannerScreenArgs args = settings.arguments;
              if (args == null || !(args is QrScannerScreenArgs)) {
                args = QrScannerScreenArgs();
              }
              return CupertinoPageRoute(builder: (_) => QrScannerScreen(args));
            case '/authenticatingScreen':
              return CupertinoPageRoute(
                  builder: (_) => AuthenticatingScreen(
                        onSuccess: (context) =>
                            Navigator.pushReplacementNamed(context, '/menu'),
                        onError: (context) => Navigator.popUntil(
                            context, ModalRoute.withName('/')),
                      ));
            case '/viewMoreInfo':
              return CupertinoPageRoute(
                builder: (_) => ViewMoreInfoScreen(),
                settings: settings,
              );
            case '/updateDatabase':
              return CupertinoPageRoute(
                builder: (_) => UpdateDatabaseScreen(),
                settings: settings,
              );
            case '/need_help':
              return CupertinoPageRoute(builder: (_) => NeedHelp());
            case '/about':
              return CupertinoPageRoute(builder: (_) => About());
            case '/privacy_policy':
              return CupertinoPageRoute(
                builder: (_) => PrivacyPolicy(),
              );
            case '/faqs':
              return CupertinoPageRoute(builder: (_) => Faqs());
            case '/settings':
              return CupertinoPageRoute(builder: (_) => SettingsScreen());
            case '/feedback':
              return CupertinoPageRoute(builder: (_) => FeedbackScreen());
            case '/usageLog':
              return CupertinoPageRoute(builder: (_) => UsageLogScreen());
            case '/usageLogDetail':
              UsageLogDetailArgs args = settings.arguments;
              if (args == null || !(args is UsageLogDetailArgs)) {
                args = UsageLogDetailArgs(0);
              }
              return CupertinoPageRoute(
                  builder: (_) => UsageLogDetailScreen(args));
            case '/usageLogCount':
              UsageLogCountArgs args = settings.arguments;
              if (args == null || !(args is UsageLogCountArgs)) {
                args = UsageLogCountArgs(null);
              }
              return CupertinoPageRoute(
                  builder: (_) => UsageLogCountScreen(args));
          }
          return null;
        },
      ),
    );
  }

  Future<ApiRepository> _buildApiRepository() async {
    final Uint8List encryptionKey = await AppStorage.getDatabaseEncryptionKey();
    debugPrint('encryptionKey: $encryptionKey');
    final localDatabaseService = LocalDatabaseService(
        appDatabase: AppDatabase(LazyDatabase(() async {
          final dbFolder = await getDatabasesPath();
          final file = File(p.join(dbFolder, 'db.sqlite'));
          return VmDatabase(file, logStatements: Flavor.isDevelopment);
        })),
        encryptionKey: encryptionKey);
    final apiRepository = ApiRepository(
      apiService: ApiService(
        baseUrl: _flavor.apiBaseUrl,
        keycloakRealm: _flavor.keycloakRealm,
        keycloakClient: _flavor.keycloakClient
      ),
      localDatabaseService: localDatabaseService,
    );
    debugPrint('_buildApiRepository() => $apiRepository');
    return apiRepository;
  }
}

void runRapidPassCheckpoint(final Flavor flavor) {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotificationsHelper.initialize()
      .then((_) => LocalNotificationsHelper.setDailyNotifications());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) => runApp(RapidPassCheckpointApp(flavor)));
}
