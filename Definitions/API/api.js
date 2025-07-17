//USR LOCAL MARIADB_REST

const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const https = require('https');
const fs = require('fs');

const app = express();

require('dotenv').config(); // Load secret values from .env file

// Load SSL/TLS certificate and key
const sslOptions = {
    key: fs.readFileSync(process.env.SSL_KEY_PATH), // Private key
    cert: fs.readFileSync(process.env.SSL_CERT_PATH) // Certificate
};

// Middleware
app.use(bodyParser.json());

// Database connection pool
const pool = mysql.createPool({
    host: process.env.DB_HOST, // Replace with your DB host
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: 'Yesh',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

function JSDateToSQL(date) {
    return date.toISOString().replace('T', ' ').split('.')[0];
}

function JSDateToSwift(date) {
    return date.toISOString().split('.')[0] + 'Z';
}

function HTTPerror(code, message) {
    return { code: code, message: message, isHTTPError: true }
}

function handleAPIerror(res, error) {
    console.log(JSON.stringify(error))
    if (error.isHTTPError) {
        return res.status(error.code).json({ error_message: error.message });
    }

    const { sqlMessage } = error;
    console.error('Internal server error:', error);
    console.log(sqlMessage)

    let message = '';

    if (sqlMessage === undefined) {
        message = 'Unknown internal server error'
    } else if (sqlMessage.includes('Users_AK_Email')) {
        message = 'That email is already taken. Please choose a different email.'
    } else if (sqlMessage.includes('Users_AK_Username')) {
        message = 'That username is already taken. Please choose a different username.'
    } else if (sqlMessage.includes('Drinks_AK_Name_User')) {
        message = 'This user already has a drink of this name'
    } else if (sqlMessage.includes('Ingredients_AK_Name_User')) {
        message = 'This user already has an ingredient of this name'
    } else {
        message = 'Unknown internal server error'
    }

    return res.status(500).json({ error_message: message });
}

const authenticateToken = (required = true) => {
    return async (req, res, next) => {
        const authHeader = req.headers['authorization'];
        const token = authHeader?.split(' ')[1];
        req.authStatus = 'no_token';
        req.user_id = undefined;

        if (token === undefined) {
            if (required) {
                throw HTTPerror(401, 'Unauthorized: No token provided');
            } else {
                return next(); // Allow unauthenticated access
            }
        }

        const connection = await pool.getConnection();

        try {
            const [rows] = await connection.query(
                'SELECT expiry, user_id FROM LoginSessions WHERE token = ?',
                [token]
            );

            if (rows.length === 0) {
                req.authStatus = 'invalid_token';
                throw HTTPerror(401, 'Unauthorized: Invalid token');
            }

            const [{ user_id, expiry }] = rows;

            if (expiry < Date.now()) {
                req.authStatus = 'expired_token';
                throw HTTPerror(401, 'Unauthorized: Token expired');
            }

            req.authStatus = 'valid_token';
            req.user_id = user_id;
            return next();
        
        } catch (error) {
            handleAPIerror(res, error);
        } finally {
            connection.release();
        }
    };
};

app.get('/api/rtt', async (req, res) => {
    res.status(200).send();
});

app.post('/api/users', async (req, res) => {
    const { username, password, email, birthdate, gender } = req.body;

    if (username === undefined || password === undefined) {
        throw HTTPerror(400, 'Missing username or password');
    }

    if (birthdate === undefined || gender === undefined) {
        throw HTTPerror(400, 'Missing fields');
    }

    const connection = await pool.getConnection();
    try {
        //First hash the plaintext password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Call stored procedure to create a user
        const [[[{ new_user_id }]]] = await connection.query(
            'CALL createUser(?, ?, ?, ?, ?)',
            [username, hashedPassword, email, birthdate, gender]
        );
        res.status(201).send({ new_user_id });

    } catch (error) {
        handleAPIerror(res, error);
    } finally {
        connection.release();
    }

});

app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;

    if (username === undefined || password === undefined) {
        throw HTTPerror(401, 'Username or password missing');
    }

    const connection = await pool.getConnection();

    try {
        const [rows] = await connection.query(
            'SELECT user_id, hashed_password FROM Users WHERE username = ?',
            [username]
        );

        //No user of this username found:
        if (rows.length == 0) {
            throw HTTPerror(401, 'Invalid username or password (user)')
        }

        const [{ user_id, hashed_password }] = rows;

        //Check password validity
        const isValidPassword = await bcrypt.compare(password, hashed_password);
        if (!isValidPassword) {
            throw HTTPerror(401, 'Invalid username or password (user)')
        }

        // Generate a random token
        const token = crypto.randomBytes(16).toString('hex');  // Generates a 32-character hexadecimal string
        const expiryTime = new Date(Date.now() + 1000 * 60 * 60 * 24 * 7); // one week

        const convertedTime = JSDateToSQL(expiryTime); //Convert to mariadb
        
        await connection.query(
            'CALL loginUser(?, ?, ?)',
            [user_id, token, convertedTime]
        );

        //Because apple lied and swift iso8601 actually doesnt handle it properly
        res.status(201).send({ user_id, login_token: token, expiry: JSDateToSwift(expiryTime) });

    } catch (error) {
        handleAPIerror(res, error)
    } finally {
        connection.release();
    }

    
});

function formatIngredient(raw) {
    return {
        ...raw,
        id: raw.ingredient_id, // Rename 'ingredient_id' to 'id' for Codable Swift
        ingredient_id: undefined,
        sugar_percent: undefined,
        delete_time: undefined, // Don't include this
        create_time: JSDateToSwift(raw.create_time),
        ABV: parseFloat(raw.ABV), // Convert ABV from string to number
        sugarPercent: parseFloat(raw.sugar_percent), // Convert sugar_percent from string to number
    };
}

//Ingredients endpoints
app.get('/api/ingredients', authenticateToken(false), async (req, res) => {
    const { name, min_ABV, max_ABV, min_sugar, max_sugar, min_date, max_date, include_tag_ids, require_all_tags, exclude_tag_ids, include_public } = req.query;
    const user_id = req.user_id;
    const include_tags_array = (include_tag_ids === undefined) ? [] : include_tag_ids.split(',').map(Number).filter(id => !isNaN(id))
    const exclude_tags_array = (exclude_tag_ids === undefined) ? [] : exclude_tag_ids.split(',').map(Number).filter(id => !isNaN(id))
    // Build the base SQL query

    let query = `
        SELECT 
            i.ingredient_id,
            i.created_user_id,
            i.create_time,
            i.description,
            i.name,
            i.ABV,
            i.sugar_percent,
            t.tag_id,
            t.name AS tag_name,
            t.type AS tag_type
     FROM Ingredients i 
     JOIN IngredientTags it ON i.ingredient_id = it.ingredient_id
     JOIN Tags t ON it.tag_id = t.tag_id
     WHERE i.delete_time IS NULL AND i.created_user_id
     `
    let queryParams = [];

    if (user_id === undefined) {
        // Unauthenticated case: only return public ingredients
        query += ' = 1';
    } else {
        // Authenticated case
        if (include_public === 'true') {
            query += ' IN (1, ?)'
        } else {
            query += ' = ?';
        }
        queryParams.push(user_id)
    }

    if (include_tags_array.length > 0) {
        const placeholders = '(' + include_tags_array.map(() => '?').join(',') + ')' // Forms the question marks eg (?,?,?)
        query += ` 
            AND i.ingredient_id IN (
                SELECT it.ingredient_id
                FROM IngredientTags it
                WHERE it.tag_id IN ${placeholders}
        `
        queryParams.push(...include_tags_array);

        if (require_all_tags === 'true') {
            query += `
                GROUP BY it.drink_id
                HAVING COUNT(DISTINCT it.tag_id) = ?
            `
            queryParams.push(include_tags_array.length);
        }

        query += ')'
    }

    if (exclude_tags_array.length > 0) {
        const placeholders = '(' + exclude_tags_array.map(() => '?').join(',') + ')'
        query += `
            AND NOT EXISTS (
                SELECT 1
                FROM IngredientTags it2
                WHERE it2.ingredient_id = i.ingredient_id
                AND it2.tag_id IN ${placeholders}
            )
        `
        queryParams.push(...exclude_tags_array);
    }
    if (name !== undefined) {
        query += ' AND name = ?';
        queryParams.push(name);
    }
    
    if (min_ABV !== undefined) {
        query += ' AND ABV >= ?';
        queryParams.push(min_ABV);
    }
    
    if (max_ABV !== undefined) {
        query += ' AND ABV <= ?';
        queryParams.push(max_ABV);
    }
    
    if (min_sugar !== undefined) {
        query += ' AND sugar_percent >= ?';
        queryParams.push(min_sugar);
    }
    
    if (max_sugar !== undefined) {
        query += ' AND sugar_percent <= ?';
        queryParams.push(max_sugar);
    }
    
    if (min_date !== undefined) {
        query += ' AND create_time >= ?';
        queryParams.push(min_date);  // Ensure this is in the correct format, e.g., 'YYYY-MM-DD'
    }
    
    if (max_date !== undefined) {
        query += ' AND create_time <= ?';
        queryParams.push(max_date);  // Ensure this is in the correct format, e.g., 'YYYY-MM-DD'
    }
    
    //TODO INGREDIENT IDS
    // Execute the query
    const connection = await pool.getConnection();
    try {
        const [rows] = await connection.query(query, queryParams);
        const ingredientMap = new Map();

        for (const row of rows) {
            const ingredient_id = row.ingredient_id;

            if (!ingredientMap.has(ingredient_id)) {
                const { name, created_user_id, create_time, description, ABV, sugar_percent } = row;
                ingredientMap.set(ingredient_id, {
                    ingredient_id,
                    created_user_id,
                    create_time,
                    description,
                    name,
                    ABV,
                    sugar_percent,
                    tags: []
                });
            }

            if (row.tag_id) {
                ingredientMap.get(ingredient_id).tags.push({
                    id: row.tag_id,
                    name: row.tag_name,
                    type: row.tag_type
                });
            }
        }

        const ingredients = Array.from(ingredientMap.values());
        res.status(200).send(ingredients.map((i) => formatIngredient(i)));

    } catch (error) {
        handleAPIerror(res, error);
    } finally {
        connection.release();
    }
});

app.post('/api/ingredients', authenticateToken(true), async (req, res) => {
    const { description = null, name, ABV, sugarPercent, tags } = req.body;
    const user_id = req.user_id;

    if (!name || !ABV || !sugarPercent) {
        throw HTTPerror(400, 'Missing some of the required parameters');
    }

    const connection = await pool.getConnection();

    try {
        const [[[{ new_ingredient_id }]]] = await connection.query(
            'CALL createIngredient(?, ?, ?, ?, ?)',
            [name, ABV, description, sugarPercent, user_id]
        );
        res.status(201).send({ new_ingredient_id });

    } catch (error) {
        handleAPIerror(res, error);
    } finally {
        connection.release();
    }
});

app.delete('/api/ingredients/:ingredient_id', authenticateToken(true), async (req, res) => {
    const { ingredient_id } = req.params;
    const user_id = req.user_id;

    if (ingredient_id === undefined) {
        throw HTTPerror(400, 'Missing ID of the ingredient to delete');
    }

    const connection = await pool.getConnection();

    try {
        await connection.query(
            'CALL deleteIngredient(?, ?)',
            [ingredient_id, user_id]
        );
        res.status(204).send();

    } catch (error) {
        handleAPIerror(res, error);
    } finally {
        connection.release();
    }
});

