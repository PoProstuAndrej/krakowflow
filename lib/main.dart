import 'package:flutter/material.dart';
import 'edit_task_screen.dart';

void main() {
  runApp(MyApp());
}

// --- TASK REPOSITORY ---
class Task {
  final String title;
  final String deadline;
  bool done;
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
  String selectedFilter = "wszystkie";

  @override
  Widget build(BuildContext context) {
    int doneCount = TaskRepository.tasks.where((task) => task.done).length;

    List<Task> filteredTasks = TaskRepository.tasks;

    if (selectedFilter == "wykonane") {
      filteredTasks = TaskRepository.tasks.where((task) => task.done).toList();
    } else if (selectedFilter == "do zrobienia") {
      filteredTasks = TaskRepository.tasks.where((task) => !task.done).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("KrakFlow"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Potwierdzenie"),
                    content: Text("Czy usunąć wszystkie zadania?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Anuluj"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            TaskRepository.tasks.clear();
                          });

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Usunięto wszystkie zadania"),
                            ),
                          );
                        },
                        child: Text("Usuń"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
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
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "wszystkie";
                    });
                  },
                  child: Text("Wszystkie"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "do zrobienia";
                    });
                  },
                  child: Text("Do zrobienia"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "wykonane";
                    });
                  },
                  child: Text("Wykonane"),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Dzisiejsze zadania",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];

                  return Dismissible(
                    key: ValueKey(task.title),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        TaskRepository.tasks.remove(task);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${task.title} usunięto"),
                        ),
                      );
                    },
                    child: TaskCard(
                      task: task,
                      onChanged: (value) {
                        setState(() {
                          task.done = value!;
                        });
                      },
                      onTap: () async {
                        final Task? updatedTask = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTaskScreen(task: task),
                          ),
                        );

                        if (updatedTask != null) {
                          setState(() {
                            TaskRepository.tasks[index] = updatedTask;
                          });
                        }
                      },
                    ),
                  );
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
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onChanged,
    this.onTap,
  });

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
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: task.done,
          onChanged: onChanged,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            decoration: task.done ? TextDecoration.lineThrough : null,
            color: task.done ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(
          "termin: ${task.deadline} | priorytet: ${task.priority}",
          style: TextStyle(color: getPriorityColor()),
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