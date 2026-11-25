import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key, required this.jobOfferId});

  final int jobOfferId;

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _apiService = ApiService();
  String? _curriculumPath;
  String? _curriculumName;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;

    final path = _curriculumPath;
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona un curriculum PDF.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _apiService.applyToJob(
        jobOfferId: widget.jobOfferId,
        firstName: _firstName.text,
        lastName: _lastName.text,
        email: _email.text,
        curriculumPath: path,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Candidatura inviata.')));
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is ApiException
                ? error.message
                : 'Invio non riuscito. Riprova.',
          ),
        ),
      );
    }
  }

  Future<void> _pickCurriculum() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (!mounted || file == null) return;

    final path = file.path;
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossibile leggere il PDF selezionato.'),
        ),
      );
      return;
    }

    setState(() {
      _curriculumPath = path;
      _curriculumName = file.name;
    });
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Candidatura')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _firstName,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Inserisci il nome.' : null,
            ),
            TextFormField(
              controller: _lastName,
              decoration: const InputDecoration(labelText: 'Cognome'),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Inserisci il cognome.' : null,
            ),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Inserisci l’email.' : null,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _isSubmitting ? null : _pickCurriculum,
              child: Text(_curriculumName ?? 'Scegli PDF'),
            ),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: Text(
                _isSubmitting ? 'Invio in corso…' : 'Invia candidatura',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