// Drink endpoints
app.get('/api/drinks', authenticateToken(false), async (req, res) => {
    const {name, min_standards, max_standards, min_sugar, max_sugar, min_ingredients, max_ingredients, min_date, max_date, include_ingredient_ids, require_all_ingredients, exclude_ingredient_ids, include_tag_ids, exclude_tag_ids, require_all_tags, include_public } = req.query;
    const user_id = req.user_id;

    console.log(include_tag_ids)

    const include_ingredients_array = (include_ingredient_ids === undefined) ? [] : include_ingredient_ids.split(',').map(Number).filter(id => !isNaN(id))
    const exclude_ingredients_array = (exclude_ingredient_ids === undefined) ? [] : exclude_ingredient_ids.split(',').map(Number).filter(id => !isNaN(id))
    const include_tags_array = (include_tag_ids === undefined) ? [] : include_tag_ids.split(',').map(Number).filter(id => !isNaN(id))
    const exclude_tags_array = (exclude_tag_ids === undefined) ? [] : exclude_tag_ids.split(',').map(Number).filter(id => !isNaN(id))

    let query = `
        SELECT
            do.drink_id AS id,
            do.name AS name,
            do.created_user_id AS created_user_id,
            do.created_user_name AS created_user_name,
            do.create_time AS create_time,
            do.n_ingredients AS n_ingredients,
            do.n_standards AS n_standards,
            do.sugar_g AS sugar_g
        FROM DrinksOverview do
        WHERE do.delete_time IS NULL
        AND do.created_user_id 
    `

    let queryParams = [];

    if (user_id === undefined) {
        // Unauthenticated case: only return public ingredients
        query += ' = 1';
    } else {
        // Authenticated case
        if (include_public === 'true') {
            query += ' IN (1, ?)'
        } else {
            query += ' = ?';
        }
        queryParams.push(user_id)
    }

    // Additional statements for including certain ingredient IDs
    if (include_ingredients_array.length > 0) {
        const placeholders = '(' + include_ingredients_array.map(() => '?').join(',') + ')' // Forms the question marks eg (?,?,?)
        query += ` 
            AND do.drink_id IN (
                SELECT di.drink_id
                FROM DrinkIngredients di
                WHERE di.ingredient_id IN ${placeholders}
        `
        queryParams.push(...include_ingredients_array);

        if (require_all_ingredients === 'true') {
            query += `
                GROUP BY di.drink_id
                HAVING COUNT(DISTINCT di.ingredient_id) = ?
            `
            queryParams.push(include_ingredients_array.length);
        }

        query += ')'
    }

    if (exclude_ingredients_array.length > 0) {
        const placeholders = '(' + exclude_ingredients_array.map(() => '?').join(',') + ')'
        query += `
            AND NOT EXISTS (
                SELECT 1
                FROM DrinkIngredients di2
                WHERE di2.drink_id = do.drink_id
                AND di2.ingredient_id IN ${placeholders}
            )
        `
        queryParams.push(...exclude_ingredients_array);
    }

    if (include_tags_array.length > 0) {
        const placeholders = '(' + include_tags_array.map(() => '?').join(',') + ')' // Forms the question marks eg (?,?,?)
        query += ` 
            AND do.drink_id IN (
                SELECT dt.drink_id
                FROM DrinkTags dt
                WHERE dt.tag_id IN ${placeholders}
        `
        queryParams.push(...include_tags_array);

        if (require_all_tags === 'true') {
            query += `
                GROUP BY dt.drink_id
                HAVING COUNT(DISTINCT dt.tag_id) = ?
            `
            queryParams.push(include_tags_array.length);
        }

        query += ')'
    }

    if (exclude_tags_array.length > 0) {
        const placeholders = '(' + exclude_tags_array.map(() => '?').join(',') + ')'
        query += `
            AND NOT EXISTS (
                SELECT 1
                FROM DrinkTags dt2
                WHERE dt2.drink_id = do.drink_id
                AND dt2.tag_id IN ${placeholders}
            )
        `
        queryParams.push(...exclude_tags_array);
    }

    if (name !== undefined) {
        query += ' AND do.name = ?';
        queryParams.push(name);
    }
    
    if (min_standards !== undefined) {
        query += ' AND do.n_standards >= ?';
        queryParams.push(min_standards);
    }
    
    if (max_standards !== undefined) {
        query += ' AND do.n_standards <= ?';
        queryParams.push(min_standards);
    }
    
    if (min_sugar !== undefined) {
        query += ' AND do.sugar_g >= ?';
        queryParams.push(min_sugar);
    }
    
    if (max_sugar !== undefined) {
        query += ' AND do.sugar_g <= ?';
        queryParams.push(max_sugar);
    }
    
    if (min_ingredients !== undefined) {
        query += ' AND do.n_ingredients >= ?';
        queryParams.push(min_ingredients);
    }
    
    if (max_ingredients !== undefined) {
        query += ' AND do.n_ingredients <= ?';
        queryParams.push(max_ingredients);
    }
    
    if (min_date !== undefined) {
        query += ' AND do.create_time >= ?';
        queryParams.push(min_date);  // Ensure this is in the correct format, e.g., 'YYYY-MM-DD'
    }
    
    if (max_date !== undefined) {
        query += ' AND do.create_time <= ?';
        queryParams.push(max_date);  // Ensure this is in the correct format, e.g., 'YYYY-MM-DD'
    }

    console.log(query)

    // Execute the query
    const connection = await pool.getConnection();
    try {
        const [rows] = await connection.query(query, queryParams);
        results = rows.map(row => ({
            ...row,
            sugar_g: parseFloat(row.sugar_g),
            create_time: JSDateToSwift(row.create_time),
            n_standards: parseFloat(row.n_standards)
        }));
        res.status(200).json(results); // Return the results as JSON
    } catch (error) {
        handleAPIerror(res, error);
    } finally {
        connection.release();
    }
});

app.get('/api/drinks/:drink_id', authenticateToken(false), async (req, res) => {
    const { drink_id } = req.params;
    const user_id = req.user_id;

    if (drink_id === undefined) {
        throw HTTPerror(400, 'Missing ID of the drink to get')
    }

    let query = `
        SELECT 
            d.drink_id AS drink_id,
            d.created_user_id AS created_user_id,
            d.name AS drink_name,
            d.create_time AS drink_time,
            i.ingredient_id AS ingredient_id,
            i.name AS ingredient_name,
            i.ABV AS ingredient_ABV,
            i.sugar_percent AS ingredient_sugar,
            i.created_user_id AS ingredient_user,
            i.create_time AS ingredient_time,
            i.description AS ingredient_description,
            di.volume AS volume
        FROM DrinksOverview d
        JOIN DrinkIngredients di ON d.drink_id = di.drink_id
        JOIN Ingredients i ON di.ingredient_id = i.ingredient_id
        WHERE d.delete_time IS NULL 
        AND d.drink_id = ?
        AND d.created_user_id
    `
    let queryParams = [drink_id];

    if (user_id === undefined) {
        // Unauthenticated case: only return public drinks
        query += ' = 1';
    } else {
        // Authenticated case
        if (include_public === 'true') {
            query += ' IN (1, ?)'
        } else {
            query += ' = ?';
        }
        queryParams.push(user_id)
    }

    const connection = await pool.getConnection();

    try {
        let [rows] = await connection.query(query, queryParams);
        let drink = undefined;

        for (const row of rows) {
            const {
                drink_id,
                created_user_id,
                drink_name,
                drink_time,
                ingredient_id,
                ingredient_name,
                ingredient_ABV,
                ingredient_sugar,
                ingredient_user,
                ingredient_time,
                ingredient_description,
                volume
            } = row;

            if (drink === undefined) {
                drink = {
                    id: drink_id,
                    create_time: drink_time,
                    created_user_id: created_user_id,
                    name: drink_name,
                    ingredients: [],
                    tags: []
                }
            }

            drink.ingredients.push({
                "ingredientType": formatIngredient({
                    ingredient_id: ingredient_id,
                    name: ingredient_name,
                    sugar_percent: ingredient_sugar,
                    ABV: ingredient_ABV,
                    create_time: ingredient_time,
                    created_user_id: ingredient_user,
                    description: ingredient_description,
                    tags: [],
                }),
                
                "volume": volume
            });
        }
        // Query 2: get the tags for each ingredient
        query = `
            SELECT
                it.ingredient_id AS ingredient_id,
                t.tag_id AS tag_id,
                t.name AS tag_name,
                t.type AS tag_type
            FROM IngredientTags it
            JOIN Tags t ON it.tag_id = t.tag_id
            WHERE it.ingredient_id IN (
                SELECT ingredient_id FROM DrinkIngredients WHERE drink_id = ?
            )
        `
        queryParams = [drink_id];

        [rows] = await connection.query(query, queryParams);
        for (const row of rows) {
            const { ingredient_id, tag_id, tag_name, tag_type } = row;
            const ingredient = drink.ingredients.find(item => item.ingredientType.id === ingredient_id);
            if (ingredient) ingredient.ingredientType.tags.push({
                id: tag_id,
                name: tag_name,
                type: tag_type
            });
        }


        // Now the JSON drink has everything except the tags

        query = `
            SELECT 
                t.tag_id AS tag_id,
                t.name AS tag_name,
                t.type AS tag_type
            FROM DrinkTags dt
            JOIN Tags t ON dt.tag_id = t.tag_id
            WHERE dt.drink_id = ?
        `
        queryParams = [drink_id];

        [rows] = await connection.query(query, queryParams);
        for (const row of rows) {
            const { tag_id, tag_name, tag_type } = row;
            drink.tags.push({
                id: tag_id,
                name: tag_name,
                type: tag_type
            });
        }

        res.status(200).json(drink);
    } catch (error) {
        handleAPIerror(res, error);
    } finally {
        connection.release();
    }
});

