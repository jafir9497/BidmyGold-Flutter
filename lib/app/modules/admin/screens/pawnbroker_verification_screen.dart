import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pawnbroker_verification_controller.dart';
import '../widgets/admin_drawer.dart';
import '../../../data/models/pawnbroker_model.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PawnbrokerVerificationScreen
    extends GetView<PawnbrokerVerificationController> {
  const PawnbrokerVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('pawnbroker_verification_title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'refresh'.tr,
            onPressed: controller.fetchPendingPawnbrokers,
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: Obx(() {
        if (controller.isLoading.value && controller.allPawnbrokers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.selectedPawnbroker.value != null) {
          return _buildDetailView(context);
        }

        return _buildListView();
      }),
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        _buildSearchField(),
        Expanded(
          child: Obx(() {
            if (controller.filteredPendingPawnbrokers.isEmpty) {
              return Center(
                child: Text(controller.searchQuery.isNotEmpty
                    ? 'pawnbroker_search_not_found'.tr
                    : 'no_pending_pawnbroker_requests'.tr),
              );
            }

            return ListView.builder(
              itemCount: controller.filteredPendingPawnbrokers.length,
              itemBuilder: (context, index) {
                final pawnbroker = controller.filteredPendingPawnbrokers[index];
                return _buildPawnbrokerListItem(pawnbroker);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'pawnbroker_search_hint'.tr,
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

  Widget _buildPawnbrokerListItem(PawnbrokerModel pawnbroker) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final createdDate = pawnbroker.createdAt != null
        ? dateFormat.format(pawnbroker.createdAt.toDate())
        : 'Unknown Date';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.amber,
          child: const Icon(Icons.store, color: Colors.white),
        ),
        title: Text(pawnbroker.shopName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'owner_label'.tr}: ${pawnbroker.ownerName}'),
            Text(
                '${'location_label'.tr}: ${pawnbroker.city}, ${pawnbroker.state}'),
            Text('${'created_label'.tr}: $createdDate'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => controller.selectPawnbroker(pawnbroker),
      ),
    );
  }

  Widget _buildDetailView(BuildContext context) {
    final pawnbroker = controller.selectedPawnbroker.value!;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final createdDate = pawnbroker.createdAt != null
        ? dateFormat.format(pawnbroker.createdAt.toDate())
        : 'Unknown Date';

    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: controller.clearSelectedPawnbroker,
          ),
          title: Text(pawnbroker.shopName),
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.isLoading.value)
                      const Center(
                          child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: CircularProgressIndicator(),
                      )),
                    _buildInfoCard(
                      context,
                      'shop_information_title'.tr,
                      [
                        _buildInfoRow(
                            'shop_name_label'.tr, pawnbroker.shopName),
                        _buildInfoRow(
                            'owner_name_label'.tr, pawnbroker.ownerName),
                        _buildInfoRow('license_number_label'.tr,
                            pawnbroker.licenseNumber),
                        _buildInfoRow('address_label'.tr, pawnbroker.address),
                        _buildInfoRow('city_label'.tr, pawnbroker.city),
                        _buildInfoRow('state_label'.tr, pawnbroker.state),
                        _buildInfoRow('pin_code_label'.tr, pawnbroker.pinCode),
                        _buildInfoRow('phone_label'.tr, pawnbroker.phone),
                        _buildInfoRow('email_label'.tr,
                            pawnbroker.email ?? 'not_available'.tr),
                        _buildInfoRow('gst_number_label'.tr,
                            pawnbroker.gstNumber ?? 'not_available'.tr),
                        _buildInfoRow(
                            'experience_label'.tr, pawnbroker.experience),
                        _buildInfoRow('status_label'.tr, pawnbroker.status),
                        _buildInfoRow('created_on_label'.tr, createdDate),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('documents_title'.tr,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    _buildDocumentSection('shop_license_label'.tr,
                        controller.shopLicenseUrl, context),
                    _buildDocumentSection(
                        'id_proof_label'.tr, controller.idProofUrl, context),
                    Obx(() {
                      if (controller.shopLicenseUrl.value == null &&
                          controller.idProofUrl.value == null &&
                          controller.shopPhotoUrls.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text('no_documents_uploaded_pawnbroker'.tr,
                              style: TextStyle(color: Colors.grey)),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    const SizedBox(height: 8),
                    const SizedBox(height: 20),
                    _buildShopImagesSection(context),
                    const SizedBox(height: 24),
                    Text('review_action_title'.tr,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.rejectionReasonController,
                      decoration: InputDecoration(
                        labelText: 'rejection_reason_hint'.tr,
                        border: OutlineInputBorder(),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              )),
                        ),
                      ],
                    ),
                    Obx(() => controller.isSubmitting.value
                        ? const Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Center(child: CircularProgressIndicator()))
                        : const SizedBox(height: 30)),
                  ],
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> rows) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            ...rows,
          ],
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

  Widget _buildShopImagesSection(BuildContext context) {
    return Obx(() {
      if (controller.shopPhotoUrls.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('shop_photos_title'.tr,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  itemCount: controller.shopPhotoUrls.length,
                  controller: PageController(
                      initialPage: controller.currentImageIndex.value),
                  onPageChanged: (index) =>
                      controller.currentImageIndex.value = index,
                  itemBuilder: (context, index) {
                    return _buildDocumentPreview(
                        controller.shopPhotoUrls[index], context);
                  },
                ),
                if (controller.shopPhotoUrls.length > 1)
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.black54),
                      onPressed: controller.prevImage,
                    ),
                  ),
                if (controller.shopPhotoUrls.length > 1)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios,
                          color: Colors.black54),
                      onPressed: controller.nextImage,
                    ),
                  ),
              ],
            ),
          ),
          if (controller.shopPhotoUrls.length > 1)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'image_counter'.trParams({
                    'current':
                        (controller.currentImageIndex.value + 1).toString(),
                    'total': controller.shopPhotoUrls.length.toString(),
                  }),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      );
    });
  }

  Widget _buildDocumentSection(
      String title, RxnString docUrl, BuildContext context) {
    return Obx(() {
      final url = docUrl.value;
      if (url == null || url.isEmpty) {
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
        Get.dialog(
          Dialog(
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
          ),
        );
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
}
