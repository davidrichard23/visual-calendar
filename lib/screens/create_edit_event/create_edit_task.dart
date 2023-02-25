// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'dart:io';

// import 'package:calendar/components/create_calendar_item_button.dart';
// import 'package:calendar/components/create_caregiver_profile.dart';
// import 'package:calendar/components/create_dependent_profile.dart';
import 'package:calendar/components/custom_text_form_field.dart';
import 'package:calendar/components/list_events.dart';
import 'package:calendar/realm/app_services.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/create_edit_event/create_edit_event.dart';
import 'package:calendar/screens/create_edit_event/image_picker.dart';
import 'package:calendar/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

class CreateEditTask extends StatefulWidget {
  final EventTask? existingTask;
  final UploadImageData? pendingImage;
  final Function(EventTask) stageAddTask;
  final Function(EventTask) stageUpdateTask;
  final Function(UploadImageData) stageAddTaskImage;
  final Function(ObjectId) removeTaskImage;
  final String eventId;

  CreateEditTask(
      {Key? key,
      this.existingTask,
      this.pendingImage,
      required this.stageAddTask,
      required this.stageUpdateTask,
      required this.stageAddTaskImage,
      required this.removeTaskImage,
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
  UploadImageData? selectedImage;
  var didRemoveExisitngImage = false;

  @override
  void initState() {
    if (widget.existingTask == null) {
      id = ObjectId();
      return;
    }

    id = widget.existingTask!.id;
    title = widget.existingTask!.title;
    description = widget.existingTask!.description;

    super.initState();
  }

  addImage(File i) {
    final proto = UploadImageData(id: ObjectId(), taskId: id, image: i);
    setState(() {
      selectedImage = proto;
    });
  }

  removeImage(ObjectId id) {
    setState(() {
      selectedImage = null;
    });
  }

  removeExistingImage() {
    setState(() {
      didRemoveExisitngImage = true;
    });
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

        if (selectedImage != null) widget.stageAddTaskImage(selectedImage!);

        EventTask task = EventTask(
            id,
            appState!.activeTeam!.id,
            ObjectId.fromHexString(currentUser!.id),
            ObjectId.fromHexString(widget.eventId),
            title,
            description);
        widget.stageAddTask(task);
        Navigator.pop(context);
      }
    }

    void handleUpdate() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        if (selectedImage != null) {
          if (widget.pendingImage == null) {
            widget.stageAddTaskImage(selectedImage!);
          } else if (widget.pendingImage!.id != selectedImage!.id) {
            widget.removeTaskImage(widget.pendingImage!.id);
            widget.stageAddTaskImage(selectedImage!);
          }
        }
        // else if (widget.pendingImage != null) {
        //   widget.removeTaskImage(widget.pendingImage!.id);
        // }

        ImageData? image;
        if (widget.existingTask!.image != null &&
            !didRemoveExisitngImage &&
            selectedImage == null) {
          image = widget.existingTask!.image;
        }
        EventTask task = EventTask(
            id,
            appState!.activeTeam!.id,
            ObjectId.fromHexString(currentUser!.id),
            ObjectId.fromHexString(widget.eventId),
            title,
            description,
            image: image);

        widget.stageUpdateTask(task);
        Navigator.pop(context);
      }
    }

    return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBar(
            // title: Text(
            //     widget.existingEvent != null ? 'Edit Event' : 'Create Event'),
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
              ImagePickerWidget(
                  existingImage: didRemoveExisitngImage
                      ? null
                      : widget.existingTask?.image,
                  pendingImage: selectedImage ?? widget.pendingImage,
                  addImage: addImage,
                  removeImage: removeImage,
                  removeExistingImage: removeExistingImage),
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

// EventModel.create(
//             realm,
//             Event(ObjectId(), currentUser!.id, 'title', 'description',
//                 'time', 60 * 60,
//                 isComplete: false, images: []));
//       },