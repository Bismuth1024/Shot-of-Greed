# JS REST API design for Shot of Greed

## Basic principles

The app cannot access the MariaDB database directly, and thus it does so through an API. This API has a number of endpoints for the expected functionalities like logging in, creating drinks, fetching history, running complex queries, and so on. The specific endpoints are in their relevant sections. It also handles some of the logic required for everything to run smoothly e.g. generating login tokens or comparing password hashes.

Most 'objects' are not returned in their database form, but are returned as JSON objects - e.g. although we have Drink and Ingredient and DrinkIngredient in the database, the API will construct this into Drink objects with a list of Ingredients etc as JSON.

Note that all routes can return a 500 response for some sort of server error too.

## Authentication

Some routes in this API require authentication using a bearer token.

To access protected endpoints, include the following header in your request:

Authorization: Bearer <login_token>

- The `login_token` is returned by the `/login` endpoint.
- The token is tied to a user and login session in the database and may expire.
- If a route requires authentication and the token is missing, invalid, or expired, the API will return a `401 Unauthorized` response.

### Possible 401 error responses:

- `"Unauthorized: No token provided"`
- `"Unauthorized: Invalid token"`
- `"Unauthorized: Token expired"`

Only routes that need authentication will enforce this header. Some routes (e.g. `/ingredients`) may allow optional authentication and return additional data when a valid token is provided. The way this works is that the authenticateToken function takes an argument for whether auth is required or not. If it is not required, the call can continue through and user_id will be set to null; if it is required, the token is checked and user_id is set to the token's corresponding id if successful.

---

## Logins/Users

### POST /login

#### Description

Attempts to login a user

#### Query Parameters

- username
- password: raw plaintext

#### Response

- 201: successful login
	- user_id: internal database ID for use in future queries
	- login_token: token to use for future authenticated queries
	- expiry: expiry time of the login token
- 401: unsuccessful login due to bad credentials
	- error_message

#### Notes

- Probably will add support for specific token expiry in future
- Token is randomly generated

### POST /users

#### Description

Creates a user

#### Query Parameters

- username
- password: raw plaintext
- email: optional
- birthdate
- gender (`'male'` or `'female'`)

#### Response

- 201: successful user creation
	- new_user_id: internal database ID for the new user
- 400: bad parameters for new user e.g. missing birthdate
	- error_message

#### Notes

- Password will be hashed and stored
- May change email to compulsory in future

## Ingredients

### GET /ingredients

#### Description

Fetches ingredients (as JSON) that match the filter criteria.

**Authentication: Optional**
If a valid token is provided, the API will also return the private ingredients for this user. Otherwise, only public ingredients are returned.

#### Query Parameters

- name: exact match
- min_ABV
- max_ABV
- min_sugar
- max_sugar
- min_date: earliest allowed creation date
- max_date
- include_public: set to true if you want to include the public ingredients too. This parameter is not checked if no auth token is provided, as only public ingredients are returned.

#### Response

- 200: successfully fetched ingredients
    - ingredients: array of JSON Ingredient objects with:
        - name
        - ABV
        - sugarPercent
        - created_user_id
        - create_time
        - id
        - description: potentially null
        - tags: **TODO**

#### Notes

- Maybe add support for searching for partial matches to a name soon.
- Tags are still a work in progress

### POST /ingredients

#### Description

Creates a new ingredient

**Authentication: REQUIRED**
We need authentication as the new ingredient will be saved under the relevant user.

#### Body Parameters

- name
- ABV
- sugarPercent
- description: optional

#### Response

- 201: successfully created
    - new_ingredient_id
- 400: missing some of the required parameters
    - error_message
    
#### Notes

- Tags are still a work in progress
- Since only those body parameters are required, the JSON of the Ingredient from Swift can be directly sent to this endpoint

### DELETE /ingredients

#### Description

Deletes a user-created ingredient

**Authentication: REQUIRED**
We need authentication as the ingredient to delete belongs to a specific user

#### Body Parameters

- id: ID of the ingredient to delete

#### Response

- 204: successfully deleted
- 400: missing ingredient ID
    
#### Notes

- Ingredient is not actually deleted from database - the deleted flag is just set. See database design file for reasoning

## Drinks

### GET /drinks

#### Description

Fetches drinks (as JSON) that match the filter criteria.

**Authentication: Optional**
If a valid token is provided, the API will also return the private drinks for this user. Otherwise, only public drinks are returned.

#### Query Parameters

- name: exact match
- min_standards
- max_standards
- min_sugar
- max_sugar
- min_ingredients: count of ingredients
- max_ingredients
- min_date: earliest allowed creation date
- max_date
- include_public: set to true if you want to include the public drinks too. This parameter is not checked if no auth token is provided, as only public drinks are returned.

#### Response

- 200: successfully fetched drinks
    - ingredients: array of JSON Drink objects with:
        - name
        - created_user_id
        - create_time
        - id
        - description: potentially null
        - tags: **TODO**
        - ingredients: array
            - volume
            - ingredient: JSON Ingredient object

#### Notes

- Maybe add support for searching for partial matches to a name soon.
- Tags are still a work in progress
- Add support for filtering based on whether the drinks contain given ingredients.

### POST /drinks

#### Description

Creates a new drink

**Authentication: REQUIRED**
We need authentication as the new drink will be saved under the relevant user.

#### Body Parameters

- drink: JSON drink

#### Response

- 201: successfully created
    - new_drink_id
- 400: missing some of the required parameters
    - error_message
    
#### Notes

- Tags are still a work in progress

### DELETE /drinks

#### Description

Deletes a user-created drinks

**Authentication: REQUIRED**
We need authentication as the drink to delete belongs to a specific user

#### Body Parameters

- id: ID of the drink to delete

#### Response

- 204: successfully deleted
- 400: missing ingredient ID
    
#### Notes

- Drink is not actually deleted from database - the deleted flag is just set. See database design file for reasoning
