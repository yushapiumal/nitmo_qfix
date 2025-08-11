import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qfix_nitmo_new/helper/itemModel.dart';

class AddItemPage extends StatefulWidget {
  final List<Item> availableItems;
  final String? selectedGroup;
  final String? selectedPriceType;
  final String documentType;
  final Function(SelectedItem) onItemSelected;
  final Function(SelectedItem) onSerialNumberTap;
  final Future<List<String>> Function(String) fetchSerialNumbers;
  final SelectedItem? selectedItem;

  const AddItemPage({
    Key? key,
    required this.availableItems,
    required this.selectedGroup,
    required this.selectedPriceType,
    required this.documentType,
    required this.onItemSelected,
    required this.onSerialNumberTap,
    required this.fetchSerialNumbers,
    this.selectedItem,
  }) : super(key: key);

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  late SelectedItem _newItem;
  String? _selectedItemId;

  @override
  void initState() {
    super.initState();
    _newItem = widget.selectedItem != null
        ? widget.selectedItem!.copy()
        : SelectedItem();
    if (widget.selectedItem != null) {
      _selectedItemId = widget.selectedItem!.item?.id;
      _newItem.quantityController.text =
          widget.selectedItem!.quantity.toString();
    } else {
      _newItem.quantityController.text = '1';
      _newItem.quantity = 1;
    }
  }

  @override
  void dispose() {
    if (widget.selectedItem == null) {
      _newItem.quantityController.dispose();
    }
    super.dispose();
  }

  void _onItemChanged(String? newId) async {
    setState(() {
      if (newId != null) {
        final selected =
            widget.availableItems.firstWhere((item) => item.id == newId);
        _newItem.item = selected;
        _selectedItemId = newId;
        if (widget.selectedItem == null) {
          _newItem.quantity = 1;
          _newItem.quantityController.text = '1';
          _newItem.serialNumbers = [];
          _newItem.selectedSerialNumbers = [];
        }
      } else {
        _newItem.item = null;
        _selectedItemId = null;
        _newItem.quantity = 0;
        _newItem.quantityController.text = '';
        _newItem.serialNumbers = [];
        _newItem.selectedSerialNumbers = [];
      }
    });
    if (newId != null &&
        widget.documentType.toLowerCase() == 'invoice' &&
        widget.selectedGroup != 'kit' &&
        _newItem.item!.itemModel.isNotEmpty &&
        _newItem.item!.itemModel != 'N/A') {
      final serialNumbers =
          await widget.fetchSerialNumbers(_newItem.item!.itemModel);
      setState(() {
        _newItem.serialNumbers = serialNumbers;
      });
    }
  }

  void _onQuantityChanged(String value) {
    setState(() {
      final newQuantity = int.tryParse(value);
      if (newQuantity != null && newQuantity > 0) {
        _newItem.quantity = newQuantity;
        if (_newItem.selectedSerialNumbers.length > newQuantity) {
          _newItem.selectedSerialNumbers =
              _newItem.selectedSerialNumbers.sublist(0, newQuantity);
        }
      } else {
        _newItem.quantity = 0;
        _newItem.quantityController.text = '';
        _newItem.selectedSerialNumbers = [];
      }
    });
  }

  Future<void> _onScanTap() async {
    if (_newItem.quantity == 0) {
      Fluttertoast.showToast(
        msg: 'Please enter a valid quantity first',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    if (_newItem.serialNumbers.isEmpty) {
      Fluttertoast.showToast(
        msg: 'This item is not in stock',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    await widget.onSerialNumberTap(_newItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.selectedItem != null ? 'Edit' : 'Add'} ${widget.selectedGroup == 'kit' ? 'Kit' : 'Item'}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${widget.selectedItem != null ? 'Edit' : 'Add'} ${widget.selectedGroup == 'kit' ? 'Kit' : 'Item'}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: widget.selectedGroup == 'kit'
                          ? 'Select Kit'
                          : 'Select Item',
                      border: const OutlineInputBorder(),
                    ),
                    value: _selectedItemId,
                    items: widget.availableItems.map((Item item) {
                      return DropdownMenuItem<String>(
                        value: item.id,
                        child: Text(
                          widget.selectedGroup == 'kit'
                              ? item.itemName
                              : item.itemDescription,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _onItemChanged,
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an ${widget.selectedGroup == 'kit' ? 'kit' : 'item'}';
                      }
                      return null;
                    },
                  ),
                  if (widget.selectedGroup != 'kit') ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newItem.quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                        hintText: 'Qty',
                      ),
                      validator: (value) {
                        if (_newItem.item == null) return null;
                        if (value == null || value.isEmpty) {
                          return 'Enter quantity';
                        }
                        final qty = int.tryParse(value);
                        if (qty == null || qty <= 0) {
                          return 'Invalid quantity';
                        }
                        if (qty > _newItem.item!.itemQuantity) {
                          return 'Max ${_newItem.item!.itemQuantity}';
                        }
                        return null;
                      },
                      onChanged: _onQuantityChanged,
                    ),
                    if (widget.documentType.toLowerCase() == 'invoice' &&
                        _newItem.item != null &&
                        _newItem.item!.itemModel.isNotEmpty &&
                        _newItem.item!.itemModel != 'N/A') ...[
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _newItem.serialNumbers.isNotEmpty
                            ? _onScanTap
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _newItem.selectedSerialNumbers.isNotEmpty
                                ? Colors.yellow
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _newItem.selectedSerialNumbers.isEmpty
                                ? (_newItem.serialNumbers.isNotEmpty
                                    ? 'Tap to scan'
                                    : 'No S/N available')
                                : 'S/N: ${_newItem.selectedSerialNumbers.join(', ')}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Unit Price: Rs${_newItem.getSelectedPrice(widget.selectedPriceType ?? '').toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Total Price: Rs${(_newItem.getSelectedPrice(widget.selectedPriceType ?? '') * _newItem.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (widget.documentType.toLowerCase() == 'invoice' &&
                            widget.selectedGroup != 'kit' &&
                            _newItem.item != null &&
                            _newItem.item!.itemModel.isNotEmpty &&
                            _newItem.item!.itemModel != 'N/A' &&
                            _newItem.selectedSerialNumbers.length !=
                                _newItem.quantity) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Please select ${_newItem.quantity} serial number(s) for ${_newItem.item!.itemDescription}'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        widget.onItemSelected(_newItem);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      widget.selectedItem != null ? 'Update Item' : 'Save Item',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}