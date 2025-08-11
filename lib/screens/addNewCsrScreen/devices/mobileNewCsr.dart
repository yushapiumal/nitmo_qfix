
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:qfix_nitmo_new/Constant/Slideanimation.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/l10n/app_localizations.dart';
import 'package:qfix_nitmo_new/widgets/widgets.dart';



class MobileNewCsr extends StatefulWidget {
  const MobileNewCsr({Key? key}) : super(key: key);

  @override
  State<MobileNewCsr> createState() => _MobileNewCsrState();
}

class _MobileNewCsrState extends State<MobileNewCsr>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  final formKey = GlobalKey<FormState>();
  APIService apiService = APIService();
  String errorText = "";
  bool showError = false;
  bool searchingProjectByAPI = false;
  bool btnDisable = false;
  bool nextPage = false;
  bool newProjectPage = false;
  int pageIndex = 0;
  bool finalBtn = false;
  TextEditingController serviceAreaController = TextEditingController();
  TextEditingController issueController = TextEditingController();
  TextEditingController solutionController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController contactPersonController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController projectSerialController = TextEditingController();
  TextEditingController projectDetailController = TextEditingController();
  TextEditingController projectTaskController = TextEditingController();

  String? customerProjectDropdownValue;
  List customerProjectList = [
    {'label': 'N/A', 'value': ''},
    {'label': 'New Project', 'value': 'new'}
  ];
  bool customerProjectSelected = false;

  String? customerDropdownValue;
  List customerList = [
    {'name': 'New Customer', 'cId': '0'}
  ];
  bool customerSelected = false;

  String? serviceTypeDropdownValue;
  var serviceTypeList = [];
  bool serviceTypeSelected = false;

  String? ownerDropdownValue;
  var ownerList = [];
  bool ownerSelected = false;

  String? assigneeDropdownValue;
  var assigneeList = [];
  bool assigneeSelected = false;

  String? complexityDropdownValue;
  var complexityList = [];
  bool complexitySelected = false;

  bool customerError = false;
  bool customerProjectError = false;
  bool serviceError = false;
  bool ownerError = false;
  bool assigneeError = false;
  bool complexityError = false;

  @override
  void initState() {
    super.initState();
    getDefaultValues();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  getDefaultValues() async {
    // getCustomerList

    var getCustomers = await apiService.getExistCustomers();

    if (getCustomers != false) {
      for (var customer in getCustomers) {
        var contain =
            customerList.where((element) => element['cId'] == customer['c_id']);
        if (contain.isEmpty) {
          setState(() {
            customerList.add({
              'name': customer['name'] + ' (' + customer['c_id'] + ')',
              'cId': customer['c_id']
            });
          });
        }
      }
    }
    //  getServiceTypes
    var getServiceTypes = await apiService.getServiceTypes();
    if (getServiceTypes != false) {
      for (var service in getServiceTypes.values) {
        if (!serviceTypeList.contains(service)) {
          setState(() {
            serviceTypeList.add(service);
          });
        }
      }
    }

    // getStaff
    var getStaff = await apiService.getStaff();
    if (getStaff != false) {
      for (var staff in getStaff) {
        var id = staff['s_id'].toString();
        var name = staff['calling_name'] ?? '-';

        if (!ownerList.contains(name + ' (' + id + ')')) {
          setState(() {
            ownerList.add(name + ' (' + id + ')');
          });
        }
        if (!assigneeList.contains(name + ' (' + id + ')')) {
          setState(() {
            assigneeList.add(name + ' (' + id + ')');
          });
        }
      }
    }

    // getComplexity
    var getComplexity = await apiService.getComplexity();
    if (getComplexity != false) {
      for (var complex in getComplexity.values) {
        if (!complexityList.contains(complex)) {
          setState(() {
            complexityList.add(complex);
          });
        }
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
              if (nextPage || newProjectPage) {
                setState(() {
                  nextPage = false;
                  newProjectPage = false;
                });
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          shadowColor: Colors.transparent,
          title: Text(
              AppLocalizations.of(context)!.addnewCsr,
            style: const TextStyle(
              letterSpacing: 4,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Container(
          margin: const EdgeInsets.only(top: 20),
          child: showBody(),
        ),
        bottomNavigationBar: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SlideAnimation(
              position: 3,
              itemCount: 10,
              slideDirection: SlideDirection.fromRight,
              animationController: _animationController,
              child: Container(
                  height: MediaQuery.of(context).size.height / 15,
                  margin: const EdgeInsets.only(
                    bottom: 05,
                    top: 15,
                  ),
                  child: submitButton()),
            )
          ],
        ),
      ),
    );
  }

  submitButton() {
    if (pageIndex == 0 || finalBtn) {
      return CupertinoButton(
        color: ColorsRes.secondaryButton,
        onPressed: () {
          btnDisable ? false : submitForm();
        },
        child: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Icon(
                  btnDisable ? Icons.hourglass_top_rounded : Icons.add,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: btnDisable ?    AppLocalizations.of(context)!.checking :   AppLocalizations.of(context)!.addnewCsr,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (pageIndex == 1) {
      return CupertinoButton(
        color: ColorsRes.secondaryButton,
        onPressed: () {
          if (customerDropdownValue == '0' &&
              customerProjectDropdownValue != 'new') {
            setState(() {
              nextPage = true;
              finalBtn = true;
            });
          }
        },
        child: RichText(
          text: const TextSpan(
            children: [
              WidgetSpan(
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: "Next",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (pageIndex == 2) {
      return CupertinoButton(
        color: ColorsRes.secondaryButton,
        onPressed: () {
          if (customerProjectDropdownValue == 'new' &&
              customerDropdownValue != '0') {
            setState(() {
              newProjectPage = true;
              finalBtn = true;
            });
          }
          if (customerProjectDropdownValue == 'new' &&
              customerDropdownValue == '0') {
            if (nextPage) {
              setState(() {
                newProjectPage = true;
                nextPage = false;
                finalBtn = true;
              });
            } else {
              setState(() {
                nextPage = true;
              });
            }
          }
        },
        child: RichText(
          text: const TextSpan(
            children: [
              WidgetSpan(
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: "Next",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  getCustomerProjects() async {
    setState(() {
      searchingProjectByAPI = true;
      newProjectPage = false;
    });
    var projects = await apiService.getCustomersProjects(customerDropdownValue);
    for (var project in projects) {
      if (customerProjectList.length == 2) {
        setState(() {
          customerProjectList.add({
            'label':
                '(' + project['contact_serial'] + ') ' + project['product'],
            'value': project['contact_serial']
          });
          searchingProjectByAPI = false;
        });
      } else {
        var contain = customerProjectList.where((element) =>
            element['label'] ==
                '(' + project['contact_serial'] + ') ' + project['product'] &&
            element['value'] == project['contact_serial']);
        if (contain.isEmpty) {
          setState(() {
            customerProjectList.add({
              'label':
                  '(' + project['contact_serial'] + ') ' + project['product'],
              'value': project['contact_serial']
            });
            searchingProjectByAPI = false;
          });
        }
      }
    }
  }

  projectField() {
    if (customerSelected) {
      if (customerDropdownValue == '0') {
        setState(() {
          newProjectPage = false;
          customerProjectList = [
            {'label': 'N/A', 'value': ''},
            {'label': 'New Project', 'value': 'new'}
          ];
        });
      } else {
        getCustomerProjects();
      }
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 40,
        ),
        child: SlideAnimation(
          position: 3,
          itemCount: 10,
          slideDirection: SlideDirection.fromRight,
          animationController: _animationController,
          child: Container(
            width: 340,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    customerError ? Colors.red[700]! : ColorsRes.warmGreyColor,
                style: BorderStyle.solid,
                width: 0.80,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                hint:  Text(
           AppLocalizations.of(context)!.selectProjectPlease,
                  style: const TextStyle(color: ColorsRes.warmGreyColor),
                ),
                items: customerProjectList.map((con) {
                  return DropdownMenuItem(
                    value: con['value'],
                    child: Text(
                      con['label'],
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == 'new') {
                    setState(() {
                      finalBtn = false;
                      pageIndex = 2;
                      customerProjectDropdownValue = 'new';
                      customerProjectSelected = true;
                      customerProjectError = false;
                    });
                  } else {
                    if (customerDropdownValue == '0') {
                      setState(() {
                        pageIndex = 1;
                      });
                    } else {
                      setState(() {
                        pageIndex = 0;
                      });
                    }

                    setState(() {
                      finalBtn = false;
                      customerProjectDropdownValue = value.toString();
                      customerProjectSelected = true;
                      customerProjectError = false;
                    });
                  }
                },
                isExpanded: true,
                value: customerProjectSelected
                    ? customerProjectDropdownValue.toString()
                    : null,
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  formHandler() {
    return Column(
      children: [
        nextPage ? customerForm() : const SizedBox(),
        newProjectPage ? projectForm() : const SizedBox(),
        !nextPage && !newProjectPage ? csrForm() : const SizedBox(),
      ],
    );
  }

  Widget showBody() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Form(
            key: formKey,
            child: formHandler(),
          ),
        ],
      ),
    );
  }

  serviceArea() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 40),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: textField(
          serviceAreaController,
             AppLocalizations.of(context)!.serviceArea,
         AppLocalizations.of(context)!.enterServiceAreaPlease,
          TextInputType.text,
          false,
          formKey,
          1,
        ),
      ),
    );
  }

  csrForm() {
    return Column(
      children: [
        serviceArea(),
        const SizedBox(
          height: 4,
        ),
        customer(),
        showCustomerErrors(),
        const SizedBox(
          height: 4,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          child: projectField(),
        ),
        const SizedBox(
          height: 4,
        ),
        const SizedBox(
          height: 4,
        ),
        issue(),
        const SizedBox(
          height: 4,
        ),
        solution(),
        const SizedBox(
          height: 4,
        ),
        serviceType(),
        showServiceErrors(),
        const SizedBox(
          height: 10,
        ),
        owner(),
        showOwnerErrors(),
        const SizedBox(
          height: 20,
        ),
        assigned(),
        showAssigneeErrors(),
        const SizedBox(
          height: 20,
        ),
        complexity(),
        showComplexityErrors(),
      ],
    );
  }

  customerForm() {
    if (customerSelected && customerDropdownValue == '0') {
      return SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 12,
                  vertical: MediaQuery.of(context).size.width / 40),
              child: SlideAnimation(
                position: 3,
                itemCount: 10,
                slideDirection: SlideDirection.fromRight,
                animationController: _animationController,
                child: textField(
                  customerNameController,
                AppLocalizations.of(context)!.customerName,
                 AppLocalizations.of(context)!.enterCustomerNamePlease,
                  TextInputType.text,
                  false,
                  formKey,
                  1,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 12,
                  vertical: MediaQuery.of(context).size.width / 40),
              child: SlideAnimation(
                position: 3,
                itemCount: 10,
                slideDirection: SlideDirection.fromRight,
                animationController: _animationController,
                child: textField(
                  contactPersonController,
                AppLocalizations.of(context)!.contactPersionName,
                 AppLocalizations.of(context)!. enterContactPersonNamePlease,
               
                  TextInputType.text,
                  false,
                  formKey,
                  1,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 12,
                  vertical: MediaQuery.of(context).size.width / 40),
              child: SlideAnimation(
                position: 3,
                itemCount: 10,
                slideDirection: SlideDirection.fromRight,
                animationController: _animationController,
                child: textField(
                  contactNumberController,
                AppLocalizations.of(context)!.contactNumber,
                   AppLocalizations.of(context)!.enterContactNumberPlease,
                  TextInputType.phone,
                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                  formKey,
                  1,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 12,
                  vertical: MediaQuery.of(context).size.width / 40),
              child: SlideAnimation(
                position: 3,
                itemCount: 10,
                slideDirection: SlideDirection.fromRight,
                animationController: _animationController,
                child: textField(
                  addressController,
                AppLocalizations.of(context)!.customerAddress,
                  AppLocalizations.of(context)!.selectCustomerAddressPlease,
                  TextInputType.text,
                  false,
                  formKey,
                  1,
                ),
              ),
            )
          ],
        ),
      );
    }
    return const SizedBox();
  }

  customer() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width / 12,
        vertical: MediaQuery.of(context).size.width / 40,
      ),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: Container(
          width: 340,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: customerError ? Colors.red[700]! : ColorsRes.warmGreyColor,
              style: BorderStyle.solid,
              width: 0.80,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              hint: Text(
                  AppLocalizations.of(context)!.selectCustomer,
                style: const TextStyle(color: ColorsRes.greyColor),
              ),
              items: customerList.map((con) {
                return DropdownMenuItem(
                  value: con['cId'],
                  child: Text(
                    con['name'],
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == '0') {
                  setState(() {
                    pageIndex = 1;
                  });
                } else {
                  setState(() {
                    pageIndex = 0;
                  });
                }
                setState(() {
                  finalBtn = false;
                  customerProjectDropdownValue = '';
                  newProjectPage = false;
                  customerDropdownValue = value.toString();
                  customerSelected = true;
                  customerError = false;
                  customerProjectList = [
                    {'label': 'N/A', 'value': ''},
                    {'label': 'New Project', 'value': 'new'}
                  ];
                  customerProjectSelected = false;
                });
              },
              isExpanded: true,
              value: customerSelected ? customerDropdownValue.toString() : null,
            ),
          ),
        ),
      ),
    );
  }

  issue() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 40),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: textField(
          issueController,
             AppLocalizations.of(context)!.issueOrRequest,
                AppLocalizations.of(context)!.beDescriptivePlease,
        
          TextInputType.text,
          false,
          formKey,
          4,
        ),
      ),
    );
  }

  solution() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 40),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: textField(
          solutionController,
             AppLocalizations.of(context)!.solution,
               AppLocalizations.of(context)!.solutionError,
        
          TextInputType.text,
          false,
          formKey,
          4,
        ),
      ),
    );
  }

  serviceType() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 40),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: Container(
          width: 340,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: serviceError ? Colors.red[700]! : ColorsRes.warmGreyColor,
              style: BorderStyle.solid,
              width: 0.80,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              hint: Text(
                   AppLocalizations.of(context)!.selectServiceType,
                style: const TextStyle(color: ColorsRes.warmGreyColor),
              ),
              items: serviceTypeList.map((con) {
                return DropdownMenuItem(
                  value: con,
                  child: Text(con),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  serviceTypeDropdownValue = value.toString();
                  serviceTypeSelected = true;
                  serviceError = false;
                });
              },
              isExpanded: false,
              value: serviceTypeSelected
                  ? serviceTypeDropdownValue.toString()
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  owner() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 100),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: Container(
          width: 340,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ownerError ? Colors.red[700]! : ColorsRes.warmGreyColor,
              style: BorderStyle.solid,
              width: 0.80,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              hint: Text(
                  AppLocalizations.of(context)!.selectOwner,
                style: const TextStyle(color: ColorsRes.warmGreyColor),
              ),
              items: ownerList.map((con) {
                return DropdownMenuItem(
                  value: con,
                  child: Text(capitalize(con)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  ownerDropdownValue = value.toString();
                  ownerSelected = true;
                  ownerError = false;
                });
              },
              isExpanded: false,
              value: ownerSelected ? ownerDropdownValue.toString() : null,
            ),
          ),
        ),
      ),
    );
  }

  assigned() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 100),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: Container(
          width: 340,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: assigneeError ? Colors.red[700]! : ColorsRes.warmGreyColor,
              style: BorderStyle.solid,
              width: 0.80,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              hint: Text(
                   AppLocalizations.of(context)!.selectTechnician,
                style: const TextStyle(color: ColorsRes.warmGreyColor),
              ),
              items: assigneeList.map((con) {
                return DropdownMenuItem(
                  value: con,
                  child: Text(capitalize(con)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  assigneeDropdownValue = value.toString();
                  assigneeSelected = true;
                  assigneeError = false;
                });
              },
              isExpanded: false,
              value: assigneeSelected ? assigneeDropdownValue.toString() : null,
            ),
          ),
        ),
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
  complexity() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 100),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: Container(
          width: 340,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  complexityError ? Colors.red[700]! : ColorsRes.warmGreyColor,
              style: BorderStyle.solid,
              width: 0.80,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              hint: Text(
                   AppLocalizations.of(context)!.selectComplexity,
                style: const TextStyle(color: ColorsRes.warmGreyColor),
              ),
              items: complexityList.map((con) {
                return DropdownMenuItem(
                  value: con,
                  child: Text(con),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  complexityDropdownValue = value.toString();
                  complexitySelected = true;
                  complexityError = false;
                });
              },
              isExpanded: false,
              value: complexitySelected
                  ? complexityDropdownValue.toString()
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  projectForm() {
    return SlideAnimation(
      position: 3,
      itemCount: 10,
      slideDirection: SlideDirection.fromRight,
      animationController: _animationController,
      child: Column(
        children: [
          Container(
            child: SlideAnimation(
              position: 3,
              itemCount: 10,
              slideDirection: SlideDirection.fromRight,
              animationController: _animationController,
              child: projectSerial(),
            ),
          ),
          Container(
            child: SlideAnimation(
              position: 3,
              itemCount: 10,
              slideDirection: SlideDirection.fromRight,
              animationController: _animationController,
              child: projectTask(),
            ),
          ),
          Container(
            child: SlideAnimation(
              position: 3,
              itemCount: 10,
              slideDirection: SlideDirection.fromRight,
              animationController: _animationController,
              child: projectDetail(),
            ),
          ),
        ],
      ),
    );
  }

  projectSerial() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 40),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: textField(
          projectSerialController,
            AppLocalizations.of(context)!.projectSerial,
           AppLocalizations.of(context)!.enterProjectSerialPlease,
          TextInputType.text,
          false,
          formKey,
          1,
        ),
      ),
    );
  }

  projectTask() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 40),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: textField(
          projectTaskController,
             AppLocalizations.of(context)!.projectOrTask,
              AppLocalizations.of(context)!.taskEror,
          
          TextInputType.text,
          false,
          formKey,
          1,
        ),
      ),
    );
  }

  projectDetail() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 40),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: textField(
          projectDetailController,
            AppLocalizations.of(context)!.projectDescription,
         AppLocalizations.of(context)!.descriptionError,
          TextInputType.text,
          false,
          formKey,
          4,
        ),
      ),
    );
  }

  Widget showCustomerErrors() {
    return customerError
        ? Container(
            margin:
                EdgeInsets.only(left: MediaQuery.of(context).size.width / 8),
            alignment: Alignment.centerLeft,
            child: Text(
               AppLocalizations.of(context)!.selectCustomer,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
          )
        : const SizedBox();
  }

  Widget showServiceErrors() {
    return serviceError
        ? Container(
            margin:
                EdgeInsets.only(left: MediaQuery.of(context).size.width / 8),
            alignment: Alignment.centerLeft,
            child: Text(
               AppLocalizations.of(context)!.selectServiceType,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
          )
        : const SizedBox();
  }

  Widget showOwnerErrors() {
    return ownerError
        ? Container(
            margin:
                EdgeInsets.only(left: MediaQuery.of(context).size.width / 8),
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.selectOwner,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
          )
        : const SizedBox();
  }

  Widget showAssigneeErrors() {
    return assigneeError
        ? Container(
            margin:
                EdgeInsets.only(left: MediaQuery.of(context).size.width / 8),
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.selectTechnician,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
          )
        : const SizedBox();
  }

  Widget showComplexityErrors() {
    return complexityError
        ? Container(
            margin:
                EdgeInsets.only(left: MediaQuery.of(context).size.width / 8),
            alignment: Alignment.centerLeft,
            child: Text(
             AppLocalizations.of(context)!.selectComplexity,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
          )
        : const SizedBox();
  }

  submitForm() async {
    if (formKey.currentState!.validate() &&
        customerDropdownValue!.isNotEmpty &&
        solutionController.text.isNotEmpty &&
        serviceTypeDropdownValue!.isNotEmpty &&
        ownerDropdownValue!.isNotEmpty &&
        assigneeDropdownValue!.isNotEmpty &&
        complexityDropdownValue!.isNotEmpty) {
      setState(() {
        btnDisable = true;
      });
      var data = {
        'service_area': serviceAreaController.text,
        'exclient': customerDropdownValue,
        'c_id': '',
        'customername': customerNameController.text.trim(),
        'contactname': contactPersonController.text,
        'phone': contactNumberController.text,
        'address': addressController.text,
        'description': issueController.text,
        'solution': solutionController.text,
        'service_type': serviceTypeDropdownValue,
        'owned_by': ownerDropdownValue,
        'assigned_to': assigneeDropdownValue,
        'service_cmplx': complexityDropdownValue,
        'projects': customerProjectDropdownValue,
        'projectSerial': projectSerialController.text,
        'projectDetail': projectDetailController.text,
        'projectTask': projectTaskController.text,
      };

      var create = await apiService.createNewCsr(data);
      if (create) {
        serviceAreaController.clear();
        // customerDropdownValue = null;
        // serviceTypeDropdownValue = null;
        // complexityDropdownValue = null;
        // customerDropdownValue = null;
        customerNameController.clear();
        contactPersonController.clear();
        contactNumberController.clear();
        addressController.clear();
        issueController.clear();
        solutionController.clear();
        projectSerialController.clear();
        projectDetailController.clear();
        projectTaskController.clear();
        setState(() {
          nextPage = false;
          btnDisable = false;
          serviceTypeSelected = false;
          ownerSelected = false;
          assigneeSelected = false;
          complexitySelected = false;
          customerSelected = false;
          newProjectPage = false;
          pageIndex = 0;
          finalBtn = false;
        });
        getDefaultValues();
      } else {
        setState(() {
          newProjectPage = false;
          nextPage = false;
          btnDisable = false;
          // pageIndex = 0;
          // finalBtn = false;
          // serviceTypeSelected = false;
          // ownerSelected = false;
          // assigneeSelected = false;
          // complexitySelected = false;
          // customerSelected = false;
        });
      }
    }
  }
}
