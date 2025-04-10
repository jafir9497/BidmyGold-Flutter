import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bidmygoldflutter/app/core/theme/app_theme.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Section
          _buildSectionTitle('Language'),
          Card(
            elevation: 0,
            color: Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() => Column(
              children: [
                _buildLanguageOption('English', controller.selectedLanguage.value == 'English'),
                const Divider(height: 1),
                _buildLanguageOption('हिंदी', controller.selectedLanguage.value == 'हिंदी'),
              ],
            )),
          ),
          const SizedBox(height: 24),

          // Support Section
          _buildSectionTitle('Support'),
          Card(
            elevation: 0,
            color: Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  'Contact Support',
                  Icons.support_agent_rounded,
                  onTap: controller.contactSupport,
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  'Privacy Policy',
                  Icons.privacy_tip_rounded,
                  onTap: controller.openPrivacyPolicy,
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  'Terms & Conditions',
                  Icons.description_rounded,
                  onTap: controller.openTermsConditions,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // App Info Section
          _buildSectionTitle('App Info'),
          Card(
            elevation: 0,
            color: Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() => _buildMenuItem(
              'Version',
              Icons.info_outline_rounded,
              trailing: controller.appVersion.value,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.subtitleColor,
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, bool isSelected) {
    return ListTile(
      onTap: () => controller.changeLanguage(language),
      title: Text(
        language,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: AppTheme.textColor,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.primaryColor,
            )
          : null,
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon, {
    VoidCallback? onTap,
    String? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: AppTheme.primaryColor,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: AppTheme.textColor,
        ),
      ),
      trailing: trailing != null
          ? Text(
              trailing,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.subtitleColor,
              ),
            )
          : const Icon(Icons.chevron_right_rounded),
    );
  }
}
