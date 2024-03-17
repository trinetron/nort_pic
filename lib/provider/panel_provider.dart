import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_all_path_provider/flutter_all_path_provider.dart';

class PanelProvider extends ChangeNotifier {
  int flgUpdatedMg = 0;
  List<String> currentDirectory = [];
  List<String> startDirectory = [];
  int unKey = 0;
  bool isCopy = false;
  Set<String> selectedImages0 = Set();
  Set<String> selectedImages1 = Set();
  List<StorageInfo> _storageInfo = [];

  Future<void> initPlatformState() async {
    late List<StorageInfo> storageInfo;

    storageInfo = await FlutterAllPathProvider.getStorageInfo();

    _storageInfo = storageInfo;
  }

  Future<void> initDirectories() async {
    if (Platform.isAndroid) await initPlatformState();
    List<String> directories = [];
    print("set dir");

    if (Platform.isIOS) {
      directories.add((await getApplicationDocumentsDirectory()).path);
      //directories.add((await getTemporaryDirectory()).path);
      //directories.add((await getApplicationSupportDirectory()).path);
    } else if (Platform.isAndroid) {
      //directories.add((await getApplicationDocumentsDirectory()).path);
      //directories.add((await getTemporaryDirectory()).path);

      directories.add(_storageInfo.isNotEmpty
          ? _storageInfo[0].rootDir
          : (await getTemporaryDirectory()).path);

      //directories.add("storage/emulated/0/");
      //directories.add((await getExternalStorageDirectory())!.path);
    } else if (Platform.isWindows) {
      directories.add((await getApplicationDocumentsDirectory()).path);
      directories.add((await getTemporaryDirectory()).path);
      directories.add((await getDownloadsDirectory())!.path);
    } else if (Platform.isMacOS) {
      // directories.add((await getApplicationDocumentsDirectory()).path);

      directories.add((await getTemporaryDirectory()).path);
      //directories.add((await getDownloadsDirectory())!.path);
    }

    setPaths(directories);
    print("set dir2");
    notifyListeners();
  }

  void setPaths(List<String> startDirectoryTmp) {
    startDirectory = startDirectoryTmp;
    //startDirectory = StorageDirectory.dcim;
    currentDirectory.add(startDirectoryTmp[0]);
    currentDirectory.add(startDirectoryTmp[0]);

    debugPrint('startDirectory  $startDirectory');
    notifyListeners();
  }

  void updatedMg0() {
    flgUpdatedMg = 0;

    debugPrint('flgUpdatedMg  $flgUpdatedMg');
    notifyListeners();
  }

  void updatedDir() {
    flgUpdatedMg++;

    debugPrint('currentDirectory  $currentDirectory');
    notifyListeners();
  }

  void setCurrentDirectory({required int nomPanel, required String fPath}) {
    if (nomPanel == 0) {
      currentDirectory[0] = fPath;
    } else {
      currentDirectory[1] = fPath;
    }

    debugPrint('setCurrentDirectory  $currentDirectory');
    notifyListeners();
  }

  void setCopy() {
    isCopy = true;

    debugPrint('isCopy  $isCopy');
    notifyListeners();
  }

  void setUnKey(int val) {
    unKey = val;

    debugPrint('unKey  $unKey');
    notifyListeners();
  }

  void setMove() {
    isCopy = false;

    debugPrint('isCopy  $isCopy');
    notifyListeners();
  }

  void copyFile() {
    Set<String> selectedImages = {};
    String destinationDirectory = '';

    if (unKey == 0) {
      destinationDirectory = currentDirectory[1];
      selectedImages = selectedImages0;
    } else {
      destinationDirectory = currentDirectory[0];
      selectedImages = selectedImages1;
    }

    if (selectedImages.isNotEmpty) {
      for (String filePath in selectedImages) {
        File sourceFile = File(filePath);

        if (sourceFile.existsSync()) {
          File targetFile = File(destinationDirectory +
              Platform.pathSeparator +
              sourceFile.path.split(Platform.pathSeparator).last);
          sourceFile.copySync(targetFile.path);
        }
      }
    }
    if (unKey == 0) {
      selectedImages0.clear();
    } else {
      selectedImages1.clear();
    }

    updatedDir();
  }

  void moveFile() {
    Set<String> selectedImages = {};
    String destinationDirectory = '';

    if (unKey == 0) {
      destinationDirectory = currentDirectory[1];
      selectedImages = selectedImages0;
    } else {
      destinationDirectory = currentDirectory[0];
      selectedImages = selectedImages1;
    }

    if (selectedImages.isNotEmpty) {
      for (String filePath in selectedImages) {
        File sourceFile = File(filePath);

        if (sourceFile.existsSync()) {
          File targetFile = File(destinationDirectory +
              Platform.pathSeparator +
              sourceFile.path.split(Platform.pathSeparator).last);
          sourceFile.copySync(targetFile.path);
          sourceFile.deleteSync();
        }
      }
    }
    if (unKey == 0) {
      selectedImages0.clear();
    } else {
      selectedImages1.clear();
    }

    updatedDir();
  }

  void delFile() {
    Set<String> selectedImages = {};
    String destinationDirectory = '';

    if (unKey == 0) {
      destinationDirectory = currentDirectory[1];
      selectedImages = selectedImages0;
    } else {
      destinationDirectory = currentDirectory[0];
      selectedImages = selectedImages1;
    }

    if (selectedImages.isNotEmpty) {
      for (String filePath in selectedImages) {
        File sourceFile = File(filePath);

        if (sourceFile.existsSync()) {
          sourceFile.deleteSync();
        }
      }
    }
    if (unKey == 0) {
      selectedImages0.clear();
    } else {
      selectedImages1.clear();
    }

    updatedDir();
  }
}
