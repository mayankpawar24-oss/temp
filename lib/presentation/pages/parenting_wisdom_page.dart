import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_meta_provider.dart';
import 'package:maternal_infant_care/presentation/pages/feeding_tracking_page.dart';
import 'package:maternal_infant_care/presentation/pages/sleep_tracking_page.dart';

class ParentingWisdomPage extends ConsumerWidget {
  const ParentingWisdomPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userMeta = ref.watch(userMetaProvider);
    final feedingAsync = ref.watch(feedingRepositoryProvider);
    final sleepAsync = ref.watch(sleepRepositoryProvider);
    final diaperAsync = ref.watch(diaperRepositoryProvider);
    final growthAsync = ref.watch(growthRepositoryProvider);

    final hasLoggingError =
        feedingAsync is AsyncError || sleepAsync is AsyncError || diaperAsync is AsyncError;
    if (hasLoggingError) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parenting Wisdom'),
      ),
      body: feedingAsync.when(
        data: (feedingRepo) {
          return sleepAsync.when(
            data: (sleepRepo) {
              return diaperAsync.when(
                data: (diaperRepo) {
                  return growthAsync.when(
                    data: (growthRepo) {
                      final birthDate = userMeta.startDate;
                      if (birthDate == null) {
                        return _buildFallbackWithAction(
                          context,
                          'Log daily activities to receive personalized parenting insights.',
                        );
                      }

                      final now = DateTime.now();
                      final ageMonths = _calculateAgeMonths(birthDate, now);
                      final today = DateTime(now.year, now.month, now.day);

                      final feedingCount = feedingRepo.getFeedingsByDate(today).length;
                      final sleepHours = sleepRepo.getTotalSleepHoursByDate(today);
                      final diaperCount = diaperRepo.getDiapersByDate(today).length;
                      final latestGrowth = growthRepo.getLatestGrowth();
                      final hasRecentGrowth = latestGrowth != null && now.difference(latestGrowth.timestamp).inDays <= 30;

                      final hasEnoughData = (feedingCount + diaperCount + (sleepHours > 0 ? 1 : 0)) >= 2 || hasRecentGrowth;
                      if (!hasEnoughData) {
                        return _buildFallbackWithAction(
                          context,
                          'Log daily activities to receive personalized parenting insights.',
                        );
                      }

                      final sleepRange = _sleepRangeForAge(ageMonths);
                      final sleepInsight = _buildSleepInsight(sleepHours, sleepRange);
                      final feedingInsight = _buildFeedingInsight(feedingCount);
                      final activityInsight = _buildActivityInsight(diaperCount);
                      final growthInsight = hasRecentGrowth
                          ? 'Recent वृद्धि (growth) log recorded in the past 30 days.'
                          : null;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Parenting Wisdom',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              softWrap: true,
                              maxLines: null,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'At this stage of शैशव अवस्था (early childhood), consistent routines support healthy विकास (development).',
                              style: Theme.of(context).textTheme.bodyMedium,
                              softWrap: true,
                              maxLines: null,
                            ),
                            const SizedBox(height: 16),
                            _buildInsightSection(
                              context,
                              'Today’s insight',
                              [
                                sleepInsight,
                                feedingInsight,
                                activityInsight,
                                if (growthInsight != null) growthInsight,
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Gentle focus on routine संतुलन (balance) may help maintain overall ओजस् (vitality).',
                              style: Theme.of(context).textTheme.bodyMedium,
                              softWrap: true,
                              maxLines: null,
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => const SizedBox.shrink(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => const SizedBox.shrink(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const SizedBox.shrink(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildInsightSection(BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          softWrap: true,
          maxLines: null,
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(
                      item,
                      softWrap: true,
                      maxLines: null,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildFallback(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          message,
          softWrap: true,
          maxLines: null,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildFallbackWithAction(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              softWrap: true,
              maxLines: null,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showLogOptions(context),
                child: const Text('Log Activities'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('Log Feeding'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedingTrackingPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bedtime_outlined),
                title: const Text('Log Sleep'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SleepTrackingPage()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  int _calculateAgeMonths(DateTime birthDate, DateTime now) {
    var months = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) {
      months -= 1;
    }
    return months < 0 ? 0 : months;
  }

  ({double min, double max}) _sleepRangeForAge(int ageMonths) {
    if (ageMonths <= 3) return (min: 14, max: 17);
    if (ageMonths <= 11) return (min: 12, max: 15);
    if (ageMonths <= 24) return (min: 11, max: 14);
    if (ageMonths <= 36) return (min: 10, max: 13);
    return (min: 10, max: 12);
  }

  String _buildSleepInsight(double sleepHours, ({double min, double max}) range) {
    if (sleepHours == 0) {
      return 'Sleep logs are missing for today.';
    }
    if (sleepHours < range.min) {
      return 'Sleep duration is below the typical range for this age.';
    }
    if (sleepHours > range.max) {
      return 'Sleep duration is above the typical range; observe daytime energy.';
    }
    return 'Sleep duration appears within the expected range for this age.';
  }

  String _buildFeedingInsight(int feedingCount) {
    if (feedingCount == 0) {
      return 'Feeding logs are missing for today.';
    }
    if (feedingCount < 3) {
      return 'Feeding frequency is lower than typical for this age.';
    }
    return 'Feeding routine appears consistent today.';
  }

  String _buildActivityInsight(int diaperCount) {
    if (diaperCount == 0) {
      return 'Daily activity logs are limited (no diaper logs today).';
    }
    if (diaperCount < 3) {
      return 'Activity logs are light today; continue routine observations.';
    }
    return 'Daily activity logs show regular care intervals.';
  }
}
