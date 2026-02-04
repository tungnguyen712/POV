import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? _selectedAge;
  final Set<String> _interests = <String>{};

  final List<String> _ageGroups = <String>[
    '0-12 (Kid)',
    '13-17 (Teen)',
    '18-59 (Adult)',
    '60+ (Senior)',
  ];

  final List<String> _interestOptions = <String>[
    'History',
    'Architecture',
    'Nature',
    'Art',
    'Food',
    'Sports',
    'Culture',
    'Photography',
    'Adventure',
    'Music',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to\nLandmark Identify',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Let's personalize your experience",
                      style: TextStyle(
                        fontSize: 14.5,
                        color: Color(0xFF6A6A6A),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Age Group *',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B3B3B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final age in _ageGroups) ...[
                      _AgeOptionCard(
                        label: age,
                        selected: _selectedAge == age,
                        onTap: () {
                          setState(() {
                            _selectedAge = age;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 8),
                    const Text(
                      'Interests (select multiple)',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B3B3B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _interestOptions.map((interest) {
                        final isSelected = _interests.contains(interest);
                        return ChoiceChip(
                          label: Text(interest),
                          selected: isSelected,
                          onSelected: (value) {
                            setState(() {
                              if (value) {
                                _interests.add(interest);
                              } else {
                                _interests.remove(interest);
                              }
                            });
                          },
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF7ADBCF)
                                  : const Color(0xFFE0E0E0),
                            ),
                          ),
                          selectedColor: const Color(0xFFDFF9F6),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFF5B5B5B),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (_selectedAge == null)
                            ? null
                            : () {
                                Navigator.pushReplacementNamed(context, '/scan');
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedAge == null
                              ? const Color(0xFFE5E5E5)
                              : const Color(0xFF7ADBCF),
                          foregroundColor: _selectedAge == null
                              ? const Color(0xFF9A9A9A)
                              : const Color(0xFF1B1B1B),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AgeOptionCard extends StatelessWidget {
  const _AgeOptionCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFDFF9F6),
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.06),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: const Color(0xFF6C6C6C)),
                  color: selected ? const Color(0xFF7ADBCF) : Colors.white,
                ),
                child: selected
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E2E2E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

