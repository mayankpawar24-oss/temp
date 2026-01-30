-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Pregnancies Table
CREATE TABLE IF NOT EXISTS pregnancies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  due_date TIMESTAMP NOT NULL,
  last_period_date TIMESTAMP NOT NULL,
  current_month INTEGER NOT NULL,
  monthly_checklists JSONB DEFAULT '{}',
  completed_tests TEXT[] DEFAULT '{}',
  risk_symptoms TEXT[] DEFAULT '{}',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Growth Table (Toddler)
CREATE TABLE IF NOT EXISTS growth_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  timestamp TIMESTAMP NOT NULL,
  weight FLOAT NOT NULL,
  height FLOAT NOT NULL,
  head_circumference FLOAT NOT NULL,
  age_in_days INTEGER NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Feeding Table
CREATE TABLE IF NOT EXISTS feeding_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  timestamp TIMESTAMP NOT NULL,
  feeding_type TEXT NOT NULL,
  duration_minutes INTEGER,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Diaper Table
CREATE TABLE IF NOT EXISTS diaper_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  timestamp TIMESTAMP NOT NULL,
  type TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Sleep Table
CREATE TABLE IF NOT EXISTS sleep_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP NOT NULL,
  duration_minutes INTEGER NOT NULL,
  quality TEXT,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Milestone Table
CREATE TABLE IF NOT EXISTS milestones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  age_in_days INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  achieved BOOLEAN DEFAULT FALSE,
  achieved_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Vaccination Table
CREATE TABLE IF NOT EXISTS vaccinations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vaccine_name TEXT NOT NULL,
  scheduled_date TIMESTAMP NOT NULL,
  administered_date TIMESTAMP,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Medical Records Table
CREATE TABLE IF NOT EXISTS medical_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  record_type TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  date TIMESTAMP NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Kick Log Table (Pregnancy)
CREATE TABLE IF NOT EXISTS kick_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  timestamp TIMESTAMP NOT NULL,
  kick_count INTEGER NOT NULL,
  duration_minutes INTEGER NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Contraction Table (Pregnancy)
CREATE TABLE IF NOT EXISTS contractions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  timestamp TIMESTAMP NOT NULL,
  duration_seconds INTEGER NOT NULL,
  intensity TEXT,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Chat Sessions Table
CREATE TABLE IF NOT EXISTS chat_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Chat Messages Table
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id UUID NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  is_user BOOLEAN NOT NULL,
  timestamp TIMESTAMP DEFAULT NOW()
);

-- Reminders Table
CREATE TABLE IF NOT EXISTS reminders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  reminder_type TEXT NOT NULL,
  reminder_date TIMESTAMP NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_pregnancies_user_id ON pregnancies(user_id);
CREATE INDEX IF NOT EXISTS idx_growth_records_user_id ON growth_records(user_id);
CREATE INDEX IF NOT EXISTS idx_feeding_records_user_id ON feeding_records(user_id);
CREATE INDEX IF NOT EXISTS idx_diaper_records_user_id ON diaper_records(user_id);
CREATE INDEX IF NOT EXISTS idx_sleep_records_user_id ON sleep_records(user_id);
CREATE INDEX IF NOT EXISTS idx_milestones_user_id ON milestones(user_id);
CREATE INDEX IF NOT EXISTS idx_vaccinations_user_id ON vaccinations(user_id);
CREATE INDEX IF NOT EXISTS idx_medical_records_user_id ON medical_records(user_id);
CREATE INDEX IF NOT EXISTS idx_kick_logs_user_id ON kick_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_contractions_user_id ON contractions(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_sessions_user_id ON chat_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_session_id ON chat_messages(session_id);
CREATE INDEX IF NOT EXISTS idx_reminders_user_id ON reminders(user_id);

-- Enable RLS (Row Level Security)
ALTER TABLE pregnancies ENABLE ROW LEVEL SECURITY;
ALTER TABLE growth_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE feeding_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE diaper_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE sleep_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE vaccinations ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE kick_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE contractions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;

-- Create RLS policies (users can only see their own data)
CREATE POLICY "Users can view own pregnancies" ON pregnancies FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own pregnancies" ON pregnancies FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own pregnancies" ON pregnancies FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own pregnancies" ON pregnancies FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own growth records" ON growth_records FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own growth records" ON growth_records FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own growth records" ON growth_records FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own growth records" ON growth_records FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own feeding records" ON feeding_records FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own feeding records" ON feeding_records FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own feeding records" ON feeding_records FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own feeding records" ON feeding_records FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own diaper records" ON diaper_records FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own diaper records" ON diaper_records FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own diaper records" ON diaper_records FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own diaper records" ON diaper_records FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own sleep records" ON sleep_records FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own sleep records" ON sleep_records FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own sleep records" ON sleep_records FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own sleep records" ON sleep_records FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own milestones" ON milestones FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own milestones" ON milestones FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own milestones" ON milestones FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own milestones" ON milestones FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own vaccinations" ON vaccinations FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own vaccinations" ON vaccinations FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own vaccinations" ON vaccinations FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own vaccinations" ON vaccinations FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own medical records" ON medical_records FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own medical records" ON medical_records FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own medical records" ON medical_records FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own medical records" ON medical_records FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own kick logs" ON kick_logs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own kick logs" ON kick_logs FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own kick logs" ON kick_logs FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own kick logs" ON kick_logs FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own contractions" ON contractions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own contractions" ON contractions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own contractions" ON contractions FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own contractions" ON contractions FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own chat sessions" ON chat_sessions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own chat sessions" ON chat_sessions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own chat sessions" ON chat_sessions FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own chat sessions" ON chat_sessions FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own chat messages" ON chat_messages FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own chat messages" ON chat_messages FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own reminders" ON reminders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own reminders" ON reminders FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own reminders" ON reminders FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own reminders" ON reminders FOR DELETE USING (auth.uid() = user_id);
