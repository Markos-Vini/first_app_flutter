import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:app_flutter/models/task.dart';
import 'package:app_flutter/screens/task_form_screen.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void _editTask(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskFormScreen(task: task)),
    ).then((editedTask) {
      if (editedTask != null) {
        setState(() {
          final index = tasks.indexWhere((t) => t.name == task.name);
          if (index != -1) {
            tasks[index] = editedTask;
          }
        });
      }
    });
  }

  Future<LatLng> _getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      Location firstLocation = locations.first;
      return LatLng(firstLocation.latitude, firstLocation.longitude);
    } catch (e) {
      print('Erro ao buscar coordenadas: $e');
      return LatLng(-23.5505199, -46.6333094); // Localização padrão em caso de erro
    }
  }

  bool _isMapExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Lista de Tarefas', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  String formattedDate = DateFormat('dd/MM/yyyy').format(task.dateTime);
                  String formattedTime = DateFormat('HH:mm').format(task.dateTime);

                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(task.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Data: $formattedDate'),
                              Text('Hora: $formattedTime'),
                              Text('Local: ${task.address}'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editTask(task),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteTask(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isMapExpanded = !_isMapExpanded;
                            });
                          },
                          child: Container(
                            height: _isMapExpanded ? 300 : 100,
                            child: FutureBuilder<LatLng>(
                              future: _getCoordinatesFromAddress(task.address),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                if (snapshot.hasError) {
                                  return const Center(child: Text('Erro ao carregar o mapa'));
                                }

                                LatLng location = snapshot.data ?? LatLng(0, 0);

                                return GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: location,
                                    zoom: 15,
                                  ),
                                  markers: {
                                    Marker(
                                      markerId: MarkerId(task.name),
                                      position: location,
                                    ),
                                  },
                                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                                    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                                  ].toSet(),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
                child: const Text('Criar Nova Tarefa'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
