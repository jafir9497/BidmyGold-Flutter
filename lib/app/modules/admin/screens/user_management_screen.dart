import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_management_controller.dart';
import '../widgets/admin_drawer.dart';
import '../models/app_user.dart';
import 'package:intl/intl.dart';
import '../../../data/models/user_model.dart'; // Import UserModel

class UserManagementScreen extends GetView<UserManagementController> {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchUsers, // Refresh action
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.users.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredUsers.isEmpty) {
                return Center(
                  child: Text(controller.searchQuery.isNotEmpty
                      ? 'No users found matching search.'
                      : 'No users found.'),
                );
              }
              return ListView.builder(
                itemCount: controller.filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = controller.filteredUsers[index];
                  return _buildUserListItem(context, user);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by name, phone, email, or user ID...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onChanged: controller.setSearchQuery,
      ),
    );
  }

  Widget _buildUserListItem(BuildContext context, UserModel user) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final createdDate = user.createdAt != null
        ? dateFormat.format(user.createdAt.toDate())
        : 'N/A';
    final kycColor = user.kycStatus == 'approved'
        ? Colors.green
        : user.kycStatus == 'rejected'
            ? Colors.red
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isDisabled
              ? Colors.grey[700]
              : Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: user.isDisabled
              ? Colors.white70
              : Theme.of(context).colorScheme.onPrimaryContainer,
          child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
        ),
        title: Text('${user.name} ${user.isDisabled ? "(Disabled)" : ""}',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: user.isDisabled ? Colors.grey[600] : null,
                decoration:
                    user.isDisabled ? TextDecoration.lineThrough : null)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${user.phone}'),
            if (user.email != null && user.email!.isNotEmpty)
              Text('Email: ${user.email!}'),
            Text('Joined: $createdDate'),
            Row(
              children: [
                const Text('KYC: '),
                Text(
                  user.kycStatus.toUpperCase(),
                  style:
                      TextStyle(color: kycColor, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Text('ID: ${user.id}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'toggle_disable') {
              controller.toggleUserAccountStatus(user.id, user.isDisabled);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'toggle_disable',
              child:
                  Text(user.isDisabled ? 'Enable Account' : 'Disable Account'),
            ),
            // Add other actions here if needed (e.g., View Details, Reset Password)
          ],
          icon: const Icon(Icons.more_vert),
        ),
        // Optional: Add onTap for a detailed user view screen later
        // onTap: () => controller.navigateToUserDetails(user.id),
      ),
    );
  }

  // *** Remove the inline detail view and its helpers ***
  /*
  Widget _buildUserDetailView(BuildContext context) {
    final user = controller.selectedUser.value!;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final createdDate = user.createdAt != null
        ? dateFormat.format(user.createdAt.toDate())
        : 'N/A';

    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: controller.clearSelectedUser,
          ),
          title: Text('User: ${user.name ?? 'Unknown'}'),
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info Card
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
                      _buildInfoRow(
                          'KYC Submitted', user.kycSubmitted.toString()),
                      _buildInfoRow('Has Active Loan',
                          user.hasActiveLoanRequest.toString()),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Address Information
                if (user.address != null ||
                    user.city != null ||
                    user.state != null)
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

                // Document Previews
                if (user.kycDocuments != null && user.kycDocuments!.isNotEmpty)
                  _buildDocumentsSection(user, context),

                const SizedBox(height: 32),

                // Action Buttons
                Text('User Actions',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          user.isDisabled ? Icons.check_circle : Icons.block,
                          color: user.isDisabled ? Colors.green : Colors.red,
                        ),
                        label: Text(
                          user.isDisabled ? 'Enable User' : 'Disable User',
                          style: TextStyle(
                            color: user.isDisabled ? Colors.green : Colors.red,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: user.isDisabled ? Colors.green : Colors.red,
                          ),
                        ),
                        onPressed: controller.isSubmitting.value ||
                                controller.togglingUserId == user.id
                            ? null
                            : () => controller.toggleUserAccountStatus(
                                user.id, user.isDisabled),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'Delete User',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.red),
                        ),
                        onPressed: controller.isSubmitting.value ||
                                controller.togglingUserId != null
                            ? null
                            : () => controller.deleteUser(user.id),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  */

  /*
  Widget _buildInfoCard(BuildContext context, String title, Widget content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            content,
          ],
        ),
      ),
    );
  }
  */

  /*
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  */

  /*
  Widget _buildDocumentsSection(UserModel user, BuildContext context) {
    final idProofUrl = user.kycDocuments?['idProofUrl'] as String?;
    final addressProofUrl = user.kycDocuments?['addressProofUrl'] as String?;
    final selfieUrl = user.kycDocuments?['selfieUrl'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('KYC Documents', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        if (idProofUrl != null) ...[
          Text('ID Proof', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildDocumentPreview(idProofUrl, context),
          const SizedBox(height: 16),
        ],
        if (addressProofUrl != null) ...[
          Text('Address Proof', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildDocumentPreview(addressProofUrl, context),
          const SizedBox(height: 16),
        ],
        if (selfieUrl != null) ...[
          Text('Selfie', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildDocumentPreview(selfieUrl, context),
        ],
        if (idProofUrl == null && addressProofUrl == null && selfieUrl == null)
          const Text('No document URLs found in user data.',
              style: TextStyle(color: Colors.grey)),
      ],
    );
  }
  */

  /*
  Widget _buildDocumentPreview(String url, BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading image',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open in browser'),
                  onPressed: () {
                    // Simple approach that opens the URL in a dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Document URL'),
                        content: SelectableText(url),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  */
}

extension UserManagementGetters on GetView<UserManagementController> {
  bool get isLoadingMore => controller.isLoadingMore.value;
  bool get hasMoreData => controller.hasMoreData.value;
  String? get togglingUserId => controller.togglingUserId.value;
}
