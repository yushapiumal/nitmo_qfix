import 'package:flutter/material.dart';

class Item {
  final String id;
  final String itemName;
  final String itemModel;
  final String itemDescription;
  final String itemTag;
  final int itemQuantity;
  final double itemRetailPrice;
  final Map<String, dynamic> itemsPeriodPrice;

  Item({
    required this.id,
    required this.itemName,
    required this.itemModel,
    required this.itemDescription,
    required this.itemTag,
    required this.itemQuantity,
    required this.itemRetailPrice,
    required this.itemsPeriodPrice,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id']?.toString() ?? UniqueKey().toString(),
      itemName: json['itemName'] ?? 'Unknown',
      itemModel: json['itemModel'] ?? 'N/A',
      itemDescription: json['itemDescription'] ?? '',
      itemTag: json['itemTag'] ?? '',
      itemQuantity: json['itemQuantity'] is int
          ? json['itemQuantity']
          : int.tryParse(json['itemQuantity']?.toString() ?? '0') ?? 0,
      itemRetailPrice: (json['itemRetailPrice'] ?? 0.0).toDouble(),
      itemsPeriodPrice: json['itemsPeriodPrice'] is Map
          ? Map<String, dynamic>.from(json['itemsPeriodPrice'])
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'itemName': itemName,
      'itemModel': itemModel,
      'itemDescription': itemDescription,
      'itemTag': itemTag,
      'itemQuantity': itemQuantity,
      'itemRetailPrice': itemRetailPrice,
      'itemsPeriodPrice': itemsPeriodPrice,
    };
  }
}

class Kit extends Item {
  final Map<String, Item> kitItems;

  Kit({
    required String id,
    required String itemName,
    required String itemModel,
    required String itemDescription,
    required String itemTag,
    required int itemQuantity,
    required double itemRetailPrice,
    required Map<String, dynamic> itemsPeriodPrice,
    required this.kitItems,
  }) : super(
          id: id,
          itemName: itemName,
          itemModel: itemModel,
          itemDescription: itemDescription,
          itemTag: itemTag,
          itemQuantity: itemQuantity,
          itemRetailPrice: itemRetailPrice,
          itemsPeriodPrice: itemsPeriodPrice,
        );

  factory Kit.fromJson(Map<String, dynamic> json) {
    final kitItemsJson = json['kitItems'] as Map<String, dynamic>? ?? {};
    final kitItems = kitItemsJson.map(
      (key, value) => MapEntry(key, Item.fromJson(Map<String, dynamic>.from(value))),
    );

    return Kit(
      id: json['_id']?.toString() ?? UniqueKey().toString(),
      itemName: json['kitName'] ?? 'Unknown Kit',
      itemModel: json['itemModel'] ?? 'N/A',
      itemDescription: json['itemDescription'] ?? '',
      itemTag: json['kitTag'] ?? 'kit',
      itemQuantity: json['kitQuantity'] is int
          ? json['kitQuantity']
          : int.tryParse(json['kitQuantity']?.toString() ?? '0') ?? 0,
      itemRetailPrice: (json['kitRetailPrice'] ?? 0.0).toDouble(),
      itemsPeriodPrice: json['kitsPeriodPrice'] is Map
          ? Map<String, dynamic>.from(json['kitsPeriodPrice'])
          : {},
      kitItems: kitItems,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'kitName': itemName,
      'itemModel': itemModel,
      'itemDescription': itemDescription,
      'kitTag': itemTag,
      'kitQuantity': itemQuantity,
      'kitRetailPrice': itemRetailPrice,
      'kitsPeriodPrice': itemsPeriodPrice,
      'kitItems': kitItems.map((key, item) => MapEntry(key, item.toJson())),
    };
  }
}

class SelectedItem {
  Item? item; // Can be Item or Kit
  int quantity;
  TextEditingController quantityController;
  List<String> serialNumbers;
  List<String> selectedSerialNumbers;
  List<SelectedItem>? subItems;

  SelectedItem({
    this.item,
    this.quantity = 0,
    this.serialNumbers = const [],
    this.selectedSerialNumbers = const [],
    this.subItems,
  }) : quantityController = TextEditingController(text: quantity > 0 ? quantity.toString() : '');

  double getSelectedPrice(String priceType) {
    if (item == null || priceType.isEmpty) return 0.0;
    return (item!.itemsPeriodPrice[priceType] ?? 0.0).toDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item?.toJson(),
      'quantity': quantity,
      'subItems': subItems?.map((subItem) => subItem.toJson()).toList(),
      'serialNumbers': serialNumbers,
      'selectedSerialNumbers': selectedSerialNumbers,
    };
  }



  SelectedItem copy() {
    final newItem = SelectedItem(
      item: item,
      quantity: quantity,
      serialNumbers: List.from(serialNumbers),
      selectedSerialNumbers: List.from(selectedSerialNumbers),
      subItems: subItems != null ? subItems!.map((subItem) => subItem.copy()).toList() : null,
    )..quantityController.text = quantityController.text;
    return newItem;
  }

    void dispose() {
    quantityController.dispose();
    subItems?.forEach((subItem) => subItem.dispose());
  }
}