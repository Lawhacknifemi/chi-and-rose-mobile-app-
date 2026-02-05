import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/composition_root/repositories/health_repository.dart';
import 'package:flutter_app/router/router.dart';
import 'package:flutter_app/presentation/providers/onboarding_provider.dart';

class PersonalizationPage extends ConsumerStatefulWidget {
  const PersonalizationPage({super.key});

  @override
  ConsumerState<PersonalizationPage> createState() => _PersonalizationPageState();
}

class _PersonalizationPageState extends ConsumerState<PersonalizationPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Selections
  final Set<String> _selectedGoals = {};
  final Set<String> _selectedDiets = {};
  final Set<String> _selectedSensitivities = {};
  final Set<String> _selectedBioData = {}; // For step 4 (Conditions/Symptoms)

  // Options from User Screenshot & Plan
  final List<String> _goalsOptions = [
    'Manage symptoms (e.g., pain, fatigue)',
    'Improve nutrition',
    'Reduce exposure to endocrine disruptors',
    'Support reproductive health',
    'Explore clean beauty & household products',
    'Better sleep quality',
    'Stress management'
  ];

  final List<String> _dietOptions = [
    'None', 'Vegan', 'Vegetarian', 'Pescatarian', 
    'Keto', 'Paleo', 'Gluten-Free', 'Dairy-Free'
  ];

  final List<String> _sensitivityOptions = [
    'None', 'Nuts', 'Shellfish', 'Dairy', 'Soy', 
    'Eggs', 'Gluten', 'Wheat', 'Fragrance'
  ];
  
  // Step 4: Let's call it "Health Conditions" for now based on context
  final List<String> _conditionOptions = [
    'None', 'PCOS', 'Endometriosis', 'Fibroids', 
    'Acne', 'Eczema', 'Thyroid Issues', 'Diabetes'
  ];


  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _skip() {
    _finish();
  }

  Future<void> _finish() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(healthRepositoryProvider).updateProfile(
        goals: _selectedGoals.toList(),
        dietaryPreferences: _selectedDiets.toList(),
        sensitivities: _selectedSensitivities.toList(),
        conditions: _selectedBioData.toList(), 
        symptoms: [], // Collecting these mostly in goals or conditions
      );
      
      await ref.read(onboardingNotifierProvider.notifier).complete();

      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Progress calculation
    final progress = (_currentPage + 1) / 4;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark background matching screen
      body: Stack(
        children: [
          // Background Pattern (Contour)
          Positioned.fill(
            child: Opacity(
              opacity: 0.3, // Adjust visibility of background lines
              child: Image.asset(
                'assets/background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                
                // Progress Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       // Progress
                       Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_currentPage + 1}/4',
                            style: const TextStyle(
                              color: Color(0xFFE91E63), // Pink accent
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Progress Bar
                          Container(
                            height: 4,
                            width: 60, // Fixed width
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                      
                      // Close Button
                      IconButton(
                        onPressed: () {
                           if (context.canPop()) {
                             context.pop();
                           } else {
                             context.go('/');
                           }
                        },
                        icon: const Icon(Icons.close, color: Colors.white, size: 24),
                      )
                    ],
                  ),
                ),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Disable swipe to force button usage
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    children: [
                      _buildPage(
                        title: 'What are your wellness goals?',
                        description: 'Let us know what you would like to achieve with the app so we can personalize your recommendations.',
                        options: _goalsOptions,
                        selectedSet: _selectedGoals,
                      ),
                      _buildPage(
                        title: 'Do you have any dietary preferences?',
                        description: 'Select any diets or eating habits you follow.',
                        options: _dietOptions,
                        selectedSet: _selectedDiets,
                      ),
                       _buildPage(
                        title: 'Do you have any sensitivities?',
                        description: 'Select ingredients you need to avoid.',
                        options: _sensitivityOptions,
                        selectedSet: _selectedSensitivities,
                      ),
                      _buildPage(
                        title: 'Any specific health conditions?',
                        description: 'This helps us flag products that might not be suitable for you.',
                        options: _conditionOptions,
                        selectedSet: _selectedBioData,
                      ),
                    ],
                  ),
                ),

                // Bottom Buttons
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: _isLoading ? null : _skip,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A0F35), // Dark Maroon/Purple
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                              _currentPage == 3 ? 'Finish' : 'Next',
                              style: const TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.normal
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
        ],
      ),
    );
  }

  Widget _buildPage({
    required String title, 
    required String description, 
    required List<String> options,
    required Set<String> selectedSet,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white70,
            height: 1.4,
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 32),
        ...options.map((option) {
          final isSelected = selectedSet.contains(option);
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedSet.remove(option);
                  } else {
                    selectedSet.add(option);
                  }
                });
              },
              child: Row(
                children: [
                  // Custom Radio/Checkbox Circle
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white60,
                        width: 1.5,
                      ),
                      color: isSelected ? Colors.white : Colors.transparent,
                    ),
                    child: isSelected 
                      ? const Center(
                          child: Icon(
                            Icons.check, 
                            size: 16, 
                            color: Colors.black 
                          ),
                        )
                      : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: const TextStyle(
                        color: Colors.white, // Using mostly white text on dark background
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
