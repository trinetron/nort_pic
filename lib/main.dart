//import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nort_pic/provider/panel_provider.dart';
import 'package:nort_pic/provider/state_provider.dart';
import 'package:nort_pic/provider/theme_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:nort_pic/models/design/theme.dart';
import 'package:nort_pic/models/local_db/secstor.dart';

import 'package:nort_pic/provider/permissions_provider.dart';
import 'package:nort_pic/provider/db_provider.dart';
import 'package:nort_pic/ui/screens/main_screen.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  //await DefaultCacheManager().emptyCache();
  // await Hive.deleteBoxFromDisk('shopping_box');

  //   hive initialization
  await Hive.initFlutter();
  Hive.registerAdapter(ChiveAdapter());

  if ((Platform.isWindows) || (Platform.isIOS) || (Platform.isLinux)) {
    // windowManager initialization
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      // size: Size(850, 400),
      minimumSize: Size(400, 500),
      center: false,
      title: 'NortPic',
      // backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  //    Localozation init
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(EasyLocalization(
    supportedLocales: const [
      Locale('en'),
      Locale('ru'),
      Locale('fr'),
      Locale('es'),
      Locale('zh'),
    ],
    path: 'lib/models/languages',
    fallbackLocale: Locale('en'),
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider<DatabaseProvider>(
          create: (_) => DatabaseProvider(),
        ),
        ChangeNotifierProvider<PermissionsService>(
          create: (context) => PermissionsService(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider<StateProvider>(
          create: (context) => StateProvider(),
        ),
        ChangeNotifierProvider<PanelProvider>(
          create: (context) => PanelProvider(),
        ),
      ],
      child: const NortPicApp(),
    ),
  ));
}

class NortPicApp extends StatefulWidget {
  const NortPicApp({super.key});

  @override
  NortPicAppState createState() => NortPicAppState();
}

class NortPicAppState extends State<NortPicApp> {
  final bColor = ColorsSHM();

  @override
  void dispose() async {
    Hive.close();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<PermissionsService>().requestStoragePermission();
    initDirectories();
  }

  Future<void> initDirectories() async {
    List<String> directories = [];

    if (Platform.isIOS) {
      directories.add((await getApplicationDocumentsDirectory()).path);
      directories.add((await getTemporaryDirectory()).path);
      directories.add((await getApplicationSupportDirectory()).path);
    } else if (Platform.isAndroid) {
      directories.add((await getApplicationDocumentsDirectory()).path);
      directories.add((await getTemporaryDirectory()).path);
      directories.add((await getExternalStorageDirectory())!.path);
    } else if (Platform.isWindows) {
      directories.add((await getApplicationDocumentsDirectory()).path);
      directories.add((await getTemporaryDirectory()).path);
      directories.add((await getDownloadsDirectory())!.path);
    }

    setState(() {
      context.read<PanelProvider>().setPaths(directories);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NORTON PICTURE',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
