import 'dart:math';

class NotesModel {
  int id;
  String title;
  String content;
  DateTime date;
  bool isNotify;
  DateTime dateNotification;

  NotesModel({this.id, this.title, this.content, this.isNotify, this.date, this.dateNotification});

  NotesModel.fromMap(Map<String, dynamic> map) {
    this.id = map['_id'];
    this.title = map['title'];
    this.content = map['content'];
    this.date = DateTime.parse(map['date']);
    this.isNotify = map['isNotify'] == 1 ? true : false;
    this.dateNotification = DateTime.parse(map['dateNotification']);

  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': this.id,
      'title': this.title,
      'content': this.content,
      'isNotify': this.isNotify == true ? 1 : 0,
      'date': this.date.toIso8601String(),
      'dateNotification': this.date.toIso8601String()
    };
  }

  NotesModel.random() {
    this.id = Random(10).nextInt(1000) + 1;
    this.title = 'Lorem Ipsum ' * (Random().nextInt(4) + 1);
    this.content = 'Lorem Ipsum ' * (Random().nextInt(4) + 1);
    this.date = DateTime.now().add(Duration(hours: Random().nextInt(100)));
    this.isNotify = Random().nextBool();
    this.dateNotification = DateTime.now().add(Duration(hours: Random().nextInt(120)));
  }
}
