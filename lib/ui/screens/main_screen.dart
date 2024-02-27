import 'package:flutter/material.dart';
import 'package:nort_pic/provider/panel_provider.dart';

import 'package:nort_pic/ui/widgets/panel.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    Key? key,
  }) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    bool _isCopy = context.watch<PanelProvider>().isCopy;
    return Stack(
      children: [
        Center(
          child: Container(
            color: Color.fromARGB(255, 2, 13, 167),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Panel(
                      unkey: 0,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Panel(
                      unkey: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(flex: 1, child: Container()),
            Column(
              children: [
                Expanded(flex: 4, child: Container()),
                Expanded(
                  flex: 1,
                  child: TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(
                              255, 177, 217, 250)), // Цвет текста иний)
                      overlayColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 0, 7, 100)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 1, 46,
                              83)), // Цвет при наведении // Цвет при наведении
                      side: MaterialStateProperty.all<BorderSide>(_isCopy
                          ? BorderSide(
                              width: 4.0,
                              color:
                                  Colors.yellow) // Желтая окантовка при нажатии
                          : BorderSide(width: 2.0, color: Colors.blue)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy),
                        Text('COPY'),
                      ],
                    ),
                    onPressed: () {
                      context.read<PanelProvider>().setCopy();
                      context.read<PanelProvider>().copyFile();
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(
                              255, 177, 217, 250)), // Цвет текста иний)
                      overlayColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 0, 7, 100)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 1, 46, 83)), // Цвет при наведении

                      side: MaterialStateProperty.all<BorderSide>(!_isCopy
                          ? BorderSide(
                              width: 4.0,
                              color:
                                  Colors.yellow) // Желтая окантовка при нажатии
                          : BorderSide(
                              width: 2.0,
                              color: Colors.blue)), // Оконтовка (голубой)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.move_up_outlined),
                        Text('MOVE'),
                      ],
                    ),
                    onPressed: () {
                      context.read<PanelProvider>().setMove();
                      // _createNewFolderDialog(context);
                    },
                  ),
                ),
                Expanded(flex: 3, child: Container()),
                Expanded(
                  flex: 1,
                  child: TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(
                              255, 177, 217, 250)), // Цвет текста иний)
                      overlayColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 148, 0, 0)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 1, 46, 83)), // Цвет при наведении
                      side: MaterialStateProperty.all<BorderSide>(BorderSide(
                          width: 2.0,
                          color: Colors.lightBlue)), // Оконтовка (голубой)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete),
                        Text('DEL'),
                      ],
                    ),
                    onPressed: () {
                      // _createNewFolderDialog(context);
                    },
                  ),
                ),
                Expanded(flex: 1, child: Container()),
              ],
            ),
            Expanded(flex: 1, child: Container()),
          ],
        ),
      ],
    );
  }
}
