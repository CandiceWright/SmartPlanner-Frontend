// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '/models/goal.dart';
// import '/services/planner_service.dart';
// import 'package:date_format/date_format.dart';
// import '/models/event.dart';

// class ProfileEditPage extends StatefulWidget {
//   const ProfileEditPage({Key? key, required this.updateEvents})
//       : super(key: key);

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//   final Function updateEvents;

//   @override
//   State<ProfileEditPage> createState() => _ProfileEditPageState();
// }

// class _ProfileEditPageState extends State<ProfileEditPage> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   DateTime selectedStartDate = DateTime.now();
//   TimeOfDay selectedStartTime = TimeOfDay(hour: 00, minute: 00);
//   DateTime selectedEndDate = DateTime.now();
//   TimeOfDay selectedEndTime = TimeOfDay(hour: 00, minute: 00);
//   var startDateTxtController = TextEditingController();
//   var endDateTxtController = TextEditingController();
//   var descriptionTxtController = TextEditingController();
//   var notesTxtController = TextEditingController();
//   var categoryTxtController = TextEditingController();
//   var locationTxtController = TextEditingController();
//   var startTimeController = TextEditingController();
//   var endTimeController = TextEditingController();

//   bool doneBtnDisabled = true;

//   @override
//   void initState() {
//     super.initState();
//     startDateTxtController.addListener(setDoneBtnState);
//     endDateTxtController.addListener(setDoneBtnState);
//     startTimeController.addListener(setDoneBtnState);
//     endTimeController.addListener(setDoneBtnState);
//     descriptionTxtController.addListener(setDoneBtnState);
//   }

//   Future<void> _selectStartDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//         context: context,
//         initialDate: selectedStartDate,
//         firstDate: DateTime(2015, 8),
//         lastDate: DateTime(2101));
//     if (picked != null && picked != selectedStartDate)
//       setState(() {
//         selectedStartDate = picked;
//         startDateTxtController.text =
//             DateFormat.yMMMd().format(selectedStartDate);
//         //print(DateFormat.yMMMd().format(selectedDate));
//       });
//   }

//   Future<void> _selectEndDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//         context: context,
//         initialDate: selectedEndDate,
//         firstDate: DateTime(2015, 8),
//         lastDate: DateTime(2101));
//     if (picked != null && picked != selectedEndDate)
//       setState(() {
//         selectedEndDate = picked;
//         endDateTxtController.text = DateFormat.yMMMd().format(selectedEndDate);
//         //print(DateFormat.yMMMd().format(selectedDate));
//       });
//   }

//   Future<Null> _selectStartTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: selectedStartTime,
//     );
//     if (picked != null) {
//       setState(() {
//         selectedStartTime = picked;
//         String _hour = selectedStartTime.hour.toString();
//         String _minute = selectedStartTime.minute.toString();
//         String _time = _hour + ' : ' + _minute;
//         startTimeController.text = _time;
//         startTimeController.text = formatDate(
//             DateTime(
//                 2019, 08, 1, selectedStartTime.hour, selectedStartTime.minute),
//             [hh, ':', nn, " ", am]).toString();
//       });
//     }
//   }

//   Future<Null> _selectEndTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: selectedEndTime,
//     );
//     if (picked != null) {
//       setState(() {
//         selectedEndTime = picked;
//         String _hour = selectedEndTime.hour.toString();
//         String _minute = selectedEndTime.minute.toString();
//         String _time = _hour + ' : ' + _minute;
//         endTimeController.text = _time;
//         endTimeController.text = formatDate(
//             DateTime(2019, 08, 1, selectedEndTime.hour, selectedEndTime.minute),
//             [hh, ':', nn, " ", am]).toString();
//       });
//     }
//   }

//   void createEvent() {
//     var eventTitle = descriptionTxtController.text;
//     var eventNotes = notesTxtController.text;
//     var category = categoryTxtController.text;
//     var eventLocation = locationTxtController.text;
//     var startDateTime = DateTime(
//         selectedStartDate.year,
//         selectedStartDate.month,
//         selectedStartDate.day,
//         selectedStartTime.hour,
//         selectedStartTime.minute);
//     var endDateTime = DateTime(selectedEndDate.year, selectedEndDate.month,
//         selectedEndDate.day, selectedEndTime.hour, selectedEndTime.minute);
//     var newEvent = Event(
//         id: PlannerService.sharedInstance.user.allEvents.length,
//         eventName: eventTitle,
//         type: "Calendar",
//         start: startDateTime,
//         end: endDateTime,
//         background: const Color(0xFFFF80b1),
//         isAllDay: false,
//         notes: eventNotes,
//         category: category,
//         location: eventLocation);

//     PlannerService.sharedInstance.user.allEvents.add(newEvent);
//     widget.updateEvents();
//     _backToEventsPage();
//   }

//   void setDoneBtnState() {
//     print(descriptionTxtController.text);
//     if (startDateTxtController.text != "" &&
//         endDateTxtController.text != "" &&
//         startTimeController.text != "" &&
//         endTimeController.text != "" &&
//         descriptionTxtController.text != "") {
//       setState(() {
//         print("button enabled");
//         doneBtnDisabled = false;
//       });
//     } else {
//       setState(() {
//         doneBtnDisabled = true;
//       });
//     }
//   }

