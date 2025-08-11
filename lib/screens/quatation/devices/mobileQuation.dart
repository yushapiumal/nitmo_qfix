import 'package:flutter/material.dart';
//import 'package:file_picker/file_picker.dart';
//import 'package:open_file/open_file.dart';
import 'package:qfix_nitmo_new/screens/CreateQuatationScreen/devices/mobileCreateQuation.dart';
//mport 'package:share_plus/share_plus.dart';



class MobileQuotationOrInvoice extends StatefulWidget {
  const MobileQuotationOrInvoice({Key? key}) : super(key: key);

  @override
  State<MobileQuotationOrInvoice> createState() => _MobileQuotationOrInvoiceState();
}

class _MobileQuotationOrInvoiceState extends State<MobileQuotationOrInvoice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 120,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quotation & Invoice',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Hello Huzaif!',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
         // _buildIconButtonsSection(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCardSection(
                    icon: Icons.description,
                    title: 'Quotation',
                    subtitle: 'Create quotes',
                    onCreate: () => _navigateToCreateScreen(context, 'Quotation'),
                    onManage: () => _navigateToManageScreen(context, 'Quotation'),
                  ),
                  const SizedBox(height: 16),
                  _buildCardSection(
                    icon: Icons.receipt_long,
                    title: 'Invoice',
                    subtitle: 'Manage invoices',
                    onCreate: () => _navigateToCreateScreen(context, 'Invoice'),
                    onManage: () => _navigateToManageScreen(context, 'Invoice'),
                  ),
                  const SizedBox(height: 16),
                  _buildCardSection(
                    icon: Icons.shopping_cart,
                    title: 'Purchase Order',
                    subtitle: 'Track orders',
                    onCreate: () => _navigateToCreateScreen(context, 'Purchase Order'),
                    onManage: () => _navigateToManageScreen(context, 'Purchase Order'),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCardSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onCreate,
    required VoidCallback onManage,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: Colors.red[500]),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCreate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[500],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Create'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onManage,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Manage'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateScreen(BuildContext context, String type) {
    Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MobileCreateDocumentScreen(documentType: type),
              
            ),
          );
  }

  void _navigateToManageScreen(BuildContext context, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Manage $type functionality will be implemented here'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
