import 'package:flutter/material.dart';
import 'package:app_flutter/models/task.dart';
import 'package:app_flutter/screens/task_form_screen.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart'; // Importe o pacote de geocodificação

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];

  // Método para excluir uma tarefa
  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  // Método para editar uma tarefa
  void _editTask(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskFormScreen(task: task)),
    ).then((editedTask) {
      if (editedTask != null) {
        setState(() {
          // Encontra a tarefa editada na lista e atualiza seus dados
          final index = tasks.indexWhere((t) => t.name == task.name);
          if (index != -1) {
            tasks[index] = editedTask;
          }
        });
      }
    });
  }

  // Método para converter coordenadas em endereço
  Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark placemark = placemarks.first;
      return '${placemark.thoroughfare}, ${placemark.subThoroughfare}, ${placemark.locality}, ${placemark.subLocality}, ${placemark.administrativeArea}, ${placemark.subAdministrativeArea}, ${placemark.postalCode}, ${placemark.country}, ${placemark.isoCountryCode}';
    } catch (e) {
      return 'Endereço não encontrado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tarefas'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          // Formata a data e a hora
          String formattedDate = DateFormat('dd/MM/yyyy').format(task.dateTime);
          String formattedTime = DateFormat('HH:mm').format(task.dateTime);

          // Converte as coordenadas em endereço
          return FutureBuilder<String>(
            future: _getAddressFromCoordinates(task.location.latitude, task.location.longitude),
            builder: (context, snapshot) {
              String address = snapshot.data ?? 'Endereço não encontrado';
              return ListTile(
                title: Text(task.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data: $formattedDate'),
                    Text('Hora: $formattedTime'),
                    Text('Endereço: $address'),
                  ],
                ),
                // Adiciona ícones de ação à direita de cada item da lista
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editTask(task),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteTask(index),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskFormScreen()),
          ).then((newTask) {
            if (newTask != null) {
              setState(() {
                tasks.add(newTask);
              });
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
