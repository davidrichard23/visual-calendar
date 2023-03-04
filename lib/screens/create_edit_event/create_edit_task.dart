// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'dart:io';

import 'package:calendar/components/custom_text_form_field.dart';
import 'package:calendar/realm/app_services.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/create_edit_event/create_edit_event.dart';
import 'package:calendar/screens/create_edit_event/image_picker.dart';
import 'package:calendar/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:collection/collection.dart';

class CreateEditTask extends StatefulWidget {
  final EventTask? existingTask;
  final List<StagedImageData> stagedImages;
  final Function(EventTask) stageAddTask;
  final Function(EventTask) stageUpdateTask;
  final Function(ObjectId, ImageData?) setImage;
  final String eventId;

  const CreateEditTask(
      {Key? key,
      this.existingTask,
      required this.stagedImages,
      required this.stageAddTask,
      required this.stageUpdateTask,
      required this.setImage,
      required this.eventId})
      : super(key: key);

  @override
  State<CreateEditTask> createState() => _CreateEditTaskState();
}

class _CreateEditTaskState extends State<CreateEditTask> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late ObjectId id;
  String title = '';
  String description = '';
  ImageData? selectedImage;

  @override
  void initState() {
    if (widget.existingTask == null) {
      id = ObjectId();
      return;
    }

    id = widget.existingTask!.id;
    title = widget.existingTask!.title;
    description = widget.existingTask!.description;
    selectedImage =
        widget.stagedImages.firstWhereOrNull((i) => i.taskId == id)?.image;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState?>(context, listen: true);
    final currentUser =
        Provider.of<AppServices>(context, listen: true).currentUser;
    final theme = Theme.of(context);

    void handleAdd() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        EventTask task = EventTask(
            id,
            appState!.activeTeam!.id,
            ObjectId.fromHexString(currentUser!.id),
            ObjectId.fromHexString(widget.eventId),
            title,
            description);
        widget.stageAddTask(task);
        widget.setImage(id, selectedImage);
        Navigator.pop(context);
      }
    }

    void handleUpdate() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        EventTask task = EventTask(
            id,
            appState!.activeTeam!.id,
            ObjectId.fromHexString(currentUser!.id),
            ObjectId.fromHexString(widget.eventId),
            title,
            description);

        widget.stageUpdateTask(task);
        inspect(selectedImage);
        widget.setImage(id, selectedImage);
        Navigator.pop(context);
      }
    }

    void handleSetImage(ImageData? image) {
      setState(() => selectedImage = image);
    }

    return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBar(
            title: Text(
              widget.existingTask == null ? 'Add Task' : 'Update Task',
              style: TextStyle(color: Colors.black.withOpacity(0.7)),
            ),
            foregroundColor: Color.fromRGBO(17, 182, 141, 1),
            backgroundColor: theme.backgroundColor,
            elevation: 0,
            actions: [
              TextButton(
                  onPressed:
                      widget.existingTask == null ? handleAdd : handleUpdate,
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromRGBO(17, 182, 141, 1),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      textStyle:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  child: Text(widget.existingTask == null ? 'Add' : 'Update'))
            ]),
        body: SingleChildScrollView(
            child: Container(
          margin: EdgeInsets.only(top: 12),
          padding: EdgeInsets.only(bottom: 48),
          child: Column(
            children: [
              ImagePickerWidget(image: selectedImage, setImage: handleSetImage),
              Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextFormField(
                          hintText: 'Title',
                          initialValue: title,
                          textInputAction: TextInputAction.next,
                          onSaved: (String? value) {
                            if (value == null) return;
                            title = value;
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        CustomTextFormField(
                          minLines: 4,
                          maxLines: 4,
                          hintText: 'Description',
                          initialValue: description,
                          onSaved: (String? value) {
                            if (value == null) return;
                            description = value;
                          },
                        ),
                      ])),
            ],
          ),
        )));
  }
}
