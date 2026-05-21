import '../models/task.dart';
import 'task_local_database.dart';

class TaskSyncService {

  static Future<void> loadInitialDataIfNeeded() async {

    if (!TaskLocalDatabase.isEmpty()) {
      return;
    }

    final tasks = [

      Task(
        id: 1,
        title: "Zrobić laboratorium",
        deadline: "dzisiaj",
        priority: "wysoki",
        done: false,
      ),

      Task(
        id: 2,
        title: "Kupić mleko",
        deadline: "jutro",
        priority: "niski",
        done: true,
      ),

      Task(
        id: 3,
        title: "Pouczyć się Fluttera",
        deadline: "piątek",
        priority: "średni",
        done: false,
      ),
    ];

    await TaskLocalDatabase.saveTasks(tasks);
  }
}