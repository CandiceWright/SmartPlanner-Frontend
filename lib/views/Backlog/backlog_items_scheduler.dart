//library event_calendar;
//part 'edit_event_page.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../models/backlog_item.dart';
import '../../models/backlog_map_ref.dart';
import '../../services/planner_service.dart';

//part 'edit_event_page.dart';

class BacklogItemsScheduler extends StatefulWidget {
  //final Function updateEvents;
  const BacklogItemsScheduler({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<BacklogItemsScheduler> createState() => _BacklogItemsSchedulerState();
  //EventDataSource(PlannerService.sharedInstance.user.allEvents);
}

class _BacklogItemsSchedulerState extends State<BacklogItemsScheduler> {
  //DateTime _selectedDate = DateTime.now();
  DateTime _selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  CalendarController calController = CalendarController();
  final DateRangePickerController _dateRangePickerController =
      DateRangePickerController();

  List<BacklogMapRef> todaysTasks = PlannerService
          .sharedInstance.user!.scheduledBacklogItemsMap
          .containsKey(DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day))
      ? List.from(PlannerService.sharedInstance.user!.scheduledBacklogItemsMap[
          DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)]!)
      : [];
  // DateTime thisDay =
  //     DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  int selectedMode = 0;
  List<BacklogMapRef> backlogItemsToShow = [];

  @override
  void initState() {
    super.initState();
    // CalendarPage.events =
    //     EventDataSource(PlannerService.sharedInstance.user!.scheduledEvents);
    //calController.displayDate = DateTime.now();
    _dateRangePickerController.selectedDate = _selectedDate;
    buildBacklogList();
  }

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _dateRangePickerController.selectedDate =
          viewChangedDetails.visibleDates[0];
      _dateRangePickerController.displayDate =
          viewChangedDetails.visibleDates[0];
    });
  }

  void selectionChanged(DateRangePickerSelectionChangedArgs args) {
    //print(_dateRangePickerController.selectedDate.toString());
    print("I am in date selection changed");
    print(args.value);

    setState(() {
      _selectedDate = _dateRangePickerController.selectedDate!;
    });
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      setState(() {
        calController.displayDate = args.value;
      });
    });
  }

  void _updateBacklog() {
    setState(() {});
  }

  void openViewDialog(BacklogItem backlogItem, int idx, String key) {
    //item is not scheduled
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: Container(
              child: Text(
                backlogItem.description,
                textAlign: TextAlign.center,
              ),
            ),
            content:
                //Card(
                //child: Container(
                //child: Column(
                Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                backlogItem.completeBy != null
                    ? Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "Deadline " +
                              DateFormat.yMMMd()
                                  .format(backlogItem.completeBy!),
                          style: const TextStyle(
                            // fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.all(4),
                        child: Text("No deadline"),
                      ),
                Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(backlogItem.notes),
                ),
              ],
            ),
            //),
            //),
          );
        });
  }

  buildBacklogList() {
    //new implementation idea
    List<BacklogMapRef> tempbacklogItemsToShow = [];

    PlannerService.sharedInstance.user!.backlogMap.forEach((key, value) {
      // List<BacklogItem> list =
      //     PlannerService.sharedInstance.user!.backlogMap[key]!;
      for (int i = 0; i < value.length; i++) {
        if (value[i].scheduledDate == null && value[i].status != "complete") {
          BacklogMapRef bmr = BacklogMapRef(categoryName: key, arrayIdx: i);
          tempbacklogItemsToShow.add(bmr);
        }
      }
    });

    tempbacklogItemsToShow.sort((backlogItem1, backlogItem2) {
      DateTime backlogItem1Date = PlannerService
          .sharedInstance
          .user!
          .backlogMap[backlogItem1.categoryName]![backlogItem1.arrayIdx]
          .completeBy!;
      DateTime backlogItem2Date = PlannerService
          .sharedInstance
          .user!
          .backlogMap[backlogItem2.categoryName]![backlogItem2.arrayIdx]
          .completeBy!;
      return backlogItem1Date.compareTo(backlogItem2Date);
    });

    setState(() {
      backlogItemsToShow = tempbacklogItemsToShow;
    });
  }

  Widget buildTasksView() {
    return Column(
      children: [
        //was Expanded
        Container(
          //color: Colors.white,
          child: Column(children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child:
                            // Text(
                            //   DateFormat.MMM()
                            //       .format(_dateRangePickerController.selectedDate!),
                            Text(
                          DateFormat.MMM().format(_selectedDate),
                          style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .fontSize),
                          // fontSize: Theme.of(context).textTheme.subtitle2!.fontSize),
                        ),
                      ),
                      Text(
                        _selectedDate.year.toString(),
                        // _dateRangePickerController.selectedDate!.year
                        //     .toString(),
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .fontSize),
                        // fontSize: Theme.of(context).textTheme.subtitle2!.fontSize),
                      )
                    ]),
                  ),
                ],
              ),
            ),
            Container(
              height: 100,
              child: SfDateRangePicker(
                backgroundColor: Colors.white,
                headerHeight: 0,
                controller: _dateRangePickerController,
                //showNavigationArrow: true,
                allowViewNavigation: false,
                monthViewSettings:
                    DateRangePickerMonthViewSettings(numberOfWeeksInView: 1),
                onSelectionChanged: selectionChanged,
              ),
            ),
          ]),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        child: Text(
                          "Backlog",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      //Expanded(child: Text("List goes here"))
                      Expanded(
                        child: backlogItemsToShow.isEmpty
                            ? Container(
                                margin: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "No backlog items have been created yet. Click the plus sign to get started or the info button at the top to learn more.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ))
                            : ListView(
                                //children: buildBacklogListView(),
                                //children: currentlyShownBacklogItems,
                                children: List.generate(
                                    backlogItemsToShow.length, (index) {
                                  return GestureDetector(
                                      onTap: () {
                                        openViewDialog(
                                            PlannerService.sharedInstance.user!
                                                        .backlogMap[
                                                    backlogItemsToShow[index]
                                                        .categoryName]![
                                                backlogItemsToShow[index]
                                                    .arrayIdx],
                                            backlogItemsToShow[index].arrayIdx,
                                            backlogItemsToShow[index]
                                                .categoryName);
                                      },
                                      child: Card(
                                        margin: EdgeInsets.all(15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: BorderSide(
                                            //color: Color(0xffd1849e),
                                            color: PlannerService
                                                    .sharedInstance
                                                    .user!
                                                    .LifeCategoriesColorMap[
                                                backlogItemsToShow[index]
                                                    .categoryName]!,
                                            width: 2.0,
                                          ),
                                        ),
                                        color: PlannerService
                                                    .sharedInstance
                                                    .user!
                                                    .backlogMap[
                                                        backlogItemsToShow[
                                                                index]
                                                            .categoryName]![
                                                        backlogItemsToShow[
                                                                index]
                                                            .arrayIdx]
                                                    .status ==
                                                "notStarted"
                                            ? Colors.grey.shade100
                                            : (PlannerService
                                                        .sharedInstance
                                                        .user!
                                                        .backlogMap[
                                                            backlogItemsToShow[
                                                                    index]
                                                                .categoryName]![
                                                            backlogItemsToShow[
                                                                    index]
                                                                .arrayIdx]
                                                        .status ==
                                                    "complete"
                                                ? Colors.green.shade200
                                                : Colors.yellow.shade200),
                                        elevation: 2,
                                        child: ListTile(
                                          // leading: Icon(
                                          //   Icons.circle,
                                          //   color: PlannerService
                                          //           .sharedInstance
                                          //           .user!
                                          //           .LifeCategoriesColorMap[
                                          //       backlogItemsToShow[index]
                                          //           .categoryName],
                                          // ),
                                          title: Padding(
                                            padding: EdgeInsets.only(bottom: 5),
                                            child: Text(
                                              PlannerService
                                                  .sharedInstance
                                                  .user!
                                                  .backlogMap[
                                                      backlogItemsToShow[index]
                                                          .categoryName]![
                                                      backlogItemsToShow[index]
                                                          .arrayIdx]
                                                  .description,
                                              style: const TextStyle(
                                                  // color: PlannerService.sharedInstance.user!
                                                  //     .backlogMap[key]![i].category.color,
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "Complete by " +
                                                DateFormat.yMMMd().format(
                                                    PlannerService
                                                        .sharedInstance
                                                        .user!
                                                        .backlogMap[
                                                            backlogItemsToShow[
                                                                    index]
                                                                .categoryName]![
                                                            backlogItemsToShow[
                                                                    index]
                                                                .arrayIdx]
                                                        .completeBy!),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ));
                                }),
                              ),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                      border: Border(
                    right: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1.0,
                    ),
                  )),
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        child: Text("To Do This Day",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),

                      //Expanded(child: Text("List goes here"))
                      Expanded(
                        //height: 150,
                        //was a column

                        child: !PlannerService.sharedInstance.user!
                                    .scheduledBacklogItemsMap
                                    .containsKey(_selectedDate) ||
                                PlannerService
                                    .sharedInstance
                                    .user!
                                    .scheduledBacklogItemsMap[_selectedDate]!
                                    .isEmpty
                            //child: todaysTasks.length == 0
                            ? Container(
                                alignment: Alignment.center,
                                child: Text("No Tasks Yet."),
                              )
                            : ListView(
                                children: List.generate(
                                    PlannerService
                                        .sharedInstance
                                        .user!
                                        .scheduledBacklogItemsMap[
                                            _selectedDate]!
                                        .length, (int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      //show dialog
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                PlannerService
                                                    .sharedInstance
                                                    .user!
                                                    .backlogMap[PlannerService
                                                            .sharedInstance
                                                            .user!
                                                            .scheduledBacklogItemsMap[
                                                                _selectedDate]![
                                                                index]
                                                            .categoryName]![
                                                        PlannerService
                                                            .sharedInstance
                                                            .user!
                                                            .scheduledBacklogItemsMap[
                                                                _selectedDate]![
                                                                index]
                                                            .arrayIdx]
                                                    .description,
                                                textAlign: TextAlign.center,
                                              ),

                                              content:
                                                  //Card(
                                                  //child: Container(
                                                  //child: Column(
                                                  Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Text(
                                                      "Complete by " +
                                                          DateFormat.yMMMd().format(PlannerService
                                                              .sharedInstance
                                                              .user!
                                                              .backlogMap[
                                                                  PlannerService
                                                                      .sharedInstance
                                                                      .user!
                                                                      .scheduledBacklogItemsMap[
                                                                          _selectedDate]![
                                                                          index]
                                                                      .categoryName]![
                                                                  PlannerService
                                                                      .sharedInstance
                                                                      .user!
                                                                      .scheduledBacklogItemsMap[
                                                                          _selectedDate]![
                                                                          index]
                                                                      .arrayIdx]
                                                              .completeBy!),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Text(PlannerService
                                                        .sharedInstance
                                                        .user!
                                                        .backlogMap[
                                                            PlannerService
                                                                .sharedInstance
                                                                .user!
                                                                .scheduledBacklogItemsMap[
                                                                    _selectedDate]![
                                                                    index]
                                                                .categoryName]![
                                                            PlannerService
                                                                .sharedInstance
                                                                .user!
                                                                .scheduledBacklogItemsMap[
                                                                    _selectedDate]![
                                                                    index]
                                                                .arrayIdx]
                                                        .notes),
                                                  ),
                                                ],
                                              ),
                                              //),
                                              //),
                                            );
                                          });
                                    },
                                    child: Card(
                                      margin: EdgeInsets.all(15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          //color: Color(0xffd1849e),
                                          color: PlannerService
                                              .sharedInstance
                                              .user!
                                              .backlogMap[PlannerService
                                                      .sharedInstance
                                                      .user!
                                                      .scheduledBacklogItemsMap[
                                                          _selectedDate]![index]
                                                      .categoryName]![
                                                  PlannerService
                                                      .sharedInstance
                                                      .user!
                                                      .scheduledBacklogItemsMap[
                                                          _selectedDate]![index]
                                                      .arrayIdx]
                                              .category
                                              .color,
                                          width: 2.0,
                                        ),
                                      ),
                                      color: PlannerService
                                                  .sharedInstance
                                                  .user!
                                                  .backlogMap[PlannerService
                                                          .sharedInstance
                                                          .user!
                                                          .scheduledBacklogItemsMap[
                                                              _selectedDate]![index]
                                                          .categoryName]![
                                                      PlannerService
                                                          .sharedInstance
                                                          .user!
                                                          .scheduledBacklogItemsMap[_selectedDate]![
                                                              index]
                                                          .arrayIdx]
                                                  .status ==
                                              "notStarted"
                                          ? Colors.grey.shade100
                                          : (PlannerService
                                                      .sharedInstance
                                                      .user!
                                                      .backlogMap[PlannerService
                                                          .sharedInstance
                                                          .user!
                                                          .scheduledBacklogItemsMap[
                                                              _selectedDate]![index]
                                                          .categoryName]![PlannerService.sharedInstance.user!.scheduledBacklogItemsMap[_selectedDate]![index].arrayIdx]
                                                      .status ==
                                                  "complete"
                                              ? Colors.green.shade200
                                              : Colors.yellow.shade200),
                                      elevation: 2,
                                      child: ListTile(
                                        // leading: Icon(
                                        //   Icons.circle,
                                        //   color: PlannerService
                                        //       .sharedInstance
                                        //       .user!
                                        //       .backlogMap[PlannerService
                                        //               .sharedInstance
                                        //               .user!
                                        //               .scheduledBacklogItemsMap[
                                        //                   _selectedDate]![index]
                                        //               .categoryName]![
                                        //           PlannerService
                                        //               .sharedInstance
                                        //               .user!
                                        //               .scheduledBacklogItemsMap[
                                        //                   _selectedDate]![index]
                                        //               .arrayIdx]
                                        //       .category
                                        //       .color,
                                        // ),
                                        title: Padding(
                                          padding: EdgeInsets.only(bottom: 5),
                                          child: Text(
                                            PlannerService
                                                .sharedInstance
                                                .user!
                                                .backlogMap[
                                                    PlannerService
                                                        .sharedInstance
                                                        .user!
                                                        .scheduledBacklogItemsMap[
                                                            _selectedDate]![
                                                            index]
                                                        .categoryName]![
                                                    PlannerService
                                                        .sharedInstance
                                                        .user!
                                                        .scheduledBacklogItemsMap[
                                                            _selectedDate]![
                                                            index]
                                                        .arrayIdx]
                                                .description,
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
        // Row(
        //   children: [
        //     Column(
        //       children: [
        //         Text("Backlog"),
        //         Expanded(
        //           child: backlogItemsToShow.isEmpty
        //               ? Container(
        //                   margin: EdgeInsets.all(10),
        //                   child: Column(
        //                     mainAxisAlignment: MainAxisAlignment.center,
        //                     children: const [
        //                       Text(
        //                         "No backlog items have been created yet. Click the plus sign to get started or the info button at the top to learn more.",
        //                         textAlign: TextAlign.center,
        //                         style: TextStyle(color: Colors.grey),
        //                       ),
        //                     ],
        //                   ))
        //               : ListView(
        //                   //children: buildBacklogListView(),
        //                   //children: currentlyShownBacklogItems,
        //                   children:
        //                       List.generate(backlogItemsToShow.length, (index) {
        //                     return GestureDetector(
        //                         onTap: () {
        //                           openViewDialog(
        //                               PlannerService.sharedInstance.user!
        //                                       .backlogMap[backlogItemsToShow[
        //                                           index]
        //                                       .categoryName]![
        //                                   backlogItemsToShow[index].arrayIdx],
        //                               backlogItemsToShow[index].arrayIdx,
        //                               backlogItemsToShow[index].categoryName);
        //                         },
        //                         child: Card(
        //                           margin: EdgeInsets.all(15),
        //                           shape: RoundedRectangleBorder(
        //                             borderRadius: BorderRadius.circular(15),
        //                           ),
        //                           color: PlannerService
        //                                       .sharedInstance
        //                                       .user!
        //                                       .backlogMap[
        //                                           backlogItemsToShow[index]
        //                                               .categoryName]![
        //                                           backlogItemsToShow[index]
        //                                               .arrayIdx]
        //                                       .status ==
        //                                   "notStarted"
        //                               ? Colors.grey.shade100
        //                               : (PlannerService
        //                                           .sharedInstance
        //                                           .user!
        //                                           .backlogMap[
        //                                               backlogItemsToShow[index]
        //                                                   .categoryName]![
        //                                               backlogItemsToShow[index]
        //                                                   .arrayIdx]
        //                                           .status ==
        //                                       "complete"
        //                                   ? Colors.green.shade200
        //                                   : Colors.yellow.shade200),
        //                           elevation: 5,
        //                           child: ListTile(
        //                             leading: Icon(
        //                               Icons.circle,
        //                               color: PlannerService.sharedInstance.user!
        //                                       .LifeCategoriesColorMap[
        //                                   backlogItemsToShow[index]
        //                                       .categoryName],
        //                             ),
        //                             title: Padding(
        //                               padding: EdgeInsets.only(bottom: 5),
        //                               child: Text(
        //                                 PlannerService
        //                                     .sharedInstance
        //                                     .user!
        //                                     .backlogMap[
        //                                         backlogItemsToShow[index]
        //                                             .categoryName]![
        //                                         backlogItemsToShow[index]
        //                                             .arrayIdx]
        //                                     .description,
        //                                 style: const TextStyle(
        //                                     // color: PlannerService.sharedInstance.user!
        //                                     //     .backlogMap[key]![i].category.color,
        //                                     color: Colors.black,
        //                                     fontSize: 16,
        //                                     fontWeight: FontWeight.bold),
        //                                 maxLines: 2,
        //                                 textAlign: TextAlign.center,
        //                               ),
        //                             ),
        //                             subtitle: Text(
        //                               "Complete by " +
        //                                   DateFormat.yMMMd().format(
        //                                       PlannerService
        //                                           .sharedInstance
        //                                           .user!
        //                                           .backlogMap[
        //                                               backlogItemsToShow[index]
        //                                                   .categoryName]![
        //                                               backlogItemsToShow[index]
        //                                                   .arrayIdx]
        //                                           .completeBy!),
        //                               textAlign: TextAlign.center,
        //                             ),
        //                           ),
        //                         ));
        //                   }),
        //                 ),
        //         )
        //       ],
        //     ),
        //     Column(
        //       children: [
        //         Text("To Do This Day"),
        //         Expanded(
        //           //height: 150,
        //           //was a column

        //           child: !PlannerService
        //                       .sharedInstance.user!.scheduledBacklogItemsMap
        //                       .containsKey(_selectedDate) ||
        //                   PlannerService.sharedInstance.user!
        //                       .scheduledBacklogItemsMap[_selectedDate]!.isEmpty
        //               //child: todaysTasks.length == 0
        //               ? Container(
        //                   alignment: Alignment.center,
        //                   child: Text("No Tasks Yet."),
        //                 )
        //               : ListView(
        //                   children: List.generate(
        //                       PlannerService
        //                           .sharedInstance
        //                           .user!
        //                           .scheduledBacklogItemsMap[_selectedDate]!
        //                           .length, (int index) {
        //                     return GestureDetector(
        //                       onTap: () {
        //                         //show dialog
        //                         showDialog(
        //                             context: context,
        //                             builder: (BuildContext context) {
        //                               return AlertDialog(
        //                                 title: Text(
        //                                   PlannerService
        //                                       .sharedInstance
        //                                       .user!
        //                                       .backlogMap[PlannerService
        //                                               .sharedInstance
        //                                               .user!
        //                                               .scheduledBacklogItemsMap[
        //                                                   _selectedDate]![index]
        //                                               .categoryName]![
        //                                           PlannerService
        //                                               .sharedInstance
        //                                               .user!
        //                                               .scheduledBacklogItemsMap[
        //                                                   _selectedDate]![index]
        //                                               .arrayIdx]
        //                                       .description,
        //                                   textAlign: TextAlign.center,
        //                                 ),

        //                                 content:
        //                                     //Card(
        //                                     //child: Container(
        //                                     //child: Column(
        //                                     Column(
        //                                   mainAxisSize: MainAxisSize.min,
        //                                   mainAxisAlignment:
        //                                       MainAxisAlignment.center,
        //                                   children: [
        //                                     Padding(
        //                                       padding: EdgeInsets.all(5),
        //                                       child: Text(
        //                                         "Complete by " +
        //                                             DateFormat.yMMMd().format(PlannerService
        //                                                 .sharedInstance
        //                                                 .user!
        //                                                 .backlogMap[
        //                                                     PlannerService
        //                                                         .sharedInstance
        //                                                         .user!
        //                                                         .scheduledBacklogItemsMap[
        //                                                             _selectedDate]![
        //                                                             index]
        //                                                         .categoryName]![
        //                                                     PlannerService
        //                                                         .sharedInstance
        //                                                         .user!
        //                                                         .scheduledBacklogItemsMap[
        //                                                             _selectedDate]![
        //                                                             index]
        //                                                         .arrayIdx]
        //                                                 .completeBy!),
        //                                       ),
        //                                     ),
        //                                     Padding(
        //                                       padding: EdgeInsets.all(5),
        //                                       child: Text(PlannerService
        //                                           .sharedInstance
        //                                           .user!
        //                                           .backlogMap[
        //                                               PlannerService
        //                                                   .sharedInstance
        //                                                   .user!
        //                                                   .scheduledBacklogItemsMap[
        //                                                       _selectedDate]![
        //                                                       index]
        //                                                   .categoryName]![
        //                                               PlannerService
        //                                                   .sharedInstance
        //                                                   .user!
        //                                                   .scheduledBacklogItemsMap[
        //                                                       _selectedDate]![
        //                                                       index]
        //                                                   .arrayIdx]
        //                                           .notes),
        //                                     ),
        //                                   ],
        //                                 ),
        //                                 //),
        //                                 //),
        //                               );
        //                             });
        //                       },
        //                       child: Card(
        //                         margin: EdgeInsets.all(15),
        //                         shape: RoundedRectangleBorder(
        //                           borderRadius: BorderRadius.circular(15),
        //                         ),
        //                         color: PlannerService
        //                                     .sharedInstance
        //                                     .user!
        //                                     .backlogMap[PlannerService
        //                                             .sharedInstance
        //                                             .user!
        //                                             .scheduledBacklogItemsMap[
        //                                                 _selectedDate]![index]
        //                                             .categoryName]![
        //                                         PlannerService
        //                                             .sharedInstance
        //                                             .user!
        //                                             .scheduledBacklogItemsMap[
        //                                                 _selectedDate]![index]
        //                                             .arrayIdx]
        //                                     .status ==
        //                                 "notStarted"
        //                             ? Colors.grey.shade100
        //                             : (PlannerService
        //                                         .sharedInstance
        //                                         .user!
        //                                         .backlogMap[PlannerService
        //                                             .sharedInstance
        //                                             .user!
        //                                             .scheduledBacklogItemsMap[_selectedDate]![index]
        //                                             .categoryName]![PlannerService.sharedInstance.user!.scheduledBacklogItemsMap[_selectedDate]![index].arrayIdx]
        //                                         .status ==
        //                                     "complete"
        //                                 ? Colors.green.shade200
        //                                 : Colors.yellow.shade200),
        //                         elevation: 5,
        //                         child: ListTile(
        //                           leading: Icon(
        //                             Icons.circle,
        //                             color: PlannerService
        //                                 .sharedInstance
        //                                 .user!
        //                                 .backlogMap[PlannerService
        //                                         .sharedInstance
        //                                         .user!
        //                                         .scheduledBacklogItemsMap[
        //                                             _selectedDate]![index]
        //                                         .categoryName]![
        //                                     PlannerService
        //                                         .sharedInstance
        //                                         .user!
        //                                         .scheduledBacklogItemsMap[
        //                                             _selectedDate]![index]
        //                                         .arrayIdx]
        //                                 .category
        //                                 .color,
        //                           ),
        //                           title: Padding(
        //                             padding: EdgeInsets.only(bottom: 5),
        //                             child: Text(
        //                               PlannerService
        //                                   .sharedInstance
        //                                   .user!
        //                                   .backlogMap[PlannerService
        //                                           .sharedInstance
        //                                           .user!
        //                                           .scheduledBacklogItemsMap[
        //                                               _selectedDate]![index]
        //                                           .categoryName]![
        //                                       PlannerService
        //                                           .sharedInstance
        //                                           .user!
        //                                           .scheduledBacklogItemsMap[
        //                                               _selectedDate]![index]
        //                                           .arrayIdx]
        //                                   .description,
        //                               maxLines: 2,
        //                               textAlign: TextAlign.center,
        //                             ),
        //                           ),
        //                         ),
        //                       ),
        //                     );
        //                   }),
        //                 ),
        //         ),
        //       ],
        //     )
        //   ],
        // ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    // return Stack(
    //   children: [
    //     Image.asset(
    //       PlannerService.sharedInstance.user!.spaceImage,
    //       height: MediaQuery.of(context).size.height,
    //       width: MediaQuery.of(context).size.width,
    //       fit: BoxFit.cover,
    //     ),
    return Scaffold(
      //backgroundColor: Colors.transparent,
      backgroundColor: Colors.white,

      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        backgroundColor: Colors.transparent,
        title:
            const Text("Task Scheduler", style: TextStyle(color: Colors.white)),

        automaticallyImplyLeading: true,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    PlannerService.sharedInstance.user!.spaceImage,
                  ),
                  fit: BoxFit.fill)),
        ),

        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor, //change your color here
        ),
      ),

      body: buildTasksView(),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
    //],
    //);
  }
}
