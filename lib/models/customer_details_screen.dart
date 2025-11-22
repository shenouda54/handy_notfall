import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handy_notfall/data/print_pdf/customer_number/view/customer_numbering_screen.dart';
import 'package:handy_notfall/data/error_widget.dart';
import 'package:intl/intl.dart';

import '../data/screen_pdfs/auftrag/view/auftrag_screen.dart';
import '../data/screen_pdfs/kostenmittlung/view/kostenmittlung_screen.dart';
import '../data/screen_pdfs/rechnung/view/rechnung_screen.dart';
import '../data/screen_pdfs/rechnung_handy/view/rechnung_handy_screen.dart';
import '../data/screen_pdfs/rechnungs_verkaufe/view/rechnungs_verkaufe_screen.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final String customerId;
  final String auftragNr;

  const CustomerDetailsScreen({super.key, required this.customerId, required this.auftragNr});

  Future<DocumentSnapshot> fetchCustomerDetails() async {
    try {
      return await FirebaseFirestore.instance
          .collection('Customers')
          .doc(customerId)
          .get();
    } catch (e) {
      throw Exception('Failed to load customer data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<DocumentSnapshot>(
      future: fetchCustomerDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return CustomErrorWidget(
            errorMessage: snapshot.error.toString(),
            onRetry: () => (context as Element).markNeedsBuild(),
            onGoBack: () => Navigator.pop(context),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return CustomErrorWidget(
            errorMessage: "Customer data not found",
            onGoBack: () => Navigator.pop(context),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Kundendetails'),
            actions: [
              IconButton(
                icon: const Icon(Icons.format_list_numbered),
                tooltip: 'ترقيم العميل',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerNumberingScreen(
                        customerName: data['customerFirstName'],
                        customerPhone: data['phoneNumber'],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(data, theme),
                const SizedBox(height: 24),
                
                _buildSectionTitle('Kundeninformationen', Icons.person, theme),
                _buildInfoCard([
                  _buildDetailRow(Icons.location_on, 'Adresse', '${data['address']}, ${data['city']}', theme),
                  _buildDetailRow(Icons.phone, 'Handy', data['phoneNumber'], theme),
                  _buildDetailRow(Icons.email, 'E-Mail', data['emailAddress'], theme),
                ], theme),
                const SizedBox(height: 20),
                
                _buildSectionTitle('Geräteinformationen', Icons.phone_android, theme),
                _buildInfoCard([
                  _buildDetailRow(Icons.smartphone, 'Modell', '${data['deviceType']} ${data['deviceModel']}', theme),
                  _buildDetailRow(Icons.qr_code, 'Seriennummer', data['serialNumber'], theme),
                  _buildDetailRow(Icons.lock, 'PIN Code', data['pinCode'], theme),
                  _buildDetailRow(Icons.build, 'Problem', data['issue'], theme),
                ], theme),
                const SizedBox(height: 20),
                
                _buildSectionTitle('Auftragsdetails', Icons.assignment, theme),
                _buildInfoCard([
                  _buildDetailRow(Icons.euro, 'Preis', "${data['price']} €", theme),
                  _buildDetailRow(Icons.calendar_today, 'Startdatum', DateFormat('dd.MM.yyyy').format((data['startDate'] as Timestamp).toDate()), theme),
                  _buildDetailRow(Icons.event, 'Enddatum', DateFormat('dd.MM.yyyy').format((data['endDate'] as Timestamp).toDate()), theme),
                ], theme),
                
                const SizedBox(height: 30),
                _buildActionButtons(context, data, customerId, theme),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Map<String, dynamic> data, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Text(
                (data['customerFirstName'] as String).isNotEmpty ? data['customerFirstName'][0].toUpperCase() : '?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['customerFirstName'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Auftrag Nr: ${data['auftragNr'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '#${data.containsKey('kundennummer') ? data['kundennummer'] : '-'}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: theme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(value ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic> data, String customerId, ThemeData theme) {
    void navigateTo(Widget screen) {
       if (data.containsKey('auftragNr')) {
          final auftragNr = data['auftragNr']?.toString() ?? '';
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
       } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ العميل غير مرقّم، من فضلك استخدم شاشة الترقيم أولًا.")));
       }
    }

    final auftragNr = data['auftragNr']?.toString() ?? '';

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () => navigateTo(AuftragScreen(customerId: customerId, auftragNr: auftragNr)),
            icon: const Icon(Icons.assignment_turned_in),
            label: const Text('Auftrag erstellen', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
             _buildActionButton(context, 'Rechnung', Icons.receipt, () => navigateTo(RechnungScreen(customerId: customerId, auftragNr: auftragNr)), theme),
             _buildActionButton(context, 'Verkaufe', Icons.sell, () => navigateTo(RechnungVerkaufeScreen(customerId: customerId, auftragNr: auftragNr)), theme),
             _buildActionButton(context, 'Gebraucht', Icons.phone_iphone, () => navigateTo(RechnungHandyScreen(customerId: customerId, auftragNr: auftragNr)), theme),
             _buildActionButton(context, 'Kosten', Icons.euro, () => navigateTo(KostenmittlungScreen(customerId: customerId, auftragNr: auftragNr)), theme),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onPressed, ThemeData theme) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: theme.primaryColor),
      label: Text(label, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 13, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.cardTheme.color,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
