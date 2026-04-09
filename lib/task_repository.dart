class Task {
  String title;
  String deadline;
  bool done;
  String priority;

  Task({
    required this.title,
    required this.deadline,
    this.done = false,
    required this.priority,
  });
}

class TaskRepository {
  static List<Task> tasks = [
    Task(title: "Projekt Flutter", deadline: "jutro", done: false, priority: "wysoki"),
    Task(title: "Oddać raport", deadline: "dzisiaj", done: true, priority: "wysoki"),
    Task(title: "Powtórzyć widgety", deadline: "w piątek", done: false, priority: "średni"),
  ];
}