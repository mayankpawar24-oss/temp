import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maternal_infant_care/data/models/fertility_profile_model.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';
import 'package:maternal_infant_care/presentation/viewmodels/auth_provider.dart';
import 'package:maternal_infant_care/presentation/pages/main_navigation_shell.dart';

class TryingToConceiveSetupPage extends ConsumerStatefulWidget {
  const TryingToConceiveSetupPage({super.key});

  @override
  ConsumerState<TryingToConceiveSetupPage> createState() =>
      _TryingToConceiveSetupPageState();
}

class _TryingToConceiveSetupPageState
    extends ConsumerState<TryingToConceiveSetupPage> {
  DateTime? _lmpDate;
  bool _cycleRegular = true;
  bool _isLoading = false;
  final TextEditingController _cycleLengthController = TextEditingController();

  @override
  void dispose() {
    _cycleLengthController.dispose();
    super.dispose();
  }

  Future<void> _selectLmpDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 28)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _lmpDate = picked;
      });
    }
  }

  Future<void> _saveSetup() async {
    final cycleLength = int.tryParse(_cycleLengthController.text.trim());

    if (_lmpDate == null || cycleLength == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide all required details.')),
      );
      return;
    }

    if (cycleLength < 20 || cycleLength > 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Average cycle length should be between 20 and 60 days.')),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authenticated user found.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(fertilityProfileRepositoryProvider);
      final profile = FertilityProfileModel(
        userId: user['id'] as String,
        lmpDate: _lmpDate!,
        avgCycleLength: cycleLength,
        cycleRegular: _cycleRegular,
      );
      await repo.upsertProfile(profile);

      final authService = ref.read(authServiceProvider);
      await authService.updateUserMetadata({
        'start_date':
            DateTime.utc(_lmpDate!.year, _lmpDate!.month, _lmpDate!.day)
                .toIso8601String(),
      });

      ref.read(authStateProvider.notifier).setUser(authService.currentUser);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving setup: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fertility Setup'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 72,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Trying to Conceive',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Provide your cycle details to personalize your fertility tracking experience.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              InkWell(
                onTap: () => _selectLmpDate(context),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Last Menstrual Period Start Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _lmpDate == null
                        ? 'Select Date'
                        : DateFormat('MMMM dd, yyyy').format(_lmpDate!),
                    style: TextStyle(
                      color: _lmpDate == null
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _cycleLengthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Average Cycle Length (days)',
                  prefixIcon: Icon(Icons.timelapse_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _cycleRegular,
                title: const Text('Cycle Regularity'),
                subtitle:
                    const Text('Turn off if your cycles vary significantly'),
                onChanged: (val) => setState(() => _cycleRegular = val),
              ),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: _isLoading ? null : _saveSetup,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Complete Setup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
