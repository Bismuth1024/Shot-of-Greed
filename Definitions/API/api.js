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
    host: process.env.DB_HOST, 
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

const authenticateToken = (required = true) => {
    return async (req, res, next) => {
        const authHeader = req.headers['authorization'];
        const token = authHeader?.split(' ')[1];
        req.authStatus = 'no_token';
        req.user_id = null;

        if (!token) {
            if (required) {
                return res.status(401).json({ error_message: 'Unauthorized: No token provided' });
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
                return res.status(401).json({ error_message: 'Unauthorized: Invalid token' });
            } 

            const [{ user_id, expiry }] = rows;

            if (expiry < Date.now()) {
                req.authStatus = 'expired_token';
                return res.status(401).json({ error_message: 'Unauthorized: Token expired' });
            } 

            req.authStatus = 'valid_token';
            req.user_id = user_id;
            return next();
        
        } catch (error) {
            console.error(error);
            return res.status(500).json({ error_message: 'Internal error while authenticating' });
        } finally {
            connection.release();
        }
    };
};




// Create Drink POST API Endpoint
app.post('/api/drinks', async (req, res) => {
    const { drink } = req.body;

    const { name, created_user_id, description = null, ingredients } = drink;

    const connection = await pool.getConnection();
    try {
        // Start a transaction
        await connection.beginTransaction();

        // Call stored procedure to create a drink
        const [[[{ new_drink_id }]]] = await connection.query(
            'CALL createDrink(?, ?, ?, NULL)',
            [name, description, created_user_id]
        );

        // Add ingredients to the drink
        for (const ingredient of ingredients) {
            const { ingredientType: { id: ingredient_id }, volume } = ingredient;
            await connection.query(
                'CALL addIngredientToDrink(?, ?, ?)',
                [ingredient_id, drink_id, volume]
            );
        }

        /*
        // Add tags if provided
        if (tags) {
            const tagList = tags.split(',');
            for (const tag of tagList) {
                await connection.query(
                    'CALL addTagToDrink(?, ?)',
                    [drink_id, tag.trim()]
                );
            }
        }
        */
        
        // Commit the transaction
        await connection.commit();
        res.status(201).send({ new_drink_id });

    } catch (error) {
        // Rollback on error
        await connection.rollback();
        res.status(500).send({ error_message: error.message });
    } finally {
        connection.release();
    }
});

app.get('/api/drinks', async (req, res) => {
    const { user_id, tags, name, min_standards, max_standards, min_sugar, max_sugar, min_ingredients, max_ingredients, min_date, max_date, ingredient_ids } = req.query;
    
    // Build the base SQL query
    let query = 'SELECT * FROM DrinksOverview WHERE 1=1';
    let queryParams = [];
    
    // Add conditions based on query parameters
    if (user_id) {
        query += ' AND created_user_id = ?';
        queryParams.push(user_id);
    }
    
    //DEAL WITH TAGS NEXT!!!! TODO
    
    if (name) {
        query += ' AND name = ?';
        queryParams.push(name);
    }
    
    if (min_standards) {
        query += ' AND n_standards >= ?';
        queryParams.push(min_standards);
    }
    
    if (max_standards) {
        query += ' AND n_standards <= ?';
        queryParams.push(min_standards);
    }
    
    if (min_sugar) {
        query += ' AND sugar_g >= ?';
        queryParams.push(min_sugar);
    }
    
    if (max_sugar) {
        query += ' AND sugar_g <= ?';
        queryParams.push(max_sugar);
    }
    
    if (min_ingredients) {
        query += ' AND n_ingredients >= ?';
        queryParams.push(min_ingredients);
    }
    
    if (max_ingredients) {
        query += ' AND n_ingredients <= ?';
        queryParams.push(max_ingredients);
    }
    
    if (min_date) {
        query += ' AND create_time >= ?';
        queryParams.push(min_date);  // Ensure this is in the correct format, e.g., 'YYYY-MM-DD'
    }
    
    if (max_date) {
        query += ' AND create_time <= ?';
        queryParams.push(max_date);  // Ensure this is in the correct format, e.g., 'YYYY-MM-DD'
    }
    
    //TODO INGREDIENT IDS
    
    // Execute the query
    const connection = await pool.getConnection();
    try {
        const [results] = await connection.query(query, queryParams);
        res.json(results); // Return the results as JSON
    } catch (error) {
        // Rollback on error
        console.error('Error executing query: ' + err.stack);
        res.status(500).send({ error_message: error.message });
    } finally {
        connection.release();
    }
});

