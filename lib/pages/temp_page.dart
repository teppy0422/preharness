// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:preharness/widgets/responsive_scaffold.dart';
import 'package:preharness/routes/app_routes.dart';

class TempPage extends StatelessWidget {
  const TempPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'temp',
      currentPage: AppRoutes.temp,
      child: Center(child: Text('作成前')),
    );
  }
}
