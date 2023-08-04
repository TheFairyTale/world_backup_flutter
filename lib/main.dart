import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/widgets/ConfigJsonReadWidget.dart';
import 'package:path/path.dart' as path;

void main() {
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int currentPageIndex = 1;
  int _counter = 0;
  var streamController;
  // 获取StreamSink用于发射事件
  StreamSink<String> get streamSink => streamController.sink;
  // 获取Stream用于监听
  Stream<String> get streamData => streamController.stream;
  // 用于首页第一张卡片显示文件备份进度的动画控制器
  late AnimationController animationController;
  List<Widget> widgetsOfFiles = [];

  // todo 某些内容不应放在init 生命周期内
  @override
  void initState() {
    streamController = StreamController<String>();
    // Future(() {
    //   return zipEncoder();
    // }).then((value) {
    //   print("zip complete.");
    // }).whenComplete(() {
    //   print("已调用");
    // });

    /// [AnimationController]s can be created with `vsync: this` because of
    /// [TickerProviderStateMixin].
    // 备份文件卡片展示用进度控制器
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addListener(() {
            print("invoked");
            setState(() {});
          });
    setState(() {
      initFirstPageWidgets();
    });

    initScanDirectory();
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // widgetsOfFiles.add(Text(
    //   '$_counter',
    //   style: Theme.of(context).textTheme.headlineMedium,
    // ));
    // 主页
    Widget homePageWidget = Container(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: widgetsOfFiles,
      ),
    );
    // 第二页
    Widget secondPageWidget = Container(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: widgetsOfFiles,
      ),
    );
    // 第三页
    Widget thirdPageWidget = Container(
      child: Card(
        margin: const EdgeInsets.all(12.0),
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: ListView(
            children: [
              const Text("第3页"),
            ],
          ),
        ),
      ),
    );
    // 添加可被底部导航栏进行切换的Widget 页面
    List<Widget> pages = [homePageWidget, secondPageWidget, thirdPageWidget];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          print("selected.");

          setState(() {
            currentPageIndex = index;
          });

          print(currentPageIndex);
        },
        selectedIndex: currentPageIndex,
        // 下方的选择图标
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.explore),
            icon: Icon(Icons.explore_outlined),
            label: '备份计划',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.folder_zip),
            icon: Icon(Icons.folder_zip_outlined),
            label: '已保存',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: '设置',
          ),
        ],
      ),
      // BottomNavigationBar(items: const [
      //   BottomNavigationBarItem(
      //     icon: Icon(Icons.widgets),
      //     label: '首页',
      //   ),
      //   BottomNavigationBarItem(
      //     icon: Icon(Icons.settings),
      //     label: '设置',
      //   )
      // ]),

      // ListView(
      //   // mainAxisAlignment: MainAxisAlignment.center,
      //   children: widgetsOfFiles,
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  void updateWidgetListVarStatus(List<Widget> widgetList) {
    setState(() {
      widgetsOfFiles = widgetList;
      // widgetsOfFiles.add(ConfigJsonReadWidget());
    });
  }

  /// 扫描指定目录下的文件及文件夹
  void initScanDirectory() {
    String dirPath =
        "C:\\Users\\Administrator\\Documents\\Flutter\\world_backup_flutter";
    Directory dirObj = Directory(dirPath);
    List<Widget> widgets = [];

    doesDirectoryExists(dirObj).then((value) {
      if (value) {
        // 存在
        dirObj.list(recursive: true, followLinks: false).forEach((element) {
          // Stream<FileSystemEntity> filesInPath = dirObj.list(recursive: true, followLinks: false);
          // for (var element in filesInPath) {

          // }
          // .forEach((element) {

          if (element is File) {
            File eleFile = element;
            String fileExtension = path.extension(path.basename(eleFile.path));
            if (!fileExtension.contains('zip')) {
              // continue;
            }

            widgets.add(Card(
              margin: const EdgeInsets.all(12.0),
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(children: [
                          const Icon(Icons.folder_zip_outlined),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    child: Text(path.basename(eleFile.path)),
                                  ),
                                  SizedBox(
                                    child: Text(
                                      eleFile.path,
                                      style: const TextStyle(
                                          color: Colors.blueGrey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ])),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.open_in_new_off_outlined),
                            label: Text("打开文件"))
                      ],
                    )
                  ],
                ),
              ),
            ));
          }
        });
      }
    }).whenComplete(() {
      updateWidgetListVarStatus(widgets);
    });
  }

  /// 判断目录是否是有效的
  Future<bool> doesDirectoryExists(Directory dirObj) async {
    return dirObj.exists();
  }

  void initFirstPageWidgets() {
    widgetsOfFiles.add(Card(
        margin: const EdgeInsets.all(12.0),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            // mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Row(children: [
                  const Text("当前正在进行的任务:"),
                ]),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: LinearProgressIndicator(
                    value: animationController.value,
                    semanticsLabel: '压缩: temp.zip 文件',
                  ),
                ),
              ),
            ],
          ),
        )));
  }

  void zipEncoder() async {
    var zipFileEncoder = ZipFileEncoder();
    String dirPathString =
        "D:\\Users\\Administrator\\Downloads\\TheMinecraft\\.minecraft\\saves\\新的世界，崭新的生活！";
    if (!dirPathString.endsWith("\\")) {
      dirPathString += "\\";
    }
    print("Path -> " + dirPathString);
    zipFileEncoder.zipDirectory(Directory(dirPathString),
        level: Deflate.BEST_COMPRESSION,
        filename: 'D:\\Users\\Administrator\\Downloads\\out.zip');
  }

  /// 读取程序目录下的配置文件
  // Future<Map<String, dynamic>> getLocalJson(String jsonName) async {
  //   // Map<String, dynamic> map = jsonDecode(
  //   //     await rootBundle.loadString("assets/json/" + jsonName + ".json"));
  //   json
  //   return map;
  // }
}
