import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:job_board_client/main.dart';
import 'package:job_board_client/models/auth_session.dart';
import 'package:job_board_client/screens/login_screen.dart';

void main() {
  testWidgets('mostra la bacheca', (tester) async {
    await tester.pumpWidget(const JobBoardApp());

    expect(find.text('Bacheca annunci'), findsOneWidget);
  });

  testWidgets('solo Esci riporta alla bacheca dall’area aziendale', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await tester.pumpWidget(const JobBoardApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Area azienda'));
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byType(LoginScreen))).pop(
        const AuthSession(
          token: 'test',
          companyId: 1,
          companyName: 'Azienda Test',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BackButton), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Azienda Test'), findsOneWidget);

      await tester.tap(find.text('Esci'));
      await tester.pumpAndSettle();
      expect(find.text('Bacheca annunci'), findsOneWidget);
      await tester.tap(find.text('Area azienda'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    }, () => MockClient((_) async => http.Response('[]', 200)));
  });
}
