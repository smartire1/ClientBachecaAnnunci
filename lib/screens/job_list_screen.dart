import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../models/job_offer.dart';
import '../services/api_service.dart';
import 'company_screen.dart';
import 'job_detail_screen.dart';
import 'login_screen.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<JobOffer>> _jobOffers;

  @override
  void initState() {
    super.initState();
    _jobOffers = _apiService.getJobOffers();
  }

  void _reload() {
    setState(() {
      _jobOffers = _apiService.getJobOffers();
    });
  }

  Future<void> _openCompanyArea() async {
    final session = await Navigator.of(
      context,
    ).push<AuthSession>(MaterialPageRoute(builder: (_) => const LoginScreen()));
    if (!mounted || session == null) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PopScope<void>(
          canPop: false,
          child: CompanyScreen(session: session),
        ),
      ),
    );
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bacheca annunci'),
        actions: [
          TextButton(
            onPressed: _openCompanyArea,
            child: const Text('Area azienda'),
          ),
        ],
      ),
      body: FutureBuilder<List<JobOffer>>(
        future: _jobOffers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Impossibile caricare gli annunci.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _reload,
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          final jobOffers = snapshot.data ?? [];

          if (jobOffers.isEmpty) {
            return const Center(child: Text('Non ci sono ancora annunci.'));
          }

          return ListView.separated(
            itemCount: jobOffers.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final jobOffer = jobOffers[index];

              return ListTile(
                title: Text(jobOffer.title),
                subtitle: Text(
                  '${jobOffer.companyName}\n${jobOffer.description}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => JobDetailScreen(jobOffer: jobOffer),
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
