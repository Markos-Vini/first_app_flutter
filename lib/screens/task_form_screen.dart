import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_flutter/models/task.dart';
import 'package:app_flutter/screens/location_selection_screen.dart';
import 'package:app_flutter/services/location_service.dart';
import 'package:intl/intl.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  TaskFormScreen({this.task});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  late TextEditingController _nameController;
  late DateTime _selectedDate = DateTime.now();
  late TimeOfDay _selectedTime = TimeOfDay.now();
  Position? _currentLocation;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    if (widget.task != null) {
      _nameController.text = widget.task!.name;
      _selectedDate = widget.task!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
      _currentLocation = widget.task!.location;
    }

    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    try {
      Position position = await LocationService.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      setState(() {
        _currentLocation = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _selectLocation(BuildContext context) async {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationSelectionScreen()),
    );
    if (selectedLocation != null) {
      setState(() {
        _currentLocation = selectedLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome da Tarefa'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Data: ${_selectedDate != null ? DateFormat('dd/MM/yyyy').format(_selectedDate) : "Selecione uma data"}'),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Selecione a Data'),
                ),
              ],
            ),
            Row(
              children: [
                Text('Hora: ${_selectedTime != null ? _selectedTime.format(context) : "Selecione uma hora"}'),
                TextButton(
                  onPressed: () => _selectTime(context),
                  child: Text('Selecione a Hora'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Localização Atual: '),
                _isLoadingLocation
                    ? CircularProgressIndicator() // Mostra um indicador de progresso quando a localização está sendo carregada
                    : Text('${_currentLocation ?? "Nenhuma localização encontrada"}'),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                await _selectLocation(context);
              },
              child: Text('Selecionar Localização'),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _nameController.text.isNotEmpty
                  ? () {
                      final newTask = Task(
                        name: _nameController.text,
                        dateTime: DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                          _selectedTime.hour,
                          _selectedTime.minute,
                        ),
                        location: _currentLocation != null
                            ? _currentLocation!
                            : Position(
                                latitude: 0,
                                longitude: 0,
                                altitude: 0,
                                accuracy: 0,
                                heading: 0,
                                speed: 0,
                                speedAccuracy: 0,
                                timestamp: DateTime.now(),
                              ),
                      );
                      Navigator.pop(context, newTask);
                    }
                  : null,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
