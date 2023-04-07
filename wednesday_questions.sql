--Simon Dutton
--due April 6, 2023
--SQL
--Week 5 - Wednesday Questions  

--1. List all customers who live in Texas (use JOINs)  

-- There are 5 customers:
-- Jennifer Davis, Kim Cruz, Richard Mccrary, Bryan Hardison, and Ian Still

-- JOIN
SELECT c.first_name, c.last_name, c.customer_id, a.district
FROM customer AS c
INNER JOIN address AS a 
ON a.address_id = c.address_id
WHERE district = 'Texas';

--SUBQUERY
SELECT first_name, last_name, customer_id
FROM customer
WHERE address_id IN (
    SELECT address_id 
    FROM address 
    WHERE district = 'Texas'
);

--2. Get all payments above $6.99 with the Customer's Full Name  

-- TOTAL of 27 payments above $6.99
-- TOTAL of 5 Customers who have paid above $6.99
-- Mary Smith, Peter Menard, Douglas Graf, Alvin Deloach, Alfredo McAdams

--JOIN
SELECT c.first_name, c.last_name, p.amount
FROM customer AS c 
INNER JOIN payment AS p 
ON c.customer_id = p.customer_id
WHERE amount > 6.99
ORDER BY p.amount DESC;

--SUBQUERY
SELECT first_name, last_name
FROM customer
WHERE customer_id IN (
    SELECT customer_id
    FROM payment 
    WHERE amount > 6.99 
    ORDER BY amount DESC
);

-- COMBINATION
SELECT first_name, last_name
FROM customer
WHERE customer_id IN (
    SELECT c.customer_id
    FROM customer AS c 
    INNER JOIN payment AS p 
    ON c.customer_id = p.customer_id
    WHERE amount > 6.99
    ORDER BY p.amount DESC
);

--3. Show all customers names who have made payments over $175 (use subqueries) 
    --Ambiguity about "payments over $175"

    -- 1) All customers who have made an individual transaction over $175
    -- 2 customers: Mary Smith (1), Douglas Graf (343)
    -- 3 total purchases (Mary paid >$175 twice)

--JOIN
SELECT c.first_name, c.last_name, p.amount
FROM customer AS c 
INNER JOIN payment AS p 
ON c.customer_id = p.customer_id
WHERE amount > 175
ORDER BY p.amount DESC;

--SUBQUERY
SELECT first_name, last_name
FROM customer
WHERE customer_id IN (
    SELECT customer_id
    FROM payment 
    WHERE amount > 175
);

    --2) All customers who have made a total payment of over $175
    -- 2 customers: Mary Smith(1), Peter Menard (341)
    -- note: Douglas Graf (343) from above has many negative payments so his total is lower

--JOIN
SELECT c.first_name, c.last_name, c.customer_id, SUM(p.amount)
FROM customer AS c 
INNER JOIN payment AS p 
ON c.customer_id = p.customer_id
GROUP BY c.first_name, c.last_name, c.customer_id
HAVING SUM(amount) > 175;

--SUBQUERY
SELECT first_name, last_name, customer_id
FROM customer
WHERE customer_id IN (
    SELECT customer_id 
    FROM payment 
    GROUP BY customer_id 
    HAVING SUM(amount) > 175
);


--4. List all customers that live in Nepal (use the city table) 

-- 1 customer: Kevin Schuler (321) from Birgunj, Nepal

--JOIN - with just 3 tables
SELECT c.first_name, c.last_name, c.customer_id, city.city, city.country_id
FROM customer AS c 
INNER JOIN address AS a
ON c.address_id = a.address_id
INNER JOIN city 
ON city.city_id = a.city_id
WHERE city.country_id = 66;

--JOIN - with 4 tables
SELECT c.first_name, c.last_name, c.customer_id, city.city, country.country
FROM customer AS c 
INNER JOIN address AS a
ON c.address_id = a.address_id
INNER JOIN city 
ON city.city_id = a.city_id
INNER JOIN country
ON city.country_id = country.country_id
WHERE country.country = 'Nepal';

