import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
          child: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(12.0),
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: ListView(
                children: [
                  const Text("定时备份时间"),
                  Padding(padding: EdgeInsets.only(top: 12.0, bottom: 12.0
                  
                  )
                  child: ListView(),
                  )
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}
