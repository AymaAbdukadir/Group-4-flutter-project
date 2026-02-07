import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../data/admin_tour_service.dart';
import '../../data/tour_service.dart';
import '../../data/tour_model.dart';
import '../../config/constants.dart';
import '../tours/tour_controller.dart';

class EditTourScreen extends ConsumerStatefulWidget {
  final String tourId;

  const EditTourScreen({super.key, required this.tourId});

  @override
  ConsumerState<EditTourScreen> createState() => _EditTourScreenState();
}

class _EditTourScreenState extends ConsumerState<EditTourScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _maxGroupSizeController = TextEditingController();
  final _summaryController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _difficulty = 'easy';
  bool _isLoading = false;
  bool _isInitialized = false;
  XFile? _imageFile;
  String? _currentImageUrl;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _maxGroupSizeController.dispose();
    _summaryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeForm(Tour tour) {
    if (_isInitialized) return;

    _nameController.text = tour.name;
    _priceController.text = tour.price.toString();
    _durationController.text = tour.duration.toString();
    _maxGroupSizeController.text = tour.maxGroupSize.toString();
    _summaryController.text = tour.summary;
    _descriptionController.text = tour.description ?? '';
    _currentImageUrl = tour.imageCover;
    _difficulty = tour.difficulty;

    _isInitialized = true;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final tourData = {
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'duration': int.parse(_durationController.text),
        'maxGroupSize': int.parse(_maxGroupSizeController.text),
        'difficulty': _difficulty,
        'summary': _summaryController.text,
        'description': _descriptionController.text,
      };

      await ref.read(adminTourServiceProvider).updateTour(
        widget.tourId, 
        tourData,
        imagePath: _imageFile?.path,
      );
      ref.invalidate(toursProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tour updated successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteTour() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Tour'),
          content: const Text('Are you sure you want to delete this tour? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await ref.read(adminTourServiceProvider).deleteTour(widget.tourId);
      ref.invalidate(toursProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tour deleted successfully')),
        );
        context.go('/admin');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text('Edit Tour'),
        backgroundColor: const Color(0xFF55C57A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTour,
            tooltip: 'Delete Tour',
          ),
        ],
      ),
      body: FutureBuilder<Tour>(
        future: ref.read(tourServiceProvider).getTour(widget.tourId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 10),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Tour not found'));
          }

          _initializeForm(snapshot.data!);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Tour Name',
                  icon: Icons.tour,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tour name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _priceController,
                  label: 'Price (USD)',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _durationController,
                        label: 'Duration (days)',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _maxGroupSizeController,
                        label: 'Max Group Size',
                        icon: Icons.people,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDifficultyDropdown(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _summaryController,
                  label: 'Summary',
                  icon: Icons.short_text,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a summary';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description (Optional)',
                  icon: Icons.description,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                _buildImagePicker(),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update Tour',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDifficultyDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        value: _difficulty,
        decoration: const InputDecoration(
          labelText: 'Difficulty',
          prefixIcon: Icon(Icons.trending_up),
          border: InputBorder.none,
        ),
        items: ['easy', 'medium', 'difficult'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value.toUpperCase()),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _difficulty = newValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tour Cover Image',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? Image.network(
                            _imageFile!.path,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(_imageFile!.path),
                            fit: BoxFit.cover,
                          ),
                  )
                : _currentImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          '${AppConstants.toursImageUrl}/$_currentImageUrl',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, size: 50, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text('Image not found', style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('Select Image', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
          ),
        ),
        if (_imageFile != null)
          TextButton.icon(
            onPressed: () => setState(() => _imageFile = null),
            icon: const Icon(Icons.refresh, color: Color(0xFF55C57A)),
            label: const Text('Reset to Current Image', style: TextStyle(color: Color(0xFF55C57A))),
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }
}
