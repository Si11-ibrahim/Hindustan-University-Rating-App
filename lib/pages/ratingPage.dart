// ignore_for_file: camel_case_types, file_names, avoid_print, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hits_rating/models/ratings.dart';
import 'package:permission_handler/permission_handler.dart';

class ratingPage extends StatefulWidget {
  const ratingPage({
    super.key,
  });

  @override
  State<ratingPage> createState() => _ratingPageState();
}

class _ratingPageState extends State<ratingPage> {
  final _successSnackBar = const SnackBar(
    backgroundColor: Color.fromARGB(255, 0, 184, 6),
    content: Text(
      'Thanks for the feedback!',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    duration: Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
  );

  final _errorSnackBar = const SnackBar(
    backgroundColor: Color.fromARGB(255, 255, 0, 0),
    content: Text(
      'Oops!! I think you forgot to Rate.',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    showCloseIcon: true,
    duration: Duration(seconds: 4),
    behavior: SnackBarBehavior.floating,
    elevation: 5,
  );

  final List<Rating> ratings = [];
  String suggestion = '';
  double rating1 = 0;
  double rating2 = 0;
  double rating3 = 0;
  var sink;

  Future<void> _saveRatingsToCSV(List<Rating> ratingsData) async {
    var documentsDirectory =
        await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOCUMENTS);
    Directory dir = Directory(documentsDirectory);
    if (!await dir.exists()) {
      dir.create(recursive: true);
    }
    var filePath = '$documentsDirectory/ratings.csv';
    var file = File(filePath);

    try {
      if (await file.exists()) {
        // If the file exists, open it in append mode
        sink = file.openWrite(mode: FileMode.append, encoding: utf8);
      } else {
        // If the file doesn't exist, create a new file and write headers
        sink = file.openWrite(mode: FileMode.writeOnly, encoding: utf8);
        sink.writeln(
            'Expectations,Career options,Overall Experience,Suggestions');
        print('New file created in $filePath');
      }

      // Write data rows
      for (var rating in ratingsData) {
        sink.writeln(
            '${rating.rating1},${rating.rating2},${rating.rating3},${rating.suggestion}');
      }

      print('Data appended to CSV file: $filePath');
    } catch (e) {
      print('Error: $e');
    } finally {
      if (sink != null) {
        await sink.flush();
        await sink.close();
      }
    }
  }

  Future<bool> _requestPermission() async {
    var status = await Permission.manageExternalStorage.request();

    return status.isGranted;
  }

  void _submitRating() async {
    var permissionGranted = await _requestPermission();
    if (permissionGranted) {
      // Simulate collecting ratings
      Rating newRating = Rating(
        rating1: rating1,
        rating2: rating2,
        rating3: rating3,
        suggestion: suggestion,
      );

      ratings.add(newRating);

      // Save ratings to CSV file
      _saveRatingsToCSV(ratings);
    } else {
      print('Storage permission not granted.');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<PermissionStatus> _checkPermission() async {
    var status = await Permission.manageExternalStorage.status;
    return status;
  }

  Color textColorwhite = Colors.white;
  Color textColorBlack = Colors.black;
  String allowedText = '';
  String permissionText = 'Ask permission';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(children: <Widget>[
        Image.asset(
          "assets/appbgimg.jpg",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                              'About this App',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            content: const Text(
                              'This app will collect the ratings from the user and save it in this device\'s internal storage.\n\nSaved path: Internal storage > Documents > ratings.csv',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            actions: [
                              Center(
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Understood',
                                    )),
                              )
                            ],
                          );
                        });
                  },
                  icon: const Icon(
                    Icons.help_outline,
                    color: Colors.white,
                    size: 25,
                  ))
            ],
          ),
          backgroundColor: Colors.transparent,
          body: FutureBuilder(
              future: _checkPermission(),
              builder: (context, snapshot) {
                if (snapshot.data == PermissionStatus.denied) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: textColorwhite,
                          borderRadius: BorderRadius.circular(25)),
                      width: MediaQuery.of(context).size.width / 100 * 90,
                      height: 245,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'This app needs storage permission to store the ratings data in this device.',
                            style: TextStyle(
                                color: textColorBlack,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const Padding(padding: EdgeInsets.only(top: 8)),
                          Text(
                            allowedText,
                            style: TextStyle(
                              color: textColorBlack,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Padding(padding: EdgeInsets.only(top: 20)),
                          ElevatedButton(
                              onPressed: () {
                                _requestPermission();
                                setState(() {
                                  allowedText =
                                      '(If you have granted permission, tap again to continue.)';
                                });
                              },
                              child: Text(permissionText))
                        ],
                      ),
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10)),
                          Text(
                            'CAREER COMPASS FEEDBACK',
                            style: TextStyle(
                                shadows: List.filled(
                                    2,
                                    Shadow(
                                        color: Colors.black,
                                        offset: Offset.fromDirection(1.1, 4),
                                        blurRadius: 5),
                                    growable: false),
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 30)),
                          Text(
                            'Kindly rate the questions based on the following ratings:',
                            style: TextStyle(
                                shadows: List.filled(
                                    1,
                                    Shadow(
                                        color: Colors.black,
                                        offset: Offset.fromDirection(1.1, 3.3),
                                        blurRadius: 5),
                                    growable: false),
                                color: textColorwhite,
                                fontSize: 23,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 150,
                            width: MediaQuery.of(context).size.width / 100 * 90,
                            decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 2.0,
                                    spreadRadius: 0.0,
                                    offset: Offset(1.0, 2.0),
                                  )
                                ],
                                color: textColorBlack,
                                borderRadius: BorderRadius.circular(25)),
                            alignment: Alignment.center,
                            child: Text(
                              '⭐                 - Not Satisfied ☹️\n⭐⭐            - Satisfied 😐\n⭐⭐⭐       - Good 🙂\n⭐⭐⭐⭐  - Very Good 😍',
                              style: TextStyle(
                                  shadows: List.filled(
                                      2,
                                      Shadow(
                                          color: Colors.black,
                                          offset: Offset.fromDirection(1.1, 1),
                                          blurRadius: 5),
                                      growable: false),
                                  color: textColorwhite,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10)),
                          Material(
                            borderRadius: BorderRadius.circular(25),
                            elevation: 10,
                            child: Container(
                              height: 150,
                              width:
                                  MediaQuery.of(context).size.width / 100 * 90,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 2.0,
                                      spreadRadius: 0.0,
                                      offset: Offset(1.0, 2.0),
                                    )
                                  ],
                                  color: textColorwhite,
                                  borderRadius: BorderRadius.circular(25)),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'Expectations met in the Career Compass?',
                                    style: TextStyle(
                                        color: textColorBlack,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(top: 20),
                                    height: 70,
                                    child: RatingBar.builder(
                                      itemSize: 44,
                                      unratedColor: Colors.blueGrey,
                                      initialRating: rating1,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      itemCount: 4,
                                      itemPadding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {
                                        rating1 = rating;
                                        // Store the rating in a variable here
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10)),
                          Material(
                            borderRadius: BorderRadius.circular(25),
                            elevation: 10,
                            child: Container(
                              height: 150,
                              width:
                                  MediaQuery.of(context).size.width / 100 * 90,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 2.0,
                                      spreadRadius: 0.0,
                                      offset: Offset(1.0, 2.0),
                                    )
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25)),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text(
                                    'Learn about various career options?',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(top: 20),
                                    height: 70,
                                    child: RatingBar.builder(
                                      unratedColor: Colors.blueGrey,
                                      initialRating: rating2,
                                      minRating: 1,
                                      itemSize: 44,
                                      direction: Axis.horizontal,
                                      itemCount: 4,
                                      itemPadding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {
                                        rating2 = rating;
                                        // Store the rating in a variable here
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10)),
                          Material(
                            borderRadius: BorderRadius.circular(25),
                            elevation: 10,
                            child: Container(
                              height: 150,
                              width:
                                  MediaQuery.of(context).size.width / 100 * 90,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 2.0,
                                      spreadRadius: 0.0,
                                      offset: Offset(1.0, 2.0),
                                    )
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25)),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text(
                                    'Overall Career Compass experience?',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(top: 20),
                                    height: 70,
                                    child: RatingBar.builder(
                                      unratedColor: Colors.blueGrey,
                                      initialRating: rating3,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      itemCount: 4,
                                      itemSize: 44,
                                      itemPadding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {
                                        rating3 = rating;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10)),
                          Text(
                            'Any suggestions?',
                            style: TextStyle(
                                shadows: List.filled(
                                    2,
                                    Shadow(
                                        color: Colors.black,
                                        offset: Offset.fromDirection(1.1, 3),
                                        blurRadius: 5),
                                    growable: false),
                                color: textColorwhite,
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Material(
                            borderRadius: BorderRadius.circular(25),
                            elevation: 10,
                            child: Container(
                              width:
                                  MediaQuery.of(context).size.width / 100 * 90,
                              height: 150,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 2.0,
                                    spreadRadius: 0.0,
                                    offset: Offset(1.0, 2.0),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.white,
                              ),
                              child: TextField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100)
                                ],
                                minLines: null,
                                maxLines: null,
                                expands: true,
                                style: const TextStyle(fontSize: 15),
                                decoration: const InputDecoration.collapsed(
                                    hintText: 'Type here...',
                                    hintStyle: TextStyle(fontSize: 14)),
                                keyboardType: TextInputType.text,
                                onChanged: (value) {
                                  suggestion = value;
                                },
                              ),
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 25)),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 100 * 70,
                            height: 50,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(20),
                                    backgroundColor:
                                        MaterialStateColor.resolveWith(
                                            (states) => Colors.amber)),
                                onPressed: () {
                                  if (rating1 != 0 &&
                                      rating2 != 0 &&
                                      rating3 != 0) {
                                    _submitRating();
                                    Future.delayed(
                                        const Duration(milliseconds: 200), () {
                                      Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration: Duration.zero,
                                          pageBuilder: (_, __, ___) =>
                                              const ratingPage(),
                                        ),
                                      );
                                    });
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(_successSnackBar);
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(_errorSnackBar);
                                  }
                                },
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
      ]),
    );
  }
}
