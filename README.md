# Практическая работа №3: Обработка жестов и State Management во Flutter

Учебный проект по дисциплине «Разработка мобильных приложений» (темы: `GestureDetector`, `Dismissible`, State Management с библиотекой `Provider` и принципы `Clean Architecture`).

---

## 1. О проекте
Приложение «Заметки» доработано на основе практической работы №2 в строгом соответствии с лекционными материалами курса:
- **Архитектура (Clean Architecture)**:
  - **Domain**: модель `Note` (`id`, `text`, `isImportant`, `createdAt`).
  - **State Management**: класс `NotesProvider extends ChangeNotifier` (`addNote`, `updateNote`, `deleteNote`, `setImportant`) с уведомлением через `notifyListeners()`.
  - **Presentation**: UI с подпиской через `context.watch<NotesProvider>()` и вызовом действий через `context.read<NotesProvider>()`.
- **Обработка жестов**:
  - `GestureDetector` со свойством `behavior: HitTestBehavior.opaque` (обеспечивает стабильное срабатывание по всей области карточки).
  - Специализированный виджет `Dismissible` для свайпов в списках без конфликта жестов.

---

## 2. Реализованный функционал

### На оценку «4»:
1. **Обычное нажатие (`onTap`)**:
   - Открывает диалоговое окно `AlertDialog` для подробного просмотра полного текста заметки, даты создания и бейджа важности.
2. **Двойное нажатие (`onDoubleTap`)**:
   - Отмечает заметку как важную (`isImportant = true`).
   - Меняет фоновый цвет карточки на мягкий янтарный оттенок.
   - Добавляет золотой элемент-звезду ⭐ (`Icons.star`).

### На оценку «5»:
1. **Долгое нажатие (`onLongPress`)**:
   - Открывает окно быстрого редактирования выбранной заметки с `TextEditingController`.
   - После сохранения (`_notesProvider.updateNote`) текст мгновенно обновляется в интерфейсе.
2. **Свайп влево (`DismissDirection.endToStart`)**:
   - Анимированное удаление заметки из списка со стилизованным красным фоном и значком корзины `Icons.delete`.
   - Показ всплывающего уведомления `SnackBar` с информацией об удалении.
3. **Свайп вправо (`DismissDirection.startToEnd`)**:
   - Снятие статуса важности заметки (`isImportant = false`).
   - Стилизованный зеленый/тиловый фон со значком `Icons.undo`.
   - Карточка плавно возвращается на место (`confirmDismiss: false`), а фон и иконка возвращаются к обычному состоянию.

---

## 3. Демонстрация работы приложения (Видео и Скриншоты)

> [!NOTE]
> Сюда прикрепляется видеозапись работы приложения и демонстрационные скриншоты.

### Видеозапись:
- `screenshots/demo_video.mp4` *(будет прикреплена)*

### Скриншоты:
1. **Главный экран списка заметок (обычные и важные ⭐)**:
   `screenshots/01_notes_list.png`
2. **Просмотр полного текста заметки (onTap)**:
   `screenshots/02_tap_view_dialog.png`
3. **Отметка важности двойным нажатием (onDoubleTap)**:
   `screenshots/03_double_tap_star.png`
4. **Редактирование по долгому нажатию (onLongPress)**:
   `screenshots/04_long_press_edit.png`
5. **Свайп влево — удаление заметки**:
   `screenshots/05_swipe_left_delete.png`
6. **Свайп вправо — сброс статуса важности**:
   `screenshots/06_swipe_right_reset.png`

---

## 4. Запуск проекта

### В веб-браузере (Google Chrome):
```bash
flutter run -d chrome
```

### В среде Windows Desktop:
```bash
flutter run -d windows
```

### Запуск автоматических тестов:
```bash
flutter test
```
