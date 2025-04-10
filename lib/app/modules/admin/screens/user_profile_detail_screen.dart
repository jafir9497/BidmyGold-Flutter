import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:bidmygoldflutter/app/data/models/user_model.dart';
import 'package:bidmygoldflutter/app/modules/admin/controllers/user_management_controller.dart';

class UserProfileDetailScreen extends StatelessWidget {
  const UserProfileDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Retrieve the user passed as an argument
    final UserModel user = Get.arguments as UserModel;
    final UserManagementController controller =
        Get.find(); // To access toggle/delete
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final createdDate = user.createdAt != null
        ? dateFormat.format(user.createdAt.toDate())
        : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Text('User Details: ${user.name ?? "Unknown"}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              context,
              'User Information',
              Column(
                children: [
                  _buildInfoRow('Name', user.name ?? 'N/A'),
                  _buildInfoRow('Phone', user.phone ?? 'N/A'),
                  _buildInfoRow('Email', user.email ?? 'N/A'),
                  _buildInfoRow('ID', user.id),
                  _buildInfoRow('Created', createdDate),
                  _buildInfoRow('KYC Status', user.kycStatus ?? 'N/A'),
                  _buildInfoRow('KYC Submitted', user.kycSubmitted.toString()),
                  _buildInfoRow(
                      'Has Active Loan', user.hasActiveLoanRequest.toString()),
                  _buildInfoRow('Account Status',
                      user.isDisabled ? 'Disabled' : 'Active'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (user.address != null || user.city != null || user.state != null)
              _buildInfoCard(
                context,
                'Address Information',
                Column(
                  children: [
                    if (user.address != null)
                      _buildInfoRow('Address', user.address ?? 'N/A'),
                    if (user.city != null)
                      _buildInfoRow('City', user.city ?? 'N/A'),
                    if (user.state != null)
                      _buildInfoRow('State', user.state ?? 'N/A'),
                    if (user.pinCode != null)
                      _buildInfoRow('PIN Code', user.pinCode ?? 'N/A'),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (user.kycDocuments != null && user.kycDocuments!.isNotEmpty)
              _buildDocumentsSection(user, context),
            const SizedBox(height: 32),
            Text('User Actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(() => ElevatedButton.icon(
                        icon: Icon(
                          user.isDisabled ? Icons.check_circle : Icons.block,
                          color: user.isDisabled ? Colors.green : Colors.red,
                        ),
                        label: Text(
                          user.isDisabled ? 'Enable User' : 'Disable User',
                          style: TextStyle(
                              color:
                                  user.isDisabled ? Colors.green : Colors.red),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                              color:
                                  user.isDisabled ? Colors.green : Colors.red),
                        ),
                        onPressed: controller.isSubmitting.value ||
                                controller.togglingUserId.value == user.id
                            ? null
                            : () => controller.toggleUserAccountStatus(
                                user.id, user.isDisabled),
                      )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => ElevatedButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Delete User',
                            style: TextStyle(color: Colors.red)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.red),
                        ),
                        onPressed: controller.isSubmitting.value ||
                                controller.togglingUserId.value != null
                            ? null
                            : () => controller.deleteUser(user.id).then((_) {
                                  // Optionally navigate back after deletion
                                  // if (Get.isDialogOpen == false) Get.back();
                                }),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods copied from UserManagementScreen (consider moving to a shared widget/util)
  Widget _buildInfoCard(BuildContext context, String title, Widget content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130, // Adjust width as needed
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(UserModel user, BuildContext context) {
    final idProofUrl = user.kycDocuments?['idProofUrl'] as String?;
    final addressProofUrl = user.kycDocuments?['addressProofUrl'] as String?;
    final selfieUrl = user.kycDocuments?['selfieUrl'] as String?;

    if (idProofUrl == null && addressProofUrl == null && selfieUrl == null) {
      return const SizedBox.shrink(); // Don't show section if no docs
    }

    return _buildInfoCard(
      context,
      'KYC Documents',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (idProofUrl != null) ...[
            _buildDocumentLink('ID Proof', idProofUrl, context),
            const SizedBox(height: 12),
          ],
          if (addressProofUrl != null) ...[
            _buildDocumentLink('Address Proof', addressProofUrl, context),
            const SizedBox(height: 12),
          ],
          if (selfieUrl != null) ...[
            _buildDocumentLink('Selfie', selfieUrl, context),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentLink(String label, String url, BuildContext context) {
    return InkWell(
      onTap: () {
        // Simple approach: show URL in dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(label),
            content: SelectableText(url),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close')),
              // TODO: Add button to open in browser using url_launcher
            ],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            const Icon(Icons.link, color: Colors.blue, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline)),
          ],
        ),
      ),
    );
  }
}
