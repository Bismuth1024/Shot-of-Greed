DELIMITER //

CREATE PROCEDURE createUser (
	IN p_username VARCHAR(50),
  	IN p_password VARCHAR(255),
  	IN p_email VARCHAR(255),
  	IN p_birthdate DATE,
  	IN p_gender ENUM('male', 'female')
)
MODIFIES SQL DATA
BEGIN
	IF p_username IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Username must not be null';
	END IF;

	IF p_password IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Password must not be null';
	END IF;

	IF p_birthdate IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Birthdate must not be null';
	END IF;

	IF p_gender IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Gender must not be null';
	END IF;

	INSERT INTO Users (username, hashed_password, email, birthdate, gender)
	VALUES (p_username, p_password, p_email, p_birthdate, p_gender);

	SELECT LAST_INSERT_ID() AS new_user_id;
END //

DELIMITER ;

#-------------------------------------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE loginUser(
	IN p_user_id INT,
	IN p_token VARCHAR(64),
	IN p_expiry DATETIME
)
MODIFIES SQL DATA
BEGIN 
	INSERT INTO LoginSessions (user_id, token, expiry)
	VALUES (p_user_id, p_token, p_expiry);
END //

DELIMITER ;

#-------------------------------------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE createDrink (
	IN p_name VARCHAR(50),
	IN p_description VARCHAR(1024),
	IN p_created_user_id INT
)
MODIFIES SQL DATA
BEGIN
	-- Insert drink
	INSERT INTO Drinks (name, description, created_user_id)
	VALUES (p_name, p_description, p_created_user_id);

	IF ROW_COUNT() = 0 THEN
	    SIGNAL SQLSTATE '45000'
    	SET MESSAGE_TEXT = 'New drink could not be created (maybe naming conflict?)';
	END IF;

	SELECT LAST_INSERT_ID() AS new_drink_id;
END //
DELIMITER ;

#-------------------------------------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE addIngredientToDrink (
	IN p_ingredient_id INT,
	IN p_drink_id INT,
	IN p_volume DECIMAL(5,2)
)
MODIFIES SQL DATA
BEGIN
	INSERT INTO DrinkIngredients (ingredient_id, drink_id, volume)
	VALUES (p_ingredient_id, p_drink_id, p_volume);
END //
DELIMITER ;

#-------------------------------------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE deleteDrink(
	IN p_drink_id INT,
	IN p_user_id INT
)

MODIFIES SQL DATA

BEGIN
	UPDATE Drinks
	SET delete_time = CURRENT_TIMESTAMP
	WHERE drink_id = p_drink_id AND created_user_id = p_user_id;

	IF ROW_COUNT() = 0 THEN
	    SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'No drink under this user with that ID exists';
	END IF;

END //

DELIMITER ;

#-------------------------------------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE createTag(
	IN p_name VARCHAR(50),
	IN p_type ENUM('Drink', 'Ingredient')
)

MODIFIES SQL DATA

BEGIN

INSERT IGNORE INTO  Tags (name, type)
VALUES (p_name, p_type);
IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Tag of that name and type (ingredient/drink) already exists';
END IF;

END //
DELIMITER ;

#-------------------------------------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE createIngredient(
	IN p_name VARCHAR(50),
	IN p_ABV DECIMAL(5,2),
	IN p_description VARCHAR(1024),
	IN p_sugar_percent DECIMAL(5,2),
	IN p_created_user_id INT
)

MODIFIES SQL DATA

BEGIN
	IF p_created_user_id IS NULL THEN
		SET p_created_user_id = 1;
	END IF;

	INSERT INTO Ingredients (name, ABV, description, sugar_percent, created_user_id)
	VALUES (p_name, p_ABV, p_description, p_sugar_percent, p_created_user_id);

	IF ROW_COUNT() = 0 THEN
	    SIGNAL SQLSTATE '45000'
    	SET MESSAGE_TEXT = 'New ingredient could not be created (maybe naming conflict?)';
	END IF;

	SELECT LAST_INSERT_ID() as new_ingredient_id;
END //

DELIMITER ;

#-------------------------------------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE deleteIngredient(
	IN p_ingredient_id INT,
	IN p_user_id INT
)

MODIFIES SQL DATA

BEGIN
	UPDATE Ingredients
	SET delete_time = CURRENT_TIMESTAMP
	WHERE ingredient_id = p_ingredient_id AND created_user_id = p_user_id;

	IF ROW_COUNT() = 0 THEN
	    SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'No ingredient under this user with that ID exists';
	END IF;

