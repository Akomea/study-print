import 'dart:io' as io;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course_select/routes/routes.dart';
import 'package:course_select/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../controllers/user_notifier.dart';
import '../utils/auth.dart';
import '../utils/firebase_data_management.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String imageUrl = '';
  late final UserNotifier userNotifier;
  final DatabaseManager db = DatabaseManager();
  final User? user = Auth().currentUser;
  late Future futureData;

  Widget _title() {
    return Text(
      'Profile',
      style: kHeadlineMedium,
    );
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: () =>
          {Auth().signOut(), Get.offAndToNamed(PageRoutes.loginRegister)},
      child: const Text('Sign Out'),
    );
  }

  Future getData() async {
    var users = await db.getUsers(userNotifier);
    userNotifier.updateUserName();
    userNotifier.updateEmail();
    userNotifier.updateAvatar();
    userNotifier.updateDate();
    return users;
  }

  late XFile? imgFile;

  Future loadAvatar(bool useCamera) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(
        source: useCamera ? ImageSource.camera : ImageSource.gallery);
    print(file?.path);

    if (file == null) return;
    //Import dart:core
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    //Get a reference to storage root
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');

    //Create a reference for the image to be stored
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    //Handle errors/success
    try {
      //Store the file
      await referenceImageToUpload.putFile(io.File(file!.path));
      //Success: get the download URL
      imageUrl = await referenceImageToUpload.getDownloadURL();
    } catch (error) {
      //Some error occurred
    }

    var myUser = await FirebaseFirestore.instance
        .collection("Users")
        .where("uid", isEqualTo: user?.uid)
        .get();
    if (myUser.docs.isNotEmpty) {
      var docId = myUser.docs.first.id;

      DocumentReference docRef =
          FirebaseFirestore.instance.collection("Users").doc(docId);
      await docRef.update({"avatar": imageUrl});

      userNotifier.avatar = imageUrl;
    }
  }

  bool imgChanged = false;

  @override
  void initState() {
    userNotifier = Provider.of<UserNotifier>(context, listen: false);
    futureData = getData();
    oldUrl = userNotifier.avatar;
    super.initState();
  }

  late String oldUrl;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.edit),
          )
        ],
      ),
      body: FutureBuilder(
          future: futureData,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.only(top: 20),
                width: double.infinity,
                height: 810,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GestureDetector(
                            onTap: () {
                              showCupertinoModalBottomSheet(
                                isDismissible: true,
                                topRadius: const Radius.circular(20),
                                barrierColor: Colors.black54,
                                elevation: 8,
                                context: context,
                                builder: (context) => Material(
                                    child: SizedBox(
                                  height: screenHeight * 0.25,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      EditImageOptionsItem(
                                        text: 'Take Photo',
                                        onPressed: () async {
                                          await loadAvatar(true);
                                          setState(() {
                                            imgChanged = true;
                                          });
                                        },
                                      ),
                                      const Divider(
                                        height: 0,
                                      ),
                                      EditImageOptionsItem(
                                        text: 'Choose Image',
                                        onPressed: () async {
                                          await loadAvatar(false);
                                          setState(() {
                                            imgChanged = true;
                                          });
                                        },
                                      ),
                                      const Divider(
                                        height: 0,
                                      ),
                                      EditImageOptionsItem(
                                        text: 'Cancel',
                                        onPressed: () {
                                          setState(() {
                                            futureData = getData();
                                          });
                                          Navigator.pop(context);
                                        },
                                      )
                                    ],
                                  ),
                                )),
                              ).whenComplete(() {
                                setState(() {
                                  futureData = getData();
                                });
                              });
                            },
                            child: Stack(children: [
                              CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.white,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(75.0),
                                    child: CachedNetworkImage(
                                      height: 100.0,
                                      width: 100.0,
                                      fit: BoxFit.cover,
                                      imageUrl: userNotifier.avatar,
                                      placeholder: (context, url) {
                                        return const CircularProgressIndicator();
                                      },
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )),
                              Positioned(
                                  bottom: 0,
                                  right: 5,
                                  child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 15,
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 20,
                                        color: kPrimaryColour,
                                      )))
                            ]))),
                    Text(
                      userNotifier.userName,
                      style: kHeadlineMedium,
                    ),
                    Text(userNotifier.email ?? 'User email'),
                    Text(userNotifier.joinDate),
                    const SizedBox(
                      height: 15,
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '3',
                              style: kHeadlineMedium.copyWith(color: kTeal),
                            ),
                            const Text('Enrolled'),
                          ],
                        ),
                        Column(
                          children: [
                            Text('2', style: kHeadlineMedium.copyWith(color: kTeal)),
                            const Text('Active'),
                          ],
                        ),
                        Column(
                          children: [
                            Text('1', style: kHeadlineMedium.copyWith(color: kTeal)),
                            const Text('Completed'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                            borderRadius: BorderRadius.circular(30),
                            color: const Color(0xfffafafa),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: SettingsList(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  platform: DevicePlatform.device,
                                  lightTheme: const SettingsThemeData(
                                      settingsListBackground: Colors.transparent),
                                  sections: [
                                    SettingsSection(
                                      title: const Text('Common'),
                                      tiles: <SettingsTile>[
                                        SettingsTile.navigation(
                                          leading: const Icon(Icons.language),
                                          title: const Text('Language'),
                                          value: const Text('English'),
                                        ),
                                        SettingsTile.switchTile(
                                          onToggle: (value) {},
                                          initialValue: false,
                                          leading: const Icon(Icons.dark_mode),
                                          title: const Text('Enable dark mode'),
                                        ),
                                      ],
                                    ),
                                    SettingsSection(
                                      title: const Text('Security & Privacy'),
                                      tiles: <SettingsTile>[
                                        SettingsTile(
                                          leading:
                                              const Icon(Icons.delete_forever),
                                          title: const Text('Delete Account'),
                                        ),
                                        SettingsTile.switchTile(
                                          onToggle: (value) {},
                                          initialValue: true,
                                          leading: const Icon(Icons.security),
                                          title: const Text(
                                              'Allow activity sharing'),
                                        ),
                                      ],
                                    ),
                                    SettingsSection(
                                      tiles: <SettingsTile>[
                                        SettingsTile(
                                          leading: const Icon(Icons.logout),
                                          title: const Text('Log out'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SafeArea(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: 300.w,
                                        child: Center(
                                          child: RichText(
                                            textAlign: TextAlign.center,
                                            text: const TextSpan(
                                                text: 'Study Sprint\'s ',
                                                style: TextStyle(color: Colors.black),
                                                children: [
                                                  TextSpan(
                                                    text: 'GDPR Privacy',
                                                    style: TextStyle(color: Colors.black, decoration: TextDecoration.underline,),
                                                  ),
                                                  TextSpan(
                                                      text: ' and '
                                                  ),
                                                  TextSpan(
                                                    text: 'Open Source Software',
                                                    style: TextStyle(color: Colors.black, decoration: TextDecoration.underline,),
                                                  ),
                                                ]
                                            ),


                                          ),
                                        ),),
                                      SizedBox(height: 10,),
                                      const Text('App version 1.0.0', style: TextStyle(color: Colors.grey),),
                                    ],
                                  ))

                            ],
                          ),
                          width: double.infinity,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            );
          }),
    );
  }
}

class EditImageOptionsItem extends StatelessWidget {
  final String text;
  final Function onPressed;

  const EditImageOptionsItem({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return TextButton(
      style: ButtonStyle(
          overlayColor: MaterialStateColor.resolveWith(
              (states) => kSelected.withOpacity(0.5)),
          minimumSize: MaterialStateProperty.all(
              Size(double.infinity, screenHeight * 0.065))),
      onPressed: () => onPressed.call(),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }
}

class PhotoAvatar extends StatelessWidget {
  final String image;

  const PhotoAvatar({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      CircleAvatar(
          radius: 45,
          backgroundColor: Colors.white,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(45),
            child: CachedNetworkImage(
              imageUrl: image,
              placeholder: (context, url) {
                return const CircularProgressIndicator();
              },
              errorWidget: (context, url, error) => const Icon(
                Icons.person,
                color: Colors.grey,
              ),
            ),
          )),
      Positioned(
          bottom: 0,
          right: 5,
          child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 15,
              child: Icon(
                Icons.camera_alt,
                size: 20,
                color: kPrimaryColour,
              )))
    ]);
  }
}
// _signOutButton(),
// //TODO create list tiles for settings and options according to design
// Text("Language"),
// Text("Clear Schedule"),
// Text("Manage Courses"),
// Text("Allow Activity Sharing"),
// Text("Log Out"),
// Text("Delete Account"),
