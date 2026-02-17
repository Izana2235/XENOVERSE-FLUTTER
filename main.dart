import 'package:firstapp/responsive/desktop_scaffold.dart';
import 'package:firstapp/responsive/mobile_scaffold.dart';
import 'package:firstapp/responsive/tablet_scaffold.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XENOVERSE',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1D2634),
        fontFamily: 'Montserrat',
      ),
      home: const ResponsiveLayout(),
    );
  }
}

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
