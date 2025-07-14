-- Create weight_history table for tracking user weight measurements
CREATE TABLE IF NOT EXISTS weight_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    weight_kg DECIMAL(5,2) NOT NULL CHECK (weight_kg > 0 AND weight_kg < 1000),
    recorded_date TIMESTAMP WITH TIME ZONE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create index for efficient queries by user and date
CREATE INDEX IF NOT EXISTS idx_weight_history_user_date 
ON weight_history (user_id, recorded_date DESC);

-- Create index for efficient queries by user only
CREATE INDEX IF NOT EXISTS idx_weight_history_user 
ON weight_history (user_id);

-- Enable Row Level Security
ALTER TABLE weight_history ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own weight history" ON weight_history
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own weight history" ON weight_history
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own weight history" ON weight_history
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own weight history" ON weight_history
    FOR DELETE USING (auth.uid() = user_id);

-- Add trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_weight_history_updated_at 
    BEFORE UPDATE ON weight_history 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();