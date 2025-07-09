-- ============================================
-- Soccer Analytics Database Schema for Supabase
-- CORRECTED VERSION - Matches actual working schema
-- ============================================

-- Drop existing tables if they exist (be careful in production!)
DROP TABLE IF EXISTS soccer_extraction_log CASCADE;
DROP TABLE IF EXISTS player_game_stats CASCADE;
DROP TABLE IF EXISTS games CASCADE;
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE IF EXISTS seasons CASCADE;
DROP TABLE IF EXISTS schools CASCADE;

-- ============================================
-- 1. SCHOOLS TABLE
-- ============================================
CREATE TABLE schools (
    school_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    conference TEXT DEFAULT 'Great American Conference',
    division TEXT DEFAULT 'Division II',
    website_pattern TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 2. SEASONS TABLE
-- ============================================
CREATE TABLE seasons (
    season_id TEXT PRIMARY KEY,
    year INTEGER NOT NULL,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 3. PLAYERS TABLE
-- ============================================
CREATE TABLE players (
    player_id TEXT PRIMARY KEY,
    school_id TEXT,
    season_id TEXT,
    jersey_number INTEGER,
    name TEXT NOT NULL,
    position TEXT,
    is_goalkeeper BOOLEAN DEFAULT FALSE,
    class_year TEXT,
    hometown TEXT,
    height TEXT,
    weight INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT players_jersey_number_check CHECK (jersey_number >= 1 AND jersey_number <= 99),
    
    -- Foreign Keys
    CONSTRAINT players_school_id_fkey FOREIGN KEY (school_id) REFERENCES schools(school_id),
    CONSTRAINT players_season_id_fkey FOREIGN KEY (season_id) REFERENCES seasons(season_id)
);

-- ============================================
-- 4. GAMES TABLE  
-- ============================================
CREATE TABLE games (
    game_id TEXT PRIMARY KEY,
    school_id TEXT,
    season_id TEXT,
    date DATE NOT NULL,
    opponent TEXT NOT NULL,
    home_score INTEGER,
    away_score INTEGER,
    location TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT games_home_score_check CHECK (home_score >= 0),
    CONSTRAINT games_away_score_check CHECK (away_score >= 0),
    CONSTRAINT games_location_check CHECK (location = ANY (ARRAY['Home'::text, 'Away'::text, 'Neutral'::text])),
    
    -- Foreign Keys
    CONSTRAINT games_school_id_fkey FOREIGN KEY (school_id) REFERENCES schools(school_id),
    CONSTRAINT games_season_id_fkey FOREIGN KEY (season_id) REFERENCES seasons(season_id)
);

-- ============================================
-- 5. PLAYER GAME STATS TABLE
-- ============================================
CREATE TABLE player_game_stats (
    stat_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id TEXT,
    game_id TEXT,
    minutes_played INTEGER DEFAULT 0,
    goals INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    shots INTEGER DEFAULT 0,
    shots_on_goal INTEGER DEFAULT 0,
    fouls INTEGER DEFAULT 0,
    yellow_cards INTEGER DEFAULT 0,
    red_cards INTEGER DEFAULT 0,
    saves INTEGER DEFAULT 0,
    goals_against INTEGER DEFAULT 0,
    shutouts INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT player_game_stats_minutes_played_check CHECK (minutes_played >= 0),
    CONSTRAINT player_game_stats_goals_check CHECK (goals >= 0),
    CONSTRAINT player_game_stats_assists_check CHECK (assists >= 0),
    CONSTRAINT player_game_stats_shots_check CHECK (shots >= 0),
    CONSTRAINT player_game_stats_shots_on_goal_check CHECK (shots_on_goal >= 0),
    CONSTRAINT player_game_stats_fouls_check CHECK (fouls >= 0),
    CONSTRAINT player_game_stats_yellow_cards_check CHECK (yellow_cards >= 0),
    CONSTRAINT player_game_stats_red_cards_check CHECK (red_cards >= 0),
    CONSTRAINT player_game_stats_saves_check CHECK (saves >= 0),
    CONSTRAINT player_game_stats_goals_against_check CHECK (goals_against >= 0),
    CONSTRAINT player_game_stats_shutouts_check CHECK (shutouts >= 0),
    
    -- Foreign Keys
    CONSTRAINT player_game_stats_player_id_fkey FOREIGN KEY (player_id) REFERENCES players(player_id),
    CONSTRAINT player_game_stats_game_id_fkey FOREIGN KEY (game_id) REFERENCES games(game_id)
);

-- ============================================
-- 6. EXTRACTION LOG TABLE
-- ============================================
CREATE TABLE soccer_extraction_log (
    id SERIAL PRIMARY KEY,
    school TEXT NOT NULL,
    season TEXT NOT NULL,
    total_players INTEGER DEFAULT 0,
    total_games INTEGER DEFAULT 0,
    total_stats INTEGER DEFAULT 0,
    extraction_successful BOOLEAN DEFAULT FALSE,
    raw_data JSONB,
    source_name TEXT,
    extracted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 7. INDEXES FOR PERFORMANCE
-- ============================================

-- Players table indexes
CREATE INDEX idx_players_school_season ON players(school_id, season_id);
CREATE INDEX idx_players_jersey_number ON players(jersey_number);
CREATE INDEX idx_players_position ON players(position);
CREATE INDEX idx_players_goalkeeper ON players(is_goalkeeper) WHERE is_goalkeeper = true;

-- Games table indexes
CREATE INDEX idx_games_school_season ON games(school_id, season_id);
CREATE INDEX idx_games_date ON games(date DESC);
CREATE INDEX idx_games_opponent ON games(opponent);

-- Player game stats indexes
CREATE INDEX idx_player_game_stats_player ON player_game_stats(player_id);
CREATE INDEX idx_player_game_stats_game ON player_game_stats(game_id);

-- Extraction log indexes
CREATE INDEX idx_extraction_log_date ON soccer_extraction_log(extracted_at DESC);
CREATE INDEX idx_extraction_log_school_season ON soccer_extraction_log(school, season);

-- ============================================
-- 8. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE seasons ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE games ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_game_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE soccer_extraction_log ENABLE ROW LEVEL SECURITY;

-- Create policies for service role (for n8n workflow)
CREATE POLICY "Allow service role full access" ON schools FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "Allow service role full access" ON seasons FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "Allow service role full access" ON players FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "Allow service role full access" ON games FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "Allow service role full access" ON player_game_stats FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "Allow service role full access" ON soccer_extraction_log FOR ALL USING (auth.role() = 'service_role');

-- Create policies for authenticated users (read-only)
CREATE POLICY "Allow authenticated users read access" ON schools FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users read access" ON seasons FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users read access" ON players FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users read access" ON games FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users read access" ON player_game_stats FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users read access" ON soccer_extraction_log FOR SELECT USING (auth.role() = 'authenticated');

-- ============================================
-- 9. INITIAL DATA SETUP
-- ============================================

-- Insert default school
INSERT INTO schools (school_id, name, conference, division, website_pattern)
VALUES ('Harding', 'Harding University', 'Great American Conference', 'Division II', 'https://static.hardingsports.com/custompages/msoc/{year}/');

-- Insert current season
INSERT INTO seasons (season_id, year, start_date, end_date, is_active)
VALUES ('2024', 2024, '2024-08-01', '2024-12-31', TRUE);

-- ============================================
-- 10. USEFUL VIEWS FOR ANALYTICS
-- ============================================

-- View: Team overview
CREATE VIEW team_overview AS
SELECT 
    s.name as school_name,
    se.year as season_year,
    COUNT(p.*) as total_players,
    COUNT(p.*) FILTER (WHERE p.is_goalkeeper = true) as goalkeepers,
    COUNT(p.*) FILTER (WHERE p.position = 'Forward') as forwards,
    COUNT(p.*) FILTER (WHERE p.position = 'Midfielder') as midfielders,
    COUNT(p.*) FILTER (WHERE p.position = 'Defender') as defenders
FROM schools s
CROSS JOIN seasons se
LEFT JOIN players p ON p.school_id = s.school_id AND p.season_id = se.season_id
WHERE se.is_active = true
GROUP BY s.school_id, s.name, se.year;

-- View: Season summary
CREATE VIEW season_summary AS
SELECT 
    s.name as school_name,
    se.year as season_year,
    COUNT(g.*) as total_games,
    COUNT(g.*) FILTER (WHERE 
        (g.location = 'Home' AND g.home_score > g.away_score) OR 
        (g.location = 'Away' AND g.away_score > g.home_score)
    ) as wins,
    COUNT(g.*) FILTER (WHERE 
        (g.location = 'Home' AND g.home_score < g.away_score) OR 
        (g.location = 'Away' AND g.away_score < g.home_score)
    ) as losses,
    COUNT(g.*) FILTER (WHERE g.home_score = g.away_score AND g.home_score IS NOT NULL) as ties,
    COUNT(g.*) FILTER (WHERE g.home_score IS NULL OR g.away_score IS NULL) as upcoming_games,
    COUNT(g.*) FILTER (WHERE g.location = 'Home') as home_games,
    COUNT(g.*) FILTER (WHERE g.location = 'Away') as away_games
FROM schools s
CROSS JOIN seasons se
LEFT JOIN games g ON g.school_id = s.school_id AND g.season_id = se.season_id
WHERE se.is_active = true
GROUP BY s.school_id, s.name, se.year;

-- ============================================
-- 11. FUNCTIONS
-- ============================================

-- Function to get latest extraction info
CREATE OR REPLACE FUNCTION get_latest_extraction()
RETURNS TABLE(
    extraction_date TIMESTAMP WITH TIME ZONE,
    school TEXT,
    season TEXT,
    players_count INTEGER,
    games_count INTEGER,
    status BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sel.extracted_at,
        sel.school,
        sel.season,
        sel.total_players,
        sel.total_games,
        sel.extraction_successful
    FROM soccer_extraction_log sel
    ORDER BY sel.extracted_at DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SETUP COMPLETE!
-- ============================================

-- Verify the setup
SELECT 'Corrected schema setup completed successfully!' as status;

-- Show table information
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('schools', 'seasons', 'players', 'games', 'player_game_stats', 'soccer_extraction_log')
ORDER BY tablename;