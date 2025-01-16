import 'package:flutter/material.dart';
import 'package:qfix_nitmo_new/helper/ColorsRes.dart';
import 'package:qfix_nitmo_new/ui/responsiveLayout.dart';


textField(controller, labelText, hintText, keyboardType, inputFormatters,
    formKey, maxLines) {
  return ResponsiveLayout(
    mobileBody: TextFormField(
      cursorColor: Colors.black,
      maxLines: maxLines,
      inputFormatters: inputFormatters != false
          ? [
              inputFormatters,
            ]
          : null,
      validator: (val) {
        if (val!.isNotEmpty) {
          return null;
        } else {
          return hintText;
        }
      },
      onChanged: (_) {
        // formKey.currentState.reset();
      },
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        // contentPadding: EdgeInsets.only(left: 15.0),
        hintStyle: TextStyle(
            color: ColorsRes.purpalColor,
            fontSize: 16,
            fontWeight: FontWeight.normal),

        filled: false,
        focusColor: ColorsRes.black,
        focusedBorder: OutlineInputBorder(
          gapPadding: 4.0,
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ColorsRes.warmGreyColor,
          ),
        ),
        border: OutlineInputBorder(
          gapPadding: 0.0,
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ColorsRes.warmGreyColor,
            width: 1,
          ),
        ),
        labelText: labelText,
        labelStyle: TextStyle(
          color: ColorsRes.warmGreyColor,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        contentPadding: EdgeInsets.all(15.0),
        // hintText: hintText,
      ),
    ),
    tabletBody: TextFormField(
      cursorColor: Colors.black,
      maxLines: maxLines,
      inputFormatters: inputFormatters != false
          ? [
              inputFormatters,
            ]
          : null,
      validator: (val) {
        if (val!.isNotEmpty) {
          return null;
        } else {
          return hintText;
        }
      },
      onChanged: (_) {
        // formKey.currentState.reset();
      },
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintStyle: TextStyle(
          color: ColorsRes.purpalColor,
          fontSize: 18,
          fontWeight: FontWeight.normal,
        ),
        errorStyle: TextStyle(
          fontSize: 18,
        ),
        filled: false,
        focusColor: ColorsRes.black,
        focusedBorder: OutlineInputBorder(
          gapPadding: 0.0,
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ColorsRes.warmGreyColor,
          ),
        ),
        border: OutlineInputBorder(
          gapPadding: 0.0,
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ColorsRes.warmGreyColor,
            width: 1.5,
          ),
        ),
        labelText: labelText,
        labelStyle: TextStyle(
          color: ColorsRes.warmGreyColor,
          fontSize: 18,
          fontWeight: FontWeight.normal,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
      ),
    ),
  );
}

dropDown(optionList, hintText, selectedValue) {
  bool itemSelected = true;

  return ResponsiveLayout(
    mobileBody: DropdownButtonHideUnderline(
      child: DropdownButton(
        hint: Text(
          hintText,
          style: TextStyle(color: ColorsRes.warmGreyColor),
        ),
        items: optionList.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (value) {
          // selectedValue = value.toString();
          // itemSelected = true;
        },
        isExpanded: false,
        // value: itemSelected ? selectedValue.toString() : null,
      ),
    ),
    tabletBody: Container(
      margin: EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
      ),
      width: 10,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorsRes.warmGreyColor,
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          hint: Text(
            hintText,
            style: TextStyle(
              color: ColorsRes.warmGreyColor,
              fontSize: 18,
            ),
          ),
          items: optionList.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                'option',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            // selectedValue = value.toString();
            // itemSelected = true;
          },
          isExpanded: false,
          // value: itemSelected ? selectedValue.toString() : null,
        ),
      ),
    ),
  );
}
