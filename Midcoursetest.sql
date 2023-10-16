--ex1 
select distinct replacement_cost from film
order by replacement_cost
limit 1
--ex2 
SELECT CASE 
		WHEN replacement_cost BETWEEN 9.99
				AND 19.99
			THEN 'low'
		WHEN replacement_cost BETWEEN 20.00
				AND 24.99
			THEN 'medium'
		WHEN replacement_cost BETWEEN 25.00
				AND 29.99
			THEN 'high'
		END AS type
	,count(*)
FROM film
GROUP BY type
--ex3
SELECT f.title
	,f.length
	,c.name
FROM film AS f
JOIN film_category AS fc ON f.film_id = fc.film_id
JOIN category AS c ON fc.category_id = c.category_id
WHERE c.name IN (
		'Drama'
		,'Sports'
		)
ORDER BY length DESC limit 1
--ex4 
SELECT c.name
	,count(*)
FROM film AS f
JOIN film_category AS fc ON f.film_id = fc.film_id
JOIN category AS c ON fc.category_id = c.category_id
WHERE c.name IN (
		'Drama'
		,'Sports'
		)
GROUP BY c.name
ORDER BY count(*) DESC limit 1
--ex5 
SELECT CONCAT (
		a.first_name
		,' '
		,a.last_name
		) AS full_name
	,count(*) AS film_count
FROM actor AS a
JOIN film_actor AS fa ON a.actor_id = fa.actor_id
JOIN film AS f ON fa.film_id = f.film_id
GROUP BY full_name
ORDER BY film_count DESC limit 1
--ex6 
SELECT count(*)
FROM customer AS c
RIGHT JOIN address AS a ON c.address_id = a.address_id
WHERE c.customer_id IS NULL
--ex7
SELECT c.city
	,sum(p.amount) AS revenue
FROM city AS c
JOIN address AS a ON c.city_id = a.city_id
JOIN customer AS cu ON cu.address_id = a.address_id
JOIN payment AS p ON p.customer_id = cu.customer_id
GROUP BY c.city
ORDER BY revenue DESC limit 1
--ex8
SELECT CONCAT (
		c.city
		,' '
		,co.country
		) AS city_country
	,sum(p.amount) AS revenue
FROM city AS c
JOIN address AS a ON c.city_id = a.city_id
JOIN customer AS cu ON cu.address_id = a.address_id
JOIN payment AS p ON p.customer_id = cu.customer_id
JOIN country AS co ON c.country_id = co.country_id
GROUP BY city_country
ORDER BY revenue DESC limit 1
