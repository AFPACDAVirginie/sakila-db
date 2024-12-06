-------------------------------------------------------------------------------------
-- Entraînement à la création de vues                                              --
--                                                                                 --
-- Travail à faire :                                                               --
-- 1. Regarder la vidéo https://www.youtube.com/watch?v=0pe3XzbjdxA                --
--    pour comprendre le concept de vue                                            --
--    Grafikart utilise une BDD SqLite mais c'est la même chose (presque) partout. --
-- 2. Compléter ce fichier avec vos propositions de requêtes.                      --
-- 3. Pousser votre code sur votre Git                                             --
--                                                                                 --
-- Merry query!                                                                    --
-------------------------------------------------------------------------------------

-- Créer une vue "long_films" qui présente tous les films (avec leur langue) de plus de 2 heures
-->
CREATE OR REPLACE
VIEW `long_films` AS
    SELECT film.title,film.length,film.language_id, `language`.`name`
    FROM `film` 
    INNER JOIN `language` ON film.language_id=`language`.language_id
    WHERE length>120  
    ORDER BY `film`.`length` ASC;

-- Créer une vue "customers_with_rentals" qui présente tous les client qui ont des prêts en cours.
--> 
CREATE VIEW `customers_with_rentals` AS
SELECT DISTINCT rental.customer_id, customer.last_name, customer.first_name FROM `rental`  
INNER JOIN customer ON rental.customer_id=customer.customer_id
WHERE return_date IS NULL  
ORDER BY `rental`.`customer_id` ASC;



-- Créer une vue "film_list" qui présente toutes les informations des films (ormis la langue) avec, en plus les noms des acteurs (sous forme de chaîne de caractères dans une colonne)
-- Indices :
-- + il vous faudra utiliser un GROUP BY ainsi que GROUP_CONCAT pour concaténer les noms des acteurs : https://sql.sh/fonctions/group_concat
-->
CREATE OR REPLACE
VIEW `film_list` AS
select
    `film`.`film_id` AS `FID`,
    `film`.`title` AS `title`,
    `film`.`description` AS `description`,
    `category`.`name` AS `category`,
    `film`.`rental_rate` AS `price`,
    `film`.`length` AS `length`,
    `film`.`rating` AS `rating`,
    GROUP_CONCAT(
        CONCAT(
            `actor`.`first_name`,
            ' ',
            `actor`.`last_name`
        ) SEPARATOR ', '
    ) AS `actors`
from
    ((((`film`
                LEFT JOIN `film_category` ON
                    (`film_category`.`film_id` = `film`.`film_id`
                    ))
            LEFT JOIN `category` ON
                (`category`.`category_id` = `film_category`.`category_id`
                ))
        LEFT JOIN `film_actor` ON
            (`film`.`film_id` = `film_actor`.`film_id`
            ))
    LEFT JOIN `actor` ON
        (`film_actor`.`actor_id` = `actor`.`actor_id`
        ))
group by
    `film`.`film_id`,
    `category`.`name`;

-- Créer une vue "top_three_genre" qui présente les 3 genres qui rapporte le plus.
-- Indices : 
-- + procédez en 2 étapes : 1->conception de la requête qui sélectionne les 3 genres avec leur revenu respectif, 2->construction de la vue
-- + pour la requête, vous allez utiliser les tables "category", "film_category", "inventory", "payment" et "rental"
--> 
SELECT category.name AS `categorie`, SUM(payment.amount) AS `total_ventes`
FROM (((((`payment`
          JOIN `rental` ON (`payment`.`rental_id` = `rental`.`rental_id`)
                    )
                JOIN `inventory` ON (`rental`.`inventory_id` = `inventory`.`inventory_id`)
                )
            JOIN `film` ON (`inventory`.`film_id` = `film`.`film_id`)
            )
        JOIN `film_category` ON (`film`.`film_id` = `film_category`.`film_id`)
        )
    JOIN `category` ON (`film_category`.`category_id` = `category`.`category_id`)
    )
GROUP BY `category`.`name`
ORDER BY SUM(`payment`.`amount`) DESC
LIMIT 3

-- exemple de la vue `actor_info`
-- select `a`.`actor_id` AS `actor_id`,`a`.`first_name` AS `first_name`,`a`.`last_name` AS `last_name`,group_concat(distinct concat(`c`.`name`,': ',(select group_concat(`f`.`title` order by `f`.`title` ASC separator ', ') 
-- from ((`sakila`.`film` `f` join `sakila`.`film_category` `fc` on(`f`.`film_id` = `fc`.`film_id`)) join `sakila`.`film_actor` `fa` on(`f`.`film_id` = `fa`.`film_id`)) 
-- where `fc`.`category_id` = `c`.`category_id` and `fa`.`actor_id` = `a`.`actor_id`)) 
-- order by `c`.`name` ASC separator '; ') AS `film_info` 
-- from (((`sakila`.`actor` `a` left join `sakila`.`film_actor` `fa` on(`a`.`actor_id` = `fa`.`actor_id`)) left join `sakila`.`film_category` `fc` on(`fa`.`film_id` = `fc`.`film_id`)) 
-- left join `sakila`.`category` `c` on(`fc`.`category_id` = `c`.`category_id`)) group by `a`.`actor_id`,`a`.`first_name`,`a`.`last_name`