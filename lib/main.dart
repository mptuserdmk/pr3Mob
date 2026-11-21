import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lecture_demo.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => NotesProvider(),
      child: const NotesApp(),
    ),
  );
}

/// Модель данных заметки
class Note {
  final String id;
  String text;
  bool isImportant;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.text,
    this.isImportant = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// Провайдер управления состоянием заметок
class NotesProvider extends ChangeNotifier {
  final List<Note> _notes = [
    Note(
      id: 'demo-1',
      text: 'Добро пожаловать в заметки!\nЗдесь реализована обработка жестов и State Management.',
      isImportant: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    Note(
      id: 'demo-2',
      text: 'Обычный тап открывает полный просмотр, а двойной тап делает заметку важной ⭐️.',
      isImportant: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    Note(
      id: 'demo-3',
      text: 'Долгое нажатие открывает редактирование. Свайп влево — удалить, свайп вправо — снять важность.',
      isImportant: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  List<Note> get notes => List.unmodifiable(_notes);

  void addNote(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmed,
      isImportant: false,
    );
    _notes.insert(0, newNote);
    notifyListeners();
  }

  void updateNote(String id, String newText) {
    final trimmed = newText.trim();
    if (trimmed.isEmpty) return;
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].text = trimmed;
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void setImportant(String id, bool isImportant) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].isImportant = isImportant;
      notifyListeners();
    }
  }
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      ),
      home: const NotesScreen(),
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _handleAddNote() {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;
    context.read<NotesProvider>().addNote(text);
    _inputController.clear();
  }

  /// Просмотр полного текста заметки (onTap)
  void _showViewDialog(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              note.isImportant ? Icons.star : Icons.note_alt_outlined,
              color: note.isImportant ? Colors.amber : Colors.indigo,
            ),
            const SizedBox(width: 8),
            const Text('Просмотр заметки'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (note.isImportant)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Важная заметка',
                        style: TextStyle(
                          color: Colors.brown,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              SelectableText(
                note.text,
                style: const TextStyle(fontSize: 16, height: 1.45),
              ),
              const SizedBox(height: 16),
              const Divider(),
              Text(
                'Создано: ${_formatDateTime(note.createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _showEditDialog(context, note);
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Редактировать'),
          ),
        ],
      ),
    );
  }

  /// Редактирование заметки (onLongPress)
  void _showEditDialog(BuildContext context, Note note) {
    final editController = TextEditingController(text: note.text);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.edit_note, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Редактировать заметку'),
          ],
        ),
        content: TextField(
          controller: editController,
          autofocus: true,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Текст заметки...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final newText = editController.text.trim();
              if (newText.isNotEmpty) {
                context.read<NotesProvider>().updateNote(note.id, newText);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Заметка успешно обновлена!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return '$d.$mo.${dt.year} в $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotesProvider>().notes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Заметки'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.school_outlined),
            tooltip: 'Демо жестов из лекции',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GestureHomePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Панель добавления заметки
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'Введите текст заметки...',
                      prefixIcon: Icon(Icons.note_add_outlined),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onSubmitted: (_) => _handleAddNote(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _handleAddNote,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить'),
                ),
              ],
            ),
          ),

          // Подсказка по жестам
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.indigo.shade100),
            ),
            child: const Wrap(
              alignment: WrapAlignment.spaceAround,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text('👆 Тап: просмотр', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text('✌️ 2 тапа: ⭐ важная', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text('⏱️ Долгое: изменить', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text('👈 Влево: удалить', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text('👉 Вправо: сброс ⭐', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          // Список заметок
          Expanded(
            child: notes.isEmpty
                ? const Center(
                    child: Text(
                      'Список пуст. Добавьте первую заметку!',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];

                      return Dismissible(
                        key: ValueKey(note.id),
                        direction: DismissDirection.horizontal,

                        // Свайп вправо: снять важность
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerLeft,
                          child: const Row(
                            children: [
                              Icon(Icons.undo, color: Colors.white, size: 26),
                              SizedBox(width: 8),
                              Text(
                                'Снять статус важной',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Свайп влево: удалить заметку
                        secondaryBackground: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Удалить заметку',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.delete, color: Colors.white, size: 26),
                            ],
                          ),
                        ),

                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            if (note.isImportant) {
                              context.read<NotesProvider>().setImportant(note.id, false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Статус важности снят ⭐ ➔ 📝'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Заметка уже имеет обычный статус'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                            return false;
                          } else if (direction == DismissDirection.endToStart) {
                            return true;
                          }
                          return false;
                        },

                        onDismissed: (direction) {
                          if (direction == DismissDirection.endToStart) {
                            context.read<NotesProvider>().deleteNote(note.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Заметка удалена'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },

                        child: Card(
                          elevation: note.isImportant ? 4.0 : 1.0,
                          color: note.isImportant ? const Color(0xFFFFF8E1) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: note.isImportant
                                  ? Colors.amber.shade400
                                  : Colors.grey.shade200,
                              width: note.isImportant ? 1.5 : 1.0,
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _showViewDialog(context, note),
                            onDoubleTap: () {
                              context.read<NotesProvider>().setImportant(note.id, true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Заметка отмечена как важная! ⭐'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            onLongPress: () => _showEditDialog(context, note),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: note.isImportant
                                        ? Colors.amber.shade200
                                        : Colors.indigo.shade50,
                                    child: note.isImportant
                                        ? const Icon(Icons.star, color: Colors.amber, size: 20)
                                        : Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo.shade800,
                                              fontSize: 13,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          note.text,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: note.isImportant
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: const Color(0xFF2C3E50),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              _formatDateTime(note.createdAt),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            if (note.isImportant) ...[
                                              const SizedBox(width: 8),
                                              const Text(
                                                '•  ⭐ Важная',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (note.isImportant)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 6),
                                          child: Icon(Icons.star, color: Colors.amber, size: 22),
                                        ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 20),
                                        tooltip: 'Редактировать',
                                        onPressed: () => _showEditDialog(context, note),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
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
