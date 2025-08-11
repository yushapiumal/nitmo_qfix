import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';








class MobileUpdate extends StatefulWidget {
 const MobileUpdate({Key? key, this.markUpdateTask , this.taskData}) : super(key: key);
  final markUpdateTask;
  final taskData;

  @override
  State<MobileUpdate> createState() => _MobileUpdateState();
}

class _MobileUpdateState extends State<MobileUpdate> {
  final LocalStorage storage = LocalStorage('qfix');
  int? selectedIndex = 0;
  String headerText = 'Details';
  APIService apiService = APIService();
  late List<Widget> fragments;
  bool updateStatus = false;
  String? _currentAddress;
  Position? _currentPosition;

  List<Color> colors = List.generate(6, (index) =>ColorsRes.secondaryButton);
  List reasons = [
    " Lack of resources",
    "Time constraints",
    "Technical issues",
    "Policy restrictions",
    "Insufficient skills",
    "Other commitments"
  ];

  int? _selectedIndex;
  String? complexity;
  bool btnDisable = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showConfirmationDialog(int index) {
    if (_selectedIndex != null && _selectedIndex != index) {
      showDialog(
        context: context,
        builder: (BuildContext context) => _buildDialog(
          index,
          title: 'Confirm Action',
          message: 'Do you want to change this reason?',
        ),
      );
    } else if (_selectedIndex == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) => _buildDialog(
          index,
          title: 'Confirm Action',
          message: 'Do you want to send this reason?',
        ),
      );
    }
  }

  AlertDialog _buildDialog(int index, {required String title, required String message}) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: const Text('No'),
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
          },
        ),
        TextButton(
          child: const Text('Yes'),
          onPressed: () async {
            setState(() {
              if (_selectedIndex != null) {
                colors[_selectedIndex!] = ColorsRes.secondaryButton;
              }
              colors[index] = Colors.red;
              _selectedIndex = index; 
            });

            Navigator.of(context).pop(); 

              var selectedReason = reasons[index];
              var submit = await widget.markUpdateTask!('pending', selectedReason, false);
        
        
          },
        ),
      ],
    );
  }

  toggleComplexity() async {
    const duration = Duration(milliseconds: 2500);

    // Update complexity level
    setState(() {
      complexity = (complexity == 'L1')
          ? 'L2'
          : (complexity == 'L2')
              ? 'L3'
              : 'L1';
    });

    // Call complexity API after a delay
    return Timer(duration, callComplexityChangeApi);
  }

  callComplexityChangeApi() async {
    setState(() {
      btnDisable = true;
    });

    // Send complexity change to backend
    if (widget.markUpdateTask != null) {
      var submit = await widget.markUpdateTask!('complexity', complexity ?? '', false);
      setState(() {
        btnDisable = !submit; // Enable button only on success
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:  GridView.count(
      crossAxisCount: 3,
      children: List.generate(6, (index) {
        return GestureDetector(
          onTap: () => _showConfirmationDialog(index),
          child: Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colors[index],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                reasons[index],
                style: const TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }),
    ),
    );
  }
  
}
