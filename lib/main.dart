import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'edit_task_screen.dart';

void main() {
  runApp(const MyApp());
}

// --- MODEL TASK ---
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

  factory Task.fromJson(Map<String, dynamic> json) {
    final random = Random();

    final priorities = ["niski", "średni", "wysoki"];
    final deadlines = [
      "poniedziałek",
      "wtorek",
      "środa",
      "czwartek",
      "piątek"
    ];

    return Task(
      title: json["todo"],
      done: json["completed"],
      priority: priorities[random.nextInt(priorities.length)],
      deadline: deadlines[random.nextInt(deadlines.length)],
    );
  }
}

// --- API SERVICE ---
class TaskApiService {
  Future<List<Task>> fetchTasks() async {
    final response =
    await http.get(Uri.parse("https://dummyjson.com/todos"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List todos = data["todos"];

      return todos.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception("Nie udało się pobrać zadań");
    }
  }
}

// --- TASK REPOSITORY ---
class TaskRepository {
  static List<Task> tasks = [];
}

// --- MAIN APP ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "KrakFlow",
      home: const HomeScreen(),
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

  late Future<List<Task>> tasksFuture;

  @override
  void initState() {
    super.initState();

    tasksFuture = TaskApiService().fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KrakFlow"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                TaskRepository.tasks.clear();
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Usunięto wszystkie zadania"),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(),
            ),
          );

          if (newTask != null) {
            setState(() {
              TaskRepository.tasks.add(newTask);
            });
          }
        },
      ),

      // --- FUTURE BUILDER ---
      body: FutureBuilder<List<Task>>(
        future: tasksFuture,
        builder: (context, snapshot) {
          // --- WAITING ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // --- ERROR ---
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Błąd: ${snapshot.error}",
                style: const TextStyle(fontSize: 18),
              ),
            );
          }

          // --- DATA ---
          if (snapshot.hasData) {
            if (TaskRepository.tasks.isEmpty) {
              TaskRepository.tasks = snapshot.data!;
            }

            int doneCount =
                TaskRepository.tasks.where((task) => task.done).length;

            List<Task> filteredTasks = TaskRepository.tasks;

            if (selectedFilter == "wykonane") {
              filteredTasks = TaskRepository.tasks
                  .where((task) => task.done)
                  .toList();
            } else if (selectedFilter == "do zrobienia") {
              filteredTasks = TaskRepository.tasks
                  .where((task) => !task.done)
                  .toList();
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Masz dziś ${TaskRepository.tasks.length} zadania (ukończone: $doneCount)",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),

                  // --- FILTERS ---
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = "wszystkie";
                          });
                        },
                        child: const Text("Wszystkie"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = "do zrobienia";
                          });
                        },
                        child: const Text("Do zrobienia"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = "wykonane";
                          });
                        },
                        child: const Text("Wykonane"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Dzisiejsze zadania",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- TASK LIST ---
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
                              final Task? updatedTask =
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditTaskScreen(task: task),
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
            );
          }

          return const SizedBox();
        },
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
            decoration:
            task.done ? TextDecoration.lineThrough : null,
            color: task.done ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(
          "termin: ${task.deadline} | priorytet: ${task.priority}",
          style: TextStyle(
            color: getPriorityColor(),
          ),
        ),
      ),
    );
  }
}

// --- ADD TASK SCREEN ---
class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});

  final TextEditingController titleController =
  TextEditingController();

  final TextEditingController deadlineController =
  TextEditingController();

  final TextEditingController priorityController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nowe zadanie"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Tytuł zadania",
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(
                labelText: "Termin",
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priorityController,
              decoration: const InputDecoration(
                labelText: "Priorytet",
              ),
            ),
            const SizedBox(height: 16),
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
              child: const Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}