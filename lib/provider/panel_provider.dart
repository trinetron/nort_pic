import 'dart:io';

import 'package:flutter/material.dart';

class PanelProvider extends ChangeNotifier {
  int flgUpdatedMg = 0;
  List<String> currentDirectory = ["/", "/"];
  int unKey = 0;
  bool isCopy = false;
  Set<String> selectedImages0 = Set();
  Set<String> selectedImages1 = Set();

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
          File targetFile = File(
              destinationDirectory + '\\' + sourceFile.path.split('\\').last);
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
          File targetFile = File(
              destinationDirectory + '\\' + sourceFile.path.split('\\').last);
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
