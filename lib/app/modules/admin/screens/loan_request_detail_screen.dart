import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:bidmygoldflutter/app/data/models/loan_request_model.dart';
import 'package:bidmygoldflutter/app/modules/admin/controllers/loan_monitoring_controller.dart';
// Import photo_view if using for image zoom
// import 'package:photo_view/photo_view.dart';
// import 'package:photo_view/photo_view_gallery.dart';
// Import url_launcher if using to open links
import 'package:url_launcher/url_launcher.dart';

// Convert to StatefulWidget to manage TextEditingController
class LoanRequestDetailScreen extends StatefulWidget {
  const LoanRequestDetailScreen({Key? key}) : super(key: key);

  @override
  _LoanRequestDetailScreenState createState() =>
      _LoanRequestDetailScreenState();
}

class _LoanRequestDetailScreenState extends State<LoanRequestDetailScreen> {
  // State for the admin note input
  late final TextEditingController _noteController;
  final LoanMonitoringController controller = Get.find();
  late final LoanRequestModel request;

  @override
  void initState() {
    super.initState();
    request = Get.arguments as LoanRequestModel;
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final createdDate = request.createdAt != null
        ? dateFormat.format(request.createdAt.toDate())
        : 'N/A';
    final userName = controller.userNames[request.userId] ?? 'Loading...';
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: Text('Loan Request: ${request.id.substring(0, 8)}...'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(context, request.status),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              'User Information',
              Column(
                children: [
                  _buildInfoRow('Name', userName),
                  _buildInfoRow(
                    'User ID', request.userId,
                    // Optional: Add button to navigate to user detail
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new,
                          size: 18, color: Colors.blue),
                      tooltip: 'View User Details',
                      onPressed: () {
                        // Fetch full UserModel first if needed, then navigate
                        // Get.toNamed(Routes.USER_PROFILE_DETAIL, arguments: userModel);
                        Get.snackbar('Info',
                            'Navigate to user profile (Not implemented yet)');
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              'Loan Details',
              Column(
                children: [
                  _buildInfoRow('Jewel Type', request.jewelType ?? 'N/A'),
                  _buildInfoRow('Weight', '${request.jewelWeight}g'),
                  _buildInfoRow('Purity', request.jewelPurity ?? 'N/A'),
                  _buildInfoRow('Requested Amount',
                      currencyFormat.format(request.loanAmount)),
                  _buildInfoRow('Tenure', '${request.loanTenure} months'),
                  _buildInfoRow('Purpose', request.loanPurpose ?? 'N/A'),
                  _buildInfoRow('Description', request.description ?? 'N/A'),
                  _buildInfoRow('Created On', createdDate),
                  // Add other relevant fields like assigned pawnbroker if available
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildPhotoGallery(
                context, request.jewelPhotoUrls, request.jewelVideoUrl),
            const SizedBox(height: 32),
            // Add Admin Actions Section
            _buildAdminActionsSection(context),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets (Consider moving to shared location) ---

  Widget _buildStatusCard(BuildContext context, String? status) {
    status = status?.toLowerCase() ?? 'unknown';
    Color color;
    IconData icon;
    String text = status.capitalizeFirst ?? status;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending_outlined;
        break;
      case 'bidding':
        color = Colors.teal;
        icon = Icons.gavel;
        break;
      case 'approved':
        color = Colors.blue;
        icon = Icons.thumb_up_alt_outlined;
        break;
      case 'active':
        color = Colors.green;
        icon = Icons.local_atm_outlined;
        break;
      case 'completed':
        color = Colors.purple;
        icon = Icons.check_circle_outline;
        break;
      case 'rejected':
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
        break;
    }

    return Card(
      color: color.withOpacity(0.1),
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Text(
              'Status: $text',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, Widget content) {
    return Card(
      margin: EdgeInsets.zero,
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

  Widget _buildInfoRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildPhotoGallery(
      BuildContext context, List<String> photoUrls, String? videoUrl) {
    if (photoUrls.isEmpty && videoUrl == null) {
      return const SizedBox.shrink();
    }
    return _buildInfoCard(
      context,
      'Jewel Media',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photoUrls.isNotEmpty)
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: photoUrls.length,
                itemBuilder: (context, index) {
                  final url = photoUrls[index];
                  return GestureDetector(
                    onTap: () => _openMediaDialog(context, url, isVideo: false),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                    ? child
                                    : const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2)),
                            errorBuilder: (context, error, stack) =>
                                const Center(
                                    child: Icon(Icons.broken_image,
                                        color: Colors.grey)),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (videoUrl != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.video_library_outlined, size: 18),
              label: const Text('View Video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColorLight,
                foregroundColor: Theme.of(context).primaryColorDark,
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () =>
                  _openMediaDialog(context, videoUrl, isVideo: true),
            ),
          ]
        ],
      ),
    );
  }

  // Function to open media (image or video link)
  void _openMediaDialog(BuildContext context, String url,
      {bool isVideo = false}) {
    // Option 1: Simple Dialog with Link
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isVideo ? 'Video URL' : 'Image URL'),
        content: SelectableText(url),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          TextButton(
              onPressed: () async {
                final uri = Uri.tryParse(url);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  Get.snackbar('Error', 'Could not open link');
                }
              },
              child: const Text('Open Link')),
        ],
      ),
    );

    // Option 2: Use photo_view for images (requires package)
    /* if (!isVideo) {
      Get.dialog(Dialog(
        child: SizedBox(
          width: Get.width * 0.9,
          height: Get.height * 0.7,
          child: PhotoView(
            imageProvider: NetworkImage(url),
            loadingBuilder: (context, event) => const Center(child: CircularProgressIndicator()),
            errorBuilder: (context, error, stackTrace) => const Center(child: Text('Could not load image')),
          ),
        ),
      ));
    } */

    // Option 3: Use video_player for video (requires package, more complex)
    /* if (isVideo) { ... } */
  }

  // --- Admin Actions Section ---
  Widget _buildAdminActionsSection(BuildContext context) {
    // Determine available actions based on current status
    final currentStatus = request.status.toLowerCase();
    bool canApprove = currentStatus == 'pending' || currentStatus == 'bidding';
    bool canReject =
        currentStatus != 'rejected' && currentStatus != 'completed';
    bool canComplete = currentStatus == 'active'; // Or maybe 'approved'?

    // Avoid showing actions if already completed or rejected?
    if (currentStatus == 'completed' || currentStatus == 'rejected') {
      return const SizedBox.shrink(); // Or show a message
    }

    return _buildInfoCard(
      context,
      'Admin Actions',
      Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Admin Note (Optional)',
                  hintText:
                      'Enter reason for status change or internal note...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                enabled:
                    !controller.isSubmitting.value, // Disable while submitting
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10.0, // Horizontal space between buttons
                runSpacing: 10.0, // Vertical space between rows
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  if (canApprove)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.white),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () => _updateStatus('approved'),
                    ),
                  if (canReject)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cancel_outlined,
                          color: Colors.white),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () => _updateStatus('rejected'),
                    ),
                  if (canComplete)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.done_all_outlined,
                          color: Colors.white),
                      label: const Text('Mark Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () => _updateStatus('completed'),
                    ),
                  // Add more status buttons if needed (e.g., 'Set to Bidding')
                ],
              ),
              if (controller.isSubmitting.value)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
            ],
          )),
    );
  }

  // Helper to call controller update method
  void _updateStatus(String newStatus) {
    // Optionally add confirmation dialog
    controller.updateLoanStatus(request.id, newStatus,
        note: _noteController.text.trim());
    // Optionally clear note after submission
    // _noteController.clear();
    // Optionally navigate back or refresh state after update (controller might handle this)
  }
}
