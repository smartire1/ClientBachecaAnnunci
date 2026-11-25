import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../models/job_application.dart';
import '../services/api_service.dart';
import 'application_detail_screen.dart';

class ApplicationListScreen extends StatefulWidget {
  const ApplicationListScreen({
    super.key,
    required this.jobOfferId,
    required this.session,
  });

  final int jobOfferId;
  final AuthSession session;

  @override
  State<ApplicationListScreen> createState() => _ApplicationListScreenState();
}

class _ApplicationListScreenState extends State<ApplicationListScreen> {
  final _api = ApiService();
  late Future<List<JobApplication>> _applications;

  @override
  void initState() {
    super.initState();
    _applications = _loadApplications();
  }

  Future<List<JobApplication>> _loadApplications() {
    return _api.getJobApplications(
      token: widget.session.token,
      jobOfferId: widget.jobOfferId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Candidature ricevute')),
      body: FutureBuilder<List<JobApplication>>(
        future: _applications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: () {
                  setState(() => _applications = _loadApplications());
                },
                child: const Text('Caricamento non riuscito. Riprova'),
              ),
            );
          }

          final applications = snapshot.data ?? [];
          if (applications.isEmpty) {
            return const Center(child: Text('Nessuna candidatura ricevuta.'));
          }

          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              return ListTile(
                title: Text('${application.firstName} ${application.lastName}'),
                subtitle: Text(application.email),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ApplicationDetailScreen(
                        application: application,
                        session: widget.session,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
