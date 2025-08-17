import 'package:flutter/material.dart';
import 'package:preharness/services/local_db_service.dart';
import 'package:preharness/widgets/responsive_scaffold.dart';
import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:preharness/routes/app_routes.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'デバッグメニュー',
      currentPage: AppRoutes.debug,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DriftDbViewer(db),
                  ),
                );
              },
              child: const Text('データベースを閲覧'),
            ),
          ],
        ),
      ),
    );
  }
}
