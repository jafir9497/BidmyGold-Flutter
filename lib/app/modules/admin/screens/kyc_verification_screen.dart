import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kyc_verification_controller.dart';
import '../widgets/admin_drawer.dart';
import '../../../data/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class KycVerificationScreen extends GetView<KycVerificationController> {
  const KycVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('kyc_verification_title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'refresh'.tr,
            onPressed: controller.fetchPendingUsers,
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: Obx(() {
        if (controller.isLoading.value && controller.pendingUsers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.selectedUser.value != null) {
          return _buildDetailView(context);
        }

        return _buildListView();
      }),
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: Obx(() {
            if (controller.filteredPendingUsers.isEmpty) {
              return Center(
                child: Text(controller.searchQuery.isNotEmpty
                    ? 'user_search_not_found'.tr
                    : 'no_pending_kyc_requests'.tr),
              );
            }
            return ListView.builder(
              itemCount: controller.filteredPendingUsers.length,
              itemBuilder: (context, index) {
                final user = controller.filteredPendingUsers[index];
                return _buildUserListItem(user);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'kyc_search_hint'.tr,
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

  Widget _buildUserListItem(UserModel user) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final submittedDate = user.createdAt != null
        ? dateFormat.format(user.createdAt.toDate())
        : 'unknown_date'.tr;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(user.name.substring(0, 1).toUpperCase() ?? 'U'),
        ),
        title: Text(
            '${user.name ?? "unknown_user".tr} (${user.phone ?? "not_available".tr})'),
        subtitle: Text('${'submitted_label'.tr}: $submittedDate'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => controller.selectUser(user),
      ),
    );
  }

  Widget _buildDetailView(BuildContext context) {
    final user = controller.selectedUser.value!;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final unknownUserName = 'unknown_user'.tr;

    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: controller.clearSelectedUser,
          ),
          title: Text(
              '${'verify_kyc_title_prefix'.tr}: ${user.name ?? unknownUserName}'),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('user_information_title'.tr,
                            style: Theme.of(context).textTheme.titleLarge),
                        const Divider(),
                        _buildInfoRow(
                            'name_label'.tr, user.name ?? 'not_available'.tr),
                        _buildInfoRow(
                            'phone_label'.tr, user.phone ?? 'not_available'.tr),
                        _buildInfoRow('user_id_label'.tr, user.id),
                        _buildInfoRow('kyc_status_label'.tr,
                            user.kycStatus ?? 'not_available'.tr),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('kyc_documents_title'.tr,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                _buildDocumentSection(
                    'id_proof_label'.tr, controller.idProofUrl, context),
                _buildDocumentSection('address_proof_label'.tr,
                    controller.addressProofUrl, context),
                _buildDocumentSection(
                    'selfie_label'.tr, controller.selfieUrl, context),
                Obx(() {
                  if (controller.idProofUrl.value == null &&
                      controller.addressProofUrl.value == null &&
                      controller.selfieUrl.value == null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('no_kyc_documents_uploaded'.tr,
                          style: const TextStyle(color: Colors.grey)),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 24),
                Text('action_title'.tr,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.rejectionReasonController,
                  decoration: InputDecoration(
                    labelText: 'rejection_reason_hint_kyc'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  enabled: !controller.isSubmitting.value,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => ElevatedButton.icon(
                            icon: const Icon(Icons.cancel_outlined),
                            label: Text('reject_button'.tr),
                            onPressed: controller.isSubmitting.value
                                ? null
                                : controller.rejectRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          )),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(() => ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text('approve_button'.tr),
                            onPressed: controller.isSubmitting.value
                                ? null
                                : controller.approveRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          )),
                    ),
                  ],
                ),
                Obx(() => controller.isSubmitting.value
                    ? const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Center(child: CircularProgressIndicator()))
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentSection(
      String title, RxnString docUrl, BuildContext context) {
    return Obx(() {
      final url = docUrl.value;
      if (url == null) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildDocumentPreview(url, context),
          const SizedBox(height: 16),
        ],
      );
    });
  }

  Widget _buildDocumentPreview(String url, BuildContext context) {
    return InkWell(
      onTap: () {
        Get.dialog(Dialog(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4,
            child: CachedNetworkImage(
              imageUrl: url,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Center(
                  child: Icon(Icons.error, color: Colors.red[300], size: 40)),
              fit: BoxFit.contain,
            ),
          ),
        ));
      },
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade100,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: url,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Center(
                child: Icon(Icons.error_outline,
                    color: Colors.red[300], size: 50)),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
