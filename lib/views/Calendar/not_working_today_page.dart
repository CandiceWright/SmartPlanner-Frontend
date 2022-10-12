  // buildCompletedList() {
  //   //new implementation idea
  //   List<BacklogMapRef> tempCompletedItemsToShow = [];

  //   selectedCategoriesCompletedView.forEach((key, value) {
  //     List<BacklogItem> list =
  //         PlannerService.sharedInstance.user!.backlogMap[key]!;
  //     for (int i = 0; i < list.length; i++) {
  //       if (list[i].status == "complete") {
  //         BacklogMapRef bmr = BacklogMapRef(categoryName: key, arrayIdx: i);
  //         tempCompletedItemsToShow.add(bmr);
  //       }
  //     }
  //   });

  //   tempCompletedItemsToShow.sort((backlogItem1, backlogItem2) {
  //     DateTime backlogItem1Date = PlannerService
  //         .sharedInstance
  //         .user!
  //         .backlogMap[backlogItem1.categoryName]![backlogItem1.arrayIdx]
  //         .completeBy!;
  //     DateTime backlogItem2Date = PlannerService
  //         .sharedInstance
  //         .user!
  //         .backlogMap[backlogItem2.categoryName]![backlogItem2.arrayIdx]
  //         .completeBy!;
  //     return backlogItem1Date.compareTo(backlogItem2Date);
  //   });

  //   setState(() {
  //     completedItemsToShow = tempCompletedItemsToShow;
  //   });
  // }

  //   buildCompletedListView() {
  //   return Column(
  //     children: [
  //       Padding(
  //         padding: EdgeInsets.all(10),
  //         child: ToggleButtons(
  //           children: const <Widget>[
  //             Padding(
  //               padding: EdgeInsets.all(5),
  //               child: Text('Backlog'),
  //             ),
  //             Padding(
  //               padding: EdgeInsets.all(5),
  //               child: Text('Scheduled'),
  //             ),
  //             Padding(
  //               padding: EdgeInsets.all(5),
  //               child: Text('Complete'),
  //             ),
  //           ],
  //           direction: Axis.horizontal,
  //           onPressed: (int index) {
  //             setState(() {
  //               // The button that is tapped is set to true, and the others to false.
  //               for (int i = 0; i < _selectedPageView.length; i++) {
  //                 _selectedPageView[i] = i == index;
  //               }
  //               selectedMode = index;
  //             });
  //           },
  //           borderRadius: const BorderRadius.all(Radius.circular(8)),
  //           selectedBorderColor: Theme.of(context).primaryColor,
  //           selectedColor: Colors.white,
  //           fillColor: Theme.of(context).primaryColor.withAlpha(100),
  //           color: Theme.of(context).primaryColor,
  //           isSelected: _selectedPageView,
  //         ),
  //       ),
  //       Padding(
  //         padding: EdgeInsets.all(10),
  //         child: Container(
  //           height: 80.0,
  //           child: ListView(
  //             scrollDirection: Axis.horizontal,
  //             children: List.generate(
  //                 PlannerService.sharedInstance.user!.lifeCategories.length,
  //                 (int index) {
  //               return GestureDetector(
  //                   onTap: () {
  //                     //first check if it is selected or not
  //                     bool isSelected = selectedCategoriesCompletedView
  //                         .containsKey(PlannerService
  //                             .sharedInstance.user!.lifeCategories[index].name);

  //                     if (isSelected) {
  //                       setState(() {
  //                         selectedCategoriesCompletedView.remove(PlannerService
  //                             .sharedInstance.user!.lifeCategories[index].name);
  //                       });
  //                     } else {
  //                       setState(() {
  //                         selectedCategoriesCompletedView.addAll({
  //                           PlannerService.sharedInstance.user!
  //                                   .lifeCategories[index].name:
  //                               PlannerService.sharedInstance.user!
  //                                   .lifeCategories[index].color
  //                         });
  //                       });
  //                     }
  //                     //updateCurrentlyShownBacklogCards();
  //                     buildCompletedList();
  //                   },
  //                   child: Card(
  //                     //margin: EdgeInsets.all(20),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(10),
  //                       side: BorderSide(
  //                         width: 2.0,
  //                         color: selectedCategoriesCompletedView.containsKey(
  //                                 PlannerService.sharedInstance.user!
  //                                     .lifeCategories[index].name)
  //                             ? Colors.grey.shade700
  //                             : Colors.transparent,
  //                       ),
  //                     ),
  //                     //color: Colors.white,
  //                     color: PlannerService
  //                         .sharedInstance.user!.lifeCategories[index].color,
  //                     elevation: 0,
  //                     //shape: const ContinuousRectangleBorder(),
  //                     shadowColor: PlannerService
  //                         .sharedInstance.user!.lifeCategories[index].color,
  //                     //color: Colors.blue[index * 100],
  //                     child: Flex(direction: Axis.horizontal, children: [
  //                       Column(
  //                         //width: 50.0,
  //                         //height: 50.0,
  //                         children: [
  //                           Padding(
  //                               padding: EdgeInsets.all(10),
  //                               child: Text(
  //                                 PlannerService.sharedInstance.user!
  //                                     .lifeCategories[index].name,
  //                                 style: TextStyle(color: Colors.white),
  //                               )),
  //                           // Icon(
  //                           //   Icons.circle,
  //                           //   color: PlannerService.sharedInstance.user!
  //                           //       .lifeCategories[index].color,
  //                           // ),
  //                         ],
  //                       )
  //                     ]),
  //                   ));
  //             }),
  //           ),
  //           color: Colors.white,
  //         ),
  //       ),
  //       Expanded(
  //         child: completedItemsToShow.isEmpty
  //             ? Container(
  //                 margin: EdgeInsets.all(10),
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: const [
  //                     Text(
  //                       "No scheduled tasks. Use the calendar tab to schedule tasks.",
  //                       textAlign: TextAlign.center,
  //                       style: TextStyle(color: Colors.grey),
  //                     ),
  //                   ],
  //                 ))
  //             : ListView(
  //                 //children: buildBacklogListView(),
  //                 //children: currentlyShownBacklogItems,
  //                 children: List.generate(completedItemsToShow.length, (index) {
  //                   return GestureDetector(
  //                       onTap: () {
  //                         viewScheduledBacklogItem(index);
  //                         // openViewDialog(
  //                         //     PlannerService.sharedInstance.user!.backlogMap[
  //                         //             scheduledItemsToShow[index]
  //                         //                 .categoryName]![
  //                         //         scheduledItemsToShow[index].arrayIdx],
  //                         //     scheduledItemsToShow[index].arrayIdx,
  //                         //     scheduledItemsToShow[index].categoryName);
  //                       },
  //                       child: Card(
  //                         margin: EdgeInsets.all(15),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(15),
  //                         ),
  //                         color: PlannerService
  //                                     .sharedInstance
  //                                     .user!
  //                                     .backlogMap[completedItemsToShow[index]
  //                                             .categoryName]![
  //                                         completedItemsToShow[index].arrayIdx]
  //                                     .status ==
  //                                 "notStarted"
  //                             ? Colors.grey.shade100
  //                             : (PlannerService
  //                                         .sharedInstance
  //                                         .user!
  //                                         .backlogMap[
  //                                             completedItemsToShow[index]
  //                                                 .categoryName]![
  //                                             completedItemsToShow[index]
  //                                                 .arrayIdx]
  //                                         .status ==
  //                                     "complete"
  //                                 ? Colors.green.shade200
  //                                 : Colors.yellow.shade200),
  //                         elevation: 5,
  //                         child: ListTile(
  //                           leading: Icon(
  //                             Icons.circle,
  //                             color: PlannerService.sharedInstance.user!
  //                                     .LifeCategoriesColorMap[
  //                                 completedItemsToShow[index].categoryName],
  //                           ),
  //                           title: Padding(
  //                             padding: EdgeInsets.only(bottom: 5),
  //                             child: Text(
  //                               PlannerService
  //                                   .sharedInstance
  //                                   .user!
  //                                   .backlogMap[completedItemsToShow[index]
  //                                           .categoryName]![
  //                                       completedItemsToShow[index].arrayIdx]
  //                                   .description,
  //                               style: const TextStyle(
  //                                   // color: PlannerService.sharedInstance.user!
  //                                   //     .backlogMap[key]![i].category.color,
  //                                   color: Colors.black,
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.bold),
  //                               maxLines: 2,
  //                               textAlign: TextAlign.center,
  //                             ),
  //                           ),
  //                           // subtitle: Text(
  //                           //   "Complete by " +
  //                           //       DateFormat.yMMMd().format(PlannerService
  //                           //           .sharedInstance
  //                           //           .user!
  //                           //           .backlogMap[scheduledItemsToShow[index]
  //                           //                   .categoryName]![
  //                           //               scheduledItemsToShow[index].arrayIdx]
  //                           //           .completeBy!),
  //                           //   textAlign: TextAlign.center,
  //                           // ),
  //                           subtitle: Text(
  //                             "Scheduled for " +
  //                                 DateFormat.yMMMd().format(PlannerService
  //                                     .sharedInstance
  //                                     .user!
  //                                     .backlogMap[completedItemsToShow[index]
  //                                             .categoryName]![
  //                                         completedItemsToShow[index].arrayIdx]
  //                                     .scheduledDate!),
  //                             textAlign: TextAlign.center,
  //                           ),
  //                         ),
  //                       ));
  //                 }),
  //               ),
  //       )
  //     ],
  //   );
  // }