--SUBQUERY -- 2 subqueries
SELECT first_name, last_name
FROM customer
WHERE address_id IN (
    SELECT address_id
    FROM address 
    WHERE city_id IN (
        SELECT city_id
        FROM city
        WHERE city.country_id = 66
    )
);

--SUBQUERY -- 3 subqueries
SELECT first_name, last_name
FROM customer
WHERE address_id IN (
    SELECT address_id
    FROM address 
    WHERE city_id IN (
        SELECT city_id
        FROM city
        WHERE country_id IN (
            SELECT country_id
            FROM country
            WHERE country = 'Nepal'
        )
    )
);

--5. Which staff member had the most transactions?

-- Jon Stephens (Staff ID #2) had the most, at 7304 transactions

-- Single Table, doesn't get name
SELECT staff_id, COUNT(staff_id)
FROM payment
GROUP BY staff_id;

--JOIN
SELECT s.first_name, s.last_name, COUNT(s.staff_id) AS c
FROM staff AS s
INNER JOIN payment AS p
ON s.staff_id = p.staff_id
GROUP BY s.staff_id
ORDER BY c DESC
FETCH FIRST 1 ROWS WITH TIES;

--SUBQUERIES
SELECT first_name, last_name, staff_id
FROM staff
WHERE staff_id = (
    SELECT staff_id
    FROM payment
    GROUP BY staff_id
    HAVING COUNT(staff_id) = (
        SELECT MAX(c) FROM (
        SELECT staff_id, COUNT(staff_id) AS c
        FROM payment
        GROUP BY staff_id
        ) AS max
    )
);

--6. How many movies of each rating are there?

-- NC-17: 209, G: 178, PG-13: 223, PG: 194, R: 196

-- not sure why we would use join/subqueries when this is an item from a single table?
SELECT rating, COUNT(rating)
FROM film
GROUP BY rating;

--7. Show all customers who have made a single payment above $6.99 (Use Subqueries) 
    --Two different interpretations of "a single payment above $6.99":

    -- 1) All customers who have paid over $6.99 in a single payment
    -- * COULD'VE MADE A PAYMENT OVER $6.99 MULTIPLE TIMES

    -- 5 customers: Mary Smith, Peter Menard, Douglas Graf, Alvin Deloach, Alfredo Mcadams

--JOIN
SELECT c.first_name, c.last_name, p.amount
FROM customer AS c 
INNER JOIN payment AS p 
ON c.customer_id = p.customer_id
WHERE amount > 6.99
ORDER BY c.last_name;

--SUBQUERY
SELECT first_name, last_name
FROM customer
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM payment 
    WHERE amount > 6.99
    ORDER BY customer_id
);

    -- 2) All customers who have paid over $6.99 in a single payment
    -- * ONLY MADE A SINGLE (1) PURCHASE OVER $6.99

    -- 3 customers: Douglas Graf, Alvin Deloach, Alfredo Mcadams

-- JOIN
SELECT c.first_name, c.last_name
FROM customer AS c 
INNER JOIN payment AS p 
ON c.customer_id = p.customer_id
WHERE amount > 6.99
GROUP BY c.first_name, c.last_name
HAVING COUNT(p.customer_id) = 1;

-- SUBQUERY
SELECT first_name, last_name
FROM customer
WHERE customer_id IN (
    SELECT customer_id
    FROM (
        SELECT customer_id, amount
        FROM payment 
        WHERE amount > 6.99
        ORDER BY customer_id
    ) AS counter
    GROUP BY customer_id
    HAVING COUNT(customer_id) = 1
);

--8. How many free rentals did our stores give away?  

-- 0 free rentals ($0.00)

-- JOIN
SELECT r.rental_id, p.amount, COUNT(r.rental_id)
FROM rental AS r 
INNER JOIN payment AS p 
ON r.rental_id = p.rental_id
WHERE p.amount = 0
GROUP BY r.rental_id, p.amount;

--SUBQUERY
SELECT rental_id, COUNT(rental_id)
FROM rental
WHERE rental_id IN (
    SELECT rental_id
    FROM payment
    WHERE amount = 0
)
GROUP BY rental_id;