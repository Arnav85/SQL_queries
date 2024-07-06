-- Create InputDates table
CREATE TABLE InputDates (
    Start_Date DATETIME,
    End_Date DATETIME
);

-- Create counttotalworkinhours table
CREATE TABLE counttotalworkinhours (
    Start_Date DATETIME,
    End_Date DATETIME,
    Total_Working_Hours INT
);

-- Create Calculate_Working_Hours stored procedure
DELIMITER //

CREATE PROCEDURE Calculate_Working_Hours()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE cur CURSOR FOR SELECT Start_Date, End_Date FROM InputDates;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO @Start_Date, @End_Date;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Adjust start date to exclude Sundays and 1st/2nd Saturdays
        SET @Adjusted_Start_Date = CASE 
                                        WHEN DAYOFWEEK(@Start_Date) = 1 THEN @Start_Date
                                        WHEN DAYOFWEEK(@Start_Date) = 7 AND DAY(@Start_Date) <= 2 THEN @Start_Date
                                        ELSE DATE_ADD(@Start_Date, INTERVAL 1 DAY)
                                   END;

        -- Adjust end date to exclude Sundays and 1st/2nd Saturdays
        SET @Adjusted_End_Date = CASE 
                                      WHEN DAYOFWEEK(@End_Date) = 1 THEN @End_Date
                                      WHEN DAYOFWEEK(@End_Date) = 7 AND DAY(@End_Date) <= 2 THEN @End_Date
                                      ELSE DATE_SUB(@End_Date, INTERVAL 1 DAY)
                                 END;

        -- Calculate total working hours (assuming 24 hours per valid working day)
        SET @Total_Working_Hours = 0;
        SET @Current_Date = @Adjusted_Start_Date;

        WHILE @Current_Date <= @Adjusted_End_Date DO
            IF DAYOFWEEK(@Current_Date) <> 1 AND NOT (DAYOFWEEK(@Current_Date) = 7 AND DAY(@Current_Date) <= 2) THEN
                SET @Total_Working_Hours = @Total_Working_Hours + 24;
            END IF;
            SET @Current_Date = DATE_ADD(@Current_Date, INTERVAL 1 DAY);
        END WHILE;

        -- Insert result into output table
        INSERT INTO counttotalworkinhours (Start_Date, End_Date, Total_Working_Hours)
        VALUES (@Start_Date, @End_Date, @Total_Working_Hours);
        
    END LOOP;

    CLOSE cur;
    
END //

DELIMITER ;

-- Insert sample data into InputDates table
INSERT INTO InputDates (Start_Date, End_Date)
VALUES ('2023-07-12', '2023-07-13');

INSERT INTO InputDates (Start_Date, End_Date)
VALUES ('2023-07-01', '2023-07-17');

-- Execute stored procedure to calculate working hours
CALL Calculate_Working_Hours();

-- View the result in increasing order of Start_Date
SELECT * FROM counttotalworkinhours
ORDER BY Start_Date;

-- Clean up: Drop objects after use
DROP PROCEDURE IF EXISTS Calculate_Working_Hours;
DROP TABLE IF EXISTS counttotalworkinhours;
DROP TABLE IF EXISTS InputDates;