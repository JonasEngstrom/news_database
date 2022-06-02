CREATE TABLE news_parameters (
    time TEXT PRIMARY KEY UNIQUE NOT NULL,
    respiratory_rate INT,
    oxygen_saturation INT,
    supplemental_oxygen BOOLEAN,
    systolic_pressure INT,
    heart_rate INT,
    consciousness CHARACTER(1),
    temperature DECIMAL(3,1),
    comment TEXT,
    CONSTRAINT check_time
        CHECK (time IS strftime('%Y-%m-%d %H:%M', time)),
    CONSTRAINT check_respiratory_rate
        CHECK (respiratory_rate BETWEEN 0 AND 200),
    CONSTRAINT check_oxygen_saturation
        CHECK (oxygen_saturation BETWEEN 0 AND 100),
    CONSTRAINT check_supplemental_oxygen
        CHECK (supplemental_oxygen IN (1, 0)),
    CONSTRAINT check_systolic_pressure
        CHECK (systolic_pressure BETWEEN 0 AND 300),
    CONSTRAINT check_heart_rate
        CHECK (heart_rate BETWEEN 0 AND 300),
    CONSTRAINT check_consciousness
        CHECK (consciousness IN ('A', 'C', 'V', 'P', 'U')),
    CONSTRAINT check_temperature
        CHECK (temperature BETWEEN 0 AND 50)
);