END //

DELIMITER ;

#-------------------------------------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE addTagToIngredient(
	IN p_ingredient_id INT,
	IN p_tag_name VARCHAR(50)
)
MODIFIES SQL DATA

BEGIN
	DECLARE p_tag_id INT;

	SELECT tag_id
	INTO p_tag_id 
	FROM Tags
	WHERE name = p_tag_name AND type = 'Ingredient'
	LIMIT 1;

	IF p_tag_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Tag not found';
	END IF;

	INSERT INTO IngredientTags (ingredient_id, tag_id)
        VALUES (p_ingredient_id, p_tag_id);

END //

DELIMITER ;

#-------------------------------------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE createSession(
	IN p_user_id INT
)

MODIFIES SQL DATA

BEGIN
	INSERT INTO Sessions (created_user_id)
	VALUES (p_user_id);

	IF ROW_COUNT() = 0 THEN
	    SIGNAL SQLSTATE '45000'
    	SET MESSAGE_TEXT = 'New session could not be created (idk why?)';
	END IF;

	SELECT LAST_INSERT_ID() as new_session_id;
END //

DELIMITER ;

------------------------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE addDrinkToSession(
	IN p_session_id INT,
	IN p_drink_id INT,
	IN p_quantity INT,
	IN p_start_time DATETIME,
	IN p_end_time DATETIME
)

MODIFIES SQL DATA

BEGIN
	INSERT INTO SessionDrinks (session_id, drink_id, quantity, start_time, end_time)
	VALUES (p_session_id, p_drink_id, p_quantity, p_start_time, p_end_time);

	IF ROW_COUNT() = 0 THEN
	    SIGNAL SQLSTATE '45000'
    	SET MESSAGE_TEXT = 'New session drink could not be logged (idk why?)';
	END IF;

	SELECT LAST_INSERT_ID() as new_pairing_id; # so that we can save it in the UI
END //

DELIMITER ;

------------------------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE removeDrinkFromSession(
	IN p_pairing_id INT,
	IN p_user_id INT
)

MODIFIES SQL DATA

BEGIN
	# Check that this sessiondrink pairing belongs to the user's session
	IF NOT EXISTS (
		SELECT 1 FROM SessionDrinks sd
		JOIN Sessions s ON sd.session_id = s.session_id
		WHERE s.created_user_id = p_user_id
		AND sd.pairing_id = p_pairing_id
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'The session drink is invalid or does not belong to the given user';
	END IF;

	DELETE FROM SessionDrinks
	WHERE pairing_id = p_pairing_id;

	IF ROW_COUNT() = 0 THEN
	    SIGNAL SQLSTATE '45000'
    	SET MESSAGE_TEXT = 'Drink could not be deleted from session (probably bad ID)';
	END IF;
END //

DELIMITER ;

------------------------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE deleteSession(
	IN p_session_id INT,
	IN p_user_id INT
)

MODIFIES SQL DATA

BEGIN
	DELETE FROM Sessions
	WHERE session_id = p_session_id AND created_user_id = p_user_id;

	IF ROW_COUNT() = 0 THEN
	    SIGNAL SQLSTATE '45000'
    	SET MESSAGE_TEXT = 'Session could not be deleted or does not belong to the given user';
	END IF;
END //

DELIMITER ;

------------------------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE parseDrinkTemp (
	IN p_created_user_id INT,
	IN p_name VARCHAR(50),
	IN p_tags VARCHAR(255), 
	IN str VARCHAR(1024)
)
MODIFIES SQL DATA
BEGIN
	DECLARE current_pos INT DEFAULT 1;
	DECLARE len INT;
	DECLARE ingredient_name VARCHAR(1024);
	DECLARE token VARCHAR(1024);
	DECLARE delim_pos INT;
	DECLARE test_ingredient INT;
	DECLARE new_drink_id INT;
	DECLARE new_tag_id INT;

	START TRANSACTION;

	INSERT INTO Drinks (name, created_user_id)
	VALUES (p_name, p_created_user_id);

	SELECT LAST_INSERT_ID() INTO new_drink_id;

	-- Parse ingredients
	SET len = LENGTH(str);

	WHILE current_pos <= len DO
		SET delim_pos = LOCATE(',', str, current_pos);
		IF delim_pos = 0 THEN
			SET delim_pos = len + 1; 
		END IF;

		SET token = TRIM(SUBSTRING(str, current_pos, delim_pos - current_pos));

		IF ingredient_name IS NULL THEN
			SET ingredient_name = token;
		ELSE 


			SELECT ingredient_id INTO test_ingredient
		    FROM Ingredients
		    WHERE name = ingredient_name AND created_user_id = 1
		    LIMIT 1;

		    IF test_ingredient IS NULL THEN
				ROLLBACK;
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Error: Ingredient not found';
			END IF;

			INSERT INTO DrinkIngredients (ingredient_id, drink_id, volume)
			SELECT 
				ingredient_id, 
				new_drink_id, 
    			CONVERT(token, DECIMAL(5,2))
    		FROM Ingredients
			WHERE name = ingredient_name;

			SET ingredient_name = NULL;
		END IF;

		SET current_pos = delim_pos + 1;
	END WHILE;
	
	IF ingredient_name IS NOT NULL THEN
		ROLLBACK;
    	SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Mismatched ingredients and volumes';
	END IF;

	-- Parse tags
	SET len = LENGTH(p_tags);
	SET current_pos = 1;

	WHILE current_pos <= len DO
		SET delim_pos = LOCATE(',', p_tags, current_pos);
		IF delim_pos = 0 THEN
			SET delim_pos = len + 1; 
		END IF;

		SET token = TRIM(SUBSTRING(p_tags, current_pos, delim_pos - current_pos));

		SELECT tag_id INTO new_tag_id
        FROM Tags
        WHERE name = token AND type = 'Drink'
        LIMIT 1;

        IF new_tag_id IS NULL THEN
       		ROLLBACK;
        	SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Tag not found';
        END IF;

        INSERT INTO DrinkTags (drink_id, tag_id)
        VALUES (new_drink_id, new_tag_id);

		SET current_pos = delim_pos + 1;
	END WHILE;

	COMMIT;

END //
DELIMITER ;

#-------------------------------------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE createIngredientTemp(
	IN p_name VARCHAR(50),
	IN p_ABV DECIMAL(5,2),
	IN p_sugar_percent DECIMAL(5,2),
	IN p_tags VARCHAR(255),
	IN p_created_user_id INT,
	IN p_description VARCHAR(1024),
	IN p_create_time DATETIME
)
MODIFIES SQL DATA

