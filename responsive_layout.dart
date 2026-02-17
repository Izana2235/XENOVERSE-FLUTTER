import 'package:flutter/material.dart';

import 'mobile_scaffold.dart';
import 'tablet_scaffold.dart';
import 'desktop_scaffold.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {

        if (constraints.maxWidth < 600) {
          return const MobileScaffold();
        } else if (constraints.maxWidth < 1100) {
          return const TabletScaffold();
        } else {
          return const DesktopScaffold();
        }

      },
    );
  }
}
