# Feature Segregation: Pregnant Mom vs Toddler Parent

## Current Implementation

The app now has **separate dashboards** with role-specific features:

### 🤰 Pregnant Mom Features (PregnantDashboardPage)
**Focus:** Pregnancy tracking and preparation

#### Core Features:
1. **Pregnancy Progress Widget**
   - Week-by-week pregnancy tracker
   - Visual progress bar (1-40 weeks)
   - Trimester information

2. **Kick Counter**
   - Track baby movements
   - 10-kick timer
   - Historical kick logs

3. **Contraction Timer**
   - Time contractions for labor
   - Track duration and frequency
   - Labor detection alerts

4. **Hospital Bag Checklist**
   - Pre-delivery preparation
   - Essential items list
   - Packing guide

5. **Symptom Tracker**
   - Log pregnancy symptoms
   - Risk symptom alerts
   - Health monitoring

6. **Daily Tips**
   - Pregnancy advice
   - Week-specific tips
   - Nutrition guidance

7. **Daily Summary & Weekly Stats**
   - Overview of pregnancy journey
   - Health trends

### 👶 Toddler Parent Features (ToddlerDashboardPage)
**Focus:** Baby/Toddler care and development

#### Core Features:
1. **Tracker Hub (Quick Actions)**
   - **Feeding Tracker**: Log breastfeeding/bottle feeds
   - **Sleep Tracker**: Monitor sleep patterns
   - **Diaper Tracker**: Track wet/dirty diapers

2. **Milestone Tracker**
   - Age-appropriate milestones
   - Development checkpoints
   - Achievement celebrations

3. **Vaccinations**
   - Immunization schedule
   - Upcoming shots
   - Vaccination records

4. **Growth Chart**
   - Height tracking
   - Weight tracking
   - Head circumference
   - WHO growth percentiles

5. **Activity Ideas**
   - Age-appropriate play
   - Developmental activities
   - Learning games

6. **Parenting Wisdom**
   - Baby care tips
   - Common concerns
   - Expert advice

7. **Daily Summary & Weekly Stats**
   - Overview of baby's day
   - Sleep/feeding patterns

## Feature Differences at a Glance

| Feature | Pregnant Mom | Toddler Parent |
|---------|--------------|----------------|
| **Kick Counter** | ✅ Yes | ❌ No |
| **Contraction Timer** | ✅ Yes | ❌ No |
| **Hospital Bag** | ✅ Yes | ❌ No |
| **Symptom Tracker** | ✅ Yes | ❌ No |
| **Feeding Tracker** | ❌ No | ✅ Yes |
| **Sleep Tracker** | ❌ No | ✅ Yes |
| **Diaper Tracker** | ❌ No | ✅ Yes |
| **Milestones** | ❌ No | ✅ Yes |
| **Vaccinations** | ❌ No | ✅ Yes |
| **Growth Chart** | ❌ No | ✅ Yes |
| **Activity Ideas** | ❌ No | ✅ Yes |

## Setup Flow Differences

### Pregnant Mom
1. Register → Select "Pregnant Mom"
2. **Pregnancy Setup Page**:
   - Enter Last Menstrual Period date
   - Enter Due Date
   - Auto-calculate pregnancy week
3. Navigate to **Pregnant Dashboard**

### Toddler Parent
1. Register → Select "Toddler Parent"
2. **Toddler Setup Page**:
   - Enter Baby's Birthday
   - Calculate age in months
3. Navigate to **Toddler Dashboard**

## How Segregation Works

### 1. User Profile Detection
```dart
final userMeta = ref.watch(userMetaProvider);

if (userMeta.role == UserProfileType.pregnant) {
  // Show pregnant features
} else {
  // Show toddler features
}
```

### 2. Dashboard Routing
In `MainNavigationShell`:
```dart
Widget homePage;
if (userMeta.role == UserProfileType.pregnant) {
   homePage = const PregnantDashboardPage();
} else {
   homePage = const ToddlerDashboardPage();
}
```

### 3. Setup Page Routing
Users without `start_date` are redirected to appropriate setup:
```dart
if (userMeta.startDate == null) {
  if (userMeta.role == UserProfileType.pregnant) {
    return const PregnancySetupPage();
  } else {
    return const ToddlerSetupPage();
  }
}
```

## Navigation Tabs (Same for Both)

Both user types have the same bottom navigation:
1. **Home** - Role-specific dashboard
2. **Resources** - Educational content
3. **Reminders** - Health checkups
4. **Profile** - Settings & account

## Testing Role-Based Features

### To Test Pregnant Mom:
1. Register with new email
2. Select "Pregnant Mom"
3. Enter pregnancy dates
4. See: Kick counter, Contraction timer, Hospital bag

### To Test Toddler Parent:
1. Register with different email
2. Select "Toddler Parent"
3. Enter baby's birthday
4. See: Feeding tracker, Milestones, Vaccinations

## Future Enhancements

### Planned Features:

**Pregnant Mom:**
- Birth plan creator
- Pregnancy journal
- Partner involvement features
- Prenatal exercise guide

**Toddler Parent:**
- Developmental photos timeline
- Teeth tracking
- Potty training tracker
- Meal planning
- Emergency contact quick dial

## Customization

Dashboard widgets are stored in Hive (local) with user preferences. Users can:
- Reorder dashboard cards
- Hide/show specific widgets
- Customize view per their needs

This ensures each user sees only relevant features for their journey! 🎉
