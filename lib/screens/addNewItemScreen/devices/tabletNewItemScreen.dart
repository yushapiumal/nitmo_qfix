import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:localstorage/localstorage.dart';
import 'package:qfix_nitmo_new/Constant/Slideanimation.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/screens/manageStoreScreen/checkStoreScreen.dart';
import 'package:qfix_nitmo_new/widgets/widgets.dart';

class TabletNewItemScreen extends StatefulWidget {
  const TabletNewItemScreen({Key? key}) : super(key: key);

  @override
  State<TabletNewItemScreen> createState() => _TabletNewItemScreenState();
}

class _TabletNewItemScreenState extends State<TabletNewItemScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  final LocalStorage storage = LocalStorage('qfix');
  APIService apiService = APIService();
  final formKey = GlobalKey<FormState>();

  String errorText = "";
  TextEditingController itemCodeController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController subCategoryController = TextEditingController();
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemDetailController = TextEditingController();
  TextEditingController itemLocationController = TextEditingController();
  TextEditingController itemMaxController = TextEditingController();
  TextEditingController itemMinController = TextEditingController();
  TextEditingController itemReorderController = TextEditingController();
  String uomDropdownValue = "Please select uom";
  var uomList = ['Pcs', 'Ft', 'Kg', 'g', 'Ltr', 'L'];
  bool showError = false;
  bool itemSelected = false;
  final bool _valItemCode = false;
  final bool _valItemName = false;
  final bool _valItemLocation = false;
  final bool _valItemDetail = false;
  final bool _valItemMax = false;
  final bool _valItemMin = false;
  final bool _valItemReorder = false;
  bool btnDisable = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    _animationController!.dispose();

    super.dispose();
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
              size: 30,
            ),
            onPressed: () {
              // Navigator.of(context).pop();
              Navigator.popAndPushNamed(context, CheckStoreScreen.routeName);
            },
          ),
          shadowColor: Colors.transparent,
          title: Text(
            "Add New Item".toUpperCase(),
            style: const TextStyle(
              letterSpacing: 4,
            ),
          ),
          bottom: const PreferredSize(
            preferredSize: Size(50, 5),
            child: Divider(
              color: ColorsRes.greyColor,
              height: 2.3,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Container(
          margin: const EdgeInsets.only(top: 20),
          child: showBody(),
        ),
      ),
    );
  }

  Widget itemCode() {
    return Container(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 10,
        right: MediaQuery.of(context).size.width / 10,
      ),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: textField(
          itemCodeController,
          'Item Code',
          'Please enter item code / bin code',
          TextInputType.text,
          FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
          formKey,
          1,
        ),
      ),
    );
  }

  Widget itemName() {
    return Container(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 10,
        right: MediaQuery.of(context).size.width / 10,
      ),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: textField(
          itemNameController,
          'Item Name',
          'Please enter item name',
          TextInputType.text,
          false,
          formKey,
          1,
        ),
      ),
    );
  }

  Widget itemLocation() {
    return Container(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 10,
        right: MediaQuery.of(context).size.width / 10,
      ),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: textField(
          itemLocationController,
          'Item Location',
          'Please enter item location',
          TextInputType.text,
          false,
          formKey,
          1,
        ),
      ),
    );
  }

  Widget itemUom() {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 10,
        right: MediaQuery.of(context).size.width / 10,
      ),
      width: MediaQuery.of(context).size.width,
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: Container(
          width: 340,
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: showError ? Colors.red[700]! : ColorsRes.warmGreyColor,
              style: BorderStyle.solid,
              width: 0.80,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              hint: const Text(
                'Please select uom',
                style: TextStyle(
                  color: ColorsRes.warmGreyColor,
                  fontSize: 18,
                ),
              ),
              items: uomList.map((con) {
                return DropdownMenuItem(
                  value: con,
                  child: Text(con),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  uomDropdownValue = value.toString();
                  itemSelected = true;
                  errorText = "";
                  showError = false;
                });
              },
              isExpanded: false,
              value: itemSelected ? uomDropdownValue.toString() : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget itemMaxCount() {
    return Container(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 10,
        right: MediaQuery.of(context).size.width / 10,
      ),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: textField(
          itemMaxController,
          'Item Max Amount',
          'Please enter item max amount',
          TextInputType.phone,
          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
          formKey,
          1,
        ),
      ),
    );
  }

  Widget itemMinCount() {
    return Container(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 10,
        right: MediaQuery.of(context).size.width / 10,
      ),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: textField(
          itemMinController,
          'Item Min Amount',
          'Please enter item min amount',
          TextInputType.phone,
          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
          formKey,
          1,
        ),
      ),
    );
  }

  Widget itemReorderCount() {
    return Container(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 10,
        right: MediaQuery.of(context).size.width / 10,
      ),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: textField(
          itemReorderController,
          'Item Re-order Amount',
          'Please enter item reorder amount',
          TextInputType.phone,
          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
          formKey,
          1,
        ),
      ),
    );
  }

  Widget itemDetails() {
    return Container(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 10,
        right: MediaQuery.of(context).size.width / 10,
      ),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: TextFormField(
          maxLines: 3,
          validator: (value) {
            if (value!.isNotEmpty) {
              return null;
            } else {
              return 'Please enter item description';
            }
          },
          controller: itemDetailController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 15.0, top: 20),
            errorStyle: const TextStyle(
              fontSize: 12,
            ),
            hintStyle: TextStyle(
              color: ColorsRes.purpalColor,
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
            labelStyle: const TextStyle(
                color: ColorsRes.warmGreyColor,
                fontSize: 18,
                fontWeight: FontWeight.normal),
            filled: false,
            focusColor: ColorsRes.warmGreyColor,
            focusedBorder: OutlineInputBorder(
              gapPadding: 2.0,
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: ColorsRes.warmGreyColor,
              ),
            ),
            border: OutlineInputBorder(
              gapPadding: 0.3,
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: ColorsRes.warmGreyColor,
                width: 1,
              ),
            ),
            labelText: 'Item Description',
            hintText: 'Please enter item description',
          ),
        ),
      ),
    );
  }

  Widget itemCategory() {
    return Container(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 10,
        right: MediaQuery.of(context).size.width / 10,
      ),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: textField(
          categoryController,
          'Item Category (optional)',
          'Please enter item category (optional)',
          TextInputType.text,
          false,
          formKey,
          1,
        ),
      ),
    );
  }

  Widget itemSubCategory() {
    return Container(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 10,
        right: MediaQuery.of(context).size.width / 10,
      ),
      child: SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: textField(
          subCategoryController,
          'Item SubCategory (optional)',
          'Please enter item subcategory (optional)',
          TextInputType.text,
          false,
          formKey,
          1,
        ),
      ),
    );
  }

  Widget showErrors() {
    return showError
        ? Container(
            margin:
                EdgeInsets.only(left: MediaQuery.of(context).size.width / 8),
            alignment: Alignment.centerLeft,
            child: Text(
              errorText,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
          )
        : const SizedBox();
  }

  submitForm() async {
    if (formKey.currentState!.validate() && itemSelected) {
      setState(() {
        btnDisable = true;
      });
      var data = {
        'item_code': itemCodeController.text,
        'item_name': itemNameController.text,
        'category': categoryController.text,
        'sub_category': subCategoryController.text,
        'location': itemLocationController.text,
        'uom': uomDropdownValue,
        'max': itemMaxController.text,
        'min': itemMinController.text,
        'reorder': itemReorderController.text,
        'description': itemDetailController.text,
      };

      var addItem = await apiService.addNewItem(itemCodeController.text, data);
      if (addItem) {
        setState(() {
          itemCodeController.clear();
          itemMaxController.clear();
          itemLocationController.clear();
          itemNameController.clear();
          uomDropdownValue = "Please select uom";
          itemSelected = false;
          itemMinController.clear();
          itemMinController.clear();
          itemReorderController.clear();
          itemDetailController.clear();
          categoryController.clear();
          subCategoryController.clear();
          btnDisable = false;
        });
      } else {
        setState(() {
          btnDisable = false;
        });
      }
    } else {
      setState(() {
        showError = true;
        errorText = 'Please select uom';
        btnDisable = false;
      });
    }
  }

  Widget showBody() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width / 45,
                ),
                itemCode(),
                SizedBox(
                  height: MediaQuery.of(context).size.width / 25,
                ),
                itemName(),
                SizedBox(
                  height: MediaQuery.of(context).size.width / 25,
                ),
                itemCategory(),
                SizedBox(
                  height: MediaQuery.of(context).size.width / 25,
                ),
                itemSubCategory(),
                SizedBox(
                  height: MediaQuery.of(context).size.width / 25,
                ),
                itemLocation(),
                SizedBox(
                  height: MediaQuery.of(context).size.width / 25,
                ),
                itemUom(),
                showErrors(),
                SizedBox(
                  height: MediaQuery.of(context).size.width / 25,
                ),
                itemMaxCount(),
                SizedBox(
                  height: MediaQuery.of(context).size.width / 25,
                ),
                itemMinCount(),
                SizedBox(
                  height: MediaQuery.of(context).size.width / 25,
                ),
                itemReorderCount(),
                SizedBox(
                  height: MediaQuery.of(context).size.width / 25,
                ),
                itemDetails(),
                SizedBox(
                  height: MediaQuery.of(context).size.width / 25,
                ),
                SlideAnimation(
                  position: 3,
                  itemCount: 10,
                  slideDirection: SlideDirection.fromRight,
                  animationController: _animationController,
                  child: Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 30,
                      right: MediaQuery.of(context).size.width / 30,
                      top: MediaQuery.of(context).size.width / 30,
                    ),
                    width: 400,
                    child: CupertinoButton(
                      onPressed: () {
                        btnDisable ? false : submitForm();
                      },
                      color: ColorsRes.secondaryButton,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            btnDisable
                                ? CupertinoIcons.hourglass
                                : CupertinoIcons.add,
                            color: Colors.black,
                            size: 35,
                          ),
                          SizedBox(width: 5),
                          Text(
                            btnDisable ? "Wait..." : "Add New Item",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
