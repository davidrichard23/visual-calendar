import 'dart:developer';

import 'package:calendar/components/cards/primary_card.dart';
import 'package:calendar/main.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/create_edit_event/create_edit_event.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:collection/collection.dart';

const ROW_HEIGHT = 75.0;

class TaskList extends StatefulWidget {
  final List<EventTask> tasks;
  final List<UploadImageData> images;
  final Function(EventTask) stageAddTask;
  final Function(EventTask) stageUpdateTask;
  final Function(int, int) reorderTask;
  final Function(int) removeTask;
  final Function(UploadImageData) stageAddTaskImage;
  final Function(ObjectId) removeImage;
  final String eventId;

  const TaskList(
      {Key? key,
      required this.tasks,
      required this.images,
      required this.stageAddTask,
      required this.stageUpdateTask,
      required this.reorderTask,
      required this.removeTask,
      required this.stageAddTaskImage,
      required this.removeImage,
      required this.eventId})
      : super(key: key);

  @override
  State<TaskList> createState() => TaskListState();
}

class TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void addNewTask() {
      Navigator.pushNamed(context, '/create-edit-event-task',
          arguments: CreateEditTaskScreenArgs(
              stageAddTask: widget.stageAddTask,
              stageUpdateTask: widget.stageUpdateTask,
              stageAddTaskImage: widget.stageAddTaskImage,
              removeTaskImage: widget.removeImage,
              eventId: widget.eventId));
    }

    void editTask(EventTask task) {
      Navigator.pushNamed(context, '/create-edit-event-task',
          arguments: CreateEditTaskScreenArgs(
              existingTask: task,
              pendingImage: widget.images
                  .firstWhereOrNull((image) => image.taskId == task.id),
              stageAddTask: widget.stageAddTask,
              stageUpdateTask: widget.stageUpdateTask,
              stageAddTaskImage: widget.stageAddTaskImage,
              removeTaskImage: widget.removeImage,
              eventId: widget.eventId));
    }

    return Column(children: [
      PrimaryCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Event Tasks',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                          '${widget.tasks.length} task${widget.tasks.length != 1 ? 's' : ''}')
                    ])),
            SizedBox(
                height: widget.tasks.length * ROW_HEIGHT,
                child: ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const NeverScrollableScrollPhysics(),
                    onReorder: widget.reorderTask,
                    itemCount: widget.tasks.length,
                    buildDefaultDragHandles: false,
                    itemBuilder: (ctx, i) {
                      final task = widget.tasks[i];

                      return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          key: Key(task.id.toString()),
                          onTap: () => editTask(task),
                          child: SizedBox(
                              height: ROW_HEIGHT,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        height: 1, color: Colors.grey[200]),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        child: Row(children: [
                                          widget.tasks.length > 1
                                              ? ReorderableDragStartListener(
                                                  index: i,
                                                  child: Icon(
                                                    Icons.drag_indicator,
                                                    color: Colors.grey[400],
                                                  ),
                                                )
                                              : Container(),
                                          Container(width: 8),
                                          Expanded(
                                              child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(task.title),
                                              IconButton(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  icon: Icon(
                                                    Icons
                                                        .delete_outline_rounded,
                                                    color: Colors.grey[400],
                                                  ),
                                                  onPressed: () =>
                                                      widget.removeTask(i))
                                            ],
                                          ))
                                        ]))
                                  ])));
                    })),
          ])),
      GestureDetector(
          onTap: addNewTask,
          child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 8),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: theme.primaryColor,
              ),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      margin: const EdgeInsets.only(right: 4),
                      child: const Icon(Icons.add_circle_outline_rounded,
                          size: 24.0, color: Color.fromRGBO(0, 69, 77, 1))),
                  const Text(
                    'Add New Task',
                    style: TextStyle(
                        color: Color.fromRGBO(0, 69, 77, 1),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              )))
    ]);
  }
}