app.post('/api/drinks', authenticateToken(true), async (req, res) => {
    const { drink } = req.body;
    const user_id = req.user_id;

    const { name, description = null, ingredients, tags } = drink;

    if (name === undefined || !Array.isArray(ingredients) || ingredients.length == 0) {
        throw HTTPerror(401, 'Missing some of the required parameters')
    }

    const connection = await pool.getConnection();
    try {
        // Start a transaction
        await connection.beginTransaction();

        // Call stored procedure to create a drink
        const [[[{ new_drink_id }]]] = await connection.query(
            'CALL createDrink(?, ?, ?)',
            [name, description, user_id]
        );


        // Add ingredients to the drink
        for (const ingredient of ingredients) {
            const { ingredientType, volume } = ingredient;
            const { id } = ingredientType;

            if (id === undefined || volume === undefined) {
                throw HTTPerror(401, 'One of the ingredients is invalid');
            }
            await connection.query(
                'CALL addIngredientToDrink(?, ?, ?)',
                [id, new_drink_id, volume]
            );
        }

        for (const tag of tags) {
            const { id } = tag;
            if (id === undefined) {
                throw HTTPerror(401, 'One of the tags is invalid');
            }
            await connection.query(
                'CALL addTagToDrink(?, ?)',
                [new_drink_id, id]
            );
        }

        // Commit the transaction
        await connection.commit();
        res.status(201).send({ new_drink_id });

    } catch (error) {
        // Rollback on error
        await connection.rollback();
        handleAPIerror(res, error);
    } finally {
        connection.release();
    }
});

app.delete('/api/drinks/:drink_id', authenticateToken(false), async (req, res) => {
    const { drink_id } = req.params;
    const user_id = req.user_id;

    if (drink_id === undefined) {
        throw HTTPerror(400, 'Missing ID of the drink to delete')
    }

    const connection = await pool.getConnection();
    try {
        await connection.query(
            'CALL deleteDrink(?, ?)',
            [drink_id, user_id]
        );
        res.status(204).send();
    } catch (error) {
        handleAPIerror(res, error);
    } finally {
        connection.release();
    }
});

//Sessions endpoints

app.post('/api/sessions', authenticateToken(true), async (req, res) => {
    const user_id = req.user_id;
    const connection = await pool.getConnection();
    try {
        const [[[{ new_session_id}]]] = await connection.query('CALL createSession(?)', [user_id]);
        res.status(201).json({ new_session_id });
    } catch (error) {
        handleAPIerror(res, error);
    } finally {
        connection.release();
    }
});

app.post('/api/sessions/:session_id/sessiondrinks', authenticateToken(true), async (req, res) => {
    const { session_id } = req.params;
    const user_id = req.user_id;
    const { drink_id, quantity = 1, start_time = null, end_time = null } = req.body;

    if (drink_id === undefined) {
        throw HTTPerror(400, 'Missing drink ID');
    }

    const connection = await pool.getConnection();

    try {
        // Check that this session belongs to the user
        const [rows] = await connection.query(
            'SELECT 1 FROM Sessions WHERE session_id = ? AND created_user_id = ? LIMIT 1',
            [session_id, user_id]
        );

        if (rows.length === 0) {
            throw HTTPerror(400, 'No session of that ID exists under this user');
        }

        const [[[{ new_pairing_id }]]] = await connection.query(
            'CALL addDrinkToSession(?, ?, ?, ?, ?)',
            [session_id, drink_id, quantity, start_time, end_time]
        );
        res.status(201).send({ new_pairing_id });
    } catch (error) {
        handleAPIerror(res, error);
    } finally {
        connection.release();
    }
    

});

app.delete('/api/sessions/:session_id', authenticateToken(true), async (req, res) => {
    const { session_id } = req.params;
    const user_id = req.user_id;

    if (session_id === undefined) {
        throw HTTPerror(400, 'Missing ID of the session to delete')
    }

    const connection = await pool.getConnection();

    try {
        await connection.query(
            'CALL deleteSession(?, ?)',
            [session_id, user_id]
        );
        res.status(204).send();

    } catch (error) {
        handleAPIerror(res, error);
    } finally {
        connection.release();
    }
});

app.delete('/api/sessions/:session_id/sessiondrinks/:session_drink_id', authenticateToken(true), async (req, res) => {
    const { session_id, session_drink_id } = req.params;
    const user_id = req.user_id;

    if (session_id === undefined || session_drink_id === undefined) {
        throw HTTPerror(400, 'Missing ID of the session or the drink within the session')
    }

    const connection = await pool.getConnection();

    try {
        await connection.query(
            'CALL removeDrinkFromSession(?, ?)',
            [session_drink_id, user_id]
        );
        res.status(204).send();
    } catch (error) {
        handleAPIerror(res, error);
    } finally {
        connection.release();
    }
});

app.get('/api/sessions', authenticateToken(true), async (req, res) => {
    const { min_standards, max_standards, min_sugar, max_sugar, min_drinks, max_drinks, min_date, max_date, min_duration, max_duration } = req.query;
    const user_id = req.user_id;
    // Build the base SQL query

    let query = 'SELECT * FROM SessionsInfo WHERE created_user_id = ?'
    let queryParams = [user_id];
    
    if (min_standards !== undefined) {
        query += ' AND total_standards >= ?';
        queryParams.push(min_standards);
    }

    if (max_standards !== undefined) {
        query += ' AND total_standards <= ?';
        queryParams.push(max_standards);
    }
    
    if (min_sugar) {
        query += ' AND total_sugar >= ?';
        queryParams.push(min_sugar);
    }
    
    if (max_sugar) {
        query += ' AND total_sugar <= ?';
        queryParams.push(max_sugar);
    }

    if (min_drinks !== undefined) {
        query += ' AND n_drinks >= ?';
        queryParams.push(min_drinks);
    }

    if (max_drinks !== undefined) {
        query += ' AND n_drinks <= ?';
        queryParams.push(max_drinks);
    }
    
    if (min_date !== undefined) {
        query += ' AND start_time >= ?';
        queryParams.push(min_date);  // Ensure this is in the correct format, e.g., 'YYYY-MM-DD'
    }
    
    if (max_date !== undefined) {
        query += ' AND start_time <= ?';
        queryParams.push(max_date);  // Ensure this is in the correct format, e.g., 'YYYY-MM-DD'
    }

    if (min_duration !== undefined) {
        query += ' AND duration >= ?';
        queryParams.push(min_duration);
    }

    if (max_duration !== undefined) {
        query += ' AND duration <= ?';
        queryParams.push(max_duration);
    }
    
    //TODO INGREDIENT IDS
    // Execute the query
    const connection = await pool.getConnection();
    try {
        const [results] = await connection.query(query, queryParams);

        // Modify the result set to rename 'ingredient_id' to 'id'
        const modifiedResults = results.map(item => {
            return formatIngredient(item);
        });

        // Return the results with 'id' instead of 'ingredient_id'
        res.status(200).json({ ingredients: modifiedResults });

    } catch (error) {
        handleAPIerror(res, error);
    } finally {
        connection.release();
    }
});

app.get('/api/tags', async (req, res) => {
    const { type } = req.query;

    const connection = await pool.getConnection();
    try {
        const [results] = await connection.query(
            'SELECT * FROM Tags WHERE type = ?',
            [type]
        );

        const updatedJson = results.map(({ tag_id, ...rest }) => ({ id: tag_id, ...rest }));

        res.json({ tags: updatedJson }); // Return the results as JSON
    } catch (error) {
        // Rollback on error
        console.error('Error executing query: ' + error.stack);
        res.status(500).send({ error_message: error.message });
    } finally {
        connection.release();
    }
});

// Start the server
https.createServer(sslOptions, app).listen(3000, () => {
    console.log('HTTPS server running on port 3000');
});
