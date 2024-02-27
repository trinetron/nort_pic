import 'dart:io';

import 'package:easy_localization/easy_localization.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:nort_pic/models/local_db/hive_names.dart';
import 'package:nort_pic/provider/state_provider.dart';
import 'package:nort_pic/ui/screens/main_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '/models/local_db/secstor.dart';
import 'package:flutter/material.dart';

//part 'package:nort_pic/models/local_db/sec_k.dart';

class DatabaseProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  String pass = '';
  bool checkPassErr = true;
  bool initialized = false;
  bool dbFilesExist = false;
  bool msgFilesExist = false;

  String msgSetting = '';

  String keyUsr = '';
  String keyMix = '';

  String dir2 = '';

  String masterPassVol = '';

  // @override
  // void dispose() async {
  //   super.dispose();
  //   Hive.close();
  // }

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  late Box<C_hive> _boxA = Hive.box<C_hive>(HiveBoxes.db_hive);

  late C_hive _selectedboxA = C_hive();

  Box<C_hive> get boxA => _boxA;

  C_hive get selectedboxA => _selectedboxA;

  Future<void> requestStoragePermission() async {
    var serviceStatus = await Permission.storage.isGranted;

    bool isStorageOn = serviceStatus == ServiceStatus.enabled;
    debugPrint(isStorageOn.toString());

    var status = await Permission.storage.request();

    if (status == PermissionStatus.granted) {
      debugPrint('Permission Granted');
    } else if (status == PermissionStatus.denied) {
      debugPrint('Permission denied');
    } else if (status == PermissionStatus.permanentlyDenied) {
      debugPrint('Permission Permanently Denied');
      await openAppSettings();
    }
  }

  String curDateTime() {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd(HH-mm)');
    String formattedDate = formatter.format(now);
    debugPrint(formattedDate);
    return formattedDate;
  }

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Hive
  ///* Updating the current selected index for that contact to pass to read from hive
  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    updateSelectedContact();
    notifyListeners();
  }

  ///* Updating the current selected item from hive
  void updateSelectedContact() {
    _selectedboxA = readFromHive()!;
    notifyListeners();
  }

  ///* reading the current selected item from hive
  C_hive? readFromHive() {
    C_hive? getItem = _boxA.getAt(_selectedIndex);

    return getItem;
  }

  void deleteFromHive() {
    _boxA.deleteAt(_selectedIndex);
    debugPrint(' _boxA.deleteAt   $_selectedIndex ');
  }

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  bool get isAuth {
    return initialized = false;
  }

  void msgdbFilesExists(var val) {
    msgFilesExist = val;
  }

  Future<bool> dbFilesExists() async {
    Directory? appDocDir = await getApplicationDocumentsDirectory();
    String appPath = appDocDir.path + '/nortpic';
    // String appPath = appDocDir.path;
    if ((await Hive.boxExists(HiveBoxes.db_hive, path: appPath))) {
      debugPrint('dbFilesExists true');
      return true;
    } else {
      debugPrint('dbFilesExists false');
      return false;
    }
  }

  void changeDataLogin(String val) {
    pass = val;
    // if (pass == 'xxx') {
    //   initialized = true;
    // }
    debugPrint('pass  $pass');
    notifyListeners();
  }

  initConfig(context) async {
    try {
      //msgSetting = await hiveSetting.readSetting();
      // await context.read<MenuProvider>().menuSet(msgSetting, context);
      debugPrint('initConfig try run: ---');
      //notifyListeners();
    } catch (e) {
      debugPrint('initConfig error caught: $e');
      debugPrint('err run: ---');
    }
  }

  initSecBD(BuildContext context) async {
    try {
      Directory? appDocDir = await getApplicationDocumentsDirectory();
      String appPath = appDocDir.path + '/nortpic';
      // String appPath = appDocDir.path;
      debugPrint('appPath  $appPath');

      _boxA = await Hive.openBox<C_hive>(HiveBoxes.db_hive,
          crashRecovery: true, path: appPath);

      debugPrint('_boxA.isOpen $_boxA.isOpen.toString()');

      // if ((await Hive.isBoxOpen('db_hive')) &&
      //     (await Hive.isBoxOpen('db_hiveCard'))) {
      if ((_boxA.isOpen)) {
        context.read<StateProvider>().changeInit(true);
        context.read<StateProvider>().changeErrState(false);
        context.read<DatabaseProvider>().checkPassErr = false;
        notifyListeners();

        await Navigator.of(context).push(
            PageRouteBuilder(pageBuilder: (context, a1, a2) => MainScreen()));
      } else {
        context.read<StateProvider>().changeErrState(false);
        context.read<StateProvider>().changeInit(false);
        context.read<DatabaseProvider>().checkPassErr = true;
        notifyListeners();
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text(LocaleKeys.pass_err.tr()),
        // ));
      }

      debugPrint('initSecBD try run: ---');
    } catch (e, s) {
      debugPrint('initSecBD error caught: $e');
      debugPrint('initSecBD error Стек: $s');
      debugPrint('initSecBD err run: ---');
    } finally {
      //
      // context.read<StateProvider>().changeInit(true);
      // notifyListeners();
      // await Navigator.of(context)
      //     .push(MaterialPageRoute(builder: (context) => MainScreen()));
    }
  }
}
