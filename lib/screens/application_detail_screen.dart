import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../models/auth_session.dart';
import '../models/job_application.dart';
import '../services/api_service.dart';

class ApplicationDetailScreen extends StatelessWidget {
  const ApplicationDetailScreen({
    super.key,
    required this.application,
    required this.session,
  });

  final JobApplication application;
  final AuthSession session;

  Future<void> _openCurriculum(BuildContext context) async {
    try {
      final bytes = await ApiService().downloadCurriculum(
        applicationId: application.id,
        token: session.token,
      );
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/curriculum-${application.id}.pdf');
      await file.writeAsBytes(bytes);

      if (!context.mounted) return;
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        throw Exception('Apertura del file non riuscita.');
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aprire il curriculum.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dettaglio candidatura')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${application.firstName} ${application.lastName}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(application.email),
          const SizedBox(height: 24),
          Text('Curriculum: ${application.cvFileName}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _openCurriculum(context),
            child: const Text('Apri Curriculum'),
          ),
        ],
      ),
    );
  }
}
