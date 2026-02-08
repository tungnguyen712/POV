import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? _selectedAge;
  final Set<String> _interests = <String>{};

  bool _saving = false;
  String? _error;

  SupabaseClient get _sb => Supabase.instance.client;

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

  String _prettyError(Object e) {
    if (e is AuthException) return e.message;
    return e.toString();
  }

  Future<void> _saveAndContinue() async {
    if (_selectedAge == null) return;

    final user = _sb.auth.currentUser;
    if (user == null) {
      setState(() => _error = 'Please log in again.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await _sb.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'age_group': _selectedAge,
        'interest': _interests.isEmpty ? null : _interests.join(', '),
        'onboarding_done': true,
      });

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/scan');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _prettyError(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ===== Match LoginScreen typography/colors =====
  static const Color _titleColor = Color(0xFF363E44);
  static const Color _muted = Color(0xFF9CA3AF);

  static const TextStyle _titleTilt = TextStyle(
    color: _titleColor,
    fontFamily: 'Tilt Warp',
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.22,
  );

  static const TextStyle _subtitleComfortaa = TextStyle(
    color: _titleColor,
    fontFamily: 'Comfortaa',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.33,
  );

  static const TextStyle _helperComfortaa = TextStyle(
    color: _muted,
    fontFamily: 'Comfortaa',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  static const TextStyle _labelComfortaa = TextStyle(
    color: _titleColor,
    fontFamily: 'Comfortaa',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.33,
  );

  static const TextStyle _buttonComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  @override
  Widget build(BuildContext context) {
    final canContinue = _selectedAge != null && !_saving;

    return Scaffold(
      backgroundColor: Colors.white,
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
                      style: _titleTilt,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Let's personalize your experience",
                      style: _helperComfortaa,
                    ),
                    const SizedBox(height: 22),

                    const Text('Age Group *', style: _labelComfortaa),
                    const SizedBox(height: 12),
                    for (final age in _ageGroups) ...[
                      _AgeOptionCard(
                        label: age,
                        selected: _selectedAge == age,
                        onTap: () => setState(() => _selectedAge = age),
                      ),
                      const SizedBox(height: 10),
                    ],

                    const SizedBox(height: 8),
                    const Text('Interests (select multiple)',
                        style: _labelComfortaa),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _interestOptions.map((interest) {
                        final isSelected = _interests.contains(interest);
                        return ChoiceChip(
                          label: Text(
                            interest,
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 14,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF1E1E1E)
                                  : const Color(0xFF5B5B5B),
                              height: 1.2,
                            ),
                          ),
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
                        );
                      }).toList(),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontFamily: 'Comfortaa',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.33,
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: canContinue ? _saveAndContinue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canContinue
                              ? const Color(0xFF7ADBCF)
                              : const Color(0xFFE5E5E5),
                          foregroundColor: canContinue
                              ? const Color(0xFF1B1B1B)
                              : const Color(0xFF9A9A9A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF1B1B1B),
                                ),
                              )
                            : const Text('Get Started', style: _buttonComfortaa),
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

  static const Color _titleColor = Color(0xFF363E44);

  static const TextStyle _ageText = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: _titleColor,
    height: 1.33,
  );

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
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(label, style: _ageText),
            ],
          ),
        ),
      ),
    );
  }
}
