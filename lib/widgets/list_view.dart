import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListViewWidget extends StatefulWidget {
  const ListViewWidget({super.key});

  @override
  State<ListViewWidget> createState() => _ListViewWidgetState();
}

class _ListViewWidgetState extends State<ListViewWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) {
          return;
        },
        separatorBuilder: (context, index) {
          return Divider(height: 10);
        },
        itemCount: 80);
  }
}
