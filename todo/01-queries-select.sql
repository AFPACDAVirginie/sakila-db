-----------------------------------------------------------------------------------
-- Entraînement LID : Langage d'interrogation des données                        --
--                                                                               --
-- Requêtes SELECT :                                                             --
-- Compléter ce fichier avec vos propositions de requêtes.                       --
--                                                                               --
-- Merry query!                                                                  --
-----------------------------------------------------------------------------------

-- Sélectionnez toutes les informations des actrices qui ont le prénom "Scarlett".
-->
SELECT actor.first_name, actor.last_name, film.title 
FROM `actor` 
INNER JOIN film_actor ON actor.actor_id=film_actor.actor_id 
INNER JOIN film ON film_actor.film_id=film.film_id 
WHERE `first_name`='Scarlett';

-- Sélectionnez le titre et la description de tous les films d'action.
-->
SELECT film.title, film.description
FROM `film` 
INNER JOIN film_category ON film.film_id=film_category.film_id
INNER JOIN category ON film_category.category_id=category.category_id
WHERE category.name='action'
-- Sélectionnez toutes les informations des villes situées en France.
-->
SELECT * 
FROM `city` 
INNER JOIN country ON city.country_id=country.country_id
WHERE country.country='France'

-- Comptez le nombre d'acteurs ayant des noms différents.
-->121
SELECT COUNT(DISTINCT actor.last_name) AS unique_actors FROM actor;
-- Sélectionez les noms de familles partagés par plusieurs acteurs.
-->
SELECT actor.last_name, COUNT(*)
FROM actor 
GROUP BY actor.last_name
HAVING COUNT(*)>1;
-- Sélectionnez les numéros de téléphone de toutes les adresses en "Californie", "Angle" ou "Taipei". pas trouvé Angle
-->
SELECT address.phone, address.district
FROM address
INNER JOIN city ON address.city_id=city.city_id
INNER JOIN country ON city.country_id=country.country_id
WHERE address.district="California" OR address.district="Ji´angsu" OR address.district="taipei";
-- Sélectionnez toutes les informations des clients qui habitent au Brésil.
-->
SELECT customer.*, country.country FROM `customer` 
INNER JOIN address ON customer.address_id=address.address_id 
INNER JOIN city ON address.city_id=city.city_id 
INNER JOIN country ON city.country_id=country.country_id 
WHERE country.country="brazil";
-- Sélectionez le titre et la description de tous les films qui ont deux catégories ou plus.
--> agrégation pour afficher toutes les catégories
SELECT film.title, film.description, GROUP_CONCAT(DISTINCT category.name ORDER BY category.name) AS categories
FROM `film` 
INNER JOIN film_category ON film.film_id=film_category.film_id
INNER JOIN category ON film_category.category_id=category.category_id  
GROUP BY film.film_id, film.title, film.description
HAVING COUNT(DISTINCT category.category_id) >1
ORDER BY `film`.`title` ASC;
-- Est-ce que le film "LADYBUGS ARMAGEDDON" est disponible à la location dans un des magasins de Californie ?
--> non, il n'y a pas de store en Californie
SELECT film.title
FROM film
INNER JOIN inventory ON film.film_id=inventory.film_id
INNER JOIN store ON inventory.store_id=store.store_id
INNER JOIN address ON store.address_id=address.address_id 
WHERE address.district="California" AND film.title="LADYBUGS ARMAGEDDON";
-- Sélectionnez tous les film qui n'ont jamais été rendus.
-->183 films non rendus
SELECT film.title 
FROM film 
INNER JOIN inventory ON film.film_id=inventory.film_id 
INNER JOIN rental ON inventory.inventory_id=rental.inventory_id 
WHERE rental.return_date IS null;
-- Quand est-ce que "ACADEMY DINOSAUR" doit être rendu au plus tard ?
-->27/08/2005
SELECT film.title, film.rental_duration, rental.rental_date, 
DATE_ADD(rental.rental_date, INTERVAL film.rental_duration DAY) AS expected_return_date 
FROM film 
INNER JOIN inventory ON film.film_id = inventory.film_id 
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id 
WHERE film.title = "ACADEMY DINOSAUR" AND rental.return_date IS NULL;

-- Sélectionnez le film le plus long proposé (tout magasin confondu).
-->
SELECT film.title, MAX(film.length)  FROM `film`;
-- Sélectionnez les titres des 3 films les plus loués.
-->
SELECT film.title, COUNT(rental.rental_id)
FROM film
INNER JOIN inventory ON film.film_id=inventory.film_id
INNER JOIN rental ON inventory.inventory_id=rental.inventory_id
GROUP BY film.film_id,film.title
ORDER BY COUNT(rental_id) DESC
LIMIT 3;
-- Quelles est la durée moyenne de tous les films disponibles ?
--> 115.2720
SELECT AVG(film.length) FROM `film`;
-- Quel est le coût de remplacement moyen d'un film ?
-->19.984000
SELECT AVG(film.replacement_cost) FROM `film`;

-- Sélectionez tous les informations des films disponibles dans le magasin géré par "Jon Stephens".
-->
SELECT film.title, staff.last_name, staff.first_name, COUNT(film.title) 
FROM `film` 
INNER JOIN inventory ON film.film_id=inventory.film_id 
INNER JOIN store ON inventory.store_id=store.store_id 
INNER JOIN staff ON store.store_id=staff.store_id 
WHERE staff.first_name="jon" 
GROUP BY film.title 
HAVING COUNT(DISTINCT film.title) 
ORDER BY `film`.`title` ASC;
-- Sélectionnez les informations des films qui ont un coût de remplacement supérieur à la moyenne.
-->536 films
SELECT * FROM film WHERE film.replacement_cost>(SELECT AVG(film.replacement_cost) FROM film);
-- Sélectionnez toutes les informations des films qui ont au moins un acteur qui a le nom "Hackman".
-->
SELECT actor.`first_name`, actor.last_name, film.* 
FROM `actor` 
INNER JOIN film_actor ON actor.actor_id=film_actor.actor_id 
INNER JOIN film ON film_actor.film_id=film.film_id 
WHERE last_name="Hackman" 
ORDER BY `film`.`title` ASC;
-- Sélectionnez l'identifiant, le titre et l'année de sortie les films qui n'ont jamais été loués.
--> 1 seul film
SELECT film.film_id, film.title, film.release_year 
FROM `film` 
INNER JOIN inventory ON film.film_id=inventory.film_id 
LEFT JOIN rental ON inventory.inventory_id=rental.inventory_id 
WHERE rental.inventory_id IS null;
-- Sélectionnez l'adresse du magasin qui a le plus de films de science fiction en stock.
-->
SELECT store.store_id, address.*, COUNT(DISTINCT inventory.film_id) AS sci_fi_count
FROM inventory
INNER JOIN film ON inventory.film_id = film.film_id
INNER JOIN film_category ON film.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id 
INNER JOIN store ON inventory.store_id  = store.store_id
INNER JOIN address ON store.address_id = address.address_id
WHERE category.name = 'Sci-Fi'
GROUP BY store.store_id,address.district 
ORDER BY sci_fi_count DESC
LIMIT 1;
-- Sélectionnez le nom et le prénom ainsi que la somme totale dépensée du client qui a le plus dépensé.
-->
SELECT SUM( payment.amount) AS payment_count, customer.customer_id, customer.first_name, customer.last_name
FROM `payment`
INNER JOIN customer ON payment.customer_id=customer.customer_id
GROUP BY payment.customer_id
ORDER BY payment_count DESC
LIMIT 1;