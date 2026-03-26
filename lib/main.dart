import 'package:flutter/material.dart';
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  final List<Task> tasks = [
    Task(title: "Przygotować aplikacje", deadline: "poniedzialek", done: false, priority: "wysoki"),
    Task(title: "Przygotować się na zajęcia", deadline: "piatek", done: true, priority: "wysoki"),
    Task(title: "Rozszerzyć portfolio", deadline: "wtorek", done: false, priority: "średni"),
    Task(title: "Poprawić program", deadline: "sroda", done: true, priority: "niski"),
  ];
  @override
  Widget build(BuildContext context) {
    int doneCount = tasks.where((task) => task.done).length;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("KrakFlow")),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Masz dziś ${tasks.length} zadania (ukończone: $doneCount)",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),

              Text(
                "Dzisiejsze zadania",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(task: tasks[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({super.key, required this.task});
  Color getPriorityColor() {
    switch (task.priority) {
      case "wysoki":
        return Colors.red;
      case "średni":
        return Colors.orange;
      case "niski":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Icon(
              task.done
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: task.done ? Colors.green : Colors.grey,
            ),
            SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: task.done
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "termin: ${task.deadline} | priorytet: ${task.priority}",
                    style: TextStyle(
                      color: getPriorityColor(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;
  Task({
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });
}