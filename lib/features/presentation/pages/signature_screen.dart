import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

/// Screen for capturing customer's digital signature.
/// Shows full Auftrag details so the customer knows what they're signing.
/// Returns Uint8List (PNG bytes) of the signature via Navigator.pop,
/// or null if the customer cancels.
class SignatureScreen extends StatefulWidget {
  final String customerName;
  final String address;
  final String city;
  final String phoneNumber;
  final String emailAddress;
  final String deviceType;
  final String deviceModel;
  final String serialNumber;
  final List<Map<String, dynamic>> defects;
  final String startDate;
  final String endDate;

  const SignatureScreen({
    super.key,
    required this.customerName,
    required this.address,
    required this.city,
    required this.phoneNumber,
    required this.emailAddress,
    required this.deviceType,
    required this.deviceModel,
    required this.serialNumber,
    required this.defects,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
  bool _hasSignature = false;
  final NumberFormat _currencyFormat = NumberFormat('#,##0.00', 'de_DE');

  void _clear() {
    _signaturePadKey.currentState?.clear();
    setState(() {
      _hasSignature = false;
    });
  }

  Future<Uint8List?> _captureSignature() async {
    try {
      // Use Syncfusion's built-in toImage
      final rawImage = await _signaturePadKey.currentState?.toImage(pixelRatio: 2.0);
      if (rawImage == null) {
        debugPrint('⚠️ Signature: toImage returned null');
        return null;
      }

      debugPrint('✅ Signature captured: ${rawImage.width}x${rawImage.height}');

      // Re-draw on a white background so signature is visible in PDF
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // White background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, rawImage.width.toDouble(), rawImage.height.toDouble()),
        Paint()..color = Colors.white,
      );

      // Signature strokes on top
      canvas.drawImage(rawImage, Offset.zero, Paint());

      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(rawImage.width, rawImage.height);
      final byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        debugPrint('⚠️ Signature: byteData is null');
        return null;
      }

      // Use proper byte slicing to avoid buffer offset issues
      final pngBytes = Uint8List.sublistView(byteData);
      debugPrint('✅ Signature PNG: ${pngBytes.length} bytes');
      return pngBytes;
    } catch (e) {
      debugPrint('❌ Error capturing signature: $e');
      return null;
    }
  }

  double get _totalAmount {
    double total = 0;
    for (var defect in widget.defects) {
      final double price = double.tryParse(defect['price'].toString()) ?? 0;
      final int qty = int.tryParse(defect['quantity'].toString()) ?? 1;
      total += (price * qty);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unterschrift'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, null),
        ),
      ),
      body: Column(
        children: [
          // Scrollable Auftrag details
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: const Text(
                      'Bitte überprüfen Sie die Daten und unterschreiben Sie unten.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1565C0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Customer Info Section
                  _buildSectionTitle('Kundendaten'),
                  _buildDetailCard([
                    _buildDetailRow('Name', widget.customerName),
                    _buildDetailRow('Adresse', widget.address),
                    _buildDetailRow('Stadt', widget.city),
                    _buildDetailRow('Telefon', widget.phoneNumber),
                    _buildDetailRow('E-Mail', widget.emailAddress),
                  ]),
                  const SizedBox(height: 12),

                  // Device Info Section
                  _buildSectionTitle('Gerätedaten'),
                  _buildDetailCard([
                    _buildDetailRow('Geräte-Typ', widget.deviceType),
                    _buildDetailRow('Modell', widget.deviceModel),
                    _buildDetailRow('Seriennummer', widget.serialNumber),
                  ]),
                  const SizedBox(height: 12),

                  // Defects / Services Section
                  _buildSectionTitle('Leistungen'),
                  _buildDefectsCard(),
                  const SizedBox(height: 12),

                  // Dates Section
                  _buildSectionTitle('Termine'),
                  _buildDetailCard([
                    _buildDetailRow('Anfang', widget.startDate),
                    _buildDetailRow('Abholung', widget.endDate),
                  ]),
                  const SizedBox(height: 16),

                  // Signature label
                  Text(
                    'Unterschrift des Kunden:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Signature Pad
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SfSignaturePad(
                        key: _signaturePadKey,
                        backgroundColor: Colors.white,
                        strokeColor: Colors.black,
                        minimumStrokeWidth: 2.0,
                        maximumStrokeWidth: 4.0,
                        onDrawStart: () {
                          setState(() {
                            _hasSignature = true;
                          });
                          return false;
                        },
                      ),
                    ),
                  ),

                  if (!_hasSignature)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Center(
                        child: Text(
                          'Bitte hier unterschreiben',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Buttons (fixed at bottom)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _hasSignature ? _clear : null,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Löschen'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _hasSignature
                        ? () async {
                            final signatureBytes = await _captureSignature();
                            if (signatureBytes != null && context.mounted) {
                              Navigator.pop(context, signatureBytes);
                            }
                          }
                        : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Bestätigen'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefectsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Beschreibung',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700])),
              ),
              SizedBox(
                width: 50,
                child: Text('Menge',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700]),
                    textAlign: TextAlign.center),
              ),
              SizedBox(
                width: 80,
                child: Text('Betrag',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700]),
                    textAlign: TextAlign.right),
              ),
            ],
          ),
          const Divider(),
          // Defect rows
          ...widget.defects.map((defect) {
            final String issue = defect['issue'] ?? '';
            final double price =
                double.tryParse(defect['price'].toString()) ?? 0;
            final int qty =
                int.tryParse(defect['quantity'].toString()) ?? 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      '$issue ${widget.deviceType} ${widget.deviceModel}',
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(qty.toString(),
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text('${_currencyFormat.format(price)} €',
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                        textAlign: TextAlign.right),
                  ),
                ],
              ),
            );
          }),
          const Divider(),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Gesamtbetrag: ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${_currencyFormat.format(_totalAmount)} €',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
