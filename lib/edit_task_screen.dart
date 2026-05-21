import 'package:flutter/material.dart';
import 'models/task.dart';

class EditTaskScreen extends StatefulWidget {

  final Task task;

  const EditTaskScreen({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskScreen> createState() =>
      _EditTaskScreenState();
}

class _EditTaskScreenState
    extends State<EditTaskScreen> {

  late TextEditingController titleController;
  late TextEditingController deadlineController;
  late TextEditingController priorityController;

  @override
  void initState() {
    super.initState();

    titleController =
        TextEditingController(
            text: widget.task.title);

    deadlineController =
        TextEditingController(
            text: widget.task.deadline);

    priorityController =
        TextEditingController(
            text: widget.task.priority);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Edycja zadania"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            TextField(
              controller: titleController,

              decoration: InputDecoration(
                labelText: "Tytuł",
              ),
            ),

            SizedBox(height: 16),

            TextField(
              controller: deadlineController,

              decoration: InputDecoration(
                labelText: "Termin",
              ),
            ),

            SizedBox(height: 16),

            TextField(
              controller: priorityController,

              decoration: InputDecoration(
                labelText: "Priorytet",
              ),
            ),

            SizedBox(height: 24),

            ElevatedButton(

              onPressed: () {


                final updatedTask = Task(
                  id: widget.task.id,
                  title: titleController.text,
                  deadline: deadlineController.text,
                  priority: priorityController.text,
                  done: widget.task.done,
                );

                Navigator.pop(
                  context,
                  updatedTask,
                );
              },

              child: Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}