//   void _backToEventsPage() {
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text("Profile"),
//         centerTitle: true,
//         leading: BackButton(color: Colors.black),
//       ),
//       body: Card(
//         child: Container(
//           child: ListView(
//             children: [
//               Image.asset(
//                 PlannerService.sharedInstance.user.profileImage,
//                 height: 80,
//                 width: 80,
//               ),
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Container(
//                       child: TextFormField(
//                         controller: descriptionTxtController,
//                         decoration: const InputDecoration(
//                           hintText: "What's the event?",
//                         ),
//                         validator: (String? value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter some text';
//                           }
//                           return null;
//                         },
//                       ),
//                       padding: EdgeInsets.all(20),
//                     ),
//                     Row(
//                       children: [
//                         Flexible(
//                           child: Padding(
//                             child: TextFormField(
//                               controller: startDateTxtController,
//                               readOnly: true,
//                               decoration: const InputDecoration(
//                                 hintText: "Start Date",
//                                 icon: Icon(
//                                   Icons.calendar_today,
//                                   color: Colors.pink,
//                                 ),
//                               ),
//                               onTap: () => _selectStartDate(context),
//                               validator: (String? value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter some text';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             padding: EdgeInsets.all(20),
//                           ),
//                         ),
//                         Flexible(
//                           child: Padding(
//                             child: TextFormField(
//                               controller: startTimeController,
//                               readOnly: true,
//                               decoration: const InputDecoration(
//                                 hintText: "Time",
//                                 icon: Icon(
//                                   Icons.timer,
//                                   color: Colors.pink,
//                                 ),
//                               ),
//                               onTap: () => _selectStartTime(context),
//                               validator: (String? value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter some text';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             padding: EdgeInsets.all(20),
//                           ),
//                         )
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         Flexible(
//                           child: Padding(
//                             child: TextFormField(
//                               controller: endDateTxtController,
//                               readOnly: true,
//                               decoration: const InputDecoration(
//                                 hintText: "End Date",
//                                 icon: Icon(
//                                   Icons.calendar_today,
//                                   color: Colors.pink,
//                                 ),
//                               ),
//                               onTap: () => _selectEndDate(context),
//                               validator: (String? value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter some text';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             padding: EdgeInsets.all(20),
//                           ),
//                         ),
//                         Flexible(
//                           child: Padding(
//                             child: TextFormField(
//                               controller: endTimeController,
//                               readOnly: true,
//                               decoration: const InputDecoration(
//                                 hintText: "Time",
//                                 icon: Icon(
//                                   Icons.timer,
//                                   color: Colors.pink,
//                                 ),
//                               ),
//                               onTap: () => _selectEndTime(context),
//                               validator: (String? value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter some text';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             padding: EdgeInsets.all(20),
//                           ),
//                         )
//                       ],
//                     ),

//                     // Container(
//                     //   child: TextFormField(
//                     //     controller: toDateTxtController,
//                     //     readOnly: true,
//                     //     decoration: const InputDecoration(
//                     //       hintText: "To",
//                     //       icon: Icon(
//                     //         Icons.calendar_today,
//                     //         color: Colors.pink,
//                     //       ),
//                     //     ),
//                     //     onTap: () => _selectToDate(context),
//                     //     validator: (String? value) {
//                     //       if (value == null || value.isEmpty) {
//                     //         return 'Please enter some text';
//                     //       }
//                     //       return null;
//                     //     },
//                     //   ),
//                     //   padding: EdgeInsets.all(20),
//                     // ),
//                     Container(
//                       child: TextFormField(
//                         controller: locationTxtController,
//                         decoration: const InputDecoration(
//                           hintText: "Location",
//                           icon: Icon(
//                             Icons.location_pin,
//                             color: Colors.pink,
//                           ),
//                         ),
//                         validator: (String? value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter some text';
//                           }
//                           return null;
//                         },
//                       ),
//                       padding: EdgeInsets.all(20),
//                     ),
//                     Container(
//                       child: TextFormField(
//                         controller: categoryTxtController,
//                         decoration: const InputDecoration(
//                             hintText: "Category",
//                             icon: Icon(
//                               Icons.category_rounded,
//                               color: Colors.pink,
//                             )),
//                         validator: (String? value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter some text';
//                           }
//                           return null;
//                         },
//                       ),
//                       padding: EdgeInsets.all(20),
//                     ),
//                     Container(
//                       child: TextFormField(
//                         controller: notesTxtController,
//                         decoration: const InputDecoration(
//                           hintText: "Notes",
//                           fillColor: Colors.white,
//                         ),
//                         validator: (String? value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter some text';
//                           }
//                           return null;
//                         },
//                         maxLines: null,
//                         minLines: 10,
//                       ),
//                       padding: EdgeInsets.all(20),
//                       margin: EdgeInsets.only(top: 10),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//           margin: EdgeInsets.all(15),
//         ),
//         color: Colors.pink.shade50,
//         // margin: EdgeInsets.all(20),
//         margin: EdgeInsets.only(top: 15, bottom: 40, left: 15, right: 15),
//         elevation: 5,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//       ),
//     );
//   }
// }
