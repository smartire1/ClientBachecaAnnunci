import 'package:flutter/material.dart';

import '../services/api_service.dart';

class CreateJobOfferScreen extends StatefulWidget {
  const CreateJobOfferScreen({super.key, required this.token});

  final String token;

  @override
  State<CreateJobOfferScreen> createState() => _CreateJobOfferScreenState();
}

class _CreateJobOfferScreenState extends State<CreateJobOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _api = ApiService();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final offer = await _api.createJobOffer(
        token: widget.token,
        title: _title.text,
        description: _description.text,
      );
      if (mounted) Navigator.of(context).pop(offer);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = error is ApiException
            ? error.message
            : 'Pubblicazione non riuscita. Riprova.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuovo annuncio')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Titolo'),
              enabled: !_submitting,
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Inserisci il titolo.' : null,
            ),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Descrizione'),
              minLines: 3,
              maxLines: 6,
              enabled: !_submitting,
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'Inserisci la descrizione.'
                  : null,
            ),
            if (_error case final error?) ...[
              const SizedBox(height: 12),
              Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitting ? null : _publish,
              child: Text(_submitting ? 'Pubblicazione in corso…' : 'Pubblica'),
            ),
          ],
        ),
      ),
    );
  }
}
