import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../models/appliance.dart';
import '../models/appliance_category.dart';
import '../models/built_in_appliances.dart';
import '../providers/appliance_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class AddApplianceFormScreen extends StatefulWidget {
  final Appliance? applianceToEdit;

  const AddApplianceFormScreen({
    super.key,
    this.applianceToEdit,
  });

  @override
  State<AddApplianceFormScreen> createState() => _AddApplianceFormScreenState();
}

class _AddApplianceFormScreenState extends State<AddApplianceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _wattageController = TextEditingController();
  final _hoursController = TextEditingController();

  ApplianceCategory _selectedCategory = ApplianceCategory.kitchen;
  String _timeUnit = 'Hours'; // 'Hours' or 'Minutes'
  bool _isLoading = false;
  int _currentPage = 0;
  static const int _itemsPerPage = 10;
  bool get _isEditing => widget.applianceToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.applianceToEdit!.name;
      _wattageController.text = widget.applianceToEdit!.wattage.toString();
      _hoursController.text = widget.applianceToEdit!.hoursPerDay.toString();
      _selectedCategory = widget.applianceToEdit!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wattageController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  List<Appliance> _getPaginatedAppliances() {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return BuiltInAppliances.all.sublist(
      startIndex,
      endIndex > BuiltInAppliances.all.length ? BuiltInAppliances.all.length : endIndex,
    );
  }

  int _getTotalPages() {
    return (BuiltInAppliances.all.length / _itemsPerPage).ceil();
  }

  Future<void> _saveAppliance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final applianceProvider = Provider.of<ApplianceProvider>(context, listen: false);

      // Convert time to hours if needed
      double hoursPerDay = double.parse(_hoursController.text.trim());
      if (_timeUnit == 'Minutes') {
        hoursPerDay = hoursPerDay / 60.0; // Convert minutes to hours
      }

      if (_isEditing) {
        // Update existing appliance
        final updatedAppliance = widget.applianceToEdit!.copyWith(
          name: _nameController.text.trim(),
          category: _selectedCategory,
          wattage: int.parse(_wattageController.text.trim()),
          hoursPerDay: hoursPerDay,
        );

        await applianceProvider.updateAppliance(updatedAppliance);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appliance updated successfully!')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        // Add new appliance
        final appliance = Appliance.create(
          id: '${Provider.of<AuthProvider>(context, listen: false).user!.uid}_${DateTime.now().millisecondsSinceEpoch}',
          name: _nameController.text.trim(),
          category: _selectedCategory,
          wattage: int.parse(_wattageController.text.trim()),
          userId: Provider.of<AuthProvider>(context, listen: false).user!.uid,
          hoursPerDay: hoursPerDay,
        );

        await applianceProvider.addAppliance(appliance);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appliance added successfully!')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving appliance: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showBuiltInApplianceDialog(Appliance builtInAppliance) async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _BuiltInApplianceDialog(appliance: builtInAppliance, settingsProvider: settingsProvider),
    );

    if (result != null && mounted) {
      setState(() => _isLoading = true);

      try {
        final applianceProvider = Provider.of<ApplianceProvider>(context, listen: false);

        // Create custom appliance based on built-in with user-specified time
        final customAppliance = Appliance.create(
          id: '${Provider.of<AuthProvider>(context, listen: false).user!.uid}_${DateTime.now().millisecondsSinceEpoch}',
          name: builtInAppliance.name,
          category: builtInAppliance.category,
          wattage: builtInAppliance.wattage,
          userId: Provider.of<AuthProvider>(context, listen: false).user!.uid,
          hoursPerDay: result['hoursPerDay'],
          icon: builtInAppliance.icon,
        );

        await applianceProvider.addAppliance(customAppliance);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${builtInAppliance.name} added successfully!')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding appliance: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkGradient
                  : AppColors.primaryGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          _isEditing ? settingsProvider.getLocalizedText('Edit Appliance') : settingsProvider.getLocalizedText('Add New Appliance'),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance spacing
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Content
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Built-in Appliances Section
                            Text(
                              settingsProvider.getLocalizedText('Quick Add (Built-in Appliances)'),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Built-in Appliances Grid
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.2,
                              ),
                              itemCount: _getPaginatedAppliances().length,
                              itemBuilder: (context, index) {
                                final appliance = _getPaginatedAppliances()[index];
                                return _buildBuiltInApplianceCard(appliance, settingsProvider);
                              },
                            ),

                            // Pagination Controls
                            if (BuiltInAppliances.all.length > _itemsPerPage)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                                      icon: Icon(
                                        Icons.chevron_left,
                                        color: _currentPage > 0 ? AppColors.primaryBlue : Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '${_currentPage + 1} / ${(_getTotalPages())}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textDark,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _currentPage < _getTotalPages() - 1 ? () => setState(() => _currentPage++) : null,
                                      icon: Icon(
                                        Icons.chevron_right,
                                        color: _currentPage < _getTotalPages() - 1 ? AppColors.primaryBlue : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 32),

                            // Custom Appliance Section
                            Text(
                              settingsProvider.getLocalizedText('Add Custom Appliance'),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Custom Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Appliance Name
                                  TextFormField(
                                    controller: _nameController,
                                    style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                                    decoration: InputDecoration(
                                      labelText: settingsProvider.getLocalizedText('Appliance Name'),
                                      hintText: settingsProvider.getLocalizedText('e.g., Laptop, Blender'),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[600]! : AppColors.cardLight),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[600]! : AppColors.cardLight),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.primaryBlue),
                                      ),
                                      filled: true,
                                      fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.cardLight,
                                      prefixIcon: Icon(Icons.electrical_services, color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.primaryBlue),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter appliance name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Wattage
                                  TextFormField(
                                    controller: _wattageController,
                                    style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                                    decoration: InputDecoration(
                                      labelText: settingsProvider.getLocalizedText('Wattage (W)'),
                                      hintText: settingsProvider.getLocalizedText('e.g., 100'),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[600]! : AppColors.cardLight),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[600]! : AppColors.cardLight),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.primaryBlue),
                                      ),
                                      filled: true,
                                      fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.cardLight,
                                      prefixIcon: Icon(Icons.flash_on, color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.primaryBlue),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter wattage';
                                      }
                                      final wattage = int.tryParse(value.trim());
                                      if (wattage == null || wattage <= 0) {
                                        return 'Please enter valid wattage';
                                      }
                                      if (wattage > 10000) {
                                        return 'Wattage seems too high (max 10,000W)';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Time Input Row
                                  Row(
                                    children: [
                                      // Time Value
                                      Expanded(
                                        flex: 3,
                                        child: TextFormField(
                                          controller: _hoursController,
                                          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                                          decoration: InputDecoration(
                                            labelText: _timeUnit == 'Hours' ? settingsProvider.getLocalizedText('Hours per Day') : settingsProvider.getLocalizedText('Minutes per Day'),
                                            hintText: _timeUnit == 'Hours' ? settingsProvider.getLocalizedText('e.g., 2.5') : settingsProvider.getLocalizedText('e.g., 30'),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[600]! : AppColors.cardLight),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[600]! : AppColors.cardLight),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.primaryBlue),
                                            ),
                                            filled: true,
                                            fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.cardLight,
                                            prefixIcon: Icon(Icons.schedule, color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.primaryBlue),
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'Please enter time per day';
                                            }
                                            final time = double.tryParse(value.trim());
                                            if (time == null || time < 0) {
                                              return 'Please enter valid time';
                                            }
                                            if (_timeUnit == 'Hours' && time > 24) {
                                              return 'Hours cannot exceed 24 per day';
                                            }
                                            if (_timeUnit == 'Minutes' && time > 1440) {
                                              return 'Minutes cannot exceed 1440 per day';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Time Unit Dropdown
                                      Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField<String>(
                                          initialValue: _timeUnit,
                                          decoration: InputDecoration(
                                            labelText: settingsProvider.getLocalizedText('Unit'),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[600]! : AppColors.cardLight),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[600]! : AppColors.cardLight),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.primaryBlue),
                                            ),
                                            filled: true,
                                            fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.cardLight,
                                          ),
                                          dropdownColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : Colors.white,
                                          items: [
                                            DropdownMenuItem(
                                              value: 'Hours',
                                              child: Text(settingsProvider.getLocalizedText('Hours'), style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                                            ),
                                            DropdownMenuItem(
                                              value: 'Minutes',
                                              child: Text(settingsProvider.getLocalizedText('Minutes'), style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() => _timeUnit = value);
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Category Dropdown
                                  DropdownButtonFormField<ApplianceCategory>(
                                    initialValue: _selectedCategory,
                                    decoration: InputDecoration(
                                      labelText: settingsProvider.getLocalizedText('Category'),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[600]! : AppColors.cardLight),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[600]! : AppColors.cardLight),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.primaryBlue),
                                      ),
                                      filled: true,
                                      fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.cardLight,
                                      prefixIcon: Icon(Icons.category, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.primaryBlue),
                                    ),
                                    dropdownColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : Colors.white,
                                    items: ApplianceCategory.values.map((category) {
                                      return DropdownMenuItem(
                                        value: category,
                                        child: Row(
                                          children: [
                                            Text(category.icon),
                                            const SizedBox(width: 8),
                                            Text(category.displayName, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => _selectedCategory = value);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 32),

                                  // Add Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _saveAppliance,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _isLoading
                                          ? const CircularProgressIndicator(color: Colors.white)
                                          : Text(
                                              _isEditing ? settingsProvider.getLocalizedText('Update Appliance') : settingsProvider.getLocalizedText('Add Appliance'),
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBuiltInApplianceCard(Appliance appliance, SettingsProvider settingsProvider) {
    return GestureDetector(
      onTap: _isLoading ? null : () => _showBuiltInApplianceDialog(appliance),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appliance.icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              appliance.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${appliance.wattage}W',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuiltInApplianceDialog extends StatefulWidget {
  final Appliance appliance;
  final SettingsProvider settingsProvider;

  const _BuiltInApplianceDialog({required this.appliance, required this.settingsProvider});

  @override
  State<_BuiltInApplianceDialog> createState() => _BuiltInApplianceDialogState();
}

class _BuiltInApplianceDialogState extends State<_BuiltInApplianceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _timeController = TextEditingController();
  String _timeUnit = 'Hours';

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return Text(
            '${settingsProvider.getLocalizedText('Set Usage Time for')} ${widget.appliance.name}',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return Text(
                    '${settingsProvider.getLocalizedText('How many')} ${_timeUnit.toLowerCase()} ${settingsProvider.getLocalizedText('per day does this appliance run?')}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textGray,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        labelText: _timeUnit,
                        hintText: _timeUnit == 'Hours' ? 'e.g., 2.5' : 'e.g., 30',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
                        if (value == null || value.trim().isEmpty) {
                          return settingsProvider.getLocalizedText('Required');
                        }
                        final time = double.tryParse(value.trim());
                        if (time == null || time <= 0) {
                          return settingsProvider.getLocalizedText('Invalid');
                        }
                        if (_timeUnit == 'Hours' && time > 24) {
                          return settingsProvider.getLocalizedText('Max 24h');
                        }
                        if (_timeUnit == 'Minutes' && time > 1440) {
                          return settingsProvider.getLocalizedText('Max 1440m');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 80, maxWidth: 120),
                    child: DropdownButtonFormField<String>(
                      initialValue: _timeUnit,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Hours', child: Text('Hours')),
                        DropdownMenuItem(value: 'Minutes', child: Text('Minutes')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _timeUnit = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: AppColors.textGray),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              double hoursPerDay = double.parse(_timeController.text.trim());
              if (_timeUnit == 'Minutes') {
                hoursPerDay = hoursPerDay / 60.0;
              }
              Navigator.pop(context, {'hoursPerDay': hoursPerDay});
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
          ),
          child: Text(
            'Add',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
