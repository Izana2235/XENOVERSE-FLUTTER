import 'package:flutter/material.dart';

import 'mobile_scaffold.dart';
import 'desktop_scaffold.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // < 600px: pure mobile layout with drawer
        if (constraints.maxWidth < 600) {
          return const MobileScaffold();
        }

        // >= 600px: use desktop scaffold, which will internally
        // adapt its grid columns based on available width so it
        // still looks good on tablets and large screens.
        return const DesktopScaffold();
      },
    );
  }
}
