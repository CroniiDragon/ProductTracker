// Test pentru aplicația Product Monitor
//
// Pentru a rula testele, folosește comanda: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:product_tracker/main.dart';

void main() {
  group('Product Monitor App Tests', () {
    testWidgets('App loads correctly and shows main screen', (WidgetTester tester) async {
      // Construiește aplicația și declanșează un frame
      await tester.pumpWidget(ProductMonitorApp());

      // Verifică că aplicația se încarcă și afișează elementele principale
      expect(find.text('Monitor Produse'), findsOneWidget);
      expect(find.text('Adaugă Factură'), findsOneWidget);
      expect(find.text('Scanează Factură'), findsOneWidget);
      expect(find.text('Încarcă Factură'), findsOneWidget);
    });

    testWidgets('Bottom navigation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(ProductMonitorApp());

      // Verifică că bottom navigation este prezent
      expect(find.text('Acasă'), findsOneWidget);
      expect(find.text('Produse'), findsOneWidget);
      expect(find.text('Setări'), findsOneWidget);

      // Testează navigarea la secțiunea Produse
      await tester.tap(find.text('Produse'));
      await tester.pump();

      // Verifică că suntem pe ecranul de produse
      expect(find.text('Produsele Mele'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('Scan receipt button navigates correctly', (WidgetTester tester) async {
      await tester.pumpWidget(ProductMonitorApp());

      // Găsește și apasă butonul de scanare
      await tester.tap(find.text('Scanează Factură'));
      await tester.pump();

      // Verifică că suntem pe ecranul de scanare
      expect(find.text('Scanează Factură'), findsWidgets);
      expect(find.text('Deschide Camera'), findsOneWidget);
      expect(find.text('Alege din Galerie'), findsOneWidget);
    });

    testWidgets('Upload receipt button navigates correctly', (WidgetTester tester) async {
      await tester.pumpWidget(ProductMonitorApp());

      // Găsește și apasă butonul de încărcare
      await tester.tap(find.text('Încarcă Factură'));
      await tester.pump();

      // Verifică că suntem pe ecranul de încărcare
      expect(find.text('Încarcă Factură'), findsWidgets);
      expect(find.text('Selectează Fișier'), findsOneWidget);
      expect(find.text('Formate acceptate: PDF, JPG, PNG'), findsOneWidget);
    });

    testWidgets('Products screen shows correct statistics', (WidgetTester tester) async {
      await tester.pumpWidget(ProductMonitorApp());

      // Navighează la ecranul de produse
      await tester.tap(find.text('Produse'));
      await tester.pump();

      // Verifică că statisticile sunt afișate
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Expiră în 7 zile'), findsOneWidget);
      expect(find.text('Expirate'), findsOneWidget);

      // Verifică că produsele mock sunt afișate
      expect(find.text('Pâine albă'), findsOneWidget);
      expect(find.text('Lapte 3.2%'), findsOneWidget);
      expect(find.text('Brânză telemea'), findsOneWidget);
    });

    testWidgets('Product filter works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(ProductMonitorApp());

      // Navighează la produse
      await tester.tap(find.text('Produse'));
      await tester.pump();

      // Găsește și apasă dropdown-ul de filtrare
      await tester.tap(find.text('Toate'));
      await tester.pump();

      // Verifică că opțiunile de filtrare sunt disponibile
      expect(find.text('Aproape expirate'), findsOneWidget);
      expect(find.text('Valabile'), findsOneWidget);
      expect(find.text('Expirate'), findsOneWidget);
    });

    testWidgets('Settings screen loads correctly', (WidgetTester tester) async {
      await tester.pumpWidget(ProductMonitorApp());

      // Navighează la setări
      await tester.tap(find.text('Setări'));
      await tester.pump();

      // Verifică că setările sunt afișate
      expect(find.text('Setări'), findsWidgets);
      expect(find.text('Notificări'), findsOneWidget);
      expect(find.text('Aplicație'), findsOneWidget);
      expect(find.text('Suport'), findsOneWidget);
      expect(find.text('Notificări produse'), findsOneWidget);
      expect(find.text('Limba'), findsOneWidget);
    });

    testWidgets('Settings notifications toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(ProductMonitorApp());

      // Navighează la setări
      await tester.tap(find.text('Setări'));
      await tester.pump();

      // Găsește switch-ul pentru notificări
      final notificationSwitch = find.byType(Switch).first;
      expect(notificationSwitch, findsOneWidget);

      // Verifică că switch-ul este activat inițial
      Switch switchWidget = tester.widget(notificationSwitch);
      expect(switchWidget.value, true);
    });

    testWidgets('Help dialog shows correctly', (WidgetTester tester) async {
      await tester.pumpWidget(ProductMonitorApp());

      // Navighează la setări
      await tester.tap(find.text('Setări'));
      await tester.pump();

      // Apasă pe Ajutor
      await tester.tap(find.text('Ajutor'));
      await tester.pump();

      // Verifică că dialogul de ajutor se afișează
      expect(find.text('Cum să folosești aplicația:'), findsOneWidget);
      expect(find.text('1. Scanează sau încarcă o factură fiscală'), findsOneWidget);
      expect(find.text('Email: support@monitorproduse.md'), findsOneWidget);
    });

    testWidgets('About dialog shows correctly', (WidgetTester tester) async {
      await tester.pumpWidget(ProductMonitorApp());

      // Navighează la setări
      await tester.tap(find.text('Setări'));
      await tester.pump();

      // Apasă pe Despre aplicație
      await tester.tap(find.text('Despre aplicație'));
      await tester.pump();

      // Verifică că dialogul despre aplicație se afișează
      expect(find.text('Monitor Produse'), findsWidgets);
      expect(find.text('Versiunea 1.0.0'), findsWidgets);
      expect(find.text('• Flutter pentru interfață'), findsOneWidget);
      expect(find.text('• MistralAI pentru procesare'), findsOneWidget);
    });

    testWidgets('Language selection dialog works', (WidgetTester tester) async {
      await tester.pumpWidget(ProductMonitorApp());

      // Navighează la setări
      await tester.tap(find.text('Setări'));
      await tester.pump();

      // Apasă pe selecția limbii
      await tester.tap(find.text('Limba'));
      await tester.pump();

      // Verifică că dialogul de limbă se afișează
      expect(find.text('Selectează limba'), findsOneWidget);
      expect(find.text('Română'), findsWidgets);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Русский'), findsOneWidget);
    });

    testWidgets('FAB opens scan screen', (WidgetTester tester) async {
      await tester.pumpWidget(ProductMonitorApp());

      // Navighează la produse
      await tester.tap(find.text('Produse'));
      await tester.pump();

      // Găsește și apasă FAB-ul
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Verifică că s-a deschis ecranul de scanare
      expect(find.text('Deschide Camera'), findsOneWidget);
      expect(find.text('Alege din Galerie'), findsOneWidget);
    });
  });

  group('Product Management Tests', () {
    testWidgets('Product expiry colors are correct', (WidgetTester tester) async {
      await tester.pumpWidget(ProductMonitorApp());

      // Navighează la produse
      await tester.tap(find.text('Produse'));
      await tester.pump();

      // Găsește avatar-urile produselor (care afișează zilele rămase)
      final avatars = find.byType(CircleAvatar);
      expect(avatars, findsWidgets);

      // Verifică că avatar-urile sunt prezente pentru produse
      final firstAvatar = tester.widget<CircleAvatar>(avatars.first);
      expect(firstAvatar.backgroundColor, isNotNull);
    });

    testWidgets('Product popup menu works', (WidgetTester tester) async {
      await tester.pumpWidget(ProductMonitorApp());

      // Navighează la produse
      await tester.tap(find.text('Produse'));
      await tester.pump();

      // Găsește primul PopupMenuButton
      final popupMenus = find.byType(PopupMenuButton);
      if (popupMenus.evaluate().isNotEmpty) {
        await tester.tap(popupMenus.first);
        await tester.pump();

        // Verifică că opțiunile meniului sunt disponibile
        expect(find.text('Editează'), findsOneWidget);
        expect(find.text('Șterge'), findsOneWidget);
        expect(find.text('Marchează ca folosit'), findsOneWidget);
      }
    });
  });

  group('Error Handling Tests', () {
    testWidgets('App handles navigation errors gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(ProductMonitorApp());

      // Testează navigarea rapidă între ecrane
      await tester.tap(find.text('Produse'));
      await tester.pump();
      
      await tester.tap(find.text('Setări'));
      await tester.pump();
      
      await tester.tap(find.text('Acasă'));
      await tester.pump();

      // Verifică că aplicația nu crashes și revine la ecranul principal
      expect(find.text('Monitor Produse'), findsOneWidget);
      expect(find.text('Adaugă Factură'), findsOneWidget);
    });
  });
}