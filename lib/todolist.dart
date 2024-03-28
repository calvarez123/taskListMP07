import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewPage extends StatefulWidget {
  @override
  _NewPageState createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  Map<String, List<String>> todoLists = {};
  bool isMenuOpen = false;
  String selectedList = '';
  List<String> selectedTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTodoLists();
  }

  // Método para cargar las listas de tareas guardadas
  _loadTodoLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      todoLists = Map<String, List<String>>.from(
        (prefs.getString('todoLists') ?? '{}').split('\n').fold({},
            (map, entry) {
          var parts = entry.split(':');
          if (parts.length == 2) {
            map[parts[0]] = parts[1].split(',').map((e) => e.trim()).toList();
          }
          return map;
        }),
      );
    });
  }

  // Método para guardar las listas de tareas actualizadas
  _saveTodoLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> lines = [];
    todoLists.forEach((key, value) {
      lines.add('$key: ${value.join(',')}');
    });
    await prefs.setString('todoLists', lines.join('\n'));
  }

  @override
  Widget build(BuildContext context) {
    List<String>? tasks =
        selectedList.isNotEmpty ? todoLists[selectedList] : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo Lists'),
        leading: IconButton(
          icon: Icon(isMenuOpen ? Icons.close : Icons.menu),
          onPressed: () {
            setState(() {
              isMenuOpen = !isMenuOpen;
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              if (selectedList.isNotEmpty) {
                _showAddTaskDialog(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selecciona una lista primero'),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              if (selectedTasks.isNotEmpty) {
                setState(() {
                  tasks!.removeWhere((task) => selectedTasks.contains(task));
                  selectedTasks.clear();
                  _saveTodoLists();
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selecciona tareas para borrar'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: tasks != null
                ? Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Card(
                          elevation: 3,
                          color: selectedTasks.contains(task)
                              ? Colors.blue[100]
                              : Colors.white,
                          child: ListTile(
                            title: Text(
                              task,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                if (selectedTasks.contains(task)) {
                                  selectedTasks.remove(task);
                                } else {
                                  selectedTasks.add(task);
                                }
                              });
                            },
                            selected: selectedTasks.contains(task),
                          ),
                        );
                      },
                    ),
                  )
                : Text(
                    'Selecciona una lista para ver sus tareas',
                    style: TextStyle(
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            transform: Matrix4.translationValues(isMenuOpen ? 0 : -200, 0, 0),
            child: Container(
              width: 200,
              color: Colors.grey[200],
              child: ListView.builder(
                itemCount: todoLists.length,
                itemBuilder: (context, index) {
                  String listName = todoLists.keys.elementAt(index);
                  return ListTile(
                    title: Text(
                      listName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selectedList == listName
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedList = listName;
                        selectedTasks.clear();
                      });
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          todoLists.remove(listName);
                          if (selectedList == listName) {
                            selectedList = '';
                            selectedTasks.clear();
                            _saveTodoLists();
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Visibility(
              visible: isMenuOpen,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  _showAddListDialog(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  child: Text(
                    'Agregar Lista',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddListDialog(BuildContext context) async {
    String newListName = '';
    TextEditingController controller =
        TextEditingController(); // Controlador para predefinir el texto
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar nueva lista'),
          content: TextField(
            controller: controller, // Asigna el controlador al TextField
            onChanged: (value) {
              newListName = value;
            },
            decoration: InputDecoration(hintText: 'Nombre de la lista'),
            onSubmitted: (_) {
              // Aceptar cuando se presiona Enter
              if (newListName.isNotEmpty) {
                setState(() {
                  todoLists[newListName] = [];
                  _saveTodoLists(); // Guardar los cambios
                });
                Navigator.of(context).pop();
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (newListName.isNotEmpty) {
                  setState(() {
                    todoLists[newListName] = [];
                    _saveTodoLists(); // Guardar los cambios
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    String newTaskName = '';
    TextEditingController controller =
        TextEditingController(); // Controlador para predefinir el texto
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar nueva tarea'),
          content: TextField(
            controller: controller, // Asigna el controlador al TextField
            onChanged: (value) {
              newTaskName = value;
            },
            decoration: InputDecoration(hintText: 'Nombre de la tarea'),
            onSubmitted: (_) {
              // Aceptar cuando se presiona Enter
              if (newTaskName.isNotEmpty) {
                setState(() {
                  if (selectedList.isNotEmpty) {
                    todoLists[selectedList]!.add(newTaskName);
                    _saveTodoLists(); // Guardar los cambios
                  }
                });
                Navigator.of(context).pop();
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (newTaskName.isNotEmpty) {
                  setState(() {
                    if (selectedList.isNotEmpty) {
                      todoLists[selectedList]!.add(newTaskName);
                      _saveTodoLists(); // Guardar los cambios
                    }
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}