//GET ingredients
app.get('/api/ingredients', authenticateToken(false), async (req, res) => {
    const { tags, name, min_ABV, max_ABV, min_sugar, max_sugar, min_date, max_date, include_public } = req.query;
    const user_id = req.user_id;
    // Build the base SQL query

    let query = 'SELECT * FROM Ingredients WHERE created_user_id'
    let queryParams = [];

    if (!user_id) {
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
    
    if (name) {
        query += ' AND name = ?';
        queryParams.push(name);
    }
    
    if (min_ABV) {
        query += ' AND ABV >= ?';
        queryParams.push(min_ABV);
    }
    
    if (max_ABV) {
        query += ' AND ABV <= ?';
        queryParams.push(max_ABV);
    }
    
    if (min_sugar) {
        query += ' AND sugar_percent >= ?';
        queryParams.push(min_sugar);
    }
    
    if (max_sugar) {
        query += ' AND sugar_percent <= ?';
        queryParams.push(max_sugar);
    }
    
    if (min_date) {
        query += ' AND create_time >= ?';
        queryParams.push(min_date);  // Ensure this is in the correct format, e.g., 'YYYY-MM-DD'
    }
    
    if (max_date) {
        query += ' AND create_time <= ?';
        queryParams.push(max_date);  // Ensure this is in the correct format, e.g., 'YYYY-MM-DD'
    }
    
    //TODO INGREDIENT IDS
    // Execute the query
    const connection = await pool.getConnection();
    try {
            const [results] = await connection.query(query, queryParams);

            // Modify the result set to rename 'ingredient_id' to 'id'
            const modifiedResults = results.map(item => {
                return {
                    ...item,
                    id: item.ingredient_id, // Rename 'ingredient_id' to 'id' for Codable Swift
                    ingredient_id: undefined,
                    create_time: JSDateToSwift(item.create_time),
                    ABV: parseFloat(item.ABV), // Convert ABV from string to number
                    sugarPercent: parseFloat(item.sugar_percent), // Convert sugar_percent from string to number
                    //TODO : TAGS!!
                    tags: []
                };
            });

            // Return the results with 'id' instead of 'ingredient_id'
            res.json({ ingredients: modifiedResults });

        } catch (error) {
            // Rollback on error
            await connection.rollback();
            console.error('Error executing query: ' + error.stack);
            res.status(500).send({ error_message: error.message });
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

app.post('/api/users', async (req, res) => {
    const { username, password, email, birthdate, gender } = req.body;

    if (!username || !password) {
        return res.status(400).send({ error_message: 'Missing username or password' });
    }

    if (!birthdate || !gender) {
        return res.status(400).send({ error_message: 'Missing fields' });
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
        // Rollback on error
        await connection.rollback();
        console.log(error)

        const { sqlMessage, code, errno, sqlState } = error;

        let message = '';

        if (sqlMessage.includes('Users_AK_Email')) {
            message = 'That email is already taken. Please choose a different email.'
        } else if (sqlMessage.includes('Users_AK_Username')) {
            message = 'That username is already taken. Please choose a different username.'
        }


        res.status(500).send({ error_message: message });
    } finally {
        connection.release();
    }

});

app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;

    const connection = await pool.getConnection();

    try {
        const [rows] = await connection.query(
            'SELECT user_id, hashed_password FROM Users WHERE username = ?',
            [username]
        );

        console.log(rows);

        //No user of this username found:
        if (rows.length == 0) {
            return res.status(401).send({ error_message: 'Invalid username or password (user)' });
        }


        const [{ user_id, hashed_password }] = rows;

        //Check password validity
        const isValidPassword = await bcrypt.compare(password, hashed_password);
        if (!isValidPassword) {
            return res.status(401).send({ error_message: 'Invalid username or password' });
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
        console.log(error);
        res.status(500).send({ error_message: error.message });
    } finally {
        connection.release();
    }

    
});

app.post('/api/ingredients', authenticateToken(false), async (req, res) => {
    const { description = null, name, ABV, sugarPercent, user_id, tags } = req.body;

    const create_time = JSDateToSQL(Date.now());

    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();
        const [[[{ new_ingredient_id }]]] = await connection.query(
            'CALL createIngredient(?, ?, ?, ?, ?, ?)',
            [name, ABV, description, sugarPercent, user_id, create_time]
        );

    } catch (error) {
        await connection.rollback();
        console.log(error)

        const { sqlMessage, code, errno, sqlState } = error;

        res.status(500).send({ error_message: sqlMessage });
        
    } finally {
        connection.release();
    }


});




// Start the server
https.createServer(sslOptions, app).listen(3000, () => {
    console.log('HTTPS server running on port 3000');
});
