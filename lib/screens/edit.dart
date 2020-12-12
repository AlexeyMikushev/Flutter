import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/painting.dart' as prefix0;
import 'package:flutter/widgets.dart';
//impo rt package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notes/data/models.dart';
import 'package:notes/services/database.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class EditNotePage extends StatefulWidget {
  Function() triggerRefetch;
  NotesModel existingNote;

  EditNotePage({Key key, Function() triggerRefetch, NotesModel existingNote})
      : super(key: key) {
    this.triggerRefetch = triggerRefetch;
    this.existingNote = existingNote;
  }
  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  // FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin;
  bool isDirty = false;
  bool isNoteNew = true;
  FocusNode titleFocus = FocusNode();
  FocusNode contentFocus = FocusNode();

  NotesModel currentNote;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TimeOfDay _time;
  DateTime pickedDate;

  @override
  void initState() {
    super.initState();
    _time = TimeOfDay.now();
    pickedDate = DateTime.now();
    if (widget.existingNote == null) {
      currentNote = NotesModel(
          content: '', title: '', date: DateTime.now(), isNotify: false);
      isNoteNew = true;
    } else {
      currentNote = widget.existingNote;
      isNoteNew = false;
    }
    titleController.text = currentNote.title;
    contentController.text = currentNote.content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                Container(
                  height: 80,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    focusNode: titleFocus,
                    autofocus: true,
                    controller: titleController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onSubmitted: (text) {
                      titleFocus.unfocus();
                      FocusScope.of(context).requestFocus(contentFocus);
                    },
                    onChanged: (value) {
                      markTitleAsDirty(value);
                    },
                    textInputAction: TextInputAction.next,
                    style: TextStyle(
                        fontFamily: 'ZillaSlab',
                        fontSize: 32,
                        fontWeight: FontWeight.w700),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Enter a title',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 32,
                          fontFamily: 'ZillaSlab',
                          fontWeight: FontWeight.w700),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    focusNode: contentFocus,
                    controller: contentController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onChanged: (value) {
                      markContentAsDirty(value);
                    },
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Start typing...',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                    ),
                  ),
                )
              ],
            ),
            ClipRect(
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: 80,
                    color: Theme.of(context).canvasColor.withOpacity(0.3),
                    child: SafeArea(
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: handleBack,
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () => {
                              _pickDate()
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.access_time),
                            onPressed: () => {

                              _pickTime()
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline),
                            onPressed: () {
                              handleDelete();
                            },
                          ),
                          AnimatedContainer(
                            margin: EdgeInsets.only(left: 10),
                            duration: Duration(milliseconds: 200),
                            width: isDirty ? 100 : 0,
                            height: 42,
                            curve: Curves.decelerate,
                            child: RaisedButton.icon(
                              color: Theme.of(context).accentColor,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(100),
                                      bottomLeft: Radius.circular(100))),
                              icon: Icon(Icons.done),
                              label: Text(
                                'SAVE',
                                style: TextStyle(letterSpacing: 1),
                              ),
                              onPressed: handleSave,
                            ),
                          )
                        ],
                      ),
                    ),
                  )),
            )
          ],
        ));
  }

  void handleSave() async {
    setState(() {
      currentNote.title = titleController.text;
      currentNote.content = contentController.text;
      //var date = new DateTime.now();
      currentNote.dateNotification = new DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
          _time.hour, _time.minute);
      // scheduleNotification(currentNote.dateNotification);
      //  currentNote.dateNotification = date;
      print('Hey there ${currentNote.content}');
    });
    if (isNoteNew) {
      var latestNote = await NotesDatabaseService.db.addNoteInDB(currentNote);
      setState(() {
        currentNote = latestNote;
      });
    } else {
      await NotesDatabaseService.db.updateNoteInDB(currentNote);
    }
    setState(() {
      isNoteNew = false;
      isDirty = false;
    });
    widget.triggerRefetch();
    titleFocus.unfocus();
    contentFocus.unfocus();
  }

  void markTitleAsDirty(String title) {
    setState(() {
      isDirty = true;
    });
  }

  void markContentAsDirty(String content) {
    setState(() {
      isDirty = true;
    });
  }
/*
  Future<void> scheduleNotification(DateTime time) async {
    var sheduleNotificationDateTime = time;
    var androidChannel = AndroidNotificationDetails(
        'channelId', 'channelName', 'channelDescription');
    if (currentNote.isNotify == true) {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '0',
        'Reminder notifications',
        'Remember about it',
        icon: 'app_icon',
      );
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

      await flutterLocalNotificationPlugin.schedule(
          0,
          'Shedule Test Title',
          'Shedule test body',
          sheduleNotificationDateTime,
        platformChannelSpecifics
      );
    }
  }*/


  _pickTime() async {
    TimeOfDay time = await showTimePicker(context: context, initialTime: _time,
        builder: (BuildContext context, Widget child) {
          return Theme(data: ThemeData(), child: child,);
        }
    );
    if (time != null)
      setState(() {
        _time = time;
      });
  }

  _pickDate() async {

    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 1),
      initialDate: pickedDate,
    );
    if (date != null)
      setState(() {
        pickedDate = date;
      });
  }

  void handleDelete() async {
    if (isNoteNew) {
      Navigator.pop(context);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              title: Text('Delete Note'),
              content: Text('Delete Note?'),
              actions: <Widget>[
                FlatButton(
                  child: Text('DELETE',
                      style: prefix0.TextStyle(
                          color: Colors.red.shade300,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1)),
                  onPressed: () async {
                    await NotesDatabaseService.db.deleteNoteInDB(currentNote);
                    widget.triggerRefetch();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('CANCEL',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    }
  }

  void handleBack() {
    Navigator.pop(context);
  }


}
