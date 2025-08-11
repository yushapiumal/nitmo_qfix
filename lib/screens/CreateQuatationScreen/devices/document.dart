import 'package:flutter/material.dart';

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
