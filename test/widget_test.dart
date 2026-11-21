import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:notes_app_gestures/main.dart';

void main() {
  Widget createTestWidget() {
    return ChangeNotifierProvider(
      create: (_) => NotesProvider(),
      child: const NotesApp(),
    );
  }

  testWidgets('Начальное состояние и добавление новой заметки', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Проверяем наличие стартовых заметок
    expect(find.text('Заметки: Жесты и Provider'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(3));

    // Вводим новую заметку в поле TextField
    await tester.enterText(find.byType(TextField).first, 'Тестовая новая заметка');
    await tester.tap(find.text('Добавить'));
    await tester.pumpAndSettle();

    // Проверяем, что заметка добавилась первой в список
    expect(find.text('Тестовая новая заметка'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(4));
  });

  testWidgets('Обычное нажатие (onTap) открывает диалог просмотра', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Нажимаем на вторую карточку
    await tester.tap(find.byType(Card).at(1));
    // Ждем таймаут разрешения конфликта с onDoubleTap (из лекции)
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    // Проверяем, что открылся AlertDialog с просмотром
    expect(find.text('Просмотр заметки'), findsOneWidget);
    expect(find.text('Закрыть'), findsOneWidget);

    // Закрываем диалог
    await tester.tap(find.text('Закрыть'));
    await tester.pumpAndSettle();
    expect(find.text('Просмотр заметки'), findsNothing);
  });

  testWidgets('Двойное нажатие (onDoubleTap) делает заметку важной со звездой', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Выполняем двойной тап по второй карточке
    final target = find.byType(Card).at(1);
    await tester.tap(target);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(target);
    await tester.pumpAndSettle();

    // Проверяем появление SnackBar и отметки
    expect(find.text('Заметка отмечена как важная! ⭐'), findsOneWidget);
  });

  testWidgets('Долгое нажатие (onLongPress) открывает диалог редактирования', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Долгое нажатие по второй карточке
    await tester.longPress(find.byType(Card).at(1));
    await tester.pumpAndSettle();

    // Проверяем диалог редактирования
    expect(find.text('Редактировать заметку'), findsOneWidget);
    expect(find.text('Сохранить'), findsOneWidget);

    // Редактируем текст и сохраняем
    await tester.enterText(find.byType(TextField).last, 'Обновленный текст заметки');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    // Проверяем, что текст обновился
    expect(find.text('Обновленный текст заметки'), findsOneWidget);
  });

  testWidgets('Свайп влево удаляет заметку из списка (Dismissible)', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('demo-3')), findsOneWidget);

    // Свайпаем влево третью заметку
    await tester.drag(find.byKey(const ValueKey('demo-3')), const Offset(-600.0, 0.0));
    await tester.pumpAndSettle();

    // Заметка demo-3 исчезла из списка
    expect(find.byKey(const ValueKey('demo-3')), findsNothing);
    expect(find.byType(Card), findsNWidgets(2));
    expect(find.text('Заметка удалена'), findsOneWidget);
  });

  testWidgets('Свайп вправо снимает статус важной заметки', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Первая заметка изначально важная (isImportant = true)
    // Свайпаем ее вправо
    await tester.drag(find.byKey(const ValueKey('demo-1')), const Offset(600.0, 0.0));
    await tester.pumpAndSettle();

    // Проверяем SnackBar о снятии важности
    expect(find.text('Статус важности снят ⭐ ➔ 📝'), findsOneWidget);
    // Заметка demo-1 осталась в списке
    expect(find.byKey(const ValueKey('demo-1')), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(3));
  });
}
