// import 'package:flutter/material.dart';
// import 'package:qfix_nitmo_new/helper/itemModel.dart';

// class ItemsKitsPage extends StatelessWidget {
//   final List<SelectedItem> selectedItems;
//   final List<Item> availableItems;
//   final List<Item> availableKits;
//   final bool isLoading;
//   final String? selectedGroup;
//   final String? selectedPriceType;
//   final String documentType;
//   final Function(BuildContext, {required bool isKit, int? parentKitIndex})
//       onAddItemRow;
//   final Function(BuildContext, SelectedItem, {int? parentKitIndex})
//       onEditItemRow;
//   final Function(int, {int? parentKitIndex}) onRemoveItemRow;
//   final Function(BuildContext, SelectedItem, int, {int? subItemIndex})
//       onSerialNumberTap;
//   final Function(int, String) fetchSerialNumbers;

//   const ItemsKitsPage({
//     Key? key,
//     required this.selectedItems,
//     required this.availableItems,
//     required this.availableKits,
//     required this.isLoading,
//     required this.selectedGroup,
//     required this.selectedPriceType,
//     required this.documentType,
//     required this.onAddItemRow,
//     required this.onEditItemRow,
//     required this.onRemoveItemRow,
//     required this.onSerialNumberTap,
//     required this.fetchSerialNumbers,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final hasSelectedItems =
//         selectedItems.any((item) => item.item != null && item.quantity > 0);
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Card(
//             elevation: 2,
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   if (selectedGroup == 'kit') ...[
//                     Text(
//                       'Select Kits',
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: Theme.of(context).primaryColor,
//                           ),
//                     ),
//                   ] else if (selectedGroup == 'item') ...[
//                     Text(
//                       'Select Items',
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: Theme.of(context).primaryColor,
//                           ),
//                     ),
//                   ],
//                   const SizedBox(height: 16),
//                   if (availableItems.isEmpty &&
//                       availableKits.isEmpty &&
//                       !isLoading)
//                     const Center(
//                       child: Text(
//                         'No items or kits available',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     )
//                   else ...[
//                     if (selectedGroup == 'kit') ...[
//                       ElevatedButton.icon(
//                         icon: const Icon(Icons.add, color: Colors.white),
//                         label: const Text(
//                           'Add Kit',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         onPressed: availableKits.isNotEmpty
//                             ? () => onAddItemRow(context, isKit: true)
//                             : null,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 12, horizontal: 24),
//                         ),
//                       ),
//                     ] else if (selectedGroup == 'item') ...[
//                       ElevatedButton.icon(
//                         icon: const Icon(Icons.add, color: Colors.white),
//                         label: const Text(
//                           'Add Item',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         onPressed: availableItems.isNotEmpty
//                             ? () => onAddItemRow(context, isKit: false)
//                             : null,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 12, horizontal: 24),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           ListView.builder(
//             key: const ValueKey('selectedItemsList'),
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: selectedItems
//                 .where((item) => item.item != null && item.quantity > 0)
//                 .length,
//             itemBuilder: (context, index) {
//               final validItems = selectedItems
//                   .asMap()
//                   .entries
//                   .where((entry) =>
//                       entry.value.item != null && entry.value.quantity > 0)
//                   .toList();
//               final selectedItem = validItems[index].value;
//               final originalIndex = validItems[index].key;
//               final isKit = selectedItem.item is Kit;
//               final kitItems =
//                   isKit ? (selectedItem.item as Kit).kitItems : null;
//               return Card(
//                 elevation: 2,
//                 margin: const EdgeInsets.only(bottom: 8.0),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   selectedItem.item!.itemName,
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   'Description: ${selectedItem.item!.itemName}',
//                                   style: const TextStyle(fontSize: 14),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Model: ${selectedItem.item!.itemModel.isEmpty ? 'N/A' : selectedItem.item!.itemModel}',
//                                   style: const TextStyle(fontSize: 14),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Stock: ${selectedItem.item!.itemQuantity}',
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Tag: ${selectedItem.item!.itemTag.isEmpty ? 'N/A' : selectedItem.item!.itemTag}',
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                                 if (isKit) ...[
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     'Price (${selectedPriceType ?? 'retail'}): Rs${selectedItem.getSelectedPrice(selectedPriceType ?? 'retail').toStringAsFixed(2)}',
//                                     style: const TextStyle(fontSize: 14),
//                                   ),
//                                   if (kitItems != null &&
//                                       kitItems.isNotEmpty) ...[
//                                     const SizedBox(height: 8),
//                                     const Text(
//                                       'Items in Kit:',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: 14),
//                                     ),
//                                     ...kitItems.entries
//                                         .toList()
//                                         .asMap()
//                                         .entries
//                                         .map((entry) {
//                                       final subIndex = entry.key;
//                                       final kitItem = entry.value.value;
//                                       final kitItemSelected = selectedItem
//                                                       .subItems !=
//                                                   null &&
//                                               subIndex <
//                                                   selectedItem.subItems!.length
//                                           ? selectedItem.subItems![subIndex]
//                                           : SelectedItem(
//                                               item: kitItem,
//                                               quantity: kitItem.itemQuantity,
//                                               serialNumbers: [],
//                                               selectedSerialNumbers: [],
//                                             );
//                                       if (documentType.toLowerCase() ==
//                                               'invoice' &&
//                                           kitItemSelected.item != null &&
//                                           kitItemSelected
//                                               .item!.itemModel.isNotEmpty &&
//                                           kitItemSelected.item!.itemModel !=
//                                               'N/A' &&
//                                           kitItemSelected
//                                               .serialNumbers.isEmpty) {
//                                         fetchSerialNumbers(originalIndex,
//                                             kitItemSelected.item!.itemModel);
//                                       }
//                                       return InkWell(
//                                         onTap:
//                                             documentType
//                                                             .toLowerCase() ==
//                                                         'invoice' &&
//                                                     kitItemSelected
//                                                             .item !=
//                                                         null &&
//                                                     kitItemSelected.item!
//                                                         .itemModel.isNotEmpty &&
//                                                     kitItemSelected
//                                                             .item!.itemModel !=
//                                                         'N/A' &&
//                                                     kitItemSelected
//                                                         .serialNumbers
//                                                         .isNotEmpty
//                                                 ? () => onSerialNumberTap(
//                                                       context,
//                                                       kitItemSelected,
//                                                       originalIndex,
//                                                       subItemIndex: subIndex,
//                                                     )
//                                                 : null,
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 8.0, top: 4.0),
//                                           child: Row(
//                                             children: [
//                                               Expanded(
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       '- ${kitItem.itemDescription}',
//                                                       style: const TextStyle(
//                                                           fontSize: 12),
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                     ),
//                                                     const SizedBox(height: 4),
//                                                     if (documentType
//                                                                 .toLowerCase() ==
//                                                             'invoice' &&
//                                                         kitItemSelected
//                                                             .item!
//                                                             .itemModel
//                                                             .isNotEmpty &&
//                                                         kitItemSelected.item!
//                                                                 .itemModel !=
//                                                             'N/A') ...[
//                                                       Container(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(8),
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           color: kitItemSelected
//                                                                   .selectedSerialNumbers
//                                                                   .isNotEmpty
//                                                               ? Colors.yellow
//                                                               : Colors.grey
//                                                                   .shade200,
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(4),
//                                                         ),
//                                                         child: Text(
//                                                           'S/N: ${kitItemSelected.selectedSerialNumbers.isEmpty ? 'Tap to scan' : kitItemSelected.selectedSerialNumbers.join(', ')}',
//                                                           style:
//                                                               const TextStyle(
//                                                             fontSize: 12,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black,
//                                                           ),
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     }),
//                                   ],
//                                 ] else ...[
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'Quantity: ${selectedItem.quantity}',
//                                     style: const TextStyle(fontSize: 14),
//                                   ),
//                                   if (documentType.toLowerCase() == 'invoice' &&
//                                       selectedGroup != 'kit' &&
//                                       selectedItem.item!.itemModel.isNotEmpty &&
//                                       selectedItem.item!.itemModel !=
//                                           'N/A') ...[
//                                     const SizedBox(height: 8),
//                                     InkWell(
//                                       onTap:
//                                           selectedItem.serialNumbers.isNotEmpty
//                                               ? () => onSerialNumberTap(context,
//                                                   selectedItem, originalIndex)
//                                               : null,
//                                       child: Container(
//                                         padding: const EdgeInsets.all(8),
//                                         decoration: BoxDecoration(
//                                           color: selectedItem
//                                                   .selectedSerialNumbers
//                                                   .isNotEmpty
//                                               ? Colors.yellow
//                                               : Colors.grey.shade200,
//                                           borderRadius:
//                                               BorderRadius.circular(4),
//                                         ),
//                                         child: Text(
//                                           'S/N: ${selectedItem.selectedSerialNumbers.isEmpty ? 'Tap to scan' : selectedItem.selectedSerialNumbers.join(', ')}',
//                                           style: const TextStyle(
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.black,
//                                           ),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'Price (${selectedPriceType ?? 'retail'}): Rs${selectedItem.getSelectedPrice(selectedPriceType ?? 'retail').toStringAsFixed(2)}',
//                                     style: const TextStyle(fontSize: 14),
//                                   ),
//                                 ],
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   'Total Price: Rs${(selectedItem.getSelectedPrice(selectedPriceType ?? 'retail') * selectedItem.quantity).toStringAsFixed(2)}',
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 14),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.edit, color: Colors.blue),
//                             tooltip: 'Edit ${isKit ? 'Kit' : 'Item'}',
//                             onPressed: () =>
//                                 onEditItemRow(context, selectedItem),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             tooltip: 'Remove ${isKit ? 'Kit' : 'Item'}',
//                             onPressed: () {
//                               print(
//                                   'Attempting to delete top-level item at originalIndex: $originalIndex at ${DateTime.now()}');
//                               onRemoveItemRow(originalIndex);
//                             },
//                           ),
//                         ],
//                       ),
//                       if (isKit && selectedGroup == 'kit') ...[
//                         const SizedBox(height: 8),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 16.0),
//                           child: ElevatedButton.icon(
//                             icon: const Icon(Icons.add, color: Colors.white),
//                             label: const Text(
//                               'Add Item to Kit',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                             onPressed: availableItems.isNotEmpty
//                                 ? () => onAddItemRow(context,
//                                     isKit: false, parentKitIndex: originalIndex)
//                                 : null,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.green,
//                               padding: const EdgeInsets.symmetric(
//                                   vertical: 8, horizontal: 16),
//                             ),
//                           ),
//                         ),
//                         if (selectedItem.subItems != null &&
//                             selectedItem.subItems!.isNotEmpty) ...[
//                           const SizedBox(height: 8),
//                           ListView.builder(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             itemCount: selectedItem.subItems!.length,
//                             itemBuilder: (context, subIndex) {
//                               final subItem = selectedItem.subItems![subIndex];
//                               if (subItem.item == null ||
//                                   subItem.quantity == 0) {
//                                 return const SizedBox();
//                               }
//                               return Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 16.0, top: 8.0),
//                                 child: Card(
//                                   elevation: 1,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: InkWell(
//                                       onTap: documentType.toLowerCase() ==
//                                                   'invoice' &&
//                                               subItem
//                                                   .item!.itemModel.isNotEmpty &&
//                                               subItem.item!.itemModel !=
//                                                   'N/A' &&
//                                               subItem.serialNumbers.isNotEmpty
//                                           ? () => onSerialNumberTap(
//                                               context, subItem, originalIndex,
//                                               subItemIndex: subIndex)
//                                           : null,
//                                       child: Row(
//                                         children: [
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   subItem.item!.itemDescription,
//                                                   style: const TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                       fontSize: 14),
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                                 const SizedBox(height: 4),
//                                                 Text(
//                                                   'Quantity: ${subItem.quantity}',
//                                                   style: const TextStyle(
//                                                       fontSize: 12),
//                                                 ),
//                                                 const SizedBox(height: 4),
//                                                 if (documentType
//                                                             .toLowerCase() ==
//                                                         'invoice' &&
//                                                     subItem.item!.itemModel
//                                                         .isNotEmpty &&
//                                                     subItem.item!.itemModel !=
//                                                         'N/A') ...[
//                                                   Container(
//                                                     padding:
//                                                         const EdgeInsets.all(8),
//                                                     decoration: BoxDecoration(
//                                                       color: subItem
//                                                               .selectedSerialNumbers
//                                                               .isNotEmpty
//                                                           ? Colors.yellow
//                                                           : Colors
//                                                               .grey.shade200,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               4),
//                                                     ),
//                                                     child: Text(
//                                                       subItem.serialNumbers
//                                                               .isEmpty
//                                                           ? 'No serial numbers available'
//                                                           : 'S/N: ${subItem.selectedSerialNumbers.isEmpty ? 'Tap to scan' : subItem.selectedSerialNumbers.join(', ')}',
//                                                       style: const TextStyle(
//                                                         fontSize: 12,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.black,
//                                                       ),
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                     ),
//                                                   ),
//                                                 ],
//                                                 const SizedBox(height: 4),
//                                                 Text(
//                                                   'Price (${selectedPriceType ?? 'retail'}): Rs${subItem.getSelectedPrice(selectedPriceType ?? 'retail').toStringAsFixed(2)}',
//                                                   style: const TextStyle(
//                                                       fontSize: 12),
//                                                 ),
//                                                 const SizedBox(height: 4),
//                                                 Text(
//                                                   'Total Price: Rs${(subItem.getSelectedPrice(selectedPriceType ?? 'retail') * subItem.quantity).toStringAsFixed(2)}',
//                                                   style: const TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                       fontSize: 12),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           IconButton(
//                                             icon: const Icon(Icons.edit,
//                                                 color: Colors.blue, size: 20),
//                                             tooltip: 'Edit Item',
//                                             onPressed: () => onEditItemRow(
//                                                 context, subItem,
//                                                 parentKitIndex: originalIndex),
//                                           ),
//                                           IconButton(
//                                             icon: const Icon(Icons.delete,
//                                                 color: Colors.red, size: 20),
//                                             tooltip: 'Remove Item',
//                                             onPressed: () => onRemoveItemRow(
//                                                 subIndex,
//                                                 parentKitIndex: originalIndex),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ],
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
