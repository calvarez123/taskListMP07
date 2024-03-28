import 'package:descktop/todolist.dart';
import 'package:flutter/material.dart';

class TaskListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TaskList'),
      ),
      body: GestureDetector(
        onTap: () {
          // Navegar a la nueva pantalla cuando se hace clic en la actual
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    NewPage()), // Reemplaza 'NewPage()' con el nombre de tu nueva pantalla
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue, // Fondo azul
          ),
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '¿Qué quieres apuntar hoy?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
