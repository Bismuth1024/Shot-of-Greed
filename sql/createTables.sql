CREATE TABLE Users (
  user_id INT NOT NULL AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL,
  hashed_password VARCHAR(255) NOT NULL,
  email VARCHAR(255) DEFAULT NULL,
  birthdate DATE NOT NULL,
  gender ENUM('male', 'female') NOT NULL,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  CONSTRAINT Users_AK_Username UNIQUE (username),
  CONSTRAINT Users_AK_Email UNIQUE (email)
);

CREATE TABLE LoginSessions (
    login_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    token VARCHAR(64) NOT NULL,
    expiry DATETIME NOT NULL,
    PRIMARY KEY (login_id),
    CONSTRAINT LS_FK_User FOREIGN KEY (user_id)
      REFERENCES Users (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Drinks (
  drink_id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  description VARCHAR(1024) DEFAULT NULL,
  created_user_id INT NOT NULL DEFAULT 1,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  delete_time DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (drink_id),
  CONSTRAINT Drinks_AK_Name_User UNIQUE (name, created_user_id, delete_time),
  INDEX Drinks_IDX_Created_User (created_user_id),
  CONSTRAINT Drinks_FK_Created_User FOREIGN KEY (created_user_id) 
      REFERENCES Users (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Ingredients (
  ingredient_id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  ABV DECIMAL(5,2) NOT NULL CHECK (ABV BETWEEN 0 AND 100),
  description VARCHAR(1024) DEFAULT NULL,
  sugar_percent DECIMAL(5,2) NOT NULL CHECK (sugar_percent BETWEEN 0 AND 100),
  created_user_id INT NOT NULL,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  delete_time DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (ingredient_id),
  CONSTRAINT Ingredients_AK_Name_User UNIQUE (name, created_user_id, delete_time),
  INDEX Ingredients_IDX_Created_User (created_user_id),
  CONSTRAINT Ingredients_FK_Created_User FOREIGN KEY (created_user_id) 
      REFERENCES Users (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE DrinkIngredients (
  pairing_id INT NOT NULL AUTO_INCREMENT,
  ingredient_id INT NOT NULL,
  drink_id INT NOT NULL,
  volume DECIMAL(5,2) NOT NULL CHECK (volume > 0),
  PRIMARY KEY (pairing_id),
  INDEX DI_IDX_Ingredient (ingredient_id),
  INDEX DI_IDX_Drink (drink_id),
  CONSTRAINT DI_FK_Drink FOREIGN KEY (drink_id) 
      REFERENCES Drinks (drink_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT DI_FK_Ingredient FOREIGN KEY (ingredient_id) 
      REFERENCES Ingredients (ingredient_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Tags (
  tag_id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  type ENUM('Drink', 'Ingredient') NOT NULL,
  PRIMARY KEY (tag_id),
  CONSTRAINT Tags_AK_Name_Type UNIQUE (name, type)
);

CREATE TABLE DrinkTags (
  pairing_id INT NOT NULL AUTO_INCREMENT,
  drink_id INT NOT NULL,
  tag_id INT NOT NULL,
  PRIMARY KEY (pairing_id),
  CONSTRAINT DT_FK_Drink FOREIGN KEY (drink_id) 
      REFERENCES Drinks (drink_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT DT_FK_Tag FOREIGN KEY (tag_id) 
      REFERENCES Tags (tag_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IngredientTags (
  pairing_id INT NOT NULL AUTO_INCREMENT,
  ingredient_id INT NOT NULL,
  tag_id INT NOT NULL,
  PRIMARY KEY (pairing_id),
  CONSTRAINT IT_FK_Ingredient FOREIGN KEY (ingredient_id) 
      REFERENCES Ingredients (ingredient_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT IT_FK_Tag FOREIGN KEY (tag_id) 
      REFERENCES Tags (tag_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Sessions (
  session_id INT NOT NULL AUTO_INCREMENT,
  created_user_id INT NOT NULL,
  start_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  end_time DATETIME NULL,
  PRIMARY KEY (session_id),
  INDEX IDX_User (created_user_id),
  CONSTRAINT Sessions_FK_Created_User FOREIGN KEY (created_user_id) 
      REFERENCES Users (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE SessionDrinks (
  pairing_id INT NOT NULL AUTO_INCREMENT,
  session_id INT NOT NULL,
  drink_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  start_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  PRIMARY KEY (pairing_id),
  CONSTRAINT SD_FK_Session FOREIGN KEY (session_id) REFERENCES Sessions (session_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT SD_FK_Drink FOREIGN KEY (drink_id) REFERENCES Drinks (drink_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE VIEW DrinksInfo AS 
SELECT 
    d.drink_id AS drink_id, 
    d.name AS name, 
    d.created_user_id AS created_user_id, 
    u.username AS created_user_name, 
    d.create_time AS create_time, 
    i.ingredient_id AS ingredient_id, 
    i.name AS ingredient, 
    di.volume AS volume,
    d.delete_time AS delete_time
FROM 
    Drinks d
LEFT JOIN 
    DrinkIngredients di ON d.drink_id = di.drink_id
LEFT JOIN 
    Ingredients i ON i.ingredient_id = di.ingredient_id
LEFT JOIN 
    Users u ON d.created_user_id = u.user_id
ORDER BY 
    d.drink_id, i.ingredient_id;

CREATE VIEW DrinksOverview AS 
SELECT 
    d.drink_id AS drink_id,
    d.name AS name,
    d.created_user_id AS created_user_id,
    u.username AS created_user_name,
    d.create_time AS create_time,
    COUNT(i.ingredient_id) AS n_ingredients,
    ROUND(SUM(di.volume * i.ABV * 0.785 / 1000), 3) AS n_standards,
    ROUND(SUM(di.volume * i.sugar_percent / 100), 2) AS sugar_g,
    d.delete_time AS delete_time
FROM 
    Drinks d
LEFT JOIN 
    DrinkIngredients di ON d.drink_id = di.drink_id
LEFT JOIN 
    Ingredients i ON i.ingredient_id = di.ingredient_id
LEFT JOIN 
    Users u ON d.created_user_id = u.user_id
GROUP BY 
    d.drink_id;


CREATE VIEW SessionsInfo AS
SELECT
    s.session_id AS session_id,
    u.user_id AS user_id,
    u.username AS username,
    s.start_time AS start_time,
    s.end_time AS end_time,
    CONCAT(
        TIMESTAMPDIFF(HOUR, s.start_time, COALESCE(s.end_time, NOW())), ' hours, ',
        MOD(TIMESTAMPDIFF(MINUTE, s.start_time, COALESCE(s.end_time, NOW())), 60), ' minutes'
    ) AS duration,
    SUM(sd.quantity) AS n_drinks,
    ROUND(SUM(do.n_standards * sd.quantity), 3) AS total_standards,
    ROUND(SUM(do.sugar_g * sd.quantity), 2) AS total_sugar
FROM
    Sessions s
LEFT JOIN 
    Users u ON s.created_user_id = u.user_id
LEFT JOIN 
    SessionDrinks sd ON s.session_id = sd.session_id
LEFT JOIN
    DrinksOverview do ON sd.drink_id = do.drink_id
GROUP BY
    s.session_id;

CREATE VIEW TestView AS
SELECT
    s.session_id AS session_id,
    u.user_id AS user_id,
    ROUND(SUM(do.n_standards * sd.quantity), 3) AS total_standards

FROM
    Sessions s
LEFT JOIN 
    Users u ON s.created_user_id = u.user_id
LEFT JOIN 
    SessionDrinks sd ON s.session_id = sd.session_id
LEFT JOIN
    DrinksOverview do ON sd.drink_id = do.drink_id
GROUP BY
    s.session_id;


