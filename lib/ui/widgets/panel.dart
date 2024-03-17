import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nort_pic/models/languages/translat_locale_keys.g.dart';
import 'package:nort_pic/provider/panel_provider.dart';
import 'package:nort_pic/provider/permissions_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:disposable_cached_images/disposable_cached_images.dart';

class Panel extends StatefulWidget {
  int unkey;
  Panel({required this.unkey});
  @override
  _PanelState createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  late List<String> directoryStack;
  late String currentDirectory;

  void openFolder(String folderPath) {
    setState(() {
      context
          .read<PanelProvider>()
          .setCurrentDirectory(nomPanel: widget.unkey, fPath: folderPath);
      directoryStack.add(folderPath);
      context.read<PanelProvider>().updatedDir();
    });
  }

  void goBack() {
    if (directoryStack.length > 1) {
      setState(() {
        directoryStack.removeLast();
        context.read<PanelProvider>().setCurrentDirectory(
            nomPanel: widget.unkey, fPath: directoryStack.last);

        context.read<PanelProvider>().updatedDir();
      });
    }
  }

  List<String> getSubFolders(String parentFolder) {
    List<String> subFolders = [];
    Directory directory = Directory(parentFolder);
    List<FileSystemEntity> entities = directory.listSync();

    for (FileSystemEntity entity in entities) {
      if (entity is Directory) {
        subFolders.add(entity.path);
      }
    }

    return subFolders;
  }

  List<String> getLastSubFolder(String parentFolder) {
    List<String> lastSubFolder = [];
    Directory directory = Directory(parentFolder);
    List<FileSystemEntity> entities = directory.listSync();

    for (FileSystemEntity entity in entities) {
      if (entity is Directory) {
        lastSubFolder.add(entity.path.split(Platform.pathSeparator).last);
      }
    }

    return lastSubFolder;
  }

  void moveFile(String sourcePath, String targetPath) {
    File sourceFile = File(sourcePath);
    if (sourceFile.existsSync()) {
      File targetFile = File(targetPath +
          Platform.pathSeparator +
          sourceFile.path.split(Platform.pathSeparator).last);
      sourceFile.copySync(targetFile.path);
      sourceFile.deleteSync();
      context.read<PanelProvider>().updatedDir();
    }
  }

  void copyFile(String sourcePath, String targetPath) {
    File sourceFile = File(sourcePath);
    // Set<String> selectedImages = {};

    if (sourceFile.existsSync()) {
      File targetFile = File(targetPath +
          Platform.pathSeparator +
          sourceFile.path.split(Platform.pathSeparator).last);
      sourceFile.copySync(targetFile.path);
      context.read<PanelProvider>().updatedDir();
    }
  }

  @override
  Widget build(BuildContext context) {
    directoryStack = context.watch<PanelProvider>().startDirectory;
    currentDirectory =
        context.watch<PanelProvider>().currentDirectory[widget.unkey];
    List<String> subFolders = getSubFolders(
        context.watch<PanelProvider>().currentDirectory[widget.unkey]);

    List<String> lastSubFolder = getLastSubFolder(
        context.watch<PanelProvider>().currentDirectory[widget.unkey]);

    //int unkey = context.watch<PanelProvider>().unKeyCnt + 1;

    if (widget.unkey == 0) {
      //левая панелька
      return Scaffold(
        body: Container(
          color: Color.fromARGB(255, 145, 189, 248),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                Expanded(
                  child: FileExplorer(
                    currentDirectory: context
                        .watch<PanelProvider>()
                        .currentDirectory[widget.unkey],
                    subFolders: subFolders,
                    lastSubFolder: lastSubFolder,
                    onSelectFolder: openFolder,
                    onNavigateUp: goBack,
                    onMoveFile: moveFile,
                    onCopyFile: copyFile,
                  ),
                ),
                Expanded(
                    child: MediaGallery(
                  currentDirectory: context
                      .watch<PanelProvider>()
                      .currentDirectory[widget.unkey],
                  uniqueKey: widget.unkey, // Уникальный ключ
                  moveFile: moveFile,
                  copyFile: copyFile,
                )),
              ],
            ),
          ),
        ),
      );
    } else {
      //правая панелька
      return Scaffold(
        body: Container(
          color: Color.fromARGB(255, 145, 189, 248),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                Expanded(
                    child: MediaGallery(
                  currentDirectory: context
                      .watch<PanelProvider>()
                      .currentDirectory[widget.unkey],
                  uniqueKey: widget.unkey, // Уникальный ключ
                  moveFile: moveFile,
                  copyFile: copyFile,
                )),
                Expanded(
                  child: FileExplorer(
                    currentDirectory: context
                        .watch<PanelProvider>()
                        .currentDirectory[widget.unkey],
                    subFolders: subFolders,
                    lastSubFolder: lastSubFolder,
                    onSelectFolder: openFolder,
                    onNavigateUp: goBack,
                    onMoveFile: moveFile,
                    onCopyFile: copyFile,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class FileExplorer extends StatefulWidget {
  final String currentDirectory;
  final List<String> subFolders;
  final List<String> lastSubFolder;
  final Function(String) onSelectFolder;
  final Function() onNavigateUp;
  final Function(String, String) onMoveFile;
  final Function(String, String) onCopyFile;

  FileExplorer({
    required this.currentDirectory,
    required this.subFolders,
    required this.lastSubFolder,
    required this.onSelectFolder,
    required this.onNavigateUp,
    required this.onMoveFile,
    required this.onCopyFile,
  });

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  void crtNewFld(String nmFld) {
    String folderName = nmFld;
    // Здесь логика создания новой папки
    String newPath =
        widget.currentDirectory + Platform.pathSeparator + '$folderName';

    Directory newDirectory = Directory(newPath);
    newDirectory.createSync(recursive: true); // Создаем новую папку
    setState(() {});
    context.read<PanelProvider>().updatedDir();
  }

  void _createNewFolderDialog(BuildContext context) {
    TextEditingController folderNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Создать новую папку'),
          content: TextField(
            controller: folderNameController,
            decoration: InputDecoration(hintText: 'Введите название папки'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                crtNewFld(folderNameController.text);
                Navigator.of(context).pop();
              },
              child: Text('Создать'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Color.fromARGB(255, 145, 189, 248),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.currentDirectory,
              style: const TextStyle(
                color: Color.fromARGB(255, 2, 13, 167),
                fontFamily: 'go',
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          color: Color.fromARGB(255, 2, 13, 167),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: TextButton(
                onPressed: widget.onNavigateUp,
                child: const Text(
                  '...',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 145, 189, 248),
                    fontFamily: 'go',
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Color.fromARGB(255, 2, 13, 167),
            child: ListView.builder(
                itemCount: widget.subFolders.length +
                    1, // Added +1 for "New Folder" button
                itemBuilder: (context, index) {
                  if (index == widget.subFolders.length) {
                    return ListTile(
                      title: Text(
                        'Новая папка',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 145, 189, 248),
                          fontFamily: 'go',
                        ),
                      ),
                      onTap: () {
                        _createNewFolderDialog(context);
                      },
                      leading: Icon(Icons.create_new_folder,
                          color: Colors.white), // Icon for "New Folder"
                    );
                  } else {
                    return ListTile(
                      title: Text(
                        widget.lastSubFolder[index],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 145, 189, 248),
                          fontFamily: 'go',
                        ),
                      ),
                      onTap: () {
                        widget.onSelectFolder(widget.subFolders[index]);
                      },
                    );
                  }
                }),
          ),
        ),
      ],
    );
  }
}

class MediaGallery extends StatefulWidget {
  final String currentDirectory;
  final int uniqueKey;
  final Function(String, String) moveFile;
  final Function(String, String) copyFile;

  MediaGallery(
      {required this.currentDirectory,
      required this.uniqueKey,
      required this.moveFile,
      required this.copyFile,
      Key? key})
      : super(key: key);

  @override
  MediaGalleryState createState() => MediaGalleryState();
}

class MediaGalleryState extends State<MediaGallery> {
  List<String> mediaFiles = [];
  Set<String> selectedImages = {};

  void toggleImageSelection(String imagePath) {
    setState(() {
      if (selectedImages.contains(imagePath)) {
        selectedImages.remove(imagePath);
      } else {
        selectedImages.add(imagePath);
      }
    });
    print(selectedImages);
  }

  bool isImageSelected(String imagePath) {
    return selectedImages.contains(imagePath);
  }

  void readMediaFiles() {
    mediaFiles.clear();
    Directory directory = Directory(widget.currentDirectory);
    List<FileSystemEntity> files = directory.listSync();

    for (FileSystemEntity file in files) {
      if (file is File &&
          (file.path.endsWith('.jpg') ||
              file.path.endsWith('.JPG') ||
              file.path.endsWith('.JPEG') ||
              file.path.endsWith('.PNG') ||
              file.path.endsWith('.png') ||
              file.path.endsWith('.GIF') ||
              file.path.endsWith('.gif') ||
              file.path.endsWith('.BMP') ||
              file.path.endsWith('.bmp') ||
              file.path.endsWith('.WebP') ||
              file.path.endsWith('.WBMP') ||
              file.path.endsWith('.Jpg'))) {
        mediaFiles.add(file.path);
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    readMediaFiles();
  }

  @override
  void didUpdateWidget(covariant MediaGallery oldWidget) {
    // if (widget.uniqueKey != oldWidget.uniqueKey ||
    //     widget.currentDirectory != oldWidget.currentDirectory) {
    // Обновляем только если уникальный ключ или директория изменились
    readMediaFiles();
    // }
    // context.read<PanelProvider>().updatedDir();
    super.didUpdateWidget(oldWidget);
  }

  void toggleImage(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FullScreenImage(imagePath: imagePath)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.uniqueKey == 0) {
      selectedImages = context.watch<PanelProvider>().selectedImages0;
    } else {
      selectedImages = context.watch<PanelProvider>().selectedImages1;
    }

    return Container(
      color: Color.fromARGB(255, 2, 13, 167),
      child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 0.0,
              mainAxisSpacing: 0.0,
            ),
            itemCount: mediaFiles.length,
            itemBuilder: (context, index) {
              String imagePath = mediaFiles[index];
              return GestureDetector(
                onTap: () {
                  toggleImageSelection(imagePath);
                  context.read<PanelProvider>().setUnKey(widget.uniqueKey);
                },
                onLongPress: () {
                  toggleImage(mediaFiles[index]);
                },
                onDoubleTap: () {
                  final String dir0 =
                      context.read<PanelProvider>().currentDirectory[0];
                  final String dir1 =
                      context.read<PanelProvider>().currentDirectory[1];

                  if (dir0 != dir1) {
                    if (widget.uniqueKey == 0) {
                      context.read<PanelProvider>().isCopy
                          ? widget.copyFile(mediaFiles[index], dir1)
                          : widget.moveFile(mediaFiles[index], dir1);
                    } else {
                      context.read<PanelProvider>().isCopy
                          ? widget.copyFile(mediaFiles[index], dir0)
                          : widget.moveFile(mediaFiles[index], dir0);
                    }
                    context.read<PanelProvider>().updatedDir();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isImageSelected(imagePath)
                          ? Colors.red
                          : Colors.transparent,
                      width: 4.0,
                    ),
                  ),
                  child: DisposableCachedImage.local(
                    imagePath: imagePath,
                    resizeImage: true,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          )),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imagePath;

  FullScreenImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 145, 189, 248),
          title: Text(
            imagePath,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 2, 13, 167),
              fontFamily: 'go',
            ),
          ),
        ),
        body: Container(
          color: Color.fromARGB(255, 2, 13, 167),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                  minWidth: MediaQuery.of(context).size.width,
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9, // пропорции
                  child: InteractiveViewer(
                    child: Image.file(File(imagePath)),
                    boundaryMargin: EdgeInsets.all(20.0),
                    minScale: 0.1,
                    maxScale: 23.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
