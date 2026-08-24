import 'package:flutter/material.dart';
import 'screens/catalog_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Sales',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Теперь первый элемент — это DiagnosisScreen()
  static const List<Widget> _widgetOptions = <Widget>[
    DiagnosisScreen(),    // экран диагностики с кнопками
    CatalogScreen(), 
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Диагностика',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Каталог',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- НОВЫЙ ВИДЖЕТ ДЛЯ ЭКРАНА ДИАГНОСТИКИ ---
class DiagnosisScreen extends StatelessWidget {
  const DiagnosisScreen({super.key});

  // Обработчики нажатий (пока просто показывают SnackBar)
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Диагностика растений',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => _showMessage(context, 'Камера открыта (заглушка)'),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Сделать фото'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showMessage(context, 'Выбор фото из галереи (заглушка)'),
            icon: const Icon(Icons.photo_library),
            label: const Text('Выбрать из галереи'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showMessage(context, 'Запуск диагностики (заглушка)'),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Запустить диагностику'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}