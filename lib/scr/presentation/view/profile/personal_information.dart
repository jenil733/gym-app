import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/core/utils/helper/toast_helper.dart';
import 'package:gym/scr/presentation/controller/profile_controller.dart';
import 'package:gym/scr/presentation/widgets/common/common_app_bar.dart';
import 'package:gym/scr/presentation/widgets/common/common_button.dart';
import 'package:image_picker/image_picker.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  late final ProfileController _controller;
  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _genderController;
  late final TextEditingController _locationController;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    _nameController = TextEditingController(text: _controller.userName);
    _mobileController = TextEditingController(text: _controller.phone);
    _genderController = TextEditingController(text: _controller.gender);
    _locationController = TextEditingController(text: _controller.location);
    _selectedImageBytes = _controller.profileImageBytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _genderController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);
    final success = await _controller.updatePersonalInformation(
      userName: _nameController.text.trim(),
      gender: _genderController.text.trim(),
      location: _locationController.text.trim(),
      imageBytes: _selectedImageBytes,
      imageName: _selectedImageName,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);

    if (success) {
      ToastHelper.success('Profile updated', 'Personal information updated');
    } else {
      ToastHelper.error(
        'Update failed',
        _controller.errorMessage ?? 'Unable to update profile',
      );
    }
  }

  Future<void> _changeProfileImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (image == null) {
        return;
      }

      final bytes = await image.readAsBytes();
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = image.name;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ToastHelper.error('Gallery error', 'Unable to open the gallery');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Personal Information'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Basic Details', style: TextHelper.homeTitle2),
              const SizedBox(height: 12),
              _ProfilePhotoCard(
                imageAsset: _controller.profileImageAsset,
                imageBytes: _selectedImageBytes,
                imageUrl: _controller.profileImageUrl,
                nameController: _nameController,
                userLevel: _controller.userLevel,
                onChangePhoto: _changeProfileImage,
              ),
              const SizedBox(height: 14),
              _ProfileTextBox(
                fieldKey: const ValueKey('profile-name-input'),
                icon: Icons.person_rounded,
                label: 'Full Name',
                controller: _nameController,
              ),
              _ProfileTextBox(
                fieldKey: const ValueKey('profile-mobile-input'),
                icon: Icons.call_rounded,
                label: 'Mobile',
                controller: _mobileController,
                readOnly: true,
              ),
              _ProfileTextBox(
                fieldKey: const ValueKey('profile-gender-input'),
                icon: Icons.wc_rounded,
                label: 'Gender',
                controller: _genderController,
              ),
              _ProfileTextBox(
                fieldKey: const ValueKey('profile-location-input'),
                icon: Icons.location_on_rounded,
                label: 'Location',
                controller: _locationController,
              ),
              const SizedBox(height: 8),
              CommonButton(
                key: const ValueKey('profile-save-button'),
                label: _isSaving ? 'Saving...' : 'Save Changes',
                onPressed: _isSaving ? null : _saveDetails,
                height: 52,
                borderRadius: 10,
                fontSize: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePhotoCard extends StatelessWidget {
  const _ProfilePhotoCard({
    required this.imageAsset,
    required this.imageBytes,
    required this.imageUrl,
    required this.nameController,
    required this.userLevel,
    required this.onChangePhoto,
  });

  final String imageAsset;
  final Uint8List? imageBytes;
  final String? imageUrl;
  final TextEditingController nameController;
  final String userLevel;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 82,
                width: 82,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.55),
                    width: 2,
                  ),
                ),
                child: imageBytes != null
                    ? Image.memory(imageBytes!, fit: BoxFit.cover)
                    : imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Image.asset(imageAsset, fit: BoxFit.cover),
                      )
                    : Image.asset(imageAsset, fit: BoxFit.cover),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    onTap: onChangePhoto,
                    borderRadius: BorderRadius.circular(999),
                    child: const SizedBox(
                      height: 30,
                      width: 30,
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.white,
                        size: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: nameController,
                  builder: (context, value, child) {
                    final name = value.text.trim().isEmpty
                        ? 'Your Name'
                        : value.text.trim();
                    return Text(name, style: TextHelper.homeTitle2);
                  },
                ),
                const SizedBox(height: 4),
                Text(userLevel, style: TextHelper.homeSubtitle),
                const SizedBox(height: 10),
                TextButton.icon(
                  key: const ValueKey('profile-change-photo-button'),
                  onPressed: onChangePhoto,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 34),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 17),
                  label: Text(
                    'Change Photo',
                    style: TextHelper.link.copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTextBox extends StatelessWidget {
  const _ProfileTextBox({
    required this.fieldKey,
    required this.icon,
    required this.label,
    required this.controller,
    this.readOnly = false,
  });

  final Key fieldKey;
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              key: fieldKey,
              controller: controller,
              readOnly: readOnly,
              style: TextHelper.fieldText,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextHelper.fieldLabel,
                suffixIcon: readOnly
                    ? const Icon(
                        Icons.lock_rounded,
                        color: AppColors.textLight,
                        size: 18,
                      )
                    : null,
                filled: true,
                fillColor: AppColors.field,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
