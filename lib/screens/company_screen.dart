import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../models/job_offer.dart';
import '../services/api_service.dart';
import 'application_list_screen.dart';
import 'create_job_offer_screen.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key, required this.session});

  final AuthSession session;

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final _api = ApiService();
  late Future<List<JobOffer>> _offers;

  @override
  void initState() {
    super.initState();
    _offers = _api.getMyJobOffers(widget.session.token);
  }

  void _reload() {
    setState(() => _offers = _api.getMyJobOffers(widget.session.token));
  }

  Future<void> _createOffer() async {
    final created = await Navigator.of(context).push<JobOffer>(
      MaterialPageRoute(
        builder: (_) => CreateJobOfferScreen(token: widget.session.token),
      ),
    );
    if (!mounted || created == null) return;

    _reload();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Annuncio pubblicato.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.session.companyName),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Esci'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _createOffer,
              child: const Text('Nuovo annuncio'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<JobOffer>>(
              future: _offers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: TextButton(
                      onPressed: _reload,
                      child: const Text('Caricamento non riuscito. Riprova'),
                    ),
                  );
                }
                final offers = snapshot.data ?? [];
                if (offers.isEmpty) {
                  return const Center(
                    child: Text('Non hai ancora pubblicato annunci.'),
                  );
                }
                return ListView.builder(
                  itemCount: offers.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(offers[index].title),
                    subtitle: Text(offers[index].description),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ApplicationListScreen(
                            jobOfferId: offers[index].id,
                            session: widget.session,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
