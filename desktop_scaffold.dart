import 'package:flutter/material.dart';
import 'mobile_scaffold.dart';

class DesktopScaffold extends StatelessWidget {
  const DesktopScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Row(
        children: [
          SizedBox(
            width: 260,
            child: buildDrawer(),
          ),
          Expanded(
            child: buildBody(4),
          ),
        ],
      ),
    );
  }
}
