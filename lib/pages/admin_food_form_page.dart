import 'dart:io'; // Import for File
import 'package:delivery_app/models/food.dart';
import 'package:delivery_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:provider/provider.dart';

class AdminFoodFormPage extends StatefulWidget {
  final Food? food; // Null if creating new, existing Food object if editing

  const AdminFoodFormPage({super.key, this.food});

  @override
  State<AdminFoodFormPage> createState() => _AdminFoodFormPageState();
}

class _AdminFoodFormPageState extends State<AdminFoodFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  FoodCategory? _selectedCategory;
  List<Addon> _availableAddons = []; // Initialize for addons UI later

  // Controllers for new addon input
  final TextEditingController _addonNameController = TextEditingController();
  final TextEditingController _addonPriceController = TextEditingController();

  File? _selectedImageFile; // To store the selected image file
  String? _initialImagePath; // To store the initial image path if editing

  bool get _isEditing => widget.food != null;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.food?.name ?? '');
    _descriptionController = TextEditingController(text: widget.food?.description ?? '');
    _priceController = TextEditingController(text: widget.food?.price.toString() ?? '');
    _selectedCategory = widget.food?.category;
    if (widget.food != null) {
      _initialImagePath = widget.food!.imagePath; // Store initial image path
      if (widget.food!.avaliableAddons.isNotEmpty) {
        _availableAddons = List<Addon>.from(widget.food!.avaliableAddons.map((addon) => Addon(name: addon.name, price: addon.price)));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addonNameController.dispose(); // Dispose new controllers
    _addonPriceController.dispose(); // Dispose new controllers
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source, imageQuality: 80);

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Photo Library'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSaving = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication error. Please log in again.')),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      // Prepare data for API
      Map<String, dynamic> foodData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'category': _selectedCategory.toString().split('.').last,
        'available_addons': _availableAddons.map((addon) => addon.toJson()).toList(),
      };

      Map<String, dynamic> result;
      if (_isEditing) {
        result = await authService.updateFoodItem(widget.food!.id.toString(), foodData, authService.token!, imageFile: _selectedImageFile);
      } else {
        if (_selectedImageFile == null) {
           if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an image for the new food item.')),
          );
          setState(() {
            _isSaving = false;
          });
          return;
        }
        result = await authService.createFoodItem(foodData, authService.token!, imageFile: _selectedImageFile!);
      }
      
      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? (_isEditing ? 'Food item updated!' : 'Food item created!'))),
        );
        Navigator.pop(context, true); // Pop with true to signal success and trigger refresh
      } else {
        String errorMessage = result['message'] ?? 'An unknown error occurred.';
        if (result['errors'] != null && result['errors'] is Map) {
          Map<String, dynamic> errors = result['errors'];
          String specificErrors = errors.entries.map((entry) => '${entry.key}: ${entry.value.join(', ')}').join('\\n');
          errorMessage += '\\n$specificErrors';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), duration: const Duration(seconds: 5)),
        );
      }

      setState(() {
        _isSaving = false;
      });
    }
  }

  void _addAddon() {
    final String name = _addonNameController.text;
    final double? price = double.tryParse(_addonPriceController.text);

    if (name.isNotEmpty && price != null && price >= 0) {
      setState(() {
        _availableAddons.add(Addon(name: name, price: price));
      });
      _addonNameController.clear();
      _addonPriceController.clear();
    } else {
      // Optionally, show a little snackbar or validation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid addon name and price (must be a positive number).')),
      );
    }
  }

  void _removeAddon(int index) {
    setState(() {
      _availableAddons.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Food Item' : 'Add New Food Item'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              if (_isSaving) const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a name';
                  return null;
                },
                readOnly: _isSaving,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a description';
                  return null;
                },
                readOnly: _isSaving,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price', prefixText: '\$', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a price';
                  if (double.tryParse(value) == null || double.parse(value) < 0) return 'Please enter a valid positive price';
                  return null;
                },
                readOnly: _isSaving,
              ),
              const SizedBox(height: 16),
              Text("Food Image", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: _selectedImageFile != null
                      ? Image.file(_selectedImageFile!, fit: BoxFit.cover, width: double.infinity, height: 150)
                      : (_isEditing && _initialImagePath != null && _initialImagePath!.isNotEmpty
                          ? Image.network(
                              // Assuming the backend will serve images from a URL.
                              // We'll need to construct the full URL based on how Laravel serves them.
                              // For now, let's assume it's an absolute URL or needs a base.
                              // This will need adjustment once the backend part is done.
                              // If _initialImagePath is a local asset path for existing items,
                              // you might need Image.asset(_initialImagePath!)
                              // Let's assume for now it will be a network URL after backend save.
                              // For local assets it would be:
                              // Uri.tryParse(_initialImagePath!)?.isAbsolute ?? false 
                              // ? Image.network(_initialImagePath!) 
                              // : Image.asset(_initialImagePath!)
                              // For simplicity, let's assume _initialImagePath is an asset path for now if not a full URL
                              (Uri.tryParse(_initialImagePath!)?.isAbsolute ?? false)
                                ? _initialImagePath!
                                : (Provider.of<AuthService>(context, listen:false).baseUrl.replaceAll("/api", "") + "/storage/" + _initialImagePath!) , // Adjust base URL and path as needed
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 150,
                              errorBuilder: (context, error, stackTrace) => const Text('Could not load image'),
                            )
                          : const Text('No image selected.')),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.image_search),
                label: const Text('Select Image'),
                onPressed: _isSaving ? null : () => _showImageSourceActionSheet(context),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FoodCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: FoodCategory.values.map((FoodCategory category) {
                  return DropdownMenuItem<FoodCategory>(
                    value: category,
                    child: Text(category.toString().split('.').last),
                  );
                }).toList(),
                onChanged: _isSaving ? null : (FoodCategory? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              Text('Available Addons:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              // UI for adding new addons
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _addonNameController,
                      decoration: const InputDecoration(labelText: 'Addon Name', border: OutlineInputBorder()),
                      readOnly: _isSaving,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _addonPriceController,
                      decoration: const InputDecoration(labelText: 'Addon Price', prefixText: '\$', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      readOnly: _isSaving,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _isSaving ? null : _addAddon,
                    tooltip: 'Add Addon',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_availableAddons.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('No addons defined yet. Tap the + button above to add one.'),
                ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // To disable scrolling within ListView
                itemCount: _availableAddons.length,
                itemBuilder: (context, index) {
                  final addon = _availableAddons[index];
                  return ListTile(
                    title: Text(addon.name),
                    subtitle: Text('\$${addon.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _isSaving ? null : () => _removeAddon(index),
                      tooltip: 'Remove Addon',
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16)
                ),
                child: Text(_isSaving ? 'Saving...' : (_isEditing ? 'Update Food Item' : 'Add Food Item')),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 