CREATE PROCEDURE UpdateSubjectAllotments
AS
BEGIN
    -- Declare variables to hold student and subject IDs
    DECLARE @StudentId VARCHAR(255), @SubjectId VARCHAR(255);
    
    -- Cursor to iterate through each record in the SubjectRequest table
    DECLARE RequestCursor CURSOR FOR
        SELECT StudentId, SubjectId
        FROM SubjectRequest;
    
    OPEN RequestCursor;
    
    FETCH NEXT FROM RequestCursor INTO @StudentId, @SubjectId;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check if the student exists in the SubjectAllotments table
        IF EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentId = @StudentId)
        BEGIN
            -- Check if the current subject is different from the requested subject
            IF EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentId = @StudentId AND SubjectId = @SubjectId AND Is_Valid = 1)
            BEGIN
                -- Do nothing if the requested subject is the same as the current subject
                PRINT 'The requested subject is already the current subject for student ' + @StudentId;
            END
            ELSE
            BEGIN
                -- Update the current subject to invalid
                UPDATE SubjectAllotments
                SET Is_Valid = 0
                WHERE StudentId = @StudentId AND Is_Valid = 1;

                -- Insert the new subject with Is_Valid set to 1
                INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_Valid)
                VALUES (@StudentId, @SubjectId, 1);
            END
        END
        ELSE
        BEGIN
            -- Insert the new subject with Is_Valid set to 1 for a new student
            INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_Valid)
            VALUES (@StudentId, @SubjectId, 1);
        END

        FETCH NEXT FROM RequestCursor INTO @StudentId, @SubjectId;
    END

    CLOSE RequestCursor;
    DEALLOCATE RequestCursor;
END;
