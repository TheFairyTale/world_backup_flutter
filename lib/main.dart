import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:async_zip/async_zip.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/models/file_entity.dart';
import 'package:flutter_demo/service/timer_clock_isolate.dart';
import 'package:flutter_demo/utils/datetime_util.dart';
import 'package:flutter_demo/utils/file_operator_util.dart';
import 'package:flutter_demo/utils/list_view_item_builder.dart';
import 'package:flutter_demo/widgets/setting_page.dart';
import 'package:isolate_manager/isolate_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:path/path.dart' as path;

// import 'package:pretty_qr_code_example/features/io_save_image.dart'
//     if (dart.library.html) 'package:pretty_qr_code_example/features/web_save_image.dart';

void main() {
  // 启用log，否则调用其他log 语句不会生效
  LogUtil.init(tag: "Main", isDebug: true, maxLen: 999999);
  // 启用子线程（初始化）
  TimerClockIsolate();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        // "backup_datetime_picker": (context) => BackupDateTimeSettingRoute()
      },
      // home: const HttpTestRoute(),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String? backupPathString;

  @protected
  late QrCode qrCode;

  @protected
  late QrImage qrImage;

  @protected
  late PrettyQrDecoration decoration;

  int screenIndex = 0;
  late bool showNavigationDrawer;

  void handleScreenChanged(int selectedScreen) {
    setState(() {
      screenIndex = selectedScreen;
    });
  }

  void openDrawer() {
    scaffoldKey.currentState!.openEndDrawer();
  }

  /// 利用MediaQuery 实现简易响应式布局
  ///
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showNavigationDrawer = MediaQuery.of(context).size.width >= 450;
  }

  @override
  void initState() {
    super.initState();

    // final SharedPreferences prefs = await _prefs;
    // backupPathString = prefs.getString('world_path');

    qrCode = QrCode.fromData(
      data:
          'http://52861.hlwyy.9yiban.com/blb1/api/spay?&A=S-410100-52861&B=10002356&C=姓名&D=9',
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );

    qrImage = QrImage(qrCode);

    decoration = const PrettyQrDecoration(
      shape: PrettyQrSmoothSymbol(
        color: Color(0xFF74565F),
      ),
      // 二维码中心所显示的图标
      image: PrettyQrDecorationImage(
        image: AssetImage('images/pub-dev-logo.png'),
        position: PrettyQrDecorationImagePosition.embedded,
      ),
    );
  }

  Widget buildBottomBarScaffold() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('Page Index = $screenIndex'),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: destinations.map((e) {
          return NavigationDestination(
            icon: e.icon,
            selectedIcon: e.selectedIcon,
            label: e.label,
            tooltip: e.label,
          );
        }).toList(),
        selectedIndex: screenIndex,
        onDestinationSelected: (value) {
          setState(() {
            screenIndex = value;
          });
        },
      ),
    );
  }

  Widget buildDrawerScaffold(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
          bottom: false,
          top: false,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: NavigationRail(
                  destinations: destinations.map((e) {
                    return NavigationRailDestination(
                        icon: e.icon,
                        label: Text(e.label),
                        selectedIcon: e.selectedIcon);
                  }).toList(),
                  selectedIndex: screenIndex,
                  useIndicator: true,
                  onDestinationSelected: (value) {
                    setState(() {
                      screenIndex = value;
                    });
                  },
                ),
              ),
              const VerticalDivider(
                thickness: 1.0,
                width: 1.0,
              ),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('Page Index = $screenIndex'),
                  ElevatedButton(
                      onPressed: openDrawer, child: const Text('Open Drawer')),
                  SizedBox(
                    width: 128,
                    height: 128,
                    child: PrettyQrView(
                      qrImage: qrImage,
                      decoration: decoration,
                    ),
                  ),
                  Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const ListTile(
                          leading: Icon(Icons.album),
                          title: Text('立即开始备份'),
                          // subtitle: Text(
                          //     'Music by Julie Gable. Lyrics by Sidney Stein.'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TextButton(
                              child: const Text('备份已配置的目录文件'),
                              onPressed: () async {
                                final SharedPreferences prefs = await _prefs;
                                backupPathString =
                                    prefs.getString('world_path');
                                if (backupPathString == null) {
                                  print('BackupPath is null');
                                  return;
                                }

                                print('starting...');
                                TimerClockIsolate.sendBackupCommandToSubtask(
                                    backupPathString!);
                              },
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              child: const Text('选择存档目录位置'),
                              onPressed: () async {
                                // 选择文件所在目录位置
                                String? selectedDirectory = await FilePicker
                                    .platform
                                    .getDirectoryPath();

                                if (selectedDirectory == null) {
                                  // User canceled the picker
                                  return;
                                }

                                final SharedPreferences prefs = await _prefs;
                                await prefs.setString(
                                    'world_path', selectedDirectory);
                                print(selectedDirectory);
                              },
                            ),
                            const SizedBox(width: 8),
                            FutureLoopTestPage(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ))
            ],
          )),
      endDrawer: NavigationDrawer(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(
              'Header',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ...destinations.map((e) {
            return NavigationDrawerDestination(
              icon: e.icon,
              label: Text(e.label),
              selectedIcon: e.selectedIcon,
            );
          }),
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
            child: Divider(),
          )
        ],
        onDestinationSelected: handleScreenChanged,
        selectedIndex: screenIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return showNavigationDrawer
        ? buildDrawerScaffold(context)
        : buildBottomBarScaffold();
  }
}