BEGIN
	DECLARE current_pos INT DEFAULT 1;
	DECLARE len INT;
	DECLARE token VARCHAR(1024);
	DECLARE delim_pos INT;
	DECLARE new_ingredient_id INT;
	DECLARE new_tag_id INT;

	IF p_created_user_id IS NULL THEN
        SET p_created_user_id = 1;
    END IF;

	IF p_create_time IS NULL THEN
        SET p_create_time = CURRENT_TIMESTAMP;
    END IF;


	IF p_ABV < 0 OR p_ABV > 100 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: ABV must be a percentage';
	END IF;

	IF p_sugar_percent < 0 OR p_sugar_percent > 100 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: sugar must be a percentage';
	END IF;


	START TRANSACTION;

	INSERT INTO Ingredients (name, ABV, sugar_percent, description, created_user_id, create_time)
	VALUES (p_name, p_ABV, p_sugar_percent, p_description, p_created_user_id, p_create_time);
	IF ROW_COUNT() = 0 THEN
		ROLLBACK;
	    SIGNAL SQLSTATE '45000'
    	SET MESSAGE_TEXT = 'New ingredient could not be created (maybe naming conflict?)';
	END IF;

	SELECT ingredient_id 
	INTO new_ingredient_id
	FROM Ingredients
	WHERE name = p_name AND created_user_id = p_created_user_id;

	SET len = LENGTH(p_tags);
	SET current_pos = 1;

	WHILE current_pos <= len DO
		SET delim_pos = LOCATE(',', p_tags, current_pos);
		IF delim_pos = 0 THEN
			SET delim_pos = len + 1; 
		END IF;

		SET token = TRIM(SUBSTRING(p_tags, current_pos, delim_pos - current_pos));

		SELECT tag_id INTO new_tag_id
        FROM Tags
        WHERE name = token AND type = 'Ingredient'
        LIMIT 1;

        IF new_tag_id IS NULL THEN
       		ROLLBACK;
        	SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Tag not found';
        END IF;

        INSERT INTO IngredientTags (ingredient_id, tag_id)
        VALUES (new_ingredient_id, new_tag_id);

		SET current_pos = delim_pos + 1;
	END WHILE;

	COMMIT;
END //

DELIMITER ;

