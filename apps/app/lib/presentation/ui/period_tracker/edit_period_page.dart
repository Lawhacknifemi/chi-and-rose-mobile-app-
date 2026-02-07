import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/presentation/providers/flow_provider.dart';
import 'package:flutter_app/composition_root/repositories/flow_repository.dart' hide flowSettingsProvider;

class EditPeriodPage extends ConsumerStatefulWidget {
  const EditPeriodPage({super.key});

  @override
  ConsumerState<EditPeriodPage> createState() => _EditPeriodPageState();
}

class _EditPeriodPageState extends ConsumerState<EditPeriodPage> {
  // State
  int _periodDuration = 4;
  int _cycleLength = 28;
  DateTime _selectedDate = DateTime.now();
  String _selectedMood = 'Neutral'; // Default mood
  final List<String> _selectedSymptoms = [];
  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
  }

  void _initializeFromSettings(Map<String, dynamic> settings) {
    if (_isInitialized) return;
    setState(() {
      _periodDuration = settings['averagePeriodLength'] ?? 4;
      _cycleLength = settings['averageCycleLength'] ?? 28;
      if (settings['lastPeriodStart'] != null) {
        _selectedDate = DateTime.parse(settings['lastPeriodStart'].toString());
      }
      _isInitialized = true;
    });
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final repository = ref.read(flowRepositoryProvider);
      
      // Update settings
      await repository.updateSettings(
        averageCycleLength: _cycleLength,
        averagePeriodLength: _periodDuration,
      );

      // Log period start (using the selected date)
      await repository.logPeriodStart(_selectedDate);

      // Log daily entry if mood/symptoms selected
      if (_selectedMood != 'Neutral' || _selectedSymptoms.isNotEmpty) {
        await repository.logDailyEntry(
          date: DateTime.now(),
          mood: _selectedMood,
          symptoms: _selectedSymptoms,
        );
      }

      // Invalidate providers to refresh UI
      ref.invalidate(flowSettingsProvider);
      ref.invalidate(calendarDataProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving changes: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Theme Colors
  final Color _primaryColor = const Color(0xFFE91E63); // Berry Pink
  final Color _bgColor = const Color(0xFFFDF8F9); // Soft Blush
  final Color _cardColor = Colors.white;

  // Mock Data
  final List<Map<String, dynamic>> _moods = [
    {'name': 'Neutral', 'icon': Icons.sentiment_neutral},
    {'name': 'Happy', 'icon': Icons.sentiment_satisfied_alt},
    {'name': 'Sad', 'icon': Icons.sentiment_dissatisfied},
    {'name': 'Sensitive', 'icon': Icons.sentiment_very_dissatisfied},
  ];

  final List<Map<String, dynamic>> _symptoms = [
    {'name': 'Headache', 'icon': Icons.healing, 'bg': const Color(0xFFFFEBEE)},
    {'name': 'Fatigue', 'icon': Icons.battery_alert, 'bg': const Color(0xFFFCE4EC)},
    {'name': 'Cramps', 'icon': Icons.spa, 'bg': const Color(0xFFF3E5F5)},
    {'name': 'Bloating', 'icon': Icons.water_drop, 'bg': const Color(0xFFE0F7FA)},
  ];

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(flowSettingsProvider);

    return settingsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (settings) {
        if (settings != null) {
          _initializeFromSettings(settings);
        }

        return Scaffold(
          backgroundColor: _bgColor,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Column(
                          children: [
                            _buildCycleInfoCard(),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildCalendarCard()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildMoodsCard()),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSymptomsCard(),
                            const SizedBox(height: 100), // Space for FAB
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Floating CTA
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 24,
                  child: SizedBox(
                    height: 56, // Full height pill
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: _primaryColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: _isSaving 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
            ),
          ),
          const Text('Edit Period', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildCycleInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildStepperRow('Period Duration', _periodDuration, (v) => setState(() => _periodDuration = v)),
          const Divider(height: 32, color: Color(0xFFF8BBD0)), // Very subtle divider
          _buildStepperRow('Cycle Length', _cycleLength, (v) => setState(() => _cycleLength = v)),
        ],
      ),
    );
  }

  Widget _buildStepperRow(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _primaryColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(label.contains("Period") ? Icons.water_drop : Icons.loop, color: _primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
        
        // Pill Stepper
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: _primaryColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              _buildStepperBtn(Icons.remove, () => onChanged(value - 1)),
              Container(
                constraints: const BoxConstraints(minWidth: 60),
                alignment: Alignment.center,
                child: Text('$value days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              _buildStepperBtn(Icons.add, () => onChanged(value + 1)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStepperBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
       borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: _primaryColor.withOpacity(0.1), // Soft pink
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: _primaryColor),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Last Period", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: ["S","M","T","W","T","F","S"].map((e) => Text(e, style:  TextStyle(fontSize: 10, color: Colors.grey[600]))).toList()),
                _buildCalRow(), 
              ],
            ),
          ),
           const SizedBox(height: 8),
           SizedBox(
             width: double.infinity,
             height: 36,
             child: TextButton(
               onPressed: () => _pickDate(context),
               style: TextButton.styleFrom(
                 backgroundColor: _primaryColor.withOpacity(0.1),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               ),
               child: Text(
                 "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", // Show selected date
                 style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 12)
                ),
             ),
           )
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  // Dynamically show the week of the selected date
  Widget _buildCalRow() {
    // Find the Sunday of the week containing _selectedDate
    DateTime sunday = _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7));
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        DateTime dayDate = sunday.add(Duration(days: index));
        bool isSelected = dayDate.year == _selectedDate.year && dayDate.month == _selectedDate.month && dayDate.day == _selectedDate.day;
        
        return Container(
          width: 20, height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? _primaryColor : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            "${dayDate.day}", 
            style: TextStyle(
              fontSize: 10, 
              color: isSelected ? Colors.white : Colors.black87, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMoodsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Moods", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _moods.map((m) => _buildMoodItem(m)).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildMoodItem(Map<String, dynamic> m) {
    bool isSelected = m['name'] == _selectedMood;
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = m['name']),
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isSelected ? _primaryColor.withOpacity(0.2) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? _primaryColor : Colors.grey.shade200),
            ),
            child: Icon(m['icon'], color: isSelected ? _primaryColor : Colors.grey[400], size: 20),
          ),
          const SizedBox(height: 4),
          Text(m['name'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSymptomsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Add Symptoms", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ..._symptoms.map((s) => _buildSymptomRow(s)),
        ],
      ),
    );
  }

  Widget _buildSymptomRow(Map<String, dynamic> data) {
    bool isSelected = _selectedSymptoms.contains(data['name']);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) _selectedSymptoms.remove(data['name']);
            else _selectedSymptoms.add(data['name']);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _primaryColor.withOpacity(0.05) : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? _primaryColor : Colors.transparent),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: (data['bg'] as Color).withOpacity(0.5), shape: BoxShape.circle),
                child: Icon(data['icon'], color: _primaryColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(data['name'], style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? _primaryColor : Colors.black87))),
              Icon(isSelected ? Icons.check_circle : Icons.add_circle_outline, color: isSelected ? _primaryColor : Colors.grey[300], size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
