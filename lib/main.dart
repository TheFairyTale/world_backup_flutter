import 'dart:async';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/models/file_entity.dart';
import 'package:flutter_demo/service/timer_clock_isolate.dart';
import 'package:flutter_demo/utils/file_operator_util.dart';
import 'package:flutter_demo/utils/list_view_item_builder.dart';
import 'package:flutter_demo/widgets/setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
                      onPressed: openDrawer, child: const Text('Open Drawer'))
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
