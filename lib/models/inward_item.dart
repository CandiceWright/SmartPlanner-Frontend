import 'package:practice_planner/models/event.dart';
import 'package:practice_planner/models/life_category.dart';

class InwardItem {
  int id;
  String caption = "";
  String media = "";
  DateTime date = DateTime.now();

  InwardItem(this.id, this.caption, this.date, this.media);
}
