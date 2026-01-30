# Supabase Migration Guide

## Overview
This guide helps you migrate from local Hive storage to Supabase cloud database.

## Step 1: Create Supabase Tables (COMPLETE THESE FIRST)

1. Go to your Supabase Dashboard: https://app.supabase.com
2. Select your project
3. Go to **SQL Editor** (left sidebar)
4. Click **New Query**
5. Copy all SQL from `SUPABASE_SETUP.sql` and paste it
6. Click **Run**

This creates all necessary tables with:
- User authentication integration
- Row Level Security (RLS) policies
- Proper indexes for performance

## Step 2: Enable Email/Password Authentication

1. In Supabase Dashboard, go to **Authentication** → **Providers**
2. Find **Email** and toggle it **ON**
3. Scroll to **Email/Password settings**
4. Turn OFF **"Confirm email"** (for instant login)
5. Click **Save**

## Step 3: Update Flutter App Dependencies

Your `pubspec.yaml` already includes `supabase_flutter`. No changes needed.

## Step 4: Understand the Migration

### Old Setup (Hive - Local)
```
App → Hive (Local Device Storage)
```

### New Setup (Supabase - Cloud)
```
App → Supabase Auth (User Management)
    ↓
    Supabase Database (Cloud Storage)
```

## Step 5: Repositories

### Current Status
- **Old repositories** (Hive-based): Still use local storage
  - `PregnancyRepository` → Uses Hive
  - `GrowthRepository` → Uses Hive
  - etc.

### New repositories (Supabase-based) [CREATED]
- `SupabasePregnancyRepository` → Uses Supabase
- `SupabaseGrowthRepository` → Uses Supabase
- More coming...

## Step 6: What You Need to Do

You have 2 options:

### Option A: Gradual Migration (Recommended)
1. Create Supabase repositories one by one (like I did)
2. Update each page to use new repositories
3. Old Hive data can be migrated using a script
4. Parallel reading (read from both, write to Supabase only)

### Option B: Complete Rewrite
1. Replace all Hive repositories with Supabase versions
2. All data stored in cloud from now on
3. Old local data is abandoned

## Key Files

| File | Purpose |
|------|---------|
| `SUPABASE_SETUP.sql` | SQL to create all tables |
| `lib/data/repositories/supabase_pregnancy_repository.dart` | Cloud pregnancy storage |
| `lib/data/repositories/supabase_growth_repository.dart` | Cloud growth storage |

## Code Examples

### Saving Data to Supabase
```dart
final repo = SupabasePregnancyRepository();
await repo.savePregnancy(pregnancy);
```

### Reading Data from Supabase
```dart
final repo = SupabasePregnancyRepository();
final pregnancy = await repo.getPregnancy();
```

### User Authentication
```dart
// Login
final authService = AuthService();
await authService.signInWithEmailAndPassword(email: 'user@example.com', password: 'pass');

// Access current user
final user = authService.currentUser; // Contains id, email, etc.
```

## Current Integration Status

✅ **Complete:**
- Supabase Auth (Email/Password)
- User Metadata Storage
- Auth State Management (Riverpod)

🔄 **In Progress:**
- Database Repositories
- Data migration tools

⏳ **Next Steps:**
- Create remaining repositories (Feeding, Sleep, Vaccination, etc.)
- Add data sync for offline-first support
- Create migration scripts for existing Hive data

## Need Help?

1. **Run SQL commands**: Go to Supabase SQL Editor
2. **Check auth works**: Try registering/logging in
3. **Debug issues**: Check Supabase logs in dashboard
4. **Ask me**: I can create specific repositories or help with any issues
