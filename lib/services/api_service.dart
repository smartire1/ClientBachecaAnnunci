import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/auth_session.dart';
import '../models/job_application.dart';
import '../models/job_offer.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;
}

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5153',
  );

  Future<List<JobOffer>> getJobOffers() async {
    final uri = Uri.parse('$baseUrl/api/job-offers');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw const ApiException('Impossibile recuperare gli annunci.');
    }

    return _decodeJobOffers(response);
  }

  List<JobOffer> _decodeJobOffers(http.Response response) {
    final items = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return items
        .map((json) => JobOffer.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );

    switch (response.statusCode) {
      case 201:
        return;
      case 409:
        throw const ApiException('Email già in uso.');
      case 400:
        throw const ApiException('Dati di registrazione non validi.');
      default:
        throw const ApiException('Impossibile registrarsi.');
    }
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    switch (response.statusCode) {
      case 200:
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        return AuthSession.fromJson(json as Map<String, dynamic>);
      case 401:
        throw const ApiException('Email o password non valide.');
      case 400:
        throw const ApiException('Controlla i dati inseriti.');
      default:
        throw const ApiException('Accesso non riuscito.');
    }
  }

  Future<List<JobOffer>> getMyJobOffers(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/job-offers/mine'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw const ApiException('Impossibile caricare i tuoi annunci.');
    }
    return _decodeJobOffers(response);
  }

  Future<JobOffer> createJobOffer({
    required String token,
    required String title,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/job-offers'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title.trim(),
        'description': description.trim(),
      }),
    );
    switch (response.statusCode) {
      case 201:
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        return JobOffer.fromJson(json as Map<String, dynamic>);
      case 400:
        throw const ApiException('Controlla titolo e descrizione.');
      case 401:
        throw const ApiException('Sessione scaduta. Accedi di nuovo.');
      default:
        throw const ApiException('Pubblicazione non riuscita.');
    }
  }

  Future<void> applyToJob({
    required int jobOfferId,
    required String firstName,
    required String lastName,
    required String email,
    required String curriculumPath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/job-offers/$jobOfferId/applications'),
    );

    request.fields['firstName'] = firstName.trim();
    request.fields['lastName'] = lastName.trim();
    request.fields['email'] = email.trim();
    request.files.add(
      await http.MultipartFile.fromPath('curriculum', curriculumPath),
    );
    final response = await http.Response.fromStream(await request.send());
    switch (response.statusCode) {
      case 201:
        return;
      case 400:
        throw const ApiException('Controlla i dati e il PDF (massimo 5 MB).');
      case 404:
        throw const ApiException('Annuncio non trovato.');
      default:
        throw const ApiException('Candidatura non riuscita.');
    }
  }

  Future<List<JobApplication>> getJobApplications({
    required String token,
    required int jobOfferId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/job-offers/$jobOfferId/applications'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw const ApiException('Impossibile caricare le candidature.');
    }
    final items = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return items
        .map((item) => JobApplication.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Uint8List> downloadCurriculum({
    required int applicationId,
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/applications/$applicationId/cv'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw const ApiException('Impossibile scaricare il curriculum.');
    }

    return response.bodyBytes;
  }
}
