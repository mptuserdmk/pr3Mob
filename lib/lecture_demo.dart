import 'package:flutter/material.dart';

void main() {
  runApp(const GestureApp());
}

class GestureApp extends StatelessWidget {
  const GestureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesture Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GestureHomePage(),
    );
  }
}

class GestureHomePage extends StatefulWidget {
  const GestureHomePage({super.key});

  @override
  State<GestureHomePage> createState() => _GestureHomePageState();
}

class _GestureHomePageState extends State<GestureHomePage> {
  String _message = "Попробуй жест";
  double _scale = 1.0;
  double _previousScale = 1.0;
  double _rotation = 0.0;

  void _setMessage(String text) {
    setState(() {
      _message = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GestureDetector Demo"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- Зона 1: тап, двойной тап, долгое нажатие ---
          GestureDetector(
            onTap: () => _setMessage("Обычный тап"),
            onDoubleTap: () => _setMessage("Двойной тап"),
            onLongPress: () => _setMessage("Долгое нажатие"),
            child: Container(
              margin: const EdgeInsets.all(10),
              height: 100,
              color: Colors.green,
              alignment: Alignment.center,
              child: const Text(
                "Тапы и долгое нажатие",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),

          // --- Зона 2: свайпы ---
          GestureDetector(
            onPanUpdate: (details) {
              if (details.delta.dx > 0) {
                _setMessage("Свайп вправо");
              } else if (details.delta.dx < 0) {
                _setMessage("Свайп влево");
              } else if (details.delta.dy > 0) {
                _setMessage("Свайп вниз");
              } else if (details.delta.dy < 0) {
                _setMessage("Свайп вверх");
              }
            },
            child: Container(
              margin: const EdgeInsets.all(10),
              height: 100,
              color: Colors.orange,
              alignment: Alignment.center,
              child: const Text(
                "Свайпы",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),

          // --- Зона 3: масштабирование и поворот ---
          GestureDetector(
            onScaleStart: (details) {
              _previousScale = _scale;
            },
            onScaleUpdate: (details) {
              setState(() {
                _scale = _previousScale * details.scale;
                _rotation = details.rotation;
                _message =
                "Масштаб: x${_scale.toStringAsFixed(2)}, Поворот: ${_rotation.toStringAsFixed(2)} рад";
              });
            },
            onScaleEnd: (details) {
              _previousScale = _scale;
            },
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                // ignore: deprecated_member_use
                ..scale(_scale)
                ..rotateZ(_rotation),
              child: Container(
                margin: const EdgeInsets.all(10),
                height: 150,
                color: Colors.blue,
                alignment: Alignment.center,
                child: const Text(
                  "Масштабирование и вращение",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),






          Text(
            _message,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}