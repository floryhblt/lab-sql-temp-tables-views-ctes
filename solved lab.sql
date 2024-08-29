use sakila;

CREATE OR REPLACE VIEW rental_info AS
SELECT customer.customer_id, customer.first_name, customer.last_name, customer.email, count(rental.rental_id) as 'rental_count'
from customer
left join rental on rental.customer_id = customer.customer_id
group by customer.customer_id, customer.first_name, customer.last_name, customer.email;

CREATE TEMPORARY TABLE total_paid_2
SELECT rental_info.rental_count, payment.customer_id, SUM(payment.amount) AS total_amount_paid
from payment
join rental_info on rental_info.customer_id = payment.customer_id
group by rental_info.rental_count, payment.customer_id;

WITH cte_rental AS (
	SELECT rental_info.customer_id, rental_info.first_name, rental_info.last_name, rental_info.email, rental_info.rental_count, total_paid_2.total_amount_paid
    FROM rental_info
    JOIN total_paid_2 ON rental_info.customer_id = total_paid_2.customer_id
    )
    
SELECT
	customer_id, first_name, last_name, email, rental_count, total_amount_paid, ROUND(total_amount_paid / rental_count, 2) AS average_payment_per_rental
FROM
	cte_rental
