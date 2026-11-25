import 'package:flutter/material.dart';

import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _api = ApiService();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    final email = _email.text.trim();
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await _api.register(
        name: _name.text,
        email: email,
        password: _password.text,
      );
      if (mounted) Navigator.of(context).pop(email);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = error is ApiException
            ? error.message
            : 'Registrazione non riuscita. Riprova.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registra azienda')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nome azienda'),
              enabled: !_submitting,
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'Inserisci il nome dell’azienda.'
                  : null,
            ),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              enabled: !_submitting,
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Inserisci l’email.' : null,
            ),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              enabled: !_submitting,
              validator: (value) =>
                  (value ?? '').length < 8 ? 'Usa almeno 8 caratteri.' : null,
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
              onPressed: _submitting ? null : _submit,
              child: Text(
                _submitting ? 'Registrazione in corso…' : 'Registrati',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
