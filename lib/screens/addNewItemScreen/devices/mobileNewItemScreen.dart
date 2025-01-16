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


class MobileNewItemScreen extends StatefulWidget {
  const MobileNewItemScreen({Key? key}) : super(key: key);

  @override
  State<MobileNewItemScreen> createState() => _MobileNewItemScreenState();
}

class _MobileNewItemScreenState extends State<MobileNewItemScreen>
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
  bool _valItemCode = false;
  bool _valItemName = false;
  bool _valItemLocation = false;
  bool _valItemDetail = false;
  bool _valItemMax = false;
  bool _valItemMin = false;
  bool _valItemReorder = false;
  bool btnDisable = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
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
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              // Navigator.of(context).pop();
              Navigator.popAndPushNamed(context, CheckStoreScreen.routeName);
            },
          ),
          shadowColor: Colors.transparent,
          title: Text(
            "Add New Item".toUpperCase(),
            style: TextStyle(
              letterSpacing: 4,
            ),
          ),
          bottom: PreferredSize(
            child: Divider(
              color: ColorsRes.greyColor,
              height: 2.3,
            ),
            preferredSize: Size(50, 5),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Container(
          margin: EdgeInsets.only(top: 20),
          child: showBody(),
        ),
      ),
    );
  }

  Widget itemCode() {
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
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 40),
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
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 40),
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
    return SlideAnimation(
      position: 3,
      itemCount: 10,
      slideDirection: SlideDirection.fromRight,
      animationController: _animationController,
      child: Container(
        margin: EdgeInsets.only(
          top: 10,
          bottom: 10,
        ),
        width: MediaQuery.of(context).size.width / 1.2,
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: showError ? Colors.red[700]! : ColorsRes.warmGreyColor,
            style: BorderStyle.solid,
            width: 0.80,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            hint: Text(
              'Please select uom',
              style: TextStyle(color: ColorsRes.warmGreyColor),
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
    );
  }

  Widget itemMaxCount() {
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
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 40),
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
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 40),
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
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 40),
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
            contentPadding: EdgeInsets.only(left: 15.0, top: 20),
            hintStyle: TextStyle(
              color: ColorsRes.purpalColor,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            labelStyle: TextStyle(
                color: ColorsRes.warmGreyColor,
                fontSize: 16,
                fontWeight: FontWeight.normal),
            filled: false,
            focusColor: ColorsRes.warmGreyColor,
            focusedBorder: OutlineInputBorder(
              gapPadding: 2.0,
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: ColorsRes.warmGreyColor,
              ),
            ),
            border: OutlineInputBorder(
              gapPadding: 0.3,
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
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
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 40),
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
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 12,
          vertical: MediaQuery.of(context).size.width / 40),
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
        : SizedBox();
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
                itemCode(),
                SizedBox(
                  height: 4,
                ),
                itemName(),
                SizedBox(
                  height: 4,
                ),
                itemCategory(),
                SizedBox(
                  height: 4,
                ),
                itemSubCategory(),
                SizedBox(
                  height: 4,
                ),
                itemLocation(),
                SizedBox(
                  height: 4,
                ),
                itemUom(),
                showErrors(),
                SizedBox(
                  height: 4,
                ),
                itemMaxCount(),
                SizedBox(
                  height: 4,
                ),
                itemMinCount(),
                SizedBox(
                  height: 4,
                ),
                itemReorderCount(),
                SizedBox(
                  height: 4,
                ),
                itemDetails(),
                SizedBox(
                  height: 4,
                ),
                SizedBox(
                  height: 30,
                ),
                SlideAnimation(
                  position: 3,
                  itemCount: 10,
                  slideDirection: SlideDirection.fromRight,
                  animationController: _animationController,
                  child: CupertinoButton(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          WidgetSpan(
                            child: Icon(
                              btnDisable
                                  ? Icons.hourglass_top_rounded
                                  : Icons.add,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: btnDisable ? "Wait..." : "Add New Item",
                            style: TextStyle(
                                fontSize: 17,
                                color: ColorsRes.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    color: ColorsRes.secondaryButton,
                    onPressed: () {
                      btnDisable ? false : submitForm();
                    },
                  ),
                ),
                SizedBox(
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