class DrawerDestination {
  const DrawerDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final Widget icon;
  final Widget selectedIcon;
}

const List<DrawerDestination> destinations = <DrawerDestination>[
  DrawerDestination('首页', Icon(Icons.widgets_outlined), Icon(Icons.widgets)),
  DrawerDestination('备份历史', Icon(Icons.history_outlined), Icon(Icons.history)),
  DrawerDestination('设置', Icon(Icons.settings_outlined), Icon(Icons.settings)),
];

class FutureLoopTestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FutureLoopTestPageState();
}

class _FutureLoopTestPageState extends State<FutureLoopTestPage> {
  late Timer _timer;
  late Timer _progressChecker;
  double? i = 0;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      // 具体的定时任务...
      i = null;
      print('开始执行定时任务... ' + i.toString());
      setState(() {});
      // if (i == 100.0) {
      //   i = 0.0;
      // }

      bool _isCompleted = false;
      final isolateFetchAndDecode = IsolateManager.create(
        _createZipFile, // Function you want to compute
        concurrent: 1, // Number of concurrent isolates. Default is 1
      );
      var computeIsolate = isolateFetchAndDecode.compute("D:\\电测听");
      computeIsolate.then((value) {
        print('压缩任务执行成功');
        // 当执行完毕后
        _isCompleted = true;
      }).whenComplete(() {
        print('任务执行完毕');
        _progressChecker = Timer.periodic(Duration(seconds: 1), (timer) async {
          print('正在检查执行情况');
          // 每一秒检查一次执行情况
          if (_isCompleted) {
            print('执行成功！');
            await isolateFetchAndDecode.stop();
            setState(() {
              i = 100;
            });
            _progressChecker.cancel();
          }
          setState(() {
            i = null;
          });
        });
      });

      print('定时任务执行完毕');
    });
  }

  @override
  void dispose() {
    // 取消定时器
    _timer.cancel();
    _progressChecker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // 圆形进度
            CircularProgressIndicator(
              value: i == null ? null : i! / 100,
            ),
            Text('-> ' + i.toString())
          ],
        )
      ],
    );
  }

  static void _createZipFile(String backupPath) async {
    print('备份正在执行');
    int _backupFileCount = 0;
    // Save bundled files to temporary directory in order to write
    // them to the Zip file. This is just for illustration purposes.
    final tempDir = Directory.systemTemp;
    // todo 自定义输出目录
    print("文件输出地址：" + tempDir.path);
    // todo 自定义时间与后缀间的名称
    final archiveFile = File(path.join(
        tempDir.path, DateTimeUtil.writeDateTimeStr(0) + "_" + '.zip'));
    // todo 可配置的备份文件夹地址
    String worldpath = backupPath;
    print("backup level folder: " + worldpath);

    // Create the Zip file synchronously同步
    final writer = ZipFileWriterSync();
    await FileOperatorUtil.dirList(worldpath).then((files) {
      LogUtil.d("FileOperatorUtil.dirList(): " + files.toString());

      return files.toList();
    }).then((value) {
      List<FileSystemEntity> fileSystemEntitiesList = <FileSystemEntity>[];
      LogUtil.d(": " + value.length.toString());
      fileSystemEntitiesList = value;
      List<FileEntity> items = <FileEntity>[];

      try {
        for (var element in fileSystemEntitiesList) {
          String path = element.path;

          final file = File(path
              // .join(tempDir.path, 'image.jpg')
              );

          writer.create(archiveFile);
          writer.writeFile(
              element.path.substring(
                  element.path.lastIndexOf("/"), element.path.length),
              file);
          // writer.writeFile('data/person.json', jsonFile);

          // final textData = await rootBundle.loadString('assets/fox.txt');
          // writer.writeData('fox.txt', Uint8List.fromList(utf8.encode(textData)));

          // butterflyFile.readAsBytes()
          // await butterflyFile.writeAsBytes(butterflyData.buffer.asUint8List());
          _backupFileCount++;
        }
      } on ZipException catch (ex) {
        print('An error occurred while creating the Zip file: ${ex.message}');
      } finally {
        writer.close();
      }
    });
    // final jsonData = await rootBundle.load('assets/person.json');
    // final jsonFile = File(path.join(tempDir.path, 'person.json'));
    // await jsonFile.writeAsBytes(jsonData.buffer.asUint8List());

    print("Completed " + _backupFileCount.toString() + " files.");
    final archiveSize = archiveFile.lengthSync();
    print(
        'Created Zip file at ${archiveFile.path} with a size of $archiveSize bytes');
  }
}
