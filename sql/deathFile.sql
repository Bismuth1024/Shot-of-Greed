DELIMITER //

CREATE PROCEDURE DropAllProcedures()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE proc_name VARCHAR(255);
    DECLARE cur CURSOR FOR 
        SELECT ROUTINE_NAME 
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE ROUTINE_TYPE = 'PROCEDURE' 
          AND ROUTINE_SCHEMA = 'your_database_name';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO proc_name;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET @stmt = CONCAT('DROP PROCEDURE IF EXISTS `', proc_name, '`;');
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur;
END //

DELIMITER ;
