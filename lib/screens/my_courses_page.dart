import 'package:cached_network_image/cached_network_image.dart';
import 'package:course_select/controllers/home_page_notifier.dart';
import 'package:course_select/shared_widgets/category_button.dart';
import 'package:course_select/shared_widgets/constants.dart';
import 'package:course_select/shared_widgets/courses_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../controllers/course_notifier.dart';
import '../models/course_data_model.dart';
import '../shared_widgets/filter_button.dart';
import '../shared_widgets/mini_course_card.dart';
import '../utils/firebase_data_management.dart';
import 'filter_sheet.dart';

class MyCourses extends StatefulWidget {
  const MyCourses({Key? key}) : super(key: key);

  @override
  State<MyCourses> createState() => _MyCoursesState();
}

class _MyCoursesState extends State<MyCourses>
    with SingleTickerProviderStateMixin {
  DatabaseManager db = DatabaseManager();
  late final CourseNotifier courseNotifier;

  //late final UserNotifier userNotifier;
  late Future futureData;

  late List<Course> displayList;

  void updateList(String value) {
    /// filter courses list
    setState(() {
      displayList = courseNotifier.courseList
          .where((element) =>
              element.courseName!.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  Future getModels() {
    //db.getUsers(userNotifier);
    return db.getCourses(courseNotifier);
  }

  late final AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    courseNotifier = Provider.of<CourseNotifier>(context, listen: false);
    //userNotifier = Provider.of<UserNotifier>(context, listen: false);
    futureData = getModels();
    displayList = List.from(courseNotifier.courseList);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    HomePageNotifier homePageNotifier = Provider.of<HomePageNotifier>(context, listen: true);
    return Scaffold(
      body: FutureBuilder(
          future: futureData,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return Padding(
              padding: const EdgeInsets.all(0),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 25.0, top: 25),
                      child: Text(
                        'Learn without limits!',
                        style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto'),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 25.0, right: 20),
                              child: TextField(
                                onChanged: (value) {
                                  updateList(value);
                                },
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    hintText: 'eg. Introduction to HTML',
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8.0)),
                                        borderSide: BorderSide(
                                            width: 1, color: kPrimaryColour)),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                    ),
                                    focusColor: kPrimaryColour),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 25.0),
                          child: FilterButton(
                            isFilterVisible: homePageNotifier.isFilterVisible,
                            onPressed: () {
                              homePageNotifier.isFilterVisible =
                                  !homePageNotifier.isFilterVisible;

                              showCupertinoModalBottomSheet(
                                duration: const Duration(milliseconds: 100),
                                topRadius: const Radius.circular(20) ,
                                barrierColor: Colors.black54,
                                elevation: 8,
                                context: context,
                                builder: (context) => SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.7,
                                    child: const Material(child: FilterSheet())),
                              ).whenComplete(() => homePageNotifier.isFilterVisible = false);

                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      // child: Text(
                      //   'Skill level',
                      //   style: TextStyle(
                      //       fontSize: 18.0,
                      //       fontWeight: FontWeight.bold,
                      //       fontFamily: 'Roboto'),
                      // ),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: CoursesFilter(isListView: true),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Expanded(
                        child: displayList.isEmpty
                            ? const Center(
                                child: Text('No results found...'),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: displayList.length,
                                    itemBuilder: (context, index) {
                                      return MiniCourseCard(
                                        displayList: displayList,
                                        index: index,
                                        onBookmarkTapped: () {
                                          setState(() {
                                            HapticFeedback.heavyImpact();
                                            displayList[index].isSaved =
                                                !displayList[index].isSaved;

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                elevation: 1,
                                                behavior:
                                                    SnackBarBehavior.fixed,
                                                backgroundColor: kKindaGreen,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                content: Center(
                                                    child: Text(
                                                      displayList[index].isSaved? 'Added to saved courses': 'Removed from saved courses',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                                duration:
                                                    const Duration(seconds: 1),
                                              ),
                                            );
                                          });
                                        },
                                      );
                                    }),
                              )),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
