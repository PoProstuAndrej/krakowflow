import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'edit_task_screen.dart';
import 'models/task.dart';
import 'services/task_local_database.dart';
import 'services/task_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox("tasks");

  runApp(const MyApp());
}

// ---------------- APP ----------------

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

// ---------------- HOME SCREEN ----------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "wszystkie";

  List<Task> tasks = [];

  int allTasksCount = 0;
  int doneTasksCount = 0;
  int todoTasksCount = 0;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    await TaskSyncService.loadInitialDataIfNeeded();

    final loadedTasks = TaskLocalDatabase.getTasks();

    setState(() {
      tasks = loadedTasks;

      allTasksCount = tasks.length;

      doneTasksCount =
          tasks.where((task) => task.done).length;

      todoTasksCount =
          tasks.where((task) => !task.done).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = tasks;

    if (selectedFilter == "wykonane") {
      filteredTasks =
          tasks.where((task) => task.done).toList();
    } else if (selectedFilter == "do zrobienia") {
      filteredTasks =
          tasks.where((task) => !task.done).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("KrakFlow"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Potwierdzenie"),
                    content: const Text(
                      "Czy usunąć wszystkie zadania?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Anuluj"),
                      ),
                      TextButton(
                        onPressed: () async {
                          await TaskLocalDatabase
                              .deleteAllTasks();

                          await loadTasks();

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Usunięto wszystkie zadania",
                              ),
                            ),
                          );
                        },
                        child: const Text("Usuń"),
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
        child: const Icon(Icons.add),

        onPressed: () async {
          final Task? newTask =
              await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddTaskScreen(),
            ),
          );

          if (newTask != null) {
            await TaskLocalDatabase.addTask(
              newTask,
            );

            await loadTasks();
          }
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              "Masz dziś $allTasksCount zadania "
              "(ukończone: $doneTasksCount)",
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter =
                          "wszystkie";
                    });
                  },
                  child: const Text(
                    "Wszystkie",
                  ),
                ),

                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter =
                          "do zrobienia";
                    });
                  },
                  child: const Text(
                    "Do zrobienia",
                  ),
                ),

                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter =
                          "wykonane";
                    });
                  },
                  child: const Text(
                    "Wykonane",
                  ),
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

            Expanded(
              child: ListView.builder(
                itemCount: filteredTasks.length,

                itemBuilder: (context, index) {
                  final task =
                      filteredTasks[index];

                  return Dismissible(
                    key: ValueKey(task.id),

                    direction:
                        DismissDirection
                            .endToStart,

                    onDismissed:
                        (direction) async {
                      await TaskLocalDatabase
                          .deleteTask(task.id);

                      await loadTasks();

                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            "${task.title} usunięto",
                          ),
                        ),
                      );
                    },

                    child: TaskCard(
                      task: task,

                      onChanged:
                          (value) async {
                        final updatedTask =
                            Task(
                          id: task.id,
                          title: task.title,
                          deadline:
                              task.deadline,
                          priority:
                              task.priority,
                          done:
                              value ?? false,
                        );

                        await TaskLocalDatabase
                            .updateTask(
                          updatedTask,
                        );

                        await loadTasks();
                      },

                      onTap: () async {
                        final Task?
                            updatedTask =
                            await Navigator
                                .push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    EditTaskScreen(
                              task: task,
                            ),
                          ),
                        );

                        if (updatedTask !=
                            null) {
                          await TaskLocalDatabase
                              .updateTask(
                            updatedTask,
                          );

                          await loadTasks();
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

// ---------------- TASK CARD ----------------

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
      margin:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),

      elevation: 4,

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
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

            decoration: task.done
                ? TextDecoration
                    .lineThrough
                : null,

            color: task.done
                ? Colors.grey
                : Colors.black,
          ),
        ),

        subtitle: Text(
          "termin: ${task.deadline} | "
          "priorytet: ${task.priority}",

          style: TextStyle(
            color: getPriorityColor(),
          ),
        ),
      ),
    );
  }
}

// ---------------- ADD TASK SCREEN ----------------

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});

  final TextEditingController
      titleController =
      TextEditingController();

  final TextEditingController
      deadlineController =
      TextEditingController();

  final TextEditingController
      priorityController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Nowe zadanie")),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller:
                  titleController,

              decoration:
                  const InputDecoration(
                labelText:
                    "Tytuł zadania",
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller:
                  deadlineController,

              decoration:
                  const InputDecoration(
                labelText: "Termin",
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller:
                  priorityController,

              decoration:
                  const InputDecoration(
                labelText:
                    "Priorytet",
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  id: Random().nextInt(
                    1000000,
                  ),

                  title:
                      titleController.text,

                  deadline:
                      deadlineController
                          .text,

                  priority:
                      priorityController
                          .text,

                  done: false,
                );

                Navigator.pop(
                  context,
                  newTask,
                );
              },

              child: const Text(
                "Zapisz",
              ),
            ),
          ],
        ),
      ),
    );
  }
}