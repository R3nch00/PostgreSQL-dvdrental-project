-- List all actors’ first and last names
SELECT first_name, last_name
FROM actor;

-- Show the first 10 films with their titles and release years
SELECT title, release_year
from film
limit 10;

-- Show the last 10 films with their titles and release years
SELECT title, release_year
FROM film
ORDER BY release_year DESC
LIMIT 10;

-- Show the 15 films starting from the 25th record
SELECT title, release_year
FROM film
ORDER BY release_year DESC
LIMIT 15 OFFSET 24;

-- Count the total number of customers
SELECT count(*) as total_customers
from customer;

-- Display all staff members’ first names and email addresses
select first_name, email
from staff;

-- Find the address of the store with store_id = 1
select a.address, a.district, a.city_id, a.postal_code
from store s
join address a on s.address_id=a.address_id
where s.store_id=1;

-- Show the rental_date and return_date for the latest 5 rentals
select rental_date, return_date
from rental
order by rental_date desc
limit 5;

-- Retrieve all categories from the category table
select category_id, name
from category;

-- Display all film titles and their rental rates
select title, rental_rate
from film;

-- Find films with rental_rate greater than 3.99 (decimal)
select title, rental_rate
from film
where rental_rate > 3.99;

-- Retrieve customer details where active = true (boolean)
select customer_id, first_name, last_name, email
from customer
WHERE active::boolean = true; -- where active = 1;

-- List all rentals where the rental_date is after 2005-05-15 (timestamp)
select rental_id, rental_date, return_date
from rental
where rental_date > '2005-05-15';

-- Find customers with an email ending in '.com' (text)
select customer_id, first_name, last_name, email
from customer
where email like '%.com';

-- Retrieve the length of film titles using a string function
select title, length(title)as title_length
from film;

-- List all films where rental_duration is exactly 3 days (integer)
select title, rental_duration 
from film 
where rental_duration = 3;

-- Find the average payment amount per customer, rounded to 2 decimal places
select customer_id, round(avg(amount), 2) as average_payment
from payment
group by customer_id
order by average_payment

-- Show each payment amount and the average payment for that customer repeated on every row
select customer_id, amount, round(avg(amount) over (partition by customer_id),2) as average_payment
from payment
order by customer_id, amount;

--  List all films where the title length (number of characters) is a prime number
select title, length(title) as length_of_title
from film
where length(title) in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47);

-- Find all films with rental_rate greater than the average rental_rate of all films
select title, rental_rate
from film
where rental_rate > (select avg(rental_rate) from film);

-- Get the number of customers whose first name starts and ends with a vowel
select count(*) as vowel_name_customers
from customer
where lower (left(first_name,1)) in ('a','e','i','o','u')
	and lower (right(first_name,1)) in ('a','e','i','o','u');

-- Show payment records where the amount is an exact integer (e.g., 1.00, 5.00)
select payment_id, amount
from payment
where amount = floor(amount);

-- Show the most recent payment for each customer, including the amount and date
select distinct on (customer_id) customer_id, amount, payment_date
from payment
order by customer_id, payment_date desc;

-- Find customers whose email username (before @) is longer than 10 characters
select customer_id, email
from customer
where position('@' in email) > 10;

-- List all rentals that happened in the first week of June 2005
select rental_id, rental_date
from rental
where rental_date between '2005-06-01' and '2005-06-07';

-- Find all films where the replacement cost has more than two decimal places
select title, replacement_cost
from film
where replacement_cost :: TEXT ~ '\.\d{3,}$';

-- Get the total number of customers grouped by whether their first name length is even or odd
select 
	case when length(first_name) % 2 = 0 then 'Even' else 'Odd' end as name_length_type, count(*) as customer_count
from customer
group by name_length_type;

-- Find the top 5 customers who made the most number of rentals
select customer_id, count(*) as rental_count
from rental
group by customer_id
order by rental_count desc
limit 5;

-- List all films that have never been rented
select f.film_id, f.title
from film f
where film_id not in(
	select inventory.film_id
	from rental
	join inventory on rental.inventory_id = inventory.inventory_id);
	
-- Find customers whose first name appears more than once in the database
select first_name, count(*) as count
from customer
group by first_name
having count(*) > 1;

-- List films that belong to both 'Comedy' and 'Action' categories
select f.title
from film f
join film_category fc on f.film_id=fc.film_id
join category c on fc.category_id=c.category_id
where c.name in('Comedy','Action')
group by f.film_id,f.title
having count(distinct c.name)=2;

-- Find payments made on a weekend
select payment_id, customer_id, amount, payment_date
from payment
where extract (dow from payment_date) in (0,6);

-- Find customers who never made any payments
select customer_id, first_name, last_name
from customer
where customer_id not in(
	select distinct customer_id
	from payment);

-- Show the first film title alphabetically for each rating (e.g., PG, R, G)

select distinct on (rating) Rating, title
from film
order by rating, title asc;

-- Create a new table called film_log that stores film_id, title, and a log_time timestamp
create table film_log(
	film_id int, 
	title varchar(255),
	log_time timestamp default now());

-- Update the birth_year column to random years between 1970 and 2000
alter table customer
add column birth_year int;

update customer
set birth_year=floor(random() * (2000-1970+1)) + 1970;

-- Rename the birth_year column to year_of_birth then Add a constraint to ensure year_of_birth is not less than 1900
alter table customer
rename column birth_year to year_of_birth;

alter table customer
add constraint check_birth_year
check (year_of_birth >= 1900);

--  Create a new table top_renters with customer_id, name, and total rentals for those who rented more than 30 times
create table top_renters as
select c.customer_id, concat(c.first_name,' ',c.last_name) as full_name,count(r.rental_id) as rental_count
from customer c
join rental r on c.customer_id=r.customer_id
group by c.customer_id, full_name
having count(r.rental_id) > 30;

--  Change the data type of rental_duration in the film table from integer to smallint
alter table film
alter column rental_duration type smallint;

-- Temporarily disable foreign key constraints in the database
ALTER TABLE rental
DROP CONSTRAINT rental_customer_id_fkey;

/* Though PostgreSQL doesn't suuport disabling consttaints globally so we must need to drop
   and re-add them manually */
/* Later, re-add: */
ALTER TABLE rental ADD CONSTRAINT rental_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(customer_id);

/* Create a table inventory_audit with:
	inventory_id(int, PK)
	change_reason (text)
	changed_at (timestamp default current time) */

create table inventory_audit(
	inventory_id int primary key,
	change_reason text,
	changed_at timestamp default current_timestamp);

-- Increase rental duration by 2 days for all films in the "Documentary" category
update film
set rental_duration = rental_duration + 2
where film_id in(
	select film_id
	from film_category fc
	join category c on fc.category_id = c.category_id
	where c.name = 'Documentary'
);

-- Set all payments made in 2005 with amount < 1 to a minimum flat value of 1.00
update payment
set amount = 1.00
where amount < 1.00 and payment_date between '2005-01-01' and '2025-12-31';

-- Update the customer table to include VIP in the last_name of customers who made over $200 in total payments
update customer
set last_name = concat(last_name, '(VIP)')
where customer_id in(
	select customer_id
	from payment
	group by customer_id
	having sum(amount) > 200
);

-- Show customers who now have '(VIP)' in their last_name
UPDATE customer
SET last_name = concat(last_name,' (VIP)')
WHERE customer_id IN (
  SELECT customer_id
  FROM payment
  GROUP BY customer_id
  HAVING SUM(amount) > 200
)
RETURNING customer_id, first_name, last_name;

-- Undo the VIP suffix in last_name
UPDATE customer
SET last_name = REPLACE(last_name, ' (VIP)', '')
WHERE last_name LIKE '% (VIP)';

-- See the customers whose last_name no longer has the VIP suffix (or check all)
SELECT customer_id, first_name, last_name
FROM customer
WHERE last_name NOT LIKE '% (VIP)%';

-- Reset return_date to NULL for any rentals with a return_date before rental_date (bad data fix)
update rental 
set rental_date = null
where return_date < rental_date;

-- Mark all customers from cities starting with ‘A’ as inactive
update customer
set active = 0
where address_id in(
	select address_id
	from address a
	join city c on a.city_id = c.city_id
	where c.city like 'A%'
);

-- Add 10% bonus to every payment made on a Monday
update payment
set amount = amount * 1.10
where extract(dow from payment_date) = 1;

-- Clone all PG-13 films into a new table called pg13_archive (structure + data)
create table pg13_archive as
select * from film
where rating = 'PG-13';

-- Add a column is_suspicious to the payment table to flag high single payments (amount > 10)
ALTER TABLE payment
ADD COLUMN is_suspicious BOOLEAN DEFAULT FALSE;

UPDATE payment
SET is_suspicious = TRUE
WHERE amount > 10;

-- Swap the first and last names of customers whose first name is "John"
update customer
set first_name = last_name, last_name = first_name
where first_name = 'John';

-- Add a new column rental_count to film and populate it with number of times each film was rented
alter table film add column rental_count int;

update film
set rental_count = (
	select count(*)
	from inventory i
	join rental r on i.inventory_id = r.inventory_id
	where i.film_id = film.film_id
);

-- Change customer names to UPPERCASE if they have rented more than 20 times the show the updated rows to verify
update customer
set first_name = upper(first_name), last_name=upper(last_name)
where customer_id in(
	select customer_id
	from rental
	group by customer_id
	having count(*) > 20
);

SELECT *
FROM customer
WHERE customer_id IN (
  SELECT customer_id
  FROM rental
  GROUP BY customer_id
  HAVING COUNT(*) > 20
);

-- Reduce replacement cost by 15% for all Action movies
update film
set replacement_cost = replacement_cost * 0.85
where film_id in(
	select film_id
	from film_category fc
	join category c on fc.category_id = c.category_id
	where c.name = 'Action'
);

-- Update all customers who haven't rented in over a year to inactive
update customer
set active = 0
where customer_id not in(
	select distinct customer_id
	from rental
	where rental_date > current_date - interval '1 year'	
);

-- Tag staff as "Senior" in a new column if they've processed over 1000 payments
alter table staff add column role text;
update staff
set role = 'Senior'
where staff_id in(
	select staff_id
	from payment
	group by staff_id
	having count(*) > 1000
);

-- Categorize films into 'Short', 'Medium', and 'Long' based on length (<60, 60–120, >120 minutes)
SELECT title, length,
  CASE
    WHEN length < 60 THEN 'Short'
    WHEN length BETWEEN 60 AND 120 THEN 'Medium'
    ELSE 'Long'
  END AS length_category
FROM film;

-- Show customers with their total payments and label 'High Spender' if total > $100, else 'Normal'
SELECT c.customer_id, c.first_name, c.last_name, COALESCE(SUM(p.amount), 0) AS total_paid,
  CASE
    WHEN COALESCE(SUM(p.amount), 0) > 100 THEN 'High Spender'
    ELSE 'Normal'
  END AS spender_category
FROM customer c
LEFT JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id;

-- Replace NULL return_date with 'Not Returned' text in rental records
SELECT rental_id, rental_date,
  COALESCE(TO_CHAR(return_date, 'YYYY-MM-DD'), 'Not Returned') AS return_status
FROM rental;

-- Show films with replacement_cost, but display 'Free' if cost is zero
SELECT title,
  CASE
    WHEN replacement_cost = 0 THEN 'Free'
    ELSE replacement_cost::TEXT
  END AS cost_display
FROM film;

-- For each payment, show 'Weekend Payment' if payment_date falls on Saturday or Sunday
SELECT payment_id, payment_date,
  CASE
    WHEN EXTRACT(DOW FROM payment_date) IN (0, 6) THEN 'Weekend Payment'
    ELSE 'Weekday Payment'
  END AS payment_day_type
FROM payment;

-- Show customer names, but if email is NULL, replace it with 'No Email Provided'
SELECT first_name, last_name,
  COALESCE(email, 'No Email Provided') AS contact_email
FROM customer;

-- Label films as 'Classic' if released before 2006, else 'Modern'
SELECT title, release_year,
  CASE
    WHEN release_year < 2006 THEN 'Classic'
    ELSE 'Modern'
  END AS era
FROM film;

-- Show the payment amount but replace values over $10 with 'High Payment'
SELECT payment_id,
  CASE
    WHEN amount > 10 THEN 'High Payment'
    ELSE amount::TEXT
  END AS payment_info
FROM payment;

-- For each customer, show 'Active' if active=1 else 'Inactive'
SELECT customer_id, first_name, last_name,
  CASE active
    WHEN 1 THEN 'Active'
    ELSE 'Inactive'
  END AS status
FROM customer;

-- List all customers with their rental counts, including customers who have never rented a film
SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id
ORDER BY rental_count DESC;

--  Find customers who rented films from multiple categories (show customer_id and count of distinct categories)
SELECT r.customer_id, COUNT(DISTINCT c.category_id) AS category_count
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY r.customer_id
HAVING COUNT(DISTINCT c.category_id) > 1;

-- Perform a self-join on the staff table to find pairs of staff working in the same store
SELECT s1.staff_id AS staff1_id, s1.first_name AS staff1_first,
       s2.staff_id AS staff2_id, s2.first_name AS staff2_first,
       s1.store_id
FROM staff s1
JOIN staff s2 ON s1.store_id = s2.store_id AND s1.staff_id <> s2.staff_id
ORDER BY s1.store_id;

-- Find customers who rented films from all categories available
WITH category_count AS (
  SELECT COUNT(*) AS total_categories FROM category
),
customer_categories AS (
  SELECT r.customer_id, COUNT(DISTINCT fc.category_id) AS rented_categories
  FROM rental r
  JOIN inventory i ON r.inventory_id = i.inventory_id
  JOIN film_category fc ON i.film_id = fc.film_id
  GROUP BY r.customer_id
)
SELECT customer_id
FROM customer_categories, category_count
WHERE rented_categories = total_categories;
