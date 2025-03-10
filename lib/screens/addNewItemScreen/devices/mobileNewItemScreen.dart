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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
               Navigator.of(context).pop();
             // Navigator.popAndPushNamed(context, CheckStoreScreen.routeName);
            },
          ),
          shadowColor: Colors.transparent,
          title: Text(
            AppLocalizations.of(context)!.addNewItem,
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
          AppLocalizations.of(context)!.itemCode,
          AppLocalizations.of(context)!.itemCodeError,
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
          AppLocalizations.of(context)!.itemName,
          AppLocalizations.of(context)!.itemNameerror,
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
          AppLocalizations.of(context)!.itemLocation,
          AppLocalizations.of(context)!.itemLocationError,
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
        margin: const EdgeInsets.only(
          top: 10,
          bottom: 10,
        ),
        width: MediaQuery.of(context).size.width / 1.2,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
              AppLocalizations.of(context)!.selectUom,
              style: const TextStyle(color: ColorsRes.warmGreyColor),
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
          AppLocalizations.of(context)!.itemMaxAmount,
          AppLocalizations.of(context)!.itemMaxAmountError,
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
          AppLocalizations.of(context)!.itemMinAmount,
          AppLocalizations.of(context)!.itemMinAmountError,
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
          AppLocalizations.of(context)!.itemReOderAmount,
          AppLocalizations.of(context)!.itemReOderAmountError,
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
              return AppLocalizations.of(context)!.pleaseitemDescription;
            }
          },
          controller: itemDetailController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 15.0, top: 20),
            hintStyle: TextStyle(
              color: ColorsRes.purpalColor,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            labelStyle: const TextStyle(
                color: ColorsRes.warmGreyColor,
                fontSize: 16,
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
            labelText: AppLocalizations.of(context)!.itemDescription,
            hintText: AppLocalizations.of(context)!.pleaseitemDescription,
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
          AppLocalizations.of(context)!.itemCategory,
          AppLocalizations.of(context)!.itemCategoryError,
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
          AppLocalizations.of(context)!.itemSubCategory,
          AppLocalizations.of(context)!.itemSubCategoryError,
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

    print("==========================${itemCodeController.text}");

      var addItem = await apiService.addNewItem(itemCodeController.text, data);
      if (addItem) {
        setState(() {
          itemCodeController.clear();
          itemMaxController.clear();
          itemLocationController.clear();
          itemNameController.clear();
          uomDropdownValue = AppLocalizations.of(context)!.selectUomError;
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
        errorText = AppLocalizations.of(context)!.selectUomError;
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
                const SizedBox(
                  height: 4,
                ),
                itemName(),
                const SizedBox(
                  height: 4,
                ),
                itemCategory(),
                const SizedBox(
                  height: 4,
                ),
                itemSubCategory(),
                const SizedBox(
                  height: 4,
                ),
                itemLocation(),
                const SizedBox(
                  height: 4,
                ),
                itemUom(),
                showErrors(),
                const SizedBox(
                  height: 4,
                ),
                itemMaxCount(),
                const SizedBox(
                  height: 4,
                ),
                itemMinCount(),
                const SizedBox(
                  height: 4,
                ),
                itemReorderCount(),
                const SizedBox(
                  height: 4,
                ),
                itemDetails(),
                const SizedBox(
                  height: 4,
                ),
                const SizedBox(
                  height: 30,
                ),
                SlideAnimation(
                  position: 3,
                  itemCount: 10,
                  slideDirection: SlideDirection.fromRight,
                  animationController: _animationController,
                  child: CupertinoButton(
                    color: ColorsRes.secondaryButton,
                    onPressed: () {
                      btnDisable ? false : submitForm();
                    },
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
                            text: btnDisable ? AppLocalizations.of(context)!.checking : AppLocalizations.of(context)!.addItem,
                            style: const TextStyle(
                                fontSize: 17,
                                color: ColorsRes.black,
                                fontWeight: FontWeight.bold),
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
