import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qfix_nitmo_new/Constant/Slideanimation.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
//import 'package:qfix_nitmo_new/helper/QRScanner.dart';
import 'package:qfix_nitmo_new/helper/StringsRes.dart';
import 'package:qfix_nitmo_new/helper/vibration_helper.dart';
import 'package:qfix_nitmo_new/l10n/app_localizations.dart';
import 'package:qfix_nitmo_new/screens/manageGRNScreen/grnScanner/grnScanner.dart';
import 'package:qfix_nitmo_new/screens/manageStoreScreen/checkStoreScreen.dart';
import 'package:qfix_nitmo_new/widgets/widgets.dart';


class MobileGRNScreen extends StatefulWidget {
  const MobileGRNScreen({Key? key}) : super(key: key);

  @override
  State<MobileGRNScreen> createState() => _MobileGRNScreenState();
}

class _MobileGRNScreenState extends State<MobileGRNScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();

  TextEditingController grnCodeController = TextEditingController();
  TextEditingController prnCodeController = TextEditingController();
  AnimationController? _animationController;
  late List<TextEditingController> _itemControllers;
  bool _validateGRN = false;
  bool _validatePRN = false;
  String headerTitle = "NEW GRN";
  bool showQRScan = false;
  List<TaskModelG> ginList = [];
  List<TaskModelG> grnList = [];
  final APIService apiService = APIService();
  late Future<Map<String, List<TaskModelG>>> _notesFuture;
  TaskModelG? _selectedTask;
  late Future<List<TaskModelG>> futureTasks;
  String? _currentItemName;
  final Map<int, String> _selectedAmounts = {}; // Store selected amounts
  final Map<int, double> _enteredAmounts = {};
  bool saveBtnDisable = false;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _itemControllers = _selectedTask != null
        ? _selectedTask!.items
            .map((item) => TextEditingController(text: item))
            .toList()
        : [];

    // futureTasks = apiService.fetchGINorGRNData('GIN');

    futureTasks = Future.delayed(const Duration(seconds: 1), () {
      return [
        TaskModelG(
          'GIN-001',
          taskNo: 'GIN-001',
          description: 'GIN Task 1',
          type: 'GIN',
          items: ['Item A', 'Item B'],
        ),
        TaskModelG(
          'GRN-002',
          taskNo: 'GRN-002',
          description: 'GRN Task 2',
          type: 'GRN',
          items: ['NUT'],
        ),
        TaskModelG(
          'GIN-003',
          taskNo: 'GIN-003',
          description: 'GIN Task 3',
          type: 'GIN',
          items: ['Item X', 'Item Y'],
        ),
        TaskModelG(
          'GRN-004',
          taskNo: 'GRN-004',
          description: 'GRN Task 4',
          type: 'GRN',
          items: [
            'NUTB',
            'Item B',
            'Item C',
            'NUT',
            'NUTB',
            'Item B',
            'Item C',
            'NUT',
            'NUTB',
            'Item B',
            'Item C',
            'NUT',
            'NUTB',
            'Item B',
            'Item C',
            'NUT'
          ],
        ),
      ];
    });
  }

  void _validateGRNCode(String taskNo) {
    setState(() {
      _validateGRN = !taskNo.startsWith('GRN');
    });
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  void formReset() {
    setState(() {
      headerTitle = "NEW GRN";
      showQRScan = false;
      _selectedTask = null; // Reset selected GRN task
      _isConfirmed = false; // Reset confirmation state

      grnCodeController.clear();
      prnCodeController.clear();

      _itemControllers.clear(); // Clear all item controllers
      _selectedAmounts.clear(); // Reset selected amounts list
    });
  }

  void formSubmit({bool fromItemButton = false, String? itemName}) async {
    if (fromItemButton && _selectedTask != null) {
      setState(() {
        showQRScan = true;
        headerTitle = itemName != null
            ? 'GRN #${_selectedTask!.taskNo} - $itemName'
            : 'GRN #${_selectedTask!.taskNo}';
        _currentItemName = itemName;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRScannerPage(
            grnCode: _selectedTask!.taskNo,
            onReset: formReset,
            itemName: itemName ?? '',
          ),
        ),
      );
      return;
    }

    if (formKey.currentState!.validate()) {
      setState(() {
        showQRScan = true;
        headerTitle = 'GRN #${grnCodeController.text}';
        _currentItemName = null;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRScannerPage(
            grnCode: grnCodeController.text,
            onReset: formReset,
            itemName: itemName ?? '',
          ),
        ),
      );
    } else {
      if (grnCodeController.text.isEmpty) {
        setState(() {
          _validateGRN = true;
        });
      }
      if (prnCodeController.text.isEmpty) {
        setState(() {
          _validatePRN = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: ColorsRes.backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              if (showQRScan) {
                formReset();
              } else {
                Navigator.popAndPushNamed(context, CheckStoreScreen.routeName);
                // Navigator.of(context).pop();
              }
            },
          ),
          shadowColor: Colors.transparent,
          title: Text(
            headerTitle.toUpperCase(),
            style: const TextStyle(
              letterSpacing: 4,
            ),
          ),
          // bottom: PreferredSize(
          //   child: Divider(
          //     color: ColorsRes.greyColor,
          //     height: 2.3,
          //   ),
          //   preferredSize: Size(50, 5),
          // ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: showBody(),
      ),
    );
  }

  Widget showBody() {
    return !showQRScan
        ? Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 12,
                    vertical: MediaQuery.of(context).size.width / 40,
                  ),
                  child: SlideAnimation(
                    position: 3,
                    itemCount: 10,
                    slideDirection: SlideDirection.fromRight,
                    animationController: _animationController,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 14,
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.grnAndPrn,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              showGRNField(),
                              showValidation1(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
              positionedButton(),
            ],
          )
        : QRScannerPage(
            grnCode: grnCodeController.text,
            itemName: _currentItemName ?? '',
          );
  }

  Widget positionedButton() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: saveBtnDisable
                  ? null
                  : () {
                      // Check if a task is selected
                      if (_selectedTask == null) {
                        VibrationHelper.triggerVibration();
                        Fluttertoast.showToast(
                          msg: "Please select a task first.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        return;
                      }
                      bool allItemsHaveAmounts =
                          _selectedTask!.items.asMap().keys.every(
                                (index) =>
                                    _selectedAmounts.containsKey(index) &&
                                    _selectedAmounts[index] != null &&
                                    _selectedAmounts[index]!.trim().isNotEmpty,
                              );
                      if (!allItemsHaveAmounts) {
                        VibrationHelper.triggerVibration();
                        print("Validation triggered: Missing amounts");
                        Fluttertoast.showToast(
                          msg: "Please scan and add an amount for all items.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        return;
                      }
                      setState(() {
                        saveBtnDisable = true;
                        _showGRNconfirmation(context, _selectedTask!);
                      });
                      Future.delayed(const Duration(seconds: 3), () {
                        setState(() {
                          saveBtnDisable = false;
                        });
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: saveBtnDisable ? Colors.grey : Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                saveBtnDisable ? 'Wait...' : 'Save',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget showValidation1() {
    if (_validateGRN) {
      return Column(
        children: [
          Text(
            AppLocalizations.of(context)!.grnError,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      );
    }

    return Container();
  }

  Widget showValidation2() {
    if (_validatePRN) {
      return Column(
        children: [
          Text(
            AppLocalizations.of(context)!.prnError,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      );
    }

    return Container();
  }

  Widget showGRNField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 300,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: FutureBuilder<List<TaskModelG>>(
          future: futureTasks,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No tasks found.'));
            } else {
              List<TaskModelG> tasks =
                  snapshot.data!.where((task) => task.type == 'GRN').toList();
              return DropdownButton<TaskModelG>(
                isExpanded: true,
                value: _selectedTask,
                underline: const SizedBox(),
                icon: Icon(Icons.task_alt, color: Colors.blue.shade700),
                iconSize: 24,
                dropdownColor: Colors.white,
                style: TextStyle(
                    color: Colors.blueGrey.shade900,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
                hint: Text("Select a Task",
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
                items: tasks.map((TaskModelG task) {
                  return DropdownMenuItem<TaskModelG>(
                    value: task,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Task No: ${task.taskNo}',
                          style: TextStyle(
                              color: _selectedTask == task
                                  ? Colors.blue.shade700
                                  : Colors.grey.shade800,
                              fontSize: 15,
                              fontWeight: _selectedTask == task
                                  ? FontWeight.w600
                                  : FontWeight.w500)),
                    ),
                  );
                }).toList(),
                onChanged: (TaskModelG? selectedTask) {
                  setState(() {
                    _selectedTask = selectedTask;
                    _isConfirmed = false;
                    grnCodeController.text = selectedTask?.taskNo ?? '';
                  });
                  if (selectedTask != null) {
                    _validateGRNCode(selectedTask.taskNo);
                    _showConfirmationDialog(context, selectedTask);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                elevation: 4,
                menuMaxHeight: 300,
              );
            }
          },
        ),
      ),
      if (_selectedTask != null && _isConfirmed)
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selected GRN Details:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text('Task No: ${_selectedTask!.taskNo}'),
              Text('Type: ${_selectedTask!.type}'),
              const SizedBox(height: 8),
              const Text(
                'Items:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              if (_selectedTask!.items.isNotEmpty)
                ..._selectedTask!.items.asMap().entries.map((entry) {
                  int index = entry.key;
                  String item = entry.value;

                  if (index >= _itemControllers.length) {
                    _itemControllers.add(TextEditingController(text: item));
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 5,
                              spreadRadius: 2,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            if (_selectedAmounts[index] != null) ...[
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  _selectedAmounts[index]!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                            Expanded(
                              child: TextField(
                                controller: _itemControllers[index],
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Item ${index + 1}',
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                ),
                                readOnly: true,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.qr_code,
                                  color: Colors.blue.shade700),
                              onPressed: () async {
                                final currentItemName =
                                    _itemControllers[index].text;

                                final enteredAmount = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QRScannerPage(
                                      grnCode: grnCodeController.text,
                                      itemName: currentItemName.isEmpty
                                          ? ''
                                          : currentItemName,
                                    ),
                                  ),
                                );

                                if (enteredAmount != null) {
                                  setState(() {
                                    _selectedAmounts[index] =
                                        enteredAmount.toString();
                                  });
                                  print(
                                      "Updated _selectedAmounts: $_selectedAmounts");
                                }
                              },
                            ),
                          ],
                        ),
                      )),
                    ],
                  );
                }),
            ],
          ),
        ),
    ]);
  }

  void _showConfirmationDialog(BuildContext context, TaskModelG selectedTask) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Selection'),
          content: Text('You selected GRN: ${selectedTask.taskNo}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isConfirmed = true;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showGRNconfirmation(BuildContext context, TaskModelG selectedTask) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Selection'),
          content: Text('You selected GRN: ${selectedTask.taskNo}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isConfirmed = true;
                });
                VibrationHelper.triggerVibration();
                _showSuccessMessage(context);
                formReset();
                Navigator.of(context).pop();
                submitData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('GRN update successful!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void submitData() {
    if (_selectedTask == null) {
      print("No task selected");
      return;
    }
    List<Map<String, String>> itemsList = List.generate(
      _selectedTask!.items.length,
      (index) => {
        "item": _selectedTask!.items[index],
        "amount": _selectedAmounts[index] ?? "0",
      },
    );

    apiService.updateStore(
        _selectedTask!.type, _selectedTask!.taskNo, itemsList);
  }
}
