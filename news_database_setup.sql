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

CREATE VIEW news_points
AS
SELECT
    *,
    CASE
        WHEN (points_respiratory_rate >= 3 OR
            points_oxygen_saturation >= 3 OR
            points_supplemental_oxygen >= 3 OR
            points_systolic_pressure >= 3 OR
            points_heart_rate >= 3 OR
            points_consciousness >= 3 OR
            points_temperature >= 3) AND
            total_points < 5 THEN
            'Låg/medium'
        WHEN total_points BETWEEN 5 AND 6 THEN
            'Medium'
        WHEN total_points >= 7 THEN
            'Hög'
        ELSE
            'Låg'
        END
    clinical_risk,
    CASE
        WHEN (points_respiratory_rate >= 3 OR
            points_oxygen_saturation >= 3 OR
            points_supplemental_oxygen >= 3 OR
            points_systolic_pressure >= 3 OR
            points_heart_rate >= 3 OR
            points_consciousness >= 3 OR
            points_temperature >= 3) AND
            total_points < 5 THEN
            'Brådskande avdelningsbaserade åtgärder'
        WHEN total_points BETWEEN 5 AND 6 THEN
            'Brådskande åtgärder'
        WHEN total_points >= 7 THEN
            'Akuta åtgärder'
        ELSE
            'Avdelningsbaserade åtgärder'
        END
    response_level
    FROM
    (
    SELECT
        *,
            IFNULL(points_respiratory_rate, 0) +
            IFNULL(points_oxygen_saturation, 0) +
            IFNULL(points_supplemental_oxygen, 0) +
            IFNULL(points_systolic_pressure, 0) +
            IFNULL(points_heart_rate, 0) +
            IFNULL(points_consciousness, 0) +
            IFNULL(points_temperature, 0)
            AS 
        total_points
        FROM
        (
        SELECT
            time,
            CASE
                WHEN respiratory_rate <= 8 THEN
                    3
                WHEN respiratory_rate BETWEEN 9 AND 11 THEN
                    1
                WHEN respiratory_rate BETWEEN 12 AND 20 THEN
                    0
                WHEN respiratory_rate BETWEEN 21 AND 24 THEN
                    2
                WHEN respiratory_rate >= 25 THEN
                    3
                END
            points_respiratory_rate,
            CASE
                WHEN oxygen_saturation <= 91 THEN
                    3
                WHEN oxygen_saturation BETWEEN 92 AND 93 THEN
                    2
                WHEN oxygen_saturation BETWEEN 94 AND 95 THEN
                    1
                WHEN oxygen_saturation >= 96 THEN
                    0
                END
            points_oxygen_saturation,
            CASE
                WHEN supplemental_oxygen IS 1 THEN
                    2
                WHEN supplemental_oxygen IS 0 THEN
                    0
                END
            points_supplemental_oxygen,
            CASE
                WHEN systolic_pressure <= 90 THEN
                    3
                WHEN systolic_pressure BETWEEN 91 AND 100 THEN
                    2
                WHEN systolic_pressure BETWEEN 101 AND 110 THEN
                    1
                WHEN systolic_pressure BETWEEN 111 AND 219 THEN
                    0
                WHEN systolic_pressure >= 220 THEN
                    3
                END
            points_systolic_pressure,
            CASE
                WHEN heart_rate <= 40 THEN
                    3
                WHEN heart_rate BETWEEN 41 AND 50 THEN
                    1
                WHEN heart_rate BETWEEN 51 AND 90 THEN
                    0
                WHEN heart_rate BETWEEN 91 AND 110 THEN
                    1
                WHEN heart_rate BETWEEN 111 AND 130 THEN
                    2
                WHEN heart_rate >= 131 THEN
                    3
                END
            points_heart_rate,
            CASE
                WHEN consciousness IS 'A' THEN
                    0
                ELSE
                    3
                END
            points_consciousness,
            CASE
                WHEN temperature <= 35.0 THEN
                    3
                WHEN temperature BETWEEN 35.1 AND 36.0 THEN
                    1
                WHEN temperature BETWEEN 36.1 AND 38.0 THEN
                    0
                WHEN temperature BETWEEN 38.1 AND 39.0 THEN
                    1
                WHEN temperature >= 39.1 THEN
                    2
                END
            points_temperature
        FROM
            news_parameters
        )
    );
    