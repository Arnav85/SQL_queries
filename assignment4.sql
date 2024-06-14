CREATE PROCEDURE AllocateSubjects()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE student_id INT;
    DECLARE preference INT;
    DECLARE subject_id VARCHAR(10);

    -- Cursor to iterate over students ordered by GPA in descending order
    DECLARE student_cursor CURSOR FOR
        SELECT StudentId
        FROM StudentDetails
        ORDER BY GPA DESC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Open the cursor
    OPEN student_cursor;

    -- Loop through each student
    read_loop: LOOP
        FETCH student_cursor INTO student_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Initialize preference
        SET preference = 1;

        -- Check each preference until a subject is allotted or all preferences are exhausted
        preference_loop: LOOP
            SELECT SubjectId INTO subject_id
            FROM StudentPreference
            WHERE StudentId = student_id AND Preference = preference;

            -- Check if the subject has remaining seats
            IF (SELECT RemainingSeats FROM SubjectDetails WHERE SubjectId = subject_id) > 0 THEN
                -- Allot the subject to the student
                INSERT INTO Allotments (SubjectId, StudentId)
                VALUES (subject_id, student_id);

                -- Update the remaining seats for the subject
                UPDATE SubjectDetails
                SET RemainingSeats = RemainingSeats - 1
                WHERE SubjectId = subject_id;

                -- Exit the preference loop
                LEAVE preference_loop;
            END IF;

            -- Move to the next preference
            SET preference = preference + 1;

            -- If all preferences are checked and no subject is allotted, mark the student as unallotted
            IF preference > 5 THEN
                INSERT INTO UnallotedStudents (StudentId)
                VALUES (student_id);
                LEAVE preference_loop;
            END IF;
        END LOOP preference_loop;

    END LOOP read_loop;

    -- Close the cursor
    CLOSE student_cursor;
END 

