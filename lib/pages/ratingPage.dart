// ignore_for_file: camel_case_types, file_names, avoid_print, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
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
  final _snackBar = const SnackBar(
    backgroundColor: Colors.black,
    content: Text(
      'Thanks for the feedback!',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    duration: Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
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
                              'About this App:',
                              style: TextStyle(fontWeight: FontWeight.bold),
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
                          Text(
                            allowedText,
                            style: TextStyle(
                                color: textColorBlack,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const Padding(padding: EdgeInsets.only(top: 20)),
                          ElevatedButton(
                              onPressed: () {
                                _requestPermission();
                                setState(() {
                                  allowedText =
                                      '(Tap again to continue if you allowed)';
                                });
                              },
                              child: const Text('Ask permission'))
                        ],
                      ),
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 100 * 90,
                      child: Column(
                        children: [
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10)),
                          const Text(
                            'OPEN HOUSE FEEDBACK',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 30)),
                          Text(
                            'Kindly rate the questions based on the following ratings.',
                            style: TextStyle(
                                color: textColorwhite,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              '⭐ - Not Satisfied ☹️\n⭐⭐ - Satisfied 😐\n⭐⭐⭐ - Good 🙂\n⭐⭐⭐⭐  - Very Good 😁',
                              style: TextStyle(
                                  color: textColorwhite,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10)),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: textColorwhite,
                                borderRadius: BorderRadius.circular(25)),
                            child: Column(
                              children: [
                                Text(
                                  'Were your expectation met in the Hindustan Open House?',
                                  style: TextStyle(
                                      color: textColorBlack,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(top: 20),
                                  height: 70,
                                  child: RatingBar.builder(
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
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10)),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25)),
                            child: Column(
                              children: [
                                const Text(
                                  'Did you learn about various career options?',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(top: 20),
                                  height: 70,
                                  child: RatingBar.builder(
                                    initialRating: rating2,
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
                                      rating2 = rating;
                                      // Store the rating in a variable here
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10)),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25)),
                            child: Column(
                              children: [
                                const Text(
                                  'Kindly rate about overall Hindustan Open House experience.',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(top: 20),
                                  height: 70,
                                  child: RatingBar.builder(
                                    initialRating: rating3,
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
                                      rating3 = rating;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10)),
                          Text(
                            'Suggestions if any:',
                            style: TextStyle(
                                color: textColorwhite,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 120,
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                            ),
                            child: TextField(
                              minLines: null,
                              maxLines: null,
                              expands: true,
                              style: const TextStyle(fontSize: 15),
                              decoration: const InputDecoration.collapsed(
                                  hintText: 'Type here...',
                                  hintStyle: TextStyle(fontSize: 12)),
                              keyboardType: TextInputType.text,
                              onChanged: (value) {
                                suggestion = value;
                              },
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 30)),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 100 * 65,
                            height: 45,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateColor.resolveWith(
                                            (states) => Colors.black)),
                                onPressed: () {
                                  _submitRating();
                                  Future.delayed(const Duration(seconds: 1),
                                      () {
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
                                      .showSnackBar(_snackBar);
                                },
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                      color: Colors.white,
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
