import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qfix_nitmo_new/api/apiService.dart';
import 'package:qfix_nitmo_new/helper/itemModel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:barcode_scan2/barcode_scan2.dart';

class MobileCreateDocumentScreen extends StatefulWidget {
  final String documentType;
  static const routeName = '/MobileCreateDocumentScreen';

  const MobileCreateDocumentScreen({Key? key, required this.documentType})
      : super(key: key);

  @override
  _MobileCreateDocumentScreenState createState() =>
      _MobileCreateDocumentScreenState();
}

class _MobileCreateDocumentScreenState
    extends State<MobileCreateDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _invoiceDiscountController = TextEditingController();
  bool _isLoading = false;
  String? _pdfPath;
  final List<SelectedItem> _selectedItems = [];
  final List<TextEditingController> _additionalAmountControllers = [];
  final List<TextEditingController> _additionalDescriptionControllers = [];
  final List<double> _additionalAmounts = [];
  final List<String> _additionalDescriptions = [];
  List<Item> _availableItems = [];
  List<Item> _availableKits = [];
  APIService apiService = APIService();
  String? _selectedPriceType;
  String? _selectedOwner;
  String? _selectedGroup;
  String? _selectedSalesPerson;
  final List<String> _priceTypes = ['dealer', 'cost', 'promotion', 'retail'];
  final List<String> _ownerTypes = ['syslink', 'ceynet'];
  final List<String> _groupTypes = ['item', 'kit'];
  List<String> _salesPersons = [];
  final PageController _pageController = PageController();

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _addAdditionalAmountField();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _descriptionController.dispose();
    _invoiceDiscountController.dispose();
    for (var selectedItem in _selectedItems) {
      selectedItem.dispose();
    }
    for (var controller in _additionalAmountControllers) {
      controller.dispose();
    }
    for (var controller in _additionalDescriptionControllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _addAdditionalAmountField() {
    setState(() {
      _additionalAmountControllers.add(TextEditingController());
      _additionalDescriptionControllers.add(TextEditingController());
      _additionalAmounts.add(0.0);
      _additionalDescriptions.add('');
    });
  }

  void _removeAdditionalAmountField(int index) {
    setState(() {
      _additionalAmountControllers[index].dispose();
      _additionalDescriptionControllers[index].dispose();
      _additionalAmountControllers.removeAt(index);
      _additionalDescriptionControllers.removeAt(index);
      _additionalAmounts.removeAt(index);
      _additionalDescriptions.removeAt(index);
    });
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _selectedItems.add(SelectedItem());
    });
    try {
      List<String> salesPersons = [];
      if (widget.documentType.toLowerCase() == 'invoice') {
        salesPersons = await apiService.fetchSalesPersons();
      }
      setState(() {
        _salesPersons =
            salesPersons.isEmpty ? ['No Salespersons Available'] : salesPersons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _salesPersons = ['No Salespersons Available'];
      });
      print('Error fetching salespersons: $e');
      Fluttertoast.showToast(
        msg: 'Failed to load salespersons: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _fetchItemsByGroup(String group) async {
    setState(() {
      _isLoading = true;
    });
    try {
      const baseUrl = 'http://192.168.1.6:3003/api';
      List<Item> items = [];
      List<Item> kits = [];
      if (group == 'item') {
        items = await apiService.fetchItems();
      } else if (group == 'kit') {
        kits = await apiService.fetchKits(baseUrl);
        items = await apiService.fetchItems();
      }
      final salesPersons = await apiService.fetchSalesPersons();
      setState(() {
        _availableItems = items;
        _availableKits = kits;
        _salesPersons =
            salesPersons.isEmpty ? ['No Salespersons Available'] : salesPersons;
        _selectedItems.clear();
        _selectedItems.add(SelectedItem());
        _isLoading = false;
      });
      if ((group == 'item' && items.isEmpty) ||
          (group == 'kit' && kits.isEmpty && items.isEmpty)) {
        Fluttertoast.showToast(
          msg: 'No ${group}s available',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching data for group $group: $e');
      Fluttertoast.showToast(
        msg: 'Failed to load ${group}s',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
  final Map<String, List<String>> _serialNumberCache = {};

Future<void> _fetchSerialNumbers(int index, String itemModel, {int? subItemIndex}) async {
  print('Fetching serial numbers for itemModel: $itemModel, index: $index, subItemIndex: $subItemIndex');
  if (itemModel.isEmpty || itemModel == 'N/A') {
    setState(() {
      if (subItemIndex != null && _selectedItems[index].subItems != null) {
        _selectedItems[index].subItems![subItemIndex].serialNumbers = [];
        _selectedItems[index].subItems![subItemIndex].selectedSerialNumbers = [];
      } else {
        _selectedItems[index].serialNumbers = [];
        _selectedItems[index].selectedSerialNumbers = [];
      }
    });
    return;
  }

  // Check cache
  if (_serialNumberCache.containsKey(itemModel)) {
    print('Using cached serial numbers for $itemModel: ${_serialNumberCache[itemModel]}');
    setState(() {
      if (subItemIndex != null && _selectedItems[index].subItems != null) {
        _selectedItems[index].subItems![subItemIndex].serialNumbers = _serialNumberCache[itemModel]!;
        _selectedItems[index].subItems![subItemIndex].selectedSerialNumbers = [];
      } else {
        _selectedItems[index].serialNumbers = _serialNumberCache[itemModel]!;
        _selectedItems[index].selectedSerialNumbers = [];
      }
    });
    return;
  }

  // Fetch from API
  try {
    final serialNumbers = await apiService.fetchSerialNumbers(itemModel);
    print('Fetched serial numbers for $itemModel: $serialNumbers');
    _serialNumberCache[itemModel] = serialNumbers; // Corrected line
    setState(() {
      if (subItemIndex != null && _selectedItems[index].subItems != null) {
        _selectedItems[index].subItems![subItemIndex].serialNumbers = serialNumbers;
        _selectedItems[index].subItems![subItemIndex].selectedSerialNumbers = [];
      } else {
        _selectedItems[index].serialNumbers = serialNumbers;
        _selectedItems[index].selectedSerialNumbers = [];
      }
    });
  } catch (e) {
    print('Error fetching serial numbers for $itemModel: $e');
    setState(() {
      if (subItemIndex != null && _selectedItems[index].subItems != null) {
        _selectedItems[index].subItems![subItemIndex].serialNumbers = [];
        _selectedItems[index].subItems![subItemIndex].selectedSerialNumbers = [];
      } else {
        _selectedItems[index].serialNumbers = [];
        _selectedItems[index].selectedSerialNumbers = [];
      }
    });
    Fluttertoast.showToast(
      msg: 'Failed to load serial numbers for $itemModel',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

  Future<String?> _scanSerialNumber() async {
    try {
      final result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        return result.rawContent;
      } else {
        Fluttertoast.showToast(
          msg: 'No data scanned',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return null;
      }
    } catch (e) {
      print('Scan error: $e');
      Fluttertoast.showToast(
        msg: 'Failed to scan: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return null;
    }
  }

  void _onSerialNumberTap(
      BuildContext context, SelectedItem item, int parentKitIndex,
      {int? subItemIndex}) async {
    if (item.quantity == 0) {
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
    if (item.serialNumbers.isEmpty) {
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
    while (item.selectedSerialNumbers.length < item.quantity) {
      final scannedSerial = await _scanSerialNumber();
      if (scannedSerial == null) break;
      if (item.serialNumbers.contains(scannedSerial) &&
          !item.selectedSerialNumbers.contains(scannedSerial)) {
        setState(() {
          item.selectedSerialNumbers.add(scannedSerial);
          if (subItemIndex != null) {
            _selectedItems[parentKitIndex].subItems![subItemIndex] = item;
          }
        });
      } else {
        Fluttertoast.showToast(
          msg: 'S/N does not match or already used: $scannedSerial',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        break;
      }
    }
  }

  void _addItemRow(BuildContext context,
      {required bool isKit, int? parentKitIndex}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemPage(
          availableItems: isKit ? _availableKits : _availableItems,
          selectedGroup: isKit ? 'kit' : 'item',
          selectedPriceType: _selectedPriceType,
          documentType: widget.documentType,
          onItemSelected: (SelectedItem newItem) {
            setState(() {
              if (parentKitIndex != null) {
                _selectedItems[parentKitIndex].subItems ??= [];
                _selectedItems[parentKitIndex].subItems!.add(newItem);
              } else {
                _selectedItems.add(newItem);
              }
            });
            Navigator.pop(context);
          },
          onSerialNumberTap: (SelectedItem item) async {
            if (item.quantity == 0) {
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
            if (item.serialNumbers.isEmpty) {
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
            while (item.selectedSerialNumbers.length < item.quantity) {
              final scannedSerial = await _scanSerialNumber();
              if (scannedSerial == null) break;
              if (item.serialNumbers.contains(scannedSerial) &&
                  !item.selectedSerialNumbers.contains(scannedSerial)) {
                setState(() {
                  item.selectedSerialNumbers.add(scannedSerial);
                });
              } else {
                Fluttertoast.showToast(
                  msg: 'S/N does not match or already used: $scannedSerial',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.orange,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                break;
              }
            }
          },
          fetchSerialNumbers: (String itemModel) async {
            if (itemModel.isEmpty || itemModel == 'N/A') return [];
            try {
              return await apiService.fetchSerialNumbers(itemModel);
            } catch (e) {
              return [];
            }
          },
        ),
      ),
    );
  }

  void _editItemRow(BuildContext context, SelectedItem item,
      {int? parentKitIndex}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemPage(
          availableItems: item.item is Kit ? _availableKits : _availableItems,
          selectedGroup: item.item is Kit ? 'kit' : 'item',
          selectedPriceType: _selectedPriceType,
          documentType: widget.documentType,
          onItemSelected: (SelectedItem editedItem) {
            setState(() {
              if (parentKitIndex != null) {
                final subItems = _selectedItems[parentKitIndex].subItems!;
                final index = subItems.indexWhere((i) => i == item);
                if (index != -1) {
                  subItems[index] = editedItem;
                }
              } else {
                final index = _selectedItems.indexWhere((i) => i == item);
                if (index != -1) {
                  _selectedItems[index] = editedItem;
                }
              }
            });
            Navigator.pop(context);
          },
          onSerialNumberTap: (SelectedItem item) async {
            if (item.quantity == 0) {
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
            if (item.serialNumbers.isEmpty) {
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
            while (item.selectedSerialNumbers.length < item.quantity) {
              final scannedSerial = await _scanSerialNumber();
              if (scannedSerial == null) break;
              if (item.serialNumbers.contains(scannedSerial) &&
                  !item.selectedSerialNumbers.contains(scannedSerial)) {
                setState(() {
                  item.selectedSerialNumbers.add(scannedSerial);
                });
              } else {
                Fluttertoast.showToast(
                  msg: 'S/N does not match or already used: $scannedSerial',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.orange,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                break;
              }
            }
          },
          fetchSerialNumbers: (String itemModel) async {
            if (itemModel.isEmpty || itemModel == 'N/A') return [];
            try {
              return await apiService.fetchSerialNumbers(itemModel);
            } catch (e) {
              return [];
            }
          },
          selectedItem: item,
        ),
      ),
    );
  }

  void removeItemRow(int index, {int? parentKitIndex}) {
    if (!mounted) return;

    if (parentKitIndex != null) {
      if (parentKitIndex >= 0 && parentKitIndex < _selectedItems.length) {
        final kit = _selectedItems[parentKitIndex];
        if (kit.subItems != null &&
            index >= 0 &&
            index < kit.subItems!.length) {
          final itemToRemove = kit.subItems![index];
          setState(() {
            kit.subItems!.removeAt(index);
          });
          // Dispose after removal and rebuild triggered
          itemToRemove.dispose();
          print('Removed sub-item at index $index from kit at $parentKitIndex');
        }
      }
    } else {
      if (index >= 0 && index < _selectedItems.length) {
        final itemToRemove = _selectedItems[index];
        setState(() {
          _selectedItems.removeAt(index);
        });
        // Dispose after removal and rebuild triggered
        itemToRemove.dispose();
        print('Removed top-level item at index: $index');
      }
    }
  }

  double _calculateTotalPrice() {
    double itemsTotal = _selectedItems.fold(0, (sum, item) {
      if (item.item == null ||
          item.quantity == 0 ||
          _selectedPriceType == null) {
        return sum;
      }
      double itemTotal =
          item.getSelectedPrice(_selectedPriceType!) * item.quantity;
      if (item.subItems != null) {
        itemTotal += item.subItems!.fold(0, (subSum, subItem) {
          if (subItem.item == null || subItem.quantity == 0) return subSum;
          return subSum +
              (subItem.getSelectedPrice(_selectedPriceType!) *
                  subItem.quantity);
        });
      }
      return sum + itemTotal;
    });
    double additionalTotal =
        _additionalAmounts.fold(0, (sum, amount) => sum + amount);
    double discount = double.tryParse(_invoiceDiscountController.text) ?? 0.0;
    return (itemsTotal + additionalTotal - discount).clamp(0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create ${widget.documentType}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _pdfPath == null ? _buildForm() : _buildSuccessScreen(),
    );
  }

  Widget _buildForm() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: PageView(
                    controller: _pageController,
                    physics: const ClampingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      DocumentSettingsPage(
                        selectedOwner: _selectedOwner,
                        ownerTypes: _ownerTypes,
                        selectedGroup: _selectedGroup,
                        groupTypes: _groupTypes,
                        selectedSalesPerson: _selectedSalesPerson,
                        salesPersons: _salesPersons,
                        selectedPriceType: _selectedPriceType,
                        priceTypes: _priceTypes,
                        documentType: widget.documentType,
                        onOwnerChanged: (newOwner) {
                          setState(() {
                            _selectedOwner = newOwner;
                          });
                        },
                        onGroupChanged: (newGroup) {
                          setState(() {
                            _selectedGroup = newGroup;
                            if (newGroup != null) {
                              _fetchItemsByGroup(newGroup);
                            } else {
                              _availableItems.clear();
                              _availableKits.clear();
                              _selectedItems.clear();
                            }
                          });
                        },
                        onSalesPersonChanged: (salesPerson) {
                          setState(() {
                            _selectedSalesPerson = salesPerson;
                          });
                        },
                        onPriceTypeChanged: (newPriceType) {
                          setState(() {
                            _selectedPriceType = newPriceType;
                          });
                        },
                      ),
                      CustomerInfoPage(
                        customerNameController: _customerNameController,
                        descriptionController: _descriptionController,
                      ),
                      ItemsKitsPage(
                        selectedItems: _selectedItems,
                        availableItems: _availableItems,
                        availableKits: _availableKits,
                        isLoading: _isLoading,
                        selectedGroup: _selectedGroup,
                        selectedPriceType: _selectedPriceType,
                        documentType: widget.documentType,
                        onAddItemRow: _addItemRow,
                        onEditItemRow: _editItemRow,
                        onRemoveItemRow: removeItemRow,
                        onSerialNumberTap: _onSerialNumberTap,
                        fetchSerialNumbers: _fetchSerialNumbers,
                      ),
                      AdditionalChargesPage(
                        invoiceDiscountController: _invoiceDiscountController,
                        additionalAmountControllers:
                            _additionalAmountControllers,
                        additionalDescriptionControllers:
                            _additionalDescriptionControllers,
                        additionalAmounts: _additionalAmounts,
                        additionalDescriptions: _additionalDescriptions,
                        onAddAdditionalAmount: _addAdditionalAmountField,
                        onRemoveAdditionalAmount: _removeAdditionalAmountField,
                        onDescriptionChanged: (index, value) {
                          setState(() {
                            _additionalDescriptions[index] = value;
                          });
                        },
                        onAmountChanged: (index, value) {
                          setState(() {
                            _additionalAmounts[index] =
                                double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                      SummaryPage(
                        selectedItems: _selectedItems,
                        selectedPriceType: _selectedPriceType,
                        additionalAmounts: _additionalAmounts,
                        invoiceDiscountController: _invoiceDiscountController,
                        calculateTotalPrice: _calculateTotalPrice,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade400,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPage > 0)
                          ElevatedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Previous'),
                          )
                        else
                          const SizedBox(),
                        if (_currentPage < 4)
                          ElevatedButton(
                            onPressed: () {
                              if (_currentPage == 0) {
                                if (_selectedOwner == null ||
                                    _selectedGroup == null ||
                                    _selectedPriceType == null ||
                                    (widget.documentType.toLowerCase() ==
                                            'invoice' &&
                                        _selectedSalesPerson == null)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        _selectedOwner == null
                                            ? 'Please select an owner'
                                            : _selectedGroup == null
                                                ? 'Please select a group'
                                                : _selectedPriceType == null
                                                    ? 'Please select a price type'
                                                    : 'Please select a salesperson',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                              } else if (_currentPage == 1) {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                              }
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Next'),
                          )
                        else
                          ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text('Create ${widget.documentType}'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: _pdfPath != null
          ? Column(
              children: [
                Expanded(
                  child: PDFView(
                    filePath: _pdfPath!,
                    onError: (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error loading PDF: $error'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        '${widget.documentType} created successfully!',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'You can view, download, or share the document with your customer.',
                        style: TextStyle(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _downloadPdf,
                            icon: const Icon(Icons.download),
                            label: const Text('Download'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _sharePdf,
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _pdfPath = null;
                            _customerNameController.clear();
                            _descriptionController.clear();
                            _invoiceDiscountController.clear();
                            _additionalAmountControllers.clear();
                            _additionalAmounts.clear();
                            _selectedItems.clear();
                            _selectedPriceType = null;
                            _selectedOwner = null;
                            _selectedGroup = null;
                            _selectedSalesPerson = null;
                            _addAdditionalAmountField();
                            _currentPage = 0;
                            _pageController.jumpToPage(0);
                          });
                        },
                        child: Text(
                          'Create Another ${widget.documentType}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 72),
                  const SizedBox(height: 24),
                  Text(
                    '${widget.documentType} created successfully!',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load PDF. Please check your network or server configuration.',
                    style: TextStyle(color: Colors.red.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _downloadPdf,
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _sharePdf,
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _pdfPath = null;
                        _customerNameController.clear();
                        _descriptionController.clear();
                        _invoiceDiscountController.clear();
                        _additionalAmountControllers.clear();
                        _additionalAmounts.clear();
                        _selectedItems.clear();
                        _selectedPriceType = null;
                        _selectedOwner = null;
                        _selectedGroup = null;
                        _selectedSalesPerson = null;
                        _addAdditionalAmountField();
                        _currentPage = 0;
                        _pageController.jumpToPage(0);
                      });
                    },
                    child: Text(
                      'Create Another ${widget.documentType}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _submitForm() async {
    final validItems = _selectedItems
        .where((item) => item.item != null && item.quantity > 0)
        .toList();
    bool isValid = _formKey.currentState!.validate() &&
        validItems.isNotEmpty &&
        _selectedPriceType != null &&
        _selectedOwner != null &&
        _selectedGroup != null;
    if (widget.documentType.toLowerCase() == 'invoice') {
      isValid = isValid && _selectedSalesPerson != null;
    }
    if (isValid) {
      if (widget.documentType.toLowerCase() == 'invoice' &&
          _selectedGroup != 'kit') {
        for (var item in validItems) {
          if (item.item != null &&
              item.item!.itemModel.isNotEmpty &&
              item.item!.itemModel != 'N/A' &&
              item.selectedSerialNumbers.length != item.quantity) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Please select ${item.quantity} serial number(s) for ${item.item!.itemDescription}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          if (item.subItems != null) {
            for (var subItem in item.subItems!) {
              if (subItem.item != null &&
                  subItem.item!.itemModel.isNotEmpty &&
                  subItem.item!.itemModel != 'N/A' &&
                  subItem.selectedSerialNumbers.length != subItem.quantity) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Please select ${subItem.quantity} serial number(s) for ${subItem.item!.itemDescription} in kit'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
            }
          }
        }
      }
      setState(() {
        _isLoading = true;
      });
      try {
        final customerName = _customerNameController.text.isNotEmpty
            ? _customerNameController.text
            : 'Unknown Customer';
        final description = _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : 'No Description';
        final discount =
            double.tryParse(_invoiceDiscountController.text) ?? 0.0;
        final additionalTotal =
            _additionalAmounts.fold<double>(0, (sum, amount) => sum + amount);
        final totalAmount = _calculateTotalPrice();
        final additionalCharges = List<Map<String, dynamic>>.generate(
          _additionalAmounts.length,
          (index) => {
            'desc': _additionalDescriptions[index],
            'price': _additionalAmounts[index],
          },
        );
        final responseData = await apiService.sendInvoice(
          validItems,
          _selectedPriceType ?? 'retail',
          _selectedOwner ?? 'syslink',
          _selectedGroup ?? 'item',
          widget.documentType.toLowerCase() == 'invoice'
              ? (_selectedSalesPerson ?? 'Unknown Salesperson')
              : '',
          customerName,
          widget.documentType.toLowerCase(),
          discount,
          additionalCharges,
        );
        if (responseData != null && responseData['invoiceId'] != null) {
          final pdfPath = await apiService.fetchInvoice(
            responseData['invoiceId'].toString(),
          );
          setState(() {
            _isLoading = false;
            _pdfPath = pdfPath;
            if (pdfPath == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Failed to fetch PDF for ${widget.documentType}. Please check your network or server.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to retrieve ${widget.documentType} ID'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create ${widget.documentType}: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        print('Submit error: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedPriceType == null
                ? 'Please select a price type'
                : _selectedOwner == null
                    ? 'Please select an owner'
                    : _selectedGroup == null
                        ? 'Please select a group'
                        : widget.documentType.toLowerCase() == 'invoice' &&
                                _selectedSalesPerson == null
                            ? 'Please select a salesperson'
                            : 'Please add at least one item with a valid quantity',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _downloadPdf() async {
    if (_pdfPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No PDF available to download'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.documentType} saved to $_pdfPath'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _sharePdf() async {
    if (_pdfPath == null || _pdfPath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No PDF available to share'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    try {
      await Share.shareXFiles(
        [XFile(_pdfPath!)],
        text:
            'Check out this ${widget.documentType} for ${_customerNameController.text}',
        subject: '${widget.documentType} from Quotation Maker',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share PDF: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class DocumentSettingsPage extends StatelessWidget {
  final String? selectedOwner;
  final List<String> ownerTypes;
  final String? selectedGroup;
  final List<String> groupTypes;
  final String? selectedSalesPerson;
  final List<String> salesPersons;
  final String? selectedPriceType;
  final List<String> priceTypes;
  final String documentType;
  final Function(String?) onOwnerChanged;
  final Function(String?) onGroupChanged;
  final Function(String?) onSalesPersonChanged;
  final Function(String?) onPriceTypeChanged;

  const DocumentSettingsPage({
    Key? key,
    required this.selectedOwner,
    required this.ownerTypes,
    required this.selectedGroup,
    required this.groupTypes,
    required this.selectedSalesPerson,
    required this.salesPersons,
    required this.selectedPriceType,
    required this.priceTypes,
    required this.documentType,
    required this.onOwnerChanged,
    required this.onGroupChanged,
    required this.onSalesPersonChanged,
    required this.onPriceTypeChanged,
  }) : super(key: key);

  Widget _buildDropdown(BuildContext context, String label, String? value,
      List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            isExpanded: true,
            underline: const SizedBox(),
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item[0].toUpperCase() + item.substring(1)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Document Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                context,
                'Select Owner*',
                selectedOwner,
                ownerTypes,
                onOwnerChanged,
              ),
              const SizedBox(height: 12),
              if (documentType.toLowerCase() == 'invoice') ...[
                _buildDropdown(
                  context,
                  'Select SalesPersons*',
                  selectedSalesPerson,
                  salesPersons,
                  onSalesPersonChanged,
                ),
                const SizedBox(height: 12),
              ],
              _buildDropdown(
                context,
                'Select Group*',
                selectedGroup,
                groupTypes,
                onGroupChanged,
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                context,
                'Select Price Type*',
                selectedPriceType,
                priceTypes,
                onPriceTypeChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomerInfoPage extends StatelessWidget {
  final TextEditingController customerNameController;
  final TextEditingController descriptionController;

  const CustomerInfoPage({
    Key? key,
    required this.customerNameController,
    required this.descriptionController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Customer Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemsKitsPage extends StatelessWidget {
  final List<SelectedItem> selectedItems;
  final List<Item> availableItems;
  final List<Item> availableKits;
  final bool isLoading;
  final String? selectedGroup;
  final String? selectedPriceType;
  final String documentType;
  final Function(BuildContext, {required bool isKit, int? parentKitIndex})
      onAddItemRow;
  final Function(BuildContext, SelectedItem, {int? parentKitIndex})
      onEditItemRow;
  final Function(int, {int? parentKitIndex}) onRemoveItemRow;
  final Function(BuildContext, SelectedItem, int, {int? subItemIndex})
      onSerialNumberTap;
  final Function(int, String) fetchSerialNumbers;

  const ItemsKitsPage({
    Key? key,
    required this.selectedItems,
    required this.availableItems,
    required this.availableKits,
    required this.isLoading,
    required this.selectedGroup,
    required this.selectedPriceType,
    required this.documentType,
    required this.onAddItemRow,
    required this.onEditItemRow,
    required this.onRemoveItemRow,
    required this.onSerialNumberTap,
    required this.fetchSerialNumbers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasSelectedItems =
        selectedItems.any((item) => item.item != null && item.quantity > 0);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (selectedGroup == 'kit') ...[
                    Text(
                      'Select Kits',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ] else if (selectedGroup == 'item') ...[
                    Text(
                      'Select Items',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (availableItems.isEmpty &&
                      availableKits.isEmpty &&
                      !isLoading)
                    const Center(
                      child: Text(
                        'No items or kits available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else ...[
                    if (selectedGroup == 'kit') ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Add Kit',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: availableKits.isNotEmpty
                            ? () => onAddItemRow(context, isKit: true)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                        ),
                      ),
                    ] else if (selectedGroup == 'item') ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Add Item',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: availableItems.isNotEmpty
                            ? () => onAddItemRow(context, isKit: false)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            key: const ValueKey('selectedItemsList'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedItems
                .where((item) => item.item != null && item.quantity > 0)
                .length,
            itemBuilder: (context, index) {
              final validItems = selectedItems
                  .asMap()
                  .entries
                  .where((entry) =>
                      entry.value.item != null && entry.value.quantity > 0)
                  .toList();
              final selectedItem = validItems[index].value;
              final originalIndex = validItems[index].key;
              final isKit = selectedItem.item is Kit;
              final kitItems =
                  isKit ? (selectedItem.item as Kit).kitItems : null;
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedItem.item!.itemName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Description: ${selectedItem.item!.itemName}',
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                              
                                const SizedBox(height: 4),
                                Text(
                                  'Stock: ${selectedItem.item!.itemQuantity}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tag: ${selectedItem.item!.itemTag.isEmpty ? 'N/A' : selectedItem.item!.itemTag}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                if (isKit) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Price (${selectedPriceType ?? 'retail'}): Rs${selectedItem.getSelectedPrice(selectedPriceType ?? 'retail').toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  if (kitItems != null &&
                                      kitItems.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Items in Kit:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                    ),
                                    ...kitItems.entries
                                        .toList()
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final subIndex = entry.key;
                                      final kitItem = entry.value.value;
                                      final kitItemSelected = selectedItem
                                                      .subItems !=
                                                  null &&
                                              subIndex <
                                                  selectedItem.subItems!.length
                                          ? selectedItem.subItems![subIndex]
                                          : SelectedItem(
                                              item: kitItem,
                                              quantity: kitItem.itemQuantity,
                                              serialNumbers: [],
                                              selectedSerialNumbers: [],
                                            );
                                      if (documentType.toLowerCase() ==
                                              'invoice' &&
                                          kitItemSelected.item != null &&
                                          kitItemSelected
                                              .item!.itemModel.isNotEmpty &&
                                          kitItemSelected.item!.itemModel !=
                                              'N/A' &&
                                          kitItemSelected
                                              .serialNumbers.isEmpty) {
                                        fetchSerialNumbers(originalIndex,
                                            kitItemSelected.item!.itemModel);
                                      }
                                      return InkWell(
                                        onTap:
                                            documentType
                                                            .toLowerCase() ==
                                                        'invoice' &&
                                                    kitItemSelected
                                                            .item !=
                                                        null &&
                                                    kitItemSelected.item!
                                                        .itemModel.isNotEmpty &&
                                                    kitItemSelected
                                                            .item!.itemModel !=
                                                        'N/A' &&
                                                    kitItemSelected
                                                        .serialNumbers
                                                        .isNotEmpty
                                                ? () => onSerialNumberTap(
                                                      context,
                                                      kitItemSelected,
                                                      originalIndex,
                                                      subItemIndex: subIndex,
                                                    )
                                                : null,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8.0, top: 4.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '- ${kitItem.itemDescription}',
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    if (documentType
                                                                .toLowerCase() ==
                                                            'invoice' &&
                                                        kitItemSelected
                                                            .item!
                                                            .itemModel
                                                            .isNotEmpty &&
                                                        kitItemSelected.item!
                                                                .itemModel !=
                                                            'N/A') ...[
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: kitItemSelected
                                                                  .selectedSerialNumbers
                                                                  .isNotEmpty
                                                              ? Colors.yellow
                                                              : Colors.grey
                                                                  .shade200,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                        child: Text(
                                                          'S/N: ${kitItemSelected.selectedSerialNumbers.isEmpty ? 'TapBBBBBBB to scan' : kitItemSelected.selectedSerialNumbers.join(', ')}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ] else ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Quantity: ${selectedItem.quantity}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  if (documentType.toLowerCase() == 'invoice' &&
                                      selectedGroup != 'kit' &&
                                      selectedItem.item!.itemModel.isNotEmpty &&
                                      selectedItem.item!.itemModel !=
                                          'N/A') ...[
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap:
                                          selectedItem.serialNumbers.isNotEmpty
                                              ? () => onSerialNumberTap(context,
                                                  selectedItem, originalIndex)
                                              : null,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: selectedItem
                                                  .selectedSerialNumbers
                                                  .isNotEmpty
                                              ? Colors.yellow
                                              : Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'S/N: ${selectedItem.selectedSerialNumbers.isEmpty ? 'TapAAAAAA to scan' : selectedItem.selectedSerialNumbers.join(', ')}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Text(
                                    'Price (${selectedPriceType ?? 'retail'}): Rs${selectedItem.getSelectedPrice(selectedPriceType ?? 'retail').toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  'Total Price: Rs${(selectedItem.getSelectedPrice(selectedPriceType ?? 'retail') * selectedItem.quantity).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Edit ${isKit ? 'Kit' : 'Item'}',
                            onPressed: () =>
                                onEditItemRow(context, selectedItem),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Remove ${isKit ? 'Kit' : 'Item'}',
                            onPressed: () {
                              print(
                                  'Attempting to delete top-level item at originalIndex: $originalIndex at ${DateTime.now()}');
                              onRemoveItemRow(originalIndex);
                            },
                          ),
                        ],
                      ),
                      if (isKit && selectedGroup == 'kit') ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Add Item to Kit',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: availableItems.isNotEmpty
                                ? () => onAddItemRow(context,
                                    isKit: false, parentKitIndex: originalIndex)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                            ),
                          ),
                        ),
                        if (selectedItem.subItems != null &&
                            selectedItem.subItems!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: selectedItem.subItems!.length,
                            itemBuilder: (context, subIndex) {
                              final subItem = selectedItem.subItems![subIndex];
                              if (subItem.item == null ||
                                  subItem.quantity == 0) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 16.0, top: 8.0),
                                child: Card(
                                  elevation: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: documentType.toLowerCase() ==
                                                  'invoice' &&
                                              subItem
                                                  .item!.itemModel.isNotEmpty &&
                                              subItem.item!.itemModel !=
                                                  'N/A' &&
                                              subItem.serialNumbers.isNotEmpty
                                          ? () => onSerialNumberTap(
                                              context, subItem, originalIndex,
                                              subItemIndex: subIndex)
                                          : null,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  subItem.item!.itemDescription,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Quantity: ${subItem.quantity}',
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                const SizedBox(height: 4),
                                                if (documentType
                                                            .toLowerCase() ==
                                                        'invoice' &&
                                                    subItem.item!.itemModel
                                                        .isNotEmpty &&
                                                    subItem.item!.itemModel !=
                                                        'N/A') ...[
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: subItem
                                                              .selectedSerialNumbers
                                                              .isNotEmpty
                                                          ? Colors.yellow
                                                          : Colors
                                                              .grey.shade200,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      subItem.serialNumbers
                                                              .isEmpty
                                                          ? 'No serial numbers available'
                                                          : 'S/N: ${subItem.selectedSerialNumbers.isEmpty ? 'Tap to scan' : subItem.selectedSerialNumbers.join(', ')}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Price (${selectedPriceType ?? 'retail'}): Rs${subItem.getSelectedPrice(selectedPriceType ?? 'retail').toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Total Price: Rs${(subItem.getSelectedPrice(selectedPriceType ?? 'retail') * subItem.quantity).toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue, size: 20),
                                            tooltip: 'Edit Item',
                                            onPressed: () => onEditItemRow(
                                                context, subItem,
                                                parentKitIndex: originalIndex),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red, size: 20),
                                            tooltip: 'Remove Item',
                                            onPressed: () => onRemoveItemRow(
                                                subIndex,
                                                parentKitIndex: originalIndex),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

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

class AdditionalChargesPage extends StatelessWidget {
  final TextEditingController invoiceDiscountController;
  final List<TextEditingController> additionalAmountControllers;
  final List<TextEditingController> additionalDescriptionControllers;
  final List<double> additionalAmounts;
  final List<String> additionalDescriptions;
  final VoidCallback onAddAdditionalAmount;
  final Function(int) onRemoveAdditionalAmount;
  final Function(int, String) onDescriptionChanged;
  final Function(int, String) onAmountChanged;

  const AdditionalChargesPage({
    Key? key,
    required this.invoiceDiscountController,
    required this.additionalAmountControllers,
    required this.additionalDescriptionControllers,
    required this.additionalAmounts,
    required this.additionalDescriptions,
    required this.onAddAdditionalAmount,
    required this.onRemoveAdditionalAmount,
    required this.onDescriptionChanged,
    required this.onAmountChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Additional Charges & Discount',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: invoiceDiscountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Invoice Discount (Rs)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.discount),
                ),
                validator: (value) {
                  final discount = double.tryParse(value ?? '');
                  if (discount != null && discount < 0) {
                    return 'Discount cannot be negative';
                  }
                  return null;
                },
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Additional Amounts',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue),
                    onPressed: onAddAdditionalAmount,
                    tooltip: 'Add additional amount',
                  ),
                ],
              ),
              ...additionalAmountControllers.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController amountController = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: additionalDescriptionControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Description ${index + 1}',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.description),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Description cannot be empty';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            onDescriptionChanged(index, value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Amount ${index + 1} (Rs)',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.attach_money),
                          ),
                          validator: (value) {
                            final amount = double.tryParse(value ?? '');
                            if (amount == null) {
                              return 'Invalid amount';
                            }
                            if (amount < 0) {
                              return 'Amount cannot be negative';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            onAmountChanged(index, value);
                          },
                        ),
                      ),
                      if (additionalAmountControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                          onPressed: () => onRemoveAdditionalAmount(index),
                          tooltip: 'Remove amount',
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryPage extends StatelessWidget {
  final List<SelectedItem> selectedItems;
  final String? selectedPriceType;
  final List<double> additionalAmounts;
  final TextEditingController invoiceDiscountController;
  final double Function() calculateTotalPrice;

  const SummaryPage({
    Key? key,
    required this.selectedItems,
    required this.selectedPriceType,
    required this.additionalAmounts,
    required this.invoiceDiscountController,
    required this.calculateTotalPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal (Items & Kits):',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Rs${selectedItems.fold<double>(0, (sum, item) {
                      if (item.item == null ||
                          item.quantity == 0 ||
                          selectedPriceType == null) return sum;
                      double itemTotal =
                          item.getSelectedPrice(selectedPriceType!) *
                              item.quantity;
                      if (item.subItems != null) {
                        itemTotal += item.subItems!.fold(0, (subSum, subItem) {
                          if (subItem.item == null || subItem.quantity == 0)
                            return subSum;
                          return subSum +
                              (subItem.getSelectedPrice(selectedPriceType!) *
                                  subItem.quantity);
                        });
                      }
                      return sum + itemTotal;
                    }).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Additional Amounts:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Rs${additionalAmounts.fold<double>(0, (sum, amount) => sum + amount).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Discount:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '-Rs${(invoiceDiscountController.text.isNotEmpty ? (double.tryParse(invoiceDiscountController.text) ?? 0.0) : 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rs${calculateTotalPrice().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}






// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:qfix_nitmo_new/api/apiService.dart';
// import 'package:qfix_nitmo_new/helper/itemModel.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:http/http.dart' as http;
// import 'package:barcode_scan2/barcode_scan2.dart';

// class MobileCreateDocumentScreen extends StatefulWidget {
//   final String documentType;
//   static const routeName = '/MobileCreateDocumentScreen';

//   const MobileCreateDocumentScreen({Key? key, required this.documentType})
//       : super(key: key);

//   @override
//   _MobileCreateDocumentScreenState createState() =>
//       _MobileCreateDocumentScreenState();
// }

// class _MobileCreateDocumentScreenState
//     extends State<MobileCreateDocumentScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _customerNameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _invoiceDiscountController = TextEditingController();
//   bool _isLoading = false;
//   String? _pdfPath;
//   final List<SelectedItem> _selectedItems = [];
//   final List<TextEditingController> _additionalAmountControllers = [];
//   final List<TextEditingController> _additionalDescriptionControllers = [];
//   final List<double> _additionalAmounts = [];
//   final List<String> _additionalDescriptions = [];
//   List<Item> _availableItems = [];
//   List<Item> _availableKits = [];
//   APIService apiService = APIService();
//   String? _selectedPriceType;
//   String? _selectedOwner;
//   String? _selectedGroup;
//   String? _selectedSalesPerson;
//   final List<String> _priceTypes = ['dealer', 'cost', 'promotion', 'retail'];
//   final List<String> _ownerTypes = ['syslink', 'ceynet'];
//   final List<String> _groupTypes = ['item', 'kit'];
//   List<String> _salesPersons = [];
//   final PageController _pageController = PageController();

//   int _currentPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchInitialData();
//     _addAdditionalAmountField();
//   }

//   @override
//   void dispose() {
//     _customerNameController.dispose();
//     _descriptionController.dispose();
//     _invoiceDiscountController.dispose();
//     for (var selectedItem in _selectedItems) {
//       selectedItem.dispose();
//     }
//     for (var controller in _additionalAmountControllers) {
//       controller.dispose();
//     }
//     for (var controller in _additionalDescriptionControllers) {
//       controller.dispose();
//     }
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _addAdditionalAmountField() {
//     setState(() {
//       _additionalAmountControllers.add(TextEditingController());
//       _additionalDescriptionControllers.add(TextEditingController());
//       _additionalAmounts.add(0.0);
//       _additionalDescriptions.add('');
//     });
//   }

//   void _removeAdditionalAmountField(int index) {
//     setState(() {
//       _additionalAmountControllers[index].dispose();
//       _additionalDescriptionControllers[index].dispose();
//       _additionalAmountControllers.removeAt(index);
//       _additionalDescriptionControllers.removeAt(index);
//       _additionalAmounts.removeAt(index);
//       _additionalDescriptions.removeAt(index);
//     });
//   }

//   Future<void> _fetchInitialData() async {
//     setState(() {
//       _isLoading = true;
//       _selectedItems.add(SelectedItem());
//     });
//     try {
//       List<String> salesPersons = [];
//       if (widget.documentType.toLowerCase() == 'invoice') {
//         salesPersons = await apiService.fetchSalesPersons();
//       }
//       setState(() {
//         _salesPersons =
//             salesPersons.isEmpty ? ['No Salespersons Available'] : salesPersons;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _salesPersons = ['No Salespersons Available'];
//       });
//       print('Error fetching salespersons: $e');
//       Fluttertoast.showToast(
//         msg: 'Failed to load salespersons: $e',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );
//     }
//   }

//   Future<void> _fetchItemsByGroup(String group) async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       const baseUrl = 'http://192.168.1.6:3003/api';
//       List<Item> items = [];
//       List<Item> kits = [];
//       if (group == 'item') {
//         items = await apiService.fetchItems();
//       } else if (group == 'kit') {
//         kits = await apiService.fetchKits(baseUrl);
//         items = await apiService.fetchItems();
//       }
//       final salesPersons = await apiService.fetchSalesPersons();
//       setState(() {
//         _availableItems = items;
//         _availableKits = kits;
//         _salesPersons =
//             salesPersons.isEmpty ? ['No Salespersons Available'] : salesPersons;
//         _selectedItems.clear();
//         _selectedItems.add(SelectedItem());
//         _isLoading = false;
//       });
//       if ((group == 'item' && items.isEmpty) ||
//           (group == 'kit' && kits.isEmpty && items.isEmpty)) {
//         Fluttertoast.showToast(
//           msg: 'No ${group}s available',
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: Colors.red,
//           textColor: Colors.white,
//           fontSize: 16.0,
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       print('Error fetching data for group $group: $e');
//       Fluttertoast.showToast(
//         msg: 'Failed to load ${group}s',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );
//     }
//   }
//  // final Map<String, List<String>> _serialNumberCache = {};

// Future<void> _fetchSerialNumbers(int index, String itemModel, {int? subItemIndex}) async {
//   print('Fetching serial numbers for itemModel: $itemModel, index: $index, subItemIndex: $subItemIndex');
//   if (itemModel.isEmpty || itemModel == 'N/A') {
//     setState(() {
//       final updatedItems = List<SelectedItem>.from(_selectedItems);
//       if (subItemIndex != null && updatedItems[index].subItems != null) {
//         final updatedSubItems = List<SelectedItem>.from(updatedItems[index].subItems!);
//         updatedSubItems[subItemIndex] = updatedSubItems[subItemIndex].copyWith(
//           serialNumbers: [],
//           selectedSerialNumbers: [],
//         );
//         updatedItems[index] = updatedItems[index].copyWith(subItems: updatedSubItems);
//       } else {
//         updatedItems[index] = updatedItems[index].copyWith(
//           serialNumbers: [],
//           selectedSerialNumbers: [],
//         );
//       }
//       _selectedItems = updatedItems;
//       print('Updated _selectedItems for empty itemModel: ${subItemIndex != null ? updatedItems[index].subItems![subItemIndex].serialNumbers : updatedItems[index].serialNumbers}');
//     });
//     return;
//   }

//   try {
//     final serialNumbers = await apiService.fetchSerialNumbers(itemModel);
//     print('Fetched serial numbers for $itemModel: $serialNumbers');
//     setState(() {
//       final updatedItems = List<SelectedItem>.from(_selectedItems);
//       if (subItemIndex != null && updatedItems[index].subItems != null) {
//         final updatedSubItems = List<SelectedItem>.from(updatedItems[index].subItems!);
//         updatedSubItems[subItemIndex] = updatedSubItems[subItemIndex].copyWith(
//           serialNumbers: serialNumbers,
//           selectedSerialNumbers: [],
//         );
//         updatedItems[index] = updatedItems[index].copyWith(subItems: updatedSubItems);
//       } else {
//         updatedItems[index] = updatedItems[index].copyWith(
//           serialNumbers: serialNumbers,
//           selectedSerialNumbers: [],
//         );
//       }
//       _selectedItems = updatedItems;
//       print('Updated _selectedItems: ${subItemIndex != null ? updatedItems[index].subItems![subItemIndex].serialNumbers : updatedItems[index].serialNumbers}');
//     });
//   } catch (e) {
//     print('Error fetching serial numbers for $itemModel: $e');
//     setState(() {
//       final updatedItems = List<SelectedItem>.from(_selectedItems);
//       if (subItemIndex != null && updatedItems[index].subItems != null) {
//         final updatedSubItems = List<SelectedItem>.from(updatedItems[index].subItems!);
//         updatedSubItems[subItemIndex] = updatedSubItems[subItemIndex].copyWith(
//           serialNumbers: [],
//           selectedSerialNumbers: [],
//         );
//         updatedItems[index] = updatedItems[index].copyWith(subItems: updatedSubItems);
//       } else {
//         updatedItems[index] = updatedItems[index].copyWith(
//           serialNumbers: [],
//           selectedSerialNumbers: [],
//         );
//       }
//       _selectedItems = updatedItems;
//       print('Updated _selectedItems after error: ${subItemIndex != null ? updatedItems[index].subItems![subItemIndex].serialNumbers : updatedItems[index].serialNumbers}');
//     });
//     Fluttertoast.showToast(
//       msg: 'Failed to load serial numbers for $itemModel',
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.red,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }
// }
//   Future<String?> _scanSerialNumber() async {
//     try {
//       final result = await BarcodeScanner.scan();
//       if (result.rawContent.isNotEmpty) {
//         return result.rawContent;
//       } else {
//         Fluttertoast.showToast(
//           msg: 'No data scanned',
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: Colors.red,
//           textColor: Colors.white,
//           fontSize: 16.0,
//         );
//         return null;
//       }
//     } catch (e) {
//       print('Scan error: $e');
//       Fluttertoast.showToast(
//         msg: 'Failed to scan: $e',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );
//       return null;
//     }
//   }

//   void _onSerialNumberTap(
//       BuildContext context, SelectedItem item, int parentKitIndex,
//       {int? subItemIndex}) async {
//     if (item.quantity == 0) {
//       Fluttertoast.showToast(
//         msg: 'Please enter a valid quantity first',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );
//       return;
//     }
//     if (item.serialNumbers.isEmpty) {
//       Fluttertoast.showToast(
//         msg: 'This item is not in stock',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.orange,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );
//       return;
//     }
//     while (item.selectedSerialNumbers.length < item.quantity) {
//       final scannedSerial = await _scanSerialNumber();
//       if (scannedSerial == null) break;
//       if (item.serialNumbers.contains(scannedSerial) &&
//           !item.selectedSerialNumbers.contains(scannedSerial)) {
//         setState(() {
//           item.selectedSerialNumbers.add(scannedSerial);
//           if (subItemIndex != null) {
//             _selectedItems[parentKitIndex].subItems![subItemIndex] = item;
//           }
//         });
//       } else {
//         Fluttertoast.showToast(
//           msg: 'S/N does not match or already used: $scannedSerial',
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: Colors.orange,
//           textColor: Colors.white,
//           fontSize: 16.0,
//         );
//         break;
//       }
//     }
//   }

//   void _addItemRow(BuildContext context,
//       {required bool isKit, int? parentKitIndex}) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddItemPage(
//           availableItems: isKit ? _availableKits : _availableItems,
//           selectedGroup: isKit ? 'kit' : 'item',
//           selectedPriceType: _selectedPriceType,
//           documentType: widget.documentType,
//           onItemSelected: (SelectedItem newItem) {
//             setState(() {
//               if (parentKitIndex != null) {
//                 _selectedItems[parentKitIndex].subItems ??= [];
//                 _selectedItems[parentKitIndex].subItems!.add(newItem);
//               } else {
//                 _selectedItems.add(newItem);
//               }
//             });
//             Navigator.pop(context);
//           },
//           onSerialNumberTap: (SelectedItem item) async {
//             if (item.quantity == 0) {
//               Fluttertoast.showToast(
//                 msg: 'Please enter a valid quantity first',
//                 toastLength: Toast.LENGTH_SHORT,
//                 gravity: ToastGravity.BOTTOM,
//                 backgroundColor: Colors.red,
//                 textColor: Colors.white,
//                 fontSize: 16.0,
//               );
//               return;
//             }
//             if (item.serialNumbers.isEmpty) {
//               Fluttertoast.showToast(
//                 msg: 'This item is not in stock',
//                 toastLength: Toast.LENGTH_SHORT,
//                 gravity: ToastGravity.BOTTOM,
//                 backgroundColor: Colors.orange,
//                 textColor: Colors.white,
//                 fontSize: 16.0,
//               );
//               return;
//             }
//             while (item.selectedSerialNumbers.length < item.quantity) {
//               final scannedSerial = await _scanSerialNumber();
//               if (scannedSerial == null) break;
//               if (item.serialNumbers.contains(scannedSerial) &&
//                   !item.selectedSerialNumbers.contains(scannedSerial)) {
//                 setState(() {
//                   item.selectedSerialNumbers.add(scannedSerial);
//                 });
//               } else {
//                 Fluttertoast.showToast(
//                   msg: 'S/N does not match or already used: $scannedSerial',
//                   toastLength: Toast.LENGTH_SHORT,
//                   gravity: ToastGravity.BOTTOM,
//                   backgroundColor: Colors.orange,
//                   textColor: Colors.white,
//                   fontSize: 16.0,
//                 );
//                 break;
//               }
//             }
//           },
//           fetchSerialNumbers: (String itemModel) async {
//             if (itemModel.isEmpty || itemModel == 'N/A') return [];
//             try {
//               return await apiService.fetchSerialNumbers(itemModel);
//             } catch (e) {
//               return [];
//             }
//           },
//         ),
//       ),
//     );
//   }

//   void _editItemRow(BuildContext context, SelectedItem item,
//       {int? parentKitIndex}) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddItemPage(
//           availableItems: item.item is Kit ? _availableKits : _availableItems,
//           selectedGroup: item.item is Kit ? 'kit' : 'item',
//           selectedPriceType: _selectedPriceType,
//           documentType: widget.documentType,
//           onItemSelected: (SelectedItem editedItem) {
//             setState(() {
//               if (parentKitIndex != null) {
//                 final subItems = _selectedItems[parentKitIndex].subItems!;
//                 final index = subItems.indexWhere((i) => i == item);
//                 if (index != -1) {
//                   subItems[index] = editedItem;
//                 }
//               } else {
//                 final index = _selectedItems.indexWhere((i) => i == item);
//                 if (index != -1) {
//                   _selectedItems[index] = editedItem;
//                 }
//               }
//             });
//             Navigator.pop(context);
//           },
//           onSerialNumberTap: (SelectedItem item) async {
//             if (item.quantity == 0) {
//               Fluttertoast.showToast(
//                 msg: 'Please enter a valid quantity first',
//                 toastLength: Toast.LENGTH_SHORT,
//                 gravity: ToastGravity.BOTTOM,
//                 backgroundColor: Colors.red,
//                 textColor: Colors.white,
//                 fontSize: 16.0,
//               );
//               return;
//             }
//             if (item.serialNumbers.isEmpty) {
//               Fluttertoast.showToast(
//                 msg: 'This item is not in stock',
//                 toastLength: Toast.LENGTH_SHORT,
//                 gravity: ToastGravity.BOTTOM,
//                 backgroundColor: Colors.orange,
//                 textColor: Colors.white,
//                 fontSize: 16.0,
//               );
//               return;
//             }
//             while (item.selectedSerialNumbers.length < item.quantity) {
//               final scannedSerial = await _scanSerialNumber();
//               if (scannedSerial == null) break;
//               if (item.serialNumbers.contains(scannedSerial) &&
//                   !item.selectedSerialNumbers.contains(scannedSerial)) {
//                 setState(() {
//                   item.selectedSerialNumbers.add(scannedSerial);
//                 });
//               } else {
//                 Fluttertoast.showToast(
//                   msg: 'S/N does not match or already used: $scannedSerial',
//                   toastLength: Toast.LENGTH_SHORT,
//                   gravity: ToastGravity.BOTTOM,
//                   backgroundColor: Colors.orange,
//                   textColor: Colors.white,
//                   fontSize: 16.0,
//                 );
//                 break;
//               }
//             }
//           },
//           fetchSerialNumbers: (String itemModel) async {
//             if (itemModel.isEmpty || itemModel == 'N/A') return [];
//             try {
//               return await apiService.fetchSerialNumbers(itemModel);
//             } catch (e) {
//               return [];
//             }
//           },
//           selectedItem: item,
//         ),
//       ),
//     );
//   }

//   void removeItemRow(int index, {int? parentKitIndex}) {
//     if (!mounted) return;

//     if (parentKitIndex != null) {
//       if (parentKitIndex >= 0 && parentKitIndex < _selectedItems.length) {
//         final kit = _selectedItems[parentKitIndex];
//         if (kit.subItems != null &&
//             index >= 0 &&
//             index < kit.subItems!.length) {
//           final itemToRemove = kit.subItems![index];
//           setState(() {
//             kit.subItems!.removeAt(index);
//           });
//           // Dispose after removal and rebuild triggered
//           itemToRemove.dispose();
//           print('Removed sub-item at index $index from kit at $parentKitIndex');
//         }
//       }
//     } else {
//       if (index >= 0 && index < _selectedItems.length) {
//         final itemToRemove = _selectedItems[index];
//         setState(() {
//           _selectedItems.removeAt(index);
//         });
//         // Dispose after removal and rebuild triggered
//         itemToRemove.dispose();
//         print('Removed top-level item at index: $index');
//       }
//     }
//   }

//   double _calculateTotalPrice() {
//     double itemsTotal = _selectedItems.fold(0, (sum, item) {
//       if (item.item == null ||
//           item.quantity == 0 ||
//           _selectedPriceType == null) {
//         return sum;
//       }
//       double itemTotal =
//           item.getSelectedPrice(_selectedPriceType!) * item.quantity;
//       if (item.subItems != null) {
//         itemTotal += item.subItems!.fold(0, (subSum, subItem) {
//           if (subItem.item == null || subItem.quantity == 0) return subSum;
//           return subSum +
//               (subItem.getSelectedPrice(_selectedPriceType!) *
//                   subItem.quantity);
//         });
//       }
//       return sum + itemTotal;
//     });
//     double additionalTotal =
//         _additionalAmounts.fold(0, (sum, amount) => sum + amount);
//     double discount = double.tryParse(_invoiceDiscountController.text) ?? 0.0;
//     return (itemsTotal + additionalTotal - discount).clamp(0, double.infinity);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Create ${widget.documentType}'),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: _pdfPath == null ? _buildForm() : _buildSuccessScreen(),
//     );
//   }

//   Widget _buildForm() {
//     return _isLoading
//         ? const Center(child: CircularProgressIndicator())
//         : Column(
//             children: [
//               Expanded(
//                 child: Form(
//                   key: _formKey,
//                   child: PageView(
//                     controller: _pageController,
//                     physics: const ClampingScrollPhysics(),
//                     onPageChanged: (index) {
//                       setState(() {
//                         _currentPage = index;
//                       });
//                     },
//                     children: [
//                       DocumentSettingsPage(
//                         selectedOwner: _selectedOwner,
//                         ownerTypes: _ownerTypes,
//                         selectedGroup: _selectedGroup,
//                         groupTypes: _groupTypes,
//                         selectedSalesPerson: _selectedSalesPerson,
//                         salesPersons: _salesPersons,
//                         selectedPriceType: _selectedPriceType,
//                         priceTypes: _priceTypes,
//                         documentType: widget.documentType,
//                         onOwnerChanged: (newOwner) {
//                           setState(() {
//                             _selectedOwner = newOwner;
//                           });
//                         },
//                         onGroupChanged: (newGroup) {
//                           setState(() {
//                             _selectedGroup = newGroup;
//                             if (newGroup != null) {
//                               _fetchItemsByGroup(newGroup);
//                             } else {
//                               _availableItems.clear();
//                               _availableKits.clear();
//                               _selectedItems.clear();
//                             }
//                           });
//                         },
//                         onSalesPersonChanged: (salesPerson) {
//                           setState(() {
//                             _selectedSalesPerson = salesPerson;
//                           });
//                         },
//                         onPriceTypeChanged: (newPriceType) {
//                           setState(() {
//                             _selectedPriceType = newPriceType;
//                           });
//                         },
//                       ),
//                       CustomerInfoPage(
//                         customerNameController: _customerNameController,
//                         descriptionController: _descriptionController,
//                       ),
//                       ItemsKitsPage(
//                         selectedItems: _selectedItems,
//                         availableItems: _availableItems,
//                         availableKits: _availableKits,
//                         isLoading: _isLoading,
//                         selectedGroup: _selectedGroup,
//                         selectedPriceType: _selectedPriceType,
//                         documentType: widget.documentType,
//                         onAddItemRow: _addItemRow,
//                         onEditItemRow: _editItemRow,
//                         onRemoveItemRow: removeItemRow,
//                         onSerialNumberTap: _onSerialNumberTap,
//                         fetchSerialNumbers: _fetchSerialNumbers,
//                       ),
//                       AdditionalChargesPage(
//                         invoiceDiscountController: _invoiceDiscountController,
//                         additionalAmountControllers:
//                             _additionalAmountControllers,
//                         additionalDescriptionControllers:
//                             _additionalDescriptionControllers,
//                         additionalAmounts: _additionalAmounts,
//                         additionalDescriptions: _additionalDescriptions,
//                         onAddAdditionalAmount: _addAdditionalAmountField,
//                         onRemoveAdditionalAmount: _removeAdditionalAmountField,
//                         onDescriptionChanged: (index, value) {
//                           setState(() {
//                             _additionalDescriptions[index] = value;
//                           });
//                         },
//                         onAmountChanged: (index, value) {
//                           setState(() {
//                             _additionalAmounts[index] =
//                                 double.tryParse(value) ?? 0.0;
//                           });
//                         },
//                       ),
//                       SummaryPage(
//                         selectedItems: _selectedItems,
//                         selectedPriceType: _selectedPriceType,
//                         additionalAmounts: _additionalAmounts,
//                         invoiceDiscountController: _invoiceDiscountController,
//                         calculateTotalPrice: _calculateTotalPrice,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(5, (index) {
//                         return Container(
//                           margin: const EdgeInsets.symmetric(horizontal: 4.0),
//                           width: 8.0,
//                           height: 8.0,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: _currentPage == index
//                                 ? Theme.of(context).primaryColor
//                                 : Colors.grey.shade400,
//                           ),
//                         );
//                       }),
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         if (_currentPage > 0)
//                           ElevatedButton(
//                             onPressed: () {
//                               _pageController.previousPage(
//                                 duration: const Duration(milliseconds: 300),
//                                 curve: Curves.easeInOut,
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 24, vertical: 12),
//                             ),
//                             child: const Text('Previous'),
//                           )
//                         else
//                           const SizedBox(),
//                         if (_currentPage < 4)
//                           ElevatedButton(
//                             onPressed: () {
//                               if (_currentPage == 0) {
//                                 if (_selectedOwner == null ||
//                                     _selectedGroup == null ||
//                                     _selectedPriceType == null ||
//                                     (widget.documentType.toLowerCase() ==
//                                             'invoice' &&
//                                         _selectedSalesPerson == null)) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text(
//                                         _selectedOwner == null
//                                             ? 'Please select an owner'
//                                             : _selectedGroup == null
//                                                 ? 'Please select a group'
//                                                 : _selectedPriceType == null
//                                                     ? 'Please select a price type'
//                                                     : 'Please select a salesperson',
//                                       ),
//                                       behavior: SnackBarBehavior.floating,
//                                     ),
//                                   );
//                                   return;
//                                 }
//                               } else if (_currentPage == 1) {
//                                 if (!_formKey.currentState!.validate()) {
//                                   return;
//                                 }
//                               }
//                               _pageController.nextPage(
//                                 duration: const Duration(milliseconds: 300),
//                                 curve: Curves.easeInOut,
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 24, vertical: 12),
//                             ),
//                             child: const Text('Next'),
//                           )
//                         else
//                           ElevatedButton(
//                             onPressed: _submitForm,
//                             style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 24, vertical: 12),
//                             ),
//                             child: Text('Create ${widget.documentType}'),
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//   }

//   Widget _buildSuccessScreen() {
//     return Center(
//       child: _pdfPath != null
//           ? Column(
//               children: [
//                 Expanded(
//                   child: PDFView(
//                     filePath: _pdfPath!,
//                     onError: (error) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('Error loading PDF: $error'),
//                           behavior: SnackBarBehavior.floating,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Text(
//                         '${widget.documentType} created successfully!',
//                         style: const TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.bold),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'You can view, download, or share the document with your customer.',
//                         style: TextStyle(color: Colors.grey.shade600),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 32),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ElevatedButton.icon(
//                             onPressed: _downloadPdf,
//                             icon: const Icon(Icons.download),
//                             label: const Text('Download'),
//                             style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 24, vertical: 12),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           ElevatedButton.icon(
//                             onPressed: _sharePdf,
//                             icon: const Icon(Icons.share),
//                             label: const Text('Share'),
//                             style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 24, vertical: 12),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 24),
//                       TextButton(
//                         onPressed: () {
//                           setState(() {
//                             _pdfPath = null;
//                             _customerNameController.clear();
//                             _descriptionController.clear();
//                             _invoiceDiscountController.clear();
//                             _additionalAmountControllers.clear();
//                             _additionalAmounts.clear();
//                             _selectedItems.clear();
//                             _selectedPriceType = null;
//                             _selectedOwner = null;
//                             _selectedGroup = null;
//                             _selectedSalesPerson = null;
//                             _addAdditionalAmountField();
//                             _currentPage = 0;
//                             _pageController.jumpToPage(0);
//                           });
//                         },
//                         child: Text(
//                           'Create Another ${widget.documentType}',
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             )
//           : Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.check_circle, color: Colors.green, size: 72),
//                   const SizedBox(height: 24),
//                   Text(
//                     '${widget.documentType} created successfully!',
//                     style: const TextStyle(
//                         fontSize: 20, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Failed to load PDF. Please check your network or server configuration.',
//                     style: TextStyle(color: Colors.red.shade600),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 32),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton.icon(
//                         onPressed: _downloadPdf,
//                         icon: const Icon(Icons.download),
//                         label: const Text('Download'),
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 24, vertical: 12),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       ElevatedButton.icon(
//                         onPressed: _sharePdf,
//                         icon: const Icon(Icons.share),
//                         label: const Text('Share'),
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 24, vertical: 12),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   TextButton(
//                     onPressed: () {
//                       setState(() {
//                         _pdfPath = null;
//                         _customerNameController.clear();
//                         _descriptionController.clear();
//                         _invoiceDiscountController.clear();
//                         _additionalAmountControllers.clear();
//                         _additionalAmounts.clear();
//                         _selectedItems.clear();
//                         _selectedPriceType = null;
//                         _selectedOwner = null;
//                         _selectedGroup = null;
//                         _selectedSalesPerson = null;
//                         _addAdditionalAmountField();
//                         _currentPage = 0;
//                         _pageController.jumpToPage(0);
//                       });
//                     },
//                     child: Text(
//                       'Create Another ${widget.documentType}',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Future<void> _submitForm() async {
//     final validItems = _selectedItems
//         .where((item) => item.item != null && item.quantity > 0)
//         .toList();
//     bool isValid = _formKey.currentState!.validate() &&
//         validItems.isNotEmpty &&
//         _selectedPriceType != null &&
//         _selectedOwner != null &&
//         _selectedGroup != null;
//     if (widget.documentType.toLowerCase() == 'invoice') {
//       isValid = isValid && _selectedSalesPerson != null;
//     }
//     if (isValid) {
//       if (widget.documentType.toLowerCase() == 'invoice' &&
//           _selectedGroup != 'kit') {
//         for (var item in validItems) {
//           if (item.item != null &&
//               item.item!.itemModel.isNotEmpty &&
//               item.item!.itemModel != 'N/A' &&
//               item.selectedSerialNumbers.length != item.quantity) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                     'Please select ${item.quantity} serial number(s) for ${item.item!.itemDescription}'),
//                 behavior: SnackBarBehavior.floating,
//               ),
//             );
//             return;
//           }
//           if (item.subItems != null) {
//             for (var subItem in item.subItems!) {
//               if (subItem.item != null &&
//                   subItem.item!.itemModel.isNotEmpty &&
//                   subItem.item!.itemModel != 'N/A' &&
//                   subItem.selectedSerialNumbers.length != subItem.quantity) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(
//                         'Please select ${subItem.quantity} serial number(s) for ${subItem.item!.itemDescription} in kit'),
//                     behavior: SnackBarBehavior.floating,
//                   ),
//                 );
//                 return;
//               }
//             }
//           }
//         }
//       }
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         final customerName = _customerNameController.text.isNotEmpty
//             ? _customerNameController.text
//             : 'Unknown Customer';
//         final description = _descriptionController.text.isNotEmpty
//             ? _descriptionController.text
//             : 'No Description';
//         final discount =
//             double.tryParse(_invoiceDiscountController.text) ?? 0.0;
//         final additionalTotal =
//             _additionalAmounts.fold<double>(0, (sum, amount) => sum + amount);
//         final totalAmount = _calculateTotalPrice();
//         final additionalCharges = List<Map<String, dynamic>>.generate(
//           _additionalAmounts.length,
//           (index) => {
//             'desc': _additionalDescriptions[index],
//             'price': _additionalAmounts[index],
//           },
//         );
//         final responseData = await apiService.sendInvoice(
//           validItems,
//           _selectedPriceType ?? 'retail',
//           _selectedOwner ?? 'syslink',
//           _selectedGroup ?? 'item',
//           widget.documentType.toLowerCase() == 'invoice'
//               ? (_selectedSalesPerson ?? 'Unknown Salesperson')
//               : '',
//           customerName,
//           widget.documentType.toLowerCase(),
//           discount,
//           additionalCharges,
//         );
//         if (responseData != null && responseData['invoiceId'] != null) {
//           final pdfPath = await apiService.fetchInvoice(
//             responseData['invoiceId'].toString(),
//           );
//           setState(() {
//             _isLoading = false;
//             _pdfPath = pdfPath;
//             if (pdfPath == null) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(
//                       'Failed to fetch PDF for ${widget.documentType}. Please check your network or server.'),
//                   behavior: SnackBarBehavior.floating,
//                 ),
//               );
//             }
//           });
//         } else {
//           setState(() {
//             _isLoading = false;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to retrieve ${widget.documentType} ID'),
//               behavior: SnackBarBehavior.floating,
//             ),
//           );
//         }
//       } catch (e) {
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to create ${widget.documentType}: $e'),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//         print('Submit error: $e');
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             _selectedPriceType == null
//                 ? 'Please select a price type'
//                 : _selectedOwner == null
//                     ? 'Please select an owner'
//                     : _selectedGroup == null
//                         ? 'Please select a group'
//                         : widget.documentType.toLowerCase() == 'invoice' &&
//                                 _selectedSalesPerson == null
//                             ? 'Please select a salesperson'
//                             : 'Please add at least one item with a valid quantity',
//           ),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   Future<void> _downloadPdf() async {
//     if (_pdfPath == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No PDF available to download'),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('${widget.documentType} saved to $_pdfPath'),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   Future<void> _sharePdf() async {
//     if (_pdfPath == null || _pdfPath!.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No PDF available to share'),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }
//     try {
//       await Share.shareXFiles(
//         [XFile(_pdfPath!)],
//         text:
//             'Check out this ${widget.documentType} for ${_customerNameController.text}',
//         subject: '${widget.documentType} from Quotation Maker',
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to share PDF: $e'),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }
// }

// class DocumentSettingsPage extends StatelessWidget {
//   final String? selectedOwner;
//   final List<String> ownerTypes;
//   final String? selectedGroup;
//   final List<String> groupTypes;
//   final String? selectedSalesPerson;
//   final List<String> salesPersons;
//   final String? selectedPriceType;
//   final List<String> priceTypes;
//   final String documentType;
//   final Function(String?) onOwnerChanged;
//   final Function(String?) onGroupChanged;
//   final Function(String?) onSalesPersonChanged;
//   final Function(String?) onPriceTypeChanged;

//   const DocumentSettingsPage({
//     Key? key,
//     required this.selectedOwner,
//     required this.ownerTypes,
//     required this.selectedGroup,
//     required this.groupTypes,
//     required this.selectedSalesPerson,
//     required this.salesPersons,
//     required this.selectedPriceType,
//     required this.priceTypes,
//     required this.documentType,
//     required this.onOwnerChanged,
//     required this.onGroupChanged,
//     required this.onSalesPersonChanged,
//     required this.onPriceTypeChanged,
//   }) : super(key: key);

//   Widget _buildDropdown(BuildContext context, String label, String? value,
//       List<String> items, Function(String?) onChanged) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//             color: Colors.grey.shade700,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade400),
//             borderRadius: BorderRadius.circular(4),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           child: DropdownButton<String>(
//             isExpanded: true,
//             underline: const SizedBox(),
//             value: value,
//             items: items.map((String item) {
//               return DropdownMenuItem<String>(
//                 value: item,
//                 child: Text(item[0].toUpperCase() + item.substring(1)),
//               );
//             }).toList(),
//             onChanged: onChanged,
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Card(
//         elevation: 2,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(
//                 'Document Settings',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).primaryColor,
//                     ),
//               ),
//               const SizedBox(height: 16),
//               _buildDropdown(
//                 context,
//                 'Select Owner*',
//                 selectedOwner,
//                 ownerTypes,
//                 onOwnerChanged,
//               ),
//               const SizedBox(height: 12),
//               if (documentType.toLowerCase() == 'invoice') ...[
//                 _buildDropdown(
//                   context,
//                   'Select SalesPersons*',
//                   selectedSalesPerson,
//                   salesPersons,
//                   onSalesPersonChanged,
//                 ),
//                 const SizedBox(height: 12),
//               ],
//               _buildDropdown(
//                 context,
//                 'Select Group*',
//                 selectedGroup,
//                 groupTypes,
//                 onGroupChanged,
//               ),
//               const SizedBox(height: 12),
//               _buildDropdown(
//                 context,
//                 'Select Price Type*',
//                 selectedPriceType,
//                 priceTypes,
//                 onPriceTypeChanged,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CustomerInfoPage extends StatelessWidget {
//   final TextEditingController customerNameController;
//   final TextEditingController descriptionController;

//   const CustomerInfoPage({
//     Key? key,
//     required this.customerNameController,
//     required this.descriptionController,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Card(
//         elevation: 2,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(
//                 'Customer Information',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).primaryColor,
//                     ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: customerNameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Customer Name*',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.person),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter customer name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: descriptionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Description*',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.description),
//                 ),
//                 maxLines: 3,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter description';
//                   }
//                   return null;
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
//   final Future<void> Function(int, String, {int? subItemIndex}) fetchSerialNumbers;


//   void printFetchSerialNumbersSignature() {
//     print('fetchSerialNumbers: $fetchSerialNumbers');
//   }
//     void printonFetchSerialNumbersSignature() {
//     print('printonFetchSerialNumbersSignature: $onEditItemRow');
//   }
  


  

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
//           printFetchSerialNumbersSignature();
//           printonFetchSerialNumbersSignature();
          
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
//                                 // Make item name clickable
//                                 InkWell(
//                                   onTap: documentType.toLowerCase() == 'invoice' &&
//                                           selectedGroup != 'kit' &&
//                                           selectedItem.item!.itemModel.isNotEmpty &&
//                                           selectedItem.item!.itemModel != 'N/A'
//                                       ? () async {
//                                           // Fetch serial numbers only if not already fetched
//                                           if (selectedItem.serialNumbers.isEmpty) {
//                                             await fetchSerialNumbers(
//                                                 originalIndex, selectedItem.item!.itemModel);
//                                           }
//                                           // Check serial numbers after fetching
//                                           if (selectedItem.serialNumbers.isEmpty) {
//                                             Fluttertoast.showToast(
//                                               msg: 'This item is not in stock',
//                                               toastLength: Toast.LENGTH_SHORT,
//                                               gravity: ToastGravity.BOTTOM,
//                                               backgroundColor: Colors.orange,
//                                               textColor: Colors.white,
//                                               fontSize: 16.0,
//                                             );
//                                           } else {
//                                             // Open scanner if serials available
//                                             onSerialNumberTap(
//                                                 context, selectedItem, originalIndex);
//                                           }
//                                         }
//                                       : null,
//                                   child: Text(
//                                     selectedItem.item!.itemName,
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                       decoration:
//                                           documentType.toLowerCase() == 'invoice' &&
//                                                   selectedGroup != 'kit' &&
//                                                   selectedItem.item!.itemModel.isNotEmpty &&
//                                                   selectedItem.item!.itemModel != 'N/A'
//                                               ? TextDecoration.underline
//                                               : null,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   'Description: ${selectedItem.item!.itemName}',
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
//                                       return InkWell(
//                                         onTap:
//                                             documentType.toLowerCase() ==
//                                                         'invoice' &&
//                                                     kitItemSelected
//                                                             .item !=
//                                                         null &&
//                                                     kitItemSelected
//                                                             .item!.itemModel
//                                                             .isNotEmpty &&
//                                                     kitItemSelected.item!
//                                                             .itemModel !=
//                                                         'N/A'
//                                                 ? () async {
//                                                    print("======================${selectedItem.serialNumbers}");
//                                                     // Fetch serial numbers only if not already fetched
//                                                     if (kitItemSelected
//                                                         .serialNumbers.isEmpty) {
//                                                       await fetchSerialNumbers(
//                                                           originalIndex,
//                                                           kitItemSelected
//                                                               .item!.itemModel,
//                                                           subItemIndex: subIndex);
//                                                     }
//                                                     // Check serial numbers after fetching
//                                                     if (kitItemSelected
//                                                         .serialNumbers.isEmpty) {
                                                         
//                                                       Fluttertoast.showToast(
//                                                         msg:
//                                                             'This item is not in stock',
//                                                         toastLength:
//                                                             Toast.LENGTH_SHORT,
//                                                         gravity:
//                                                             ToastGravity.BOTTOM,
//                                                         backgroundColor:
//                                                             Colors.orange,
//                                                         textColor: Colors.white,
//                                                         fontSize: 16.0,
//                                                       );
//                                                     } else {
//                                                       // Open scanner if serials available
//                                                       onSerialNumberTap(
//                                                         context,
//                                                         kitItemSelected,
//                                                         originalIndex,
//                                                         subItemIndex: subIndex,
//                                                       );
//                                                     }
//                                                   }
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
//                                                       style: TextStyle(
//                                                         fontSize: 12,
//                                                         decoration: documentType
//                                                                         .toLowerCase() ==
//                                                                     'invoice' &&
//                                                                 kitItemSelected
//                                                                         .item !=
//                                                                     null &&
//                                                                 kitItemSelected
//                                                                     .item!
//                                                                     .itemModel
//                                                                     .isNotEmpty &&
//                                                                 kitItemSelected
//                                                                         .item!
//                                                                         .itemModel !=
//                                                                     'N/A'
//                                                             ? TextDecoration
//                                                                 .underline
//                                                             : null,
//                                                       ),
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
//                                                       InkWell(
//                                                         onTap: () async {
//                                                           // Fetch serial numbers only if not already fetched
//                                                           if (kitItemSelected
//                                                               .serialNumbers
//                                                               .isEmpty) {
//                                                             await fetchSerialNumbers(
//                                                                 originalIndex,
//                                                                 kitItemSelected.item!
//                                                                     .itemModel,
//                                                                 subItemIndex:
//                                                                     subIndex);
//                                                           }
//                                                           // Check serial numbers after fetching
//                                                           if (kitItemSelected
//                                                               .serialNumbers
//                                                               .isEmpty) {
//                                                             Fluttertoast.showToast(
//                                                               msg:
//                                                                   'This item is not in stock',
//                                                               toastLength:
//                                                                   Toast.LENGTH_SHORT,
//                                                               gravity: ToastGravity
//                                                                   .BOTTOM,
//                                                               backgroundColor:
//                                                                   Colors.orange,
//                                                               textColor:
//                                                                   Colors.white,
//                                                               fontSize: 16.0,
//                                                             );
//                                                           } else {
//                                                             // Open scanner if serials available
//                                                             onSerialNumberTap(
//                                                               context,
//                                                               kitItemSelected,
//                                                               originalIndex,
//                                                               subItemIndex: subIndex,
//                                                             );
//                                                           }
//                                                         },
//                                                         child: Container(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .all(8),
//                                                           decoration: BoxDecoration(
//                                                             color: kitItemSelected
//                                                                     .selectedSerialNumbers
//                                                                     .isNotEmpty
//                                                                 ? Colors.yellow
//                                                                 : Colors
//                                                                     .grey.shade200,
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(4),
//                                                           ),
//                                                           child: Text(
//                                                             kitItemSelected
//                                                                     .serialNumbers
//                                                                     .isEmpty
//                                                                 ? 'No serial numbers available'
//                                                                 : 'S/N: ${kitItemSelected.selectedSerialNumbers.isEmpty ? 'Tap to scan' : kitItemSelected.selectedSerialNumbers.join(', ')}',
//                                                             style: const TextStyle(
//                                                               fontSize: 12,
//                                                               fontWeight:
//                                                                   FontWeight.bold,
//                                                               color: Colors.black,
//                                                             ),
//                                                             overflow:
//                                                                 TextOverflow
//                                                                     .ellipsis,
//                                                           ),
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
//                                   ]
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
//                                       onTap: () async {
//                                         // Fetch serial numbers only if not already fetched
//                                         if (selectedItem.serialNumbers.isEmpty) {
//                                           await fetchSerialNumbers(originalIndex,
//                                               selectedItem.item!.itemModel);
//                                         }
//                                         // Check serial numbers after fetching
//                                         if (selectedItem.serialNumbers.isEmpty) {
//                                           Fluttertoast.showToast(
//                                             msg: 'This item is not in stock',
//                                             toastLength: Toast.LENGTH_SHORT,
//                                             gravity: ToastGravity.BOTTOM,
//                                             backgroundColor: Colors.orange,
//                                             textColor: Colors.white,
//                                             fontSize: 16.0,
//                                           );
//                                         } else {
//                                           // Open scanner if serials available
//                                           onSerialNumberTap(
//                                               context, selectedItem, originalIndex);
//                                         }
//                                       },
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
//                                           selectedItem.serialNumbers.isEmpty
//                                               ? 'No serial numbers available'
//                                               : 'S/N: ${selectedItem.selectedSerialNumbers.isEmpty ? 'Tap to scan' : selectedItem.selectedSerialNumbers.join(', ')}',
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
//                               if (subItem.item == null || subItem.quantity == 0) {
//                                 return const SizedBox();
//                               }
//                               return Padding(
//                                 padding: const EdgeInsets.only(left: 16.0, top: 8.0),
//                                 child: Card(
//                                   elevation: 1,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               InkWell(
//                                                 onTap: documentType.toLowerCase() ==
//                                                             'invoice' &&
//                                                         subItem.item!.itemModel
//                                                             .isNotEmpty &&
//                                                         subItem.item!.itemModel !=
//                                                             'N/A'
//                                                     ? () async {
//                                                         // Fetch serial numbers only if not already fetched
//                                                         if (subItem.serialNumbers.isEmpty) {
//                                                           await fetchSerialNumbers(
//                                                               originalIndex,
//                                                               subItem.item!.itemModel,
//                                                               subItemIndex: subIndex);
//                                                         }
//                                                         // Check serial numbers after fetching
//                                                         if (subItem.serialNumbers.isEmpty) {
//                                                           Fluttertoast.showToast(
//                                                             msg: 'This item is not in stock',
//                                                             toastLength: Toast.LENGTH_SHORT,
//                                                             gravity: ToastGravity.BOTTOM,
//                                                             backgroundColor: Colors.orange,
//                                                             textColor: Colors.white,
//                                                             fontSize: 16.0,
//                                                           );
//                                                         } else {
//                                                           // Open scanner if serials available
//                                                           onSerialNumberTap(context, subItem, originalIndex,
//                                                               subItemIndex: subIndex);
//                                                         }
//                                                       }
//                                                     : null,
//                                                 child: Text(
//                                                   subItem.item!.itemDescription,
//                                                   style: TextStyle(
//                                                     fontWeight: FontWeight.w600,
//                                                     fontSize: 14,
//                                                     decoration: documentType
//                                                                     .toLowerCase() ==
//                                                                 'invoice' &&
//                                                             subItem.item!.itemModel
//                                                                 .isNotEmpty &&
//                                                             subItem.item!.itemModel !=
//                                                                 'N/A'
//                                                         ? TextDecoration.underline
//                                                         : null,
//                                                   ),
//                                                   overflow: TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 4),
//                                               Text(
//                                                 'Quantity: ${subItem.quantity}',
//                                                 style: const TextStyle(fontSize: 12),
//                                               ),
//                                               const SizedBox(height: 4),
//                                               Text(
//                                                 'Model: ${subItem.item!.itemModel}',
//                                                 style: const TextStyle(fontSize: 12),
//                                               ),
//                                               const SizedBox(height: 4),
//                                               Text(
//                                                 'Price (${selectedPriceType ?? 'retail'}): Rs${subItem.getSelectedPrice(selectedPriceType ?? 'retail').toStringAsFixed(2)}',
//                                                 style: const TextStyle(fontSize: 12),
//                                               ),
//                                               const SizedBox(height: 4),
//                                               Text(
//                                                 'Total Price: Rs${(subItem.getSelectedPrice(selectedPriceType ?? 'retail') * subItem.quantity).toStringAsFixed(2)}',
//                                                 style: const TextStyle(
//                                                   fontWeight: FontWeight.w600,
//                                                   fontSize: 12,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         InkWell(
//                                           onTap: documentType.toLowerCase() ==
//                                                       'invoice' &&
//                                                   subItem.item!.itemModel.isNotEmpty &&
//                                                   subItem.item!.itemModel != 'N/A'
//                                               ? () async {
//                                                   // Fetch serial numbers only if not already fetched
//                                                   if (subItem.serialNumbers.isEmpty) {
//                                                     await fetchSerialNumbers(
//                                                         originalIndex,
//                                                         subItem.item!.itemModel,
//                                                         subItemIndex: subIndex);
//                                                   }
//                                                   // Check serial numbers after fetching
//                                                   if (subItem.serialNumbers.isEmpty) {
//                                                     Fluttertoast.showToast(
//                                                       msg: 'This item is not in stock',
//                                                       toastLength: Toast.LENGTH_SHORT,
//                                                       gravity: ToastGravity.BOTTOM,
//                                                       backgroundColor: Colors.orange,
//                                                       textColor: Colors.white,
//                                                       fontSize: 16.0,
//                                                     );
//                                                   } else {
//                                                     // Open scanner if serials available
//                                                     onSerialNumberTap(context, subItem,
//                                                         originalIndex,
//                                                         subItemIndex: subIndex);
//                                                   }
//                                                 }
//                                               : null,
//                                           child: Container(
//                                             margin: const EdgeInsets.only(left: 8),
//                                             padding: const EdgeInsets.all(8),
//                                             decoration: BoxDecoration(
//                                               color: subItem.selectedSerialNumbers
//                                                       .isNotEmpty
//                                                   ? Colors.yellow
//                                                   : Colors.grey.shade200,
//                                               borderRadius:
//                                                   BorderRadius.circular(4),
//                                             ),
//                                             child: Text(
//                                               subItem.serialNumbers.isEmpty
//                                                   ? 'No serial numbers available'
//                                                   : 'S/N: ${subItem.selectedSerialNumbers.isEmpty ? 'Tap to scan' : subItem.selectedSerialNumbers.join(', ')}',
//                                               style: const TextStyle(
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black,
//                                               ),
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(Icons.edit,
//                                               color: Colors.blue, size: 20),
//                                           tooltip: 'Edit Item',
//                                           onPressed: () => onEditItemRow(context,
//                                               subItem,
//                                               parentKitIndex: originalIndex),
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(Icons.delete,
//                                               color: Colors.red, size: 20),
//                                           tooltip: 'Remove Item',
//                                           onPressed: () => onRemoveItemRow(subIndex,
//                                               parentKitIndex: originalIndex),
//                                         ),
//                                       ],
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

// class AddItemPage extends StatefulWidget {
//   final List<Item> availableItems;
//   final String? selectedGroup;
//   final String? selectedPriceType;
//   final String documentType;
//   final Function(SelectedItem) onItemSelected;
//   final Function(SelectedItem) onSerialNumberTap;
//   final Future<List<String>> Function(String) fetchSerialNumbers;
//   final SelectedItem? selectedItem;
//   const AddItemPage({
//     Key? key,
//     required this.availableItems,
//     required this.selectedGroup,
//     required this.selectedPriceType,
//     required this.documentType,
//     required this.onItemSelected,
//     required this.onSerialNumberTap,
//     required this.fetchSerialNumbers,
//     this.selectedItem,
//   }) : super(key: key);

//   @override
//   _AddItemPageState createState() => _AddItemPageState();
// }

// class _AddItemPageState extends State<AddItemPage> {
//   final _formKey = GlobalKey<FormState>();
//   late SelectedItem _newItem;
//   String? _selectedItemId;

//   @override
//   void initState() {
//     super.initState();
//     _newItem = widget.selectedItem != null
//         ? widget.selectedItem!.copyWith()
//         : SelectedItem();
//     if (widget.selectedItem != null) {
//       _selectedItemId = widget.selectedItem!.item?.id;
//       _newItem.quantityController.text =
//           widget.selectedItem!.quantity.toString();
//     } else {
//       _newItem.quantityController.text = '1';
//       _newItem.quantity = 1;
//     }
//   }

//   @override
//   void dispose() {
//     if (widget.selectedItem == null) {
//       _newItem.quantityController.dispose();
//     }
//     super.dispose();
//   }

//   void _onItemChanged(String? newId) async {
//     setState(() {
//       if (newId != null) {
//         final selected =
//             widget.availableItems.firstWhere((item) => item.id == newId);
//         _newItem.item = selected;
//         _selectedItemId = newId;
//         if (widget.selectedItem == null) {
//           _newItem.quantity = 1;
//           _newItem.quantityController.text = '1';
//           _newItem.serialNumbers = [];
//           _newItem.selectedSerialNumbers = [];
//         }
//       } else {
//         _newItem.item = null;
//         _selectedItemId = null;
//         _newItem.quantity = 0;
//         _newItem.quantityController.text = '';
//         _newItem.serialNumbers = [];
//         _newItem.selectedSerialNumbers = [];
//       }
//     });
//     if (newId != null &&
//         widget.documentType.toLowerCase() == 'invoice' &&
//         widget.selectedGroup != 'kit' &&
//         _newItem.item!.itemModel.isNotEmpty &&
//         _newItem.item!.itemModel != 'N/A') {
//       final serialNumbers =
//           await widget.fetchSerialNumbers(_newItem.item!.itemModel);
//       setState(() {
//         _newItem.serialNumbers = serialNumbers;
//       });
//     }
//   }

//   void _onQuantityChanged(String value) {
//     setState(() {
//       final newQuantity = int.tryParse(value);
//       if (newQuantity != null && newQuantity > 0) {
//         _newItem.quantity = newQuantity;
//         if (_newItem.selectedSerialNumbers.length > newQuantity) {
//           _newItem.selectedSerialNumbers =
//               _newItem.selectedSerialNumbers.sublist(0, newQuantity);
//         }
//       } else {
//         _newItem.quantity = 0;
//         _newItem.quantityController.text = '';
//         _newItem.selectedSerialNumbers = [];
//       }
//     });
//   }

//   Future<void> _onScanTap() async {
//     if (_newItem.quantity == 0) {
//       Fluttertoast.showToast(
//         msg: 'Please enter a valid quantity first',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );
//       return;
//     }
//     if (_newItem.serialNumbers.isEmpty) {
//       Fluttertoast.showToast(
//         msg: 'This item is not in stock',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.orange,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );
//       return;
//     }
//     await widget.onSerialNumberTap(_newItem);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//             '${widget.selectedItem != null ? 'Edit' : 'Add'} ${widget.selectedGroup == 'kit' ? 'Kit' : 'Item'}'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Card(
//           elevation: 2,
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Text(
//                     '${widget.selectedItem != null ? 'Edit' : 'Add'} ${widget.selectedGroup == 'kit' ? 'Kit' : 'Item'}',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: Theme.of(context).primaryColor,
//                         ),
//                   ),
//                   const SizedBox(height: 16),
//                   DropdownButtonFormField<String>(
//                     decoration: InputDecoration(
//                       labelText: widget.selectedGroup == 'kit'
//                           ? 'Select Kit'
//                           : 'Select Item',
//                       border: const OutlineInputBorder(),
//                     ),
//                     value: _selectedItemId,
//                     items: widget.availableItems.map((Item item) {
//                       return DropdownMenuItem<String>(
//                         value: item.id,
//                         child: Text(
//                           widget.selectedGroup == 'kit'
//                               ? item.itemName
//                               : item.itemDescription,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       );
//                     }).toList(),
//                     onChanged: _onItemChanged,
//                     validator: (value) {
//                       if (value == null) {
//                         return 'Please select an ${widget.selectedGroup == 'kit' ? 'kit' : 'item'}';
//                       }
//                       return null;
//                     },
//                   ),
//                   if (widget.selectedGroup != 'kit') ...[
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _newItem.quantityController,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         labelText: 'Quantity',
//                         border: OutlineInputBorder(),
//                         hintText: 'Qty',
//                       ),
//                       validator: (value) {
//                         if (_newItem.item == null) return null;
//                         if (value == null || value.isEmpty) {
//                           return 'Enter quantity';
//                         }
//                         final qty = int.tryParse(value);
//                         if (qty == null || qty <= 0) {
//                           return 'Invalid quantity';
//                         }
//                         if (qty > _newItem.item!.itemQuantity) {
//                           return 'Max ${_newItem.item!.itemQuantity}';
//                         }
//                         return null;
//                       },
//                       onChanged: _onQuantityChanged,
//                     ),
//                     if (widget.documentType.toLowerCase() == 'invoice' &&
//                         _newItem.item != null &&
//                         _newItem.item!.itemModel.isNotEmpty &&
//                         _newItem.item!.itemModel != 'N/A') ...[
//                       const SizedBox(height: 16),
//                       InkWell(
//                         onTap: _newItem.serialNumbers.isNotEmpty
//                             ? _onScanTap
//                             : null,
//                         child: Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: _newItem.selectedSerialNumbers.isNotEmpty
//                                 ? Colors.yellow
//                                 : Colors.grey.shade200,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             _newItem.selectedSerialNumbers.isEmpty
//                                 ? (_newItem.serialNumbers.isNotEmpty
//                                     ? 'Tap to scan'
//                                     : 'No S/N available')
//                                 : 'S/N: ${_newItem.selectedSerialNumbers.join(', ')}',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ),
//                     ],
//                     const SizedBox(height: 16),
//                     Text(
//                       'Unit Price: Rs${_newItem.getSelectedPrice(widget.selectedPriceType ?? '').toStringAsFixed(2)}',
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ],
//                   const SizedBox(height: 16),
//                   Text(
//                     'Total Price: Rs${(_newItem.getSelectedPrice(widget.selectedPriceType ?? '') * _newItem.quantity).toStringAsFixed(2)}',
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 14),
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         if (widget.documentType.toLowerCase() == 'invoice' &&
//                             widget.selectedGroup != 'kit' &&
//                             _newItem.item != null &&
//                             _newItem.item!.itemModel.isNotEmpty &&
//                             _newItem.item!.itemModel != 'N/A' &&
//                             _newItem.selectedSerialNumbers.length !=
//                                 _newItem.quantity) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(
//                                   'Please select ${_newItem.quantity} serial number(s) for ${_newItem.item!.itemDescription}'),
//                               behavior: SnackBarBehavior.floating,
//                             ),
//                           );
//                           return;
//                         }
//                         widget.onItemSelected(_newItem);
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                     child: Text(
//                       widget.selectedItem != null ? 'Update Item' : 'Save Item',
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class AdditionalChargesPage extends StatelessWidget {
//   final TextEditingController invoiceDiscountController;
//   final List<TextEditingController> additionalAmountControllers;
//   final List<TextEditingController> additionalDescriptionControllers;
//   final List<double> additionalAmounts;
//   final List<String> additionalDescriptions;
//   final VoidCallback onAddAdditionalAmount;
//   final Function(int) onRemoveAdditionalAmount;
//   final Function(int, String) onDescriptionChanged;
//   final Function(int, String) onAmountChanged;

//   const AdditionalChargesPage({
//     Key? key,
//     required this.invoiceDiscountController,
//     required this.additionalAmountControllers,
//     required this.additionalDescriptionControllers,
//     required this.additionalAmounts,
//     required this.additionalDescriptions,
//     required this.onAddAdditionalAmount,
//     required this.onRemoveAdditionalAmount,
//     required this.onDescriptionChanged,
//     required this.onAmountChanged,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Card(
//         elevation: 2,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(
//                 'Additional Charges & Discount',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).primaryColor,
//                     ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: invoiceDiscountController,
//                 keyboardType:
//                     const TextInputType.numberWithOptions(decimal: true),
//                 decoration: const InputDecoration(
//                   labelText: 'Invoice Discount (Rs)',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.discount),
//                 ),
//                 validator: (value) {
//                   final discount = double.tryParse(value ?? '');
//                   if (discount != null && discount < 0) {
//                     return 'Discount cannot be negative';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {},
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Additional Amounts',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.add, color: Colors.blue),
//                     onPressed: onAddAdditionalAmount,
//                     tooltip: 'Add additional amount',
//                   ),
//                 ],
//               ),
//               ...additionalAmountControllers.asMap().entries.map((entry) {
//                 int index = entry.key;
//                 TextEditingController amountController = entry.value;
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 8.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         flex: 2,
//                         child: TextFormField(
//                           controller: additionalDescriptionControllers[index],
//                           decoration: InputDecoration(
//                             labelText: 'Description ${index + 1}',
//                             border: const OutlineInputBorder(),
//                             prefixIcon: const Icon(Icons.description),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Description cannot be empty';
//                             }
//                             return null;
//                           },
//                           onChanged: (value) {
//                             onDescriptionChanged(index, value);
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         flex: 1,
//                         child: TextFormField(
//                           controller: amountController,
//                           keyboardType: const TextInputType.numberWithOptions(
//                               decimal: true),
//                           decoration: InputDecoration(
//                             labelText: 'Amount ${index + 1} (Rs)',
//                             border: const OutlineInputBorder(),
//                             prefixIcon: const Icon(Icons.attach_money),
//                           ),
//                           validator: (value) {
//                             final amount = double.tryParse(value ?? '');
//                             if (amount == null) {
//                               return 'Invalid amount';
//                             }
//                             if (amount < 0) {
//                               return 'Amount cannot be negative';
//                             }
//                             return null;
//                           },
//                           onChanged: (value) {
//                             onAmountChanged(index, value);
//                           },
//                         ),
//                       ),
//                       if (additionalAmountControllers.length > 1)
//                         IconButton(
//                           icon: const Icon(Icons.remove_circle,
//                               color: Colors.red),
//                           onPressed: () => onRemoveAdditionalAmount(index),
//                           tooltip: 'Remove amount',
//                         ),
//                     ],
//                   ),
//                 );
//               }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SummaryPage extends StatelessWidget {
//   final List<SelectedItem> selectedItems;
//   final String? selectedPriceType;
//   final List<double> additionalAmounts;
//   final TextEditingController invoiceDiscountController;
//   final double Function() calculateTotalPrice;

//   const SummaryPage({
//     Key? key,
//     required this.selectedItems,
//     required this.selectedPriceType,
//     required this.additionalAmounts,
//     required this.invoiceDiscountController,
//     required this.calculateTotalPrice,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Card(
//         elevation: 2,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(
//                 'Summary',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).primaryColor,
//                     ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Subtotal (Items & Kits):',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   Text(
//                     'Rs${selectedItems.fold<double>(0, (sum, item) {
//                       if (item.item == null ||
//                           item.quantity == 0 ||
//                           selectedPriceType == null) return sum;
//                       double itemTotal =
//                           item.getSelectedPrice(selectedPriceType!) *
//                               item.quantity;
//                       if (item.subItems != null) {
//                         itemTotal += item.subItems!.fold(0, (subSum, subItem) {
//                           if (subItem.item == null || subItem.quantity == 0)
//                             return subSum;
//                           return subSum +
//                               (subItem.getSelectedPrice(selectedPriceType!) *
//                                   subItem.quantity);
//                         });
//                       }
//                       return sum + itemTotal;
//                     }).toStringAsFixed(2)}',
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Additional Amounts:',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   Text(
//                     'Rs${additionalAmounts.fold<double>(0, (sum, amount) => sum + amount).toStringAsFixed(2)}',
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Discount:',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   Text(
//                     '-Rs${(invoiceDiscountController.text.isNotEmpty ? (double.tryParse(invoiceDiscountController.text) ?? 0.0) : 0.0).toStringAsFixed(2)}',
//                     style: const TextStyle(fontSize: 16, color: Colors.red),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Total Amount:',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     'Rs${calculateTotalPrice().toStringAsFixed(2)}',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
