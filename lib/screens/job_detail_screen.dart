import 'package:flutter/material.dart';

import '../models/job_offer.dart';
import 'application_form_screen.dart';

class JobDetailScreen extends StatelessWidget {
  final JobOffer jobOffer;

  const JobDetailScreen({super.key, required this.jobOffer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dettaglio annuncio')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            jobOffer.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            jobOffer.companyName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Text('Descrizione: ${jobOffer.description}'),
          const SizedBox(height: 8),
          Text(
            'Data di pubblicazione: '
            '${jobOffer.createdAt.toLocal().toString().split(' ')[0]}',
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ApplicationFormScreen(jobOfferId: jobOffer.id),
                ),
              );
            },
            child: const Text('Candidati'),
          ),
        ],
      ),
    );
  }
}
