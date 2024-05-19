import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_flutter/models/task.dart';

class CalendarScreen extends StatelessWidget {
  final List<Task> tasks;

  CalendarScreen({required this.tasks});

  @override
  Widget build(BuildContext context) {
    // Lógica para agrupar tarefas por dia
    Map<DateTime, List<Task>> tasksByDate = {};

    for (var task in tasks) {
      DateTime date = DateTime(task.dateTime.year, task.dateTime.month, task.dateTime.day);
      if (!tasksByDate.containsKey(date)) {
        tasksByDate[date] = [];
      }
      tasksByDate[date]!.add(task);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendário de Tarefas'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, // Quantidade de colunas no calendário (dias da semana)
        ),
        itemCount: tasksByDate.length,
        itemBuilder: (context, index) {
          DateTime date = tasksByDate.keys.elementAt(index);
          List<Task> tasksForDate = tasksByDate[date] ?? [];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskListByDateScreen(date: date, tasks: tasksForDate)),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
                color: tasksForDate.isNotEmpty ? Colors.blue.shade50 : Colors.white,
              ),
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}/${date.month}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Flexible(
                    child: Text(
                      '${tasksForDate.length} Tarefa(s)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TaskListByDateScreen extends StatelessWidget {
  final DateTime date;
  final List<Task> tasks;

  TaskListByDateScreen({required this.date, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarefas em ${DateFormat('dd/MM/yyyy').format(date)}'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          String formattedTime = DateFormat('HH:mm').format(task.dateTime);

          return ListTile(
            title: Text(task.name),
            subtitle: Text('Hora: $formattedTime'),
            onTap: () {
              // Implemente o que deseja fazer ao clicar em uma tarefa da lista
            },
          );
        },
      ),
    );
  }
}
