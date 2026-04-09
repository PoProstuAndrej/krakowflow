import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// --- TASK REPOSITORY ---
class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;

  Task({
    required this.title,
    required this.deadline,
    this.done = false,
    required this.priority,
  });
}

class TaskRepository {
  static List<Task> tasks = [
    Task(title: "Przygotować aplikacje", deadline: "poniedzialek", done: false, priority: "wysoki"),
    Task(title: "Przygotować się na zajęcia", deadline: "piatek", done: true, priority: "wysoki"),
    Task(title: "Rozszerzyć portfolio", deadline: "wtorek", done: false, priority: "średni"),
    Task(title: "Poprawić program", deadline: "sroda", done: true, priority: "niski"),
  ];
}

// --- MAIN APP ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "KrakFlow",
      home: HomeScreen(),
    );
  }
}

// --- HOME SCREEN ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    int doneCount = TaskRepository.tasks.where((task) => task.done).length;

    return Scaffold(
      appBar: AppBar(title: Text("KrakFlow")),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
          if (newTask != null) {
            setState(() {
              TaskRepository.tasks.add(newTask);
            });
          }
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Masz dziś ${TaskRepository.tasks.length} zadania (ukończone: $doneCount)",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              "Dzisiejsze zadania",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: TaskRepository.tasks.length,
                itemBuilder: (context, index) {
                  return TaskCard(task: TaskRepository.tasks[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- TASK CARD ---
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              task.done ? Icons.check_circle : Icons.radio_button_unchecked,
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
                      decoration: task.done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "termin: ${task.deadline} | priorytet: ${task.priority}",
                    style: TextStyle(color: getPriorityColor()),
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

// --- ADD TASK SCREEN ---
class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nowe zadanie")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: "Tytuł zadania")),
            SizedBox(height: 8),
            TextField(controller: deadlineController, decoration: InputDecoration(labelText: "Termin")),
            SizedBox(height: 8),
            TextField(controller: priorityController, decoration: InputDecoration(labelText: "Priorytet")),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  done: false,
                  priority: priorityController.text,
                );
                Navigator.pop(context, newTask);
              },
              child: Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}