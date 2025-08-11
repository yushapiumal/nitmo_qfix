import 'package:flutter/material.dart';
import 'package:qfix_nitmo_new/helper/itemModel.dart';

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
