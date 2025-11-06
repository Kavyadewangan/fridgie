-- Create Database
CREATE DATABASE fridgee;
USE fridgee;

-- Create Database
CREATE DATABASE SmartKitchenDB;
USE SmartKitchenDB;

-- ==========================
-- 1️⃣ Ingredients Table
-- ==========================
CREATE TABLE Ingredients (
    ingredient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    quantity FLOAT DEFAULT 0,
    unit VARCHAR(20),
    purchase_date DATE,
    expiry_date DATE,
    storage_location VARCHAR(50),
    food_type VARCHAR(50),
    notes TEXT,
    CHECK (quantity >= 0)
);

-- ==========================
-- 2️⃣ Recipes Table
-- ==========================
CREATE TABLE Recipes (
    recipe_id INT AUTO_INCREMENT PRIMARY KEY,
    recipe_name VARCHAR(100) NOT NULL,
    description TEXT,
    instructions TEXT,
    prep_time INT,
    cook_time INT,
    category VARCHAR(50)
);

-- ==========================
-- 3️⃣ Recipe_Ingredients (Mapping Table)
-- ==========================
CREATE TABLE Recipe_Ingredients (
    recipe_id INT,
    ingredient_name VARCHAR(100),
    quantity_required FLOAT,
    unit VARCHAR(20),
    PRIMARY KEY (recipe_id, ingredient_name),
    FOREIGN KEY (recipe_id) REFERENCES Recipes(recipe_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ==========================
-- 4️⃣ Alerts Table
-- ==========================
CREATE TABLE Alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    ingredient_id INT,
    alert_type VARCHAR(50),
    alert_date DATE,
    status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (ingredient_id) REFERENCES Ingredients(ingredient_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ==========================
-- 5️⃣ Example Trigger: Auto-generate alert for expiring items
-- ==========================
DELIMITER $$
CREATE TRIGGER check_expiry_before_insert
BEFORE INSERT ON Ingredients
FOR EACH ROW
BEGIN
    DECLARE days_left INT;
    SET days_left = DATEDIFF(NEW.expiry_date, CURDATE());
    
    IF days_left <= 2 THEN
        INSERT INTO Alerts (ingredient_id, alert_type, alert_date, status)
        VALUES (NEW.ingredient_id, 'Expiring Soon', CURDATE(), 'Pending');
    END IF;
END$$
DELIMITER ;

-- ==========================
-- 6️⃣ Example Query: Find Recipes you can make with expiring ingredients
-- ==========================
-- (You can run this manually)
-- Lists recipes that use ingredients expiring in 3 days or less

/*
SELECT DISTINCT r.recipe_name, r.category
FROM Recipes r
JOIN Recipe_Ingredients ri ON r.recipe_id = ri.recipe_id
WHERE ri.ingredient_name IN (
    SELECT name FROM Ingredients
    WHERE DATEDIFF(expiry_date, CURDATE()) <= 3
);
*/

-- ==========================
-- 7️⃣ Example Data Insert
-- ==========================
INSERT INTO Ingredients (name, quantity, unit, purchase_date, expiry_date, storage_location, food_type, notes)
VALUES 
('Cooked Rice', 0.5, 'kg', '2025-11-03', '2025-11-07', 'Fridge', 'Cooked', 'Use for fried rice'),
('Tomato', 3, 'pcs', '2025-11-04', '2025-11-08', 'Fridge', 'Vegetable', 'Slightly soft');

INSERT INTO Recipes (recipe_name, description, instructions, prep_time, cook_time, category)
VALUES
('Tomato Fried Rice', 'Quick leftover recipe using rice and tomato.', 
 'Mix chopped tomato and rice with spices. Stir-fry for 5 mins.', 10, 10, 'Lunch');

INSERT INTO Recipe_Ingredients (recipe_id, ingredient_name, quantity_required, unit)
VALUES
(1, 'Cooked Rice', 0.5, 'kg'),
(1, 'Tomato', 2, 'pcs');

