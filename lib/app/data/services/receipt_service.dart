import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

// Import the actual EmiData model from the controller file
import '../../modules/user/emi_payment/controllers/emi_payment_controller.dart'
    show EmiData;

class ReceiptService {
  Future<Uint8List> generateEmiReceiptPdf({
    required EmiData emiData,
    required Map<String, dynamic>
        loanData, // e.g., { 'id': 'loan123', 'principalAmount': 50000, ... }
    required Map<String, dynamic>
        userData, // e.g., { 'name': 'John Doe', 'phone': '+91...', ... }
    required Map<String, dynamic>
        pawnbrokerData, // e.g., { 'shopName': 'ABC Jewellers', 'address': '...', ... }
  }) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    // --- Helper Functions for PDF Widgets ---
    pw.Widget _buildHeader() {
      return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('BidMyGold - EMI Payment Receipt',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Date Generated: ${dateFormat.format(DateTime.now())}'),
            pw.Divider(thickness: 1, height: 20),
          ]);
    }

    pw.Widget _buildSectionTitle(String title) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 15, bottom: 5),
        child: pw.Text(title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      );
    }

    pw.Widget _buildDetailRow(String label, String value) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label),
              pw.Text(value,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
            ]),
      );
    }

    // --- PDF Page Definition ---
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              _buildSectionTitle('Payment Details'),
              _buildDetailRow('EMI Number:', emiData.emiNumber.toString()),
              _buildDetailRow(
                  'Amount Paid:', currencyFormat.format(emiData.amount)),
              _buildDetailRow(
                  'Payment Date:',
                  emiData.paidDate != null
                      ? dateFormat.format(emiData.paidDate!.toDate())
                      : 'N/A'),
              _buildDetailRow(
                  'Payment ID (Razorpay):', emiData.paymentId ?? 'N/A'),
              _buildDetailRow('Payment Status:',
                  'Paid'), // Assuming receipt is only for paid

              _buildSectionTitle('Loan Details'),
              _buildDetailRow('Loan ID:', loanData['id'] ?? 'N/A'),
              _buildDetailRow('Original Due Date:',
                  dateFormat.format(emiData.dueDate.toDate())),
              // Add more loan details if needed
              _buildDetailRow('Principal Amount:',
                  currencyFormat.format(loanData['principalAmount'] ?? 0.0)),

              _buildSectionTitle('Customer Details'),
              _buildDetailRow('Customer Name:', userData['name'] ?? 'N/A'),
              _buildDetailRow('Customer Phone:', userData['phone'] ?? 'N/A'),
              // Add more user details if needed

              _buildSectionTitle('Pawnbroker Details'),
              _buildDetailRow(
                  'Pawnbroker:', pawnbrokerData['shopName'] ?? 'N/A'),
              _buildDetailRow('Address:', pawnbrokerData['address'] ?? 'N/A'),

              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Text('Thank you for your payment! - BidMyGold',
                    style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
              )
            ],
          );
        }, // build
      ), // Page
    ); // addPage

    // Return PDF data
    return pdf.save();
  }
}
