-----------------------------------------------------------------------------------------------
-- Implémentation de procédures stockées                                                     --
--                                                                                           --
-- Complétez ce fichier avec vos propositions de procédures                                  --
-- Dans le cas où du code vous est déjà fourni, bien faire attention de compléter les "????" --
--                                                                                           --
-- Bon courage !                                                                             --
-----------------------------------------------------------------------------------------------

-- Ecrire une fonction qui renvoie un status utilisateur en fonction du nombre de DVD déjà loués.
-- De 0 à 10 locations : le status est "Casual viewer"
-- de 10 à 30 locations : le status est "Amateur"
-- > 30 locations : le status est "Cinéphile"
--
-- En SQL, pour appeler une fonction vous pouvez utiliser un SELECT.
-- Exemple : SELECT user_status(1);
--
-- Données en entrée :
-- + int, identifiant de l'utilisateur
-- Donnée en sortie :
-- + VARCHAR(20), le status de l'utilisateur
CREATE FUNCTION sakila.user_status(IN user_id INT)
RETURNS VARCHAR(20)
BEGIN
    DECLARE rentals_count INT DEFAULT 0;
    DECLARE user_status VARCHAR(20);

    -- Compter le nombre de locations pour l'utilisateur
    SELECT COUNT(*) INTO rentals_count FROM rental WHERE customer_id = user_id;

    -- Déterminer le statut utilisateur en fonction du nombre de locations
    IF rentals_count <= 10 THEN
        SET user_status = 'Casual viewer';
    ELSEIF rentals_count <= 30 THEN
        SET user_status = 'Amateur';
    ELSE
        SET user_status = 'Cinéphile';
    END IF;

    -- Retourner le statut de l'utilisateur
    RETURN user_status;
END;

-- utilisation :
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    sakila.user_status(c.customer_id) AS status
FROM customer c  
ORDER BY `c`.`customer_id` ASC;

CREATE FUNCTION sakila.user_status(IN user_id int)
RETURNS VARCHAR(20)
BEGIN
	DECLARE rentals_count INT DEFAULT 0;

	SELECT count(*) INTO rentals_count FROM rental WHERE customer_id = user_id;
RETURN user_status;
	-- Implémenter une structure de contrôle permettant de renvoyer la chaîne de caractère attendue
    -- Plus d'information sur les structures de contrôle en MariaDB : https://mariadb.com/kb/en/programmatic-compound-statements/
END

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

-- Ecrire une fonction qui retourne le nombre de DVD disponibles à location (non empruntés) proposés par un magasin.
-- 
-- Attention, si l'identifiant du magasin n'existe pas dans la table magasin il faudra lever une erreur avec le mécanisme de SIGNAL de MariaDb
-- Plus d'information sur SIGNAL : https://mariadb.com/kb/en/signal/
--
-- Donnée d'entrée :
-- + int, identifiant d'un magasin
DELIMITER $$
CREATE FUNCTION sakila.count_inventory(IN store_id int)
RETURNS INT
BEGIN
	DECLARE store_ok TINYINT(1) DEFAULT 0;
	DECLARE inventory_count INT DEFAULT 0;

	-- vérification de l'existence du magasin
	SET store_ok = EXISTS(SELECT * from store s WHERE s.store_id = store_id);
	
	-- Traiter l'erreur au besoin
    IF store_ok = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Magasin non trouvé';
    END IF;

	-- Comptage des DVDs disponibles
    SELECT COUNT(*) INTO inventory_count
    FROM inventory i
    WHERE i.store_id = store_id
    AND i.inventory_id NOT IN (
        SELECT r.inventory_id 
        FROM rental r 
        WHERE r.return_date IS NULL
    );
	
	return inventory_count;
END$

DELIMITER ;

--utilisation : avec store_id=2, retourne 2221
SET @p0='2'; SELECT `count_inventory_film`(@p0) AS `count_inventory_film`;


-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

-- Ecrire une fonction qui renvoie "VRAI" si le DVD est en inventaire dans un magasin précisé en paramètre.
-- 
-- La fonction retourne "FAUX" dans le cas contraire.
--
-- Données en entrée : 
-- + int, identifiant d'un magasin
-- + text, titre du film
-- Donnée en sortie :
-- + TINYINT(1) (équivalent du bool en MySQL) : 1 si le film est en inventaire, 0 sinon
--
-- Pour tester votre fonction utilisez l'appel suivant : SELECT is_film_in_inventory(1, "ACADEMY DINOSAUR");
CREATE FUNCTION sakila.is_film_in_inventory(int store_id, TEXT film_title)
RETURNS TINYINT(1)
BEGIN
    -- Déclaration de la variable résultat
    DECLARE inventory_count INT DEFAULT 0;

    -- Faire la requête permettant de mettre à jour la variable
    SELECT COUNT(*) INTO inventory_count
    FROM inventory i
    JOIN film f ON i.film_id = f.film_id
    WHERE i.store_id = store_id
      AND f.title = film_title;

    -- retourner le résultat de la fonction
     IF inventory_count > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END

-- utilisation => renvoie 1
SET @p0='1'; SET @p1='ACADEMY DINOSAUR'; SELECT `is_film_in_inventory`(@p0, @p1) AS `is_film_in_inventory`;

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--
-- Ecrire une procédure qui renvoie une chaîne de caractère correspondant à la concaténation des 3 films les plus loués.
-- Il vous est demandé d'utiliser un curseur pour constuire cette procédure.
-- 
-- Données en entrée : aucune
-- Données en sortie : chaîne de caractère correspondant à la concaténation de 3 titres de films
--
-- Avec le jeu d'essai founi vous devriez obtenir : "FORWARD TEMPLE, ROCKETEER MOTHER, BUCKET BROTHERHOOD"
--
-- Ci-dessous la déclaration de la procédure et des indices sur le développement

CREATE FUNCTION sakila.most_rented_films()
RETURNS TEXT 
BEGIN
    -- Vous allez utiliser un curseur pour passer en revue les résultats d'une requête
    -- Voici un tutoriel sur le fonctionnement des curseurs en MySQL : https://waytolearnx.com/2019/11/les-curseurs-dans-mysql.html

    -- Les étapes de l'algorithme à développer sont :
    -- 1 déclaration des variables qui seront utilisées

    -- 2 Déclaration du curseur avec la requête répondant au besoin (vous avez peut être déjà fait cette requête :) )

    -- 3 Boucle qui permettra de passer en revue les résultat de la requête et constuire la chaîne de caractère résultat

    -- 4 retour de la chaîne de caractères résultat
end

-- procédure qui renvoie "null"
DELIMITER $$
CREATE PROCEDURE sakila.most_rented_films_1(OUT result TEXT)
BEGIN
    DECLARE
        done INT DEFAULT 0 ; DECLARE film_title TEXT ; DECLARE result TEXT DEFAULT '' ; --=> la déclaration du result ici renvoie la valeur null, il faut 
        -- l'initialiser entre declare continue handler... et open cur
    DECLARE cur CURSOR FOR
    SELECT
        f.title
    FROM
        film f
    JOIN inventory i ON
        f.film_id = i.film_id
    JOIN rental r ON
        i.inventory_id = r.inventory_id
    GROUP BY
        f.title
    ORDER BY
        COUNT(r.rental_id)
    DESC
LIMIT 3 ; 
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1 ; 
OPEN cur ; 
read_loop: LOOP 
	FETCH cur INTO film_title ; 
    IF done THEN LEAVE read_loop ;
	END IF ; 
    
    IF result IS NOT NULL AND result != '' THEN
            SET result = CONCAT(result, ', ');
        END IF;

        
        SET result = CONCAT(result, film_title);
END LOOP ; 
CLOSE cur ;
END$

DELIMITER ;

-- même code en fonction, renvoie le bon résultat
CREATE FUNCTION sakila.most_rented_films_1()
RETURNS TEXT
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE film_title TEXT;
    DECLARE result TEXT DEFAULT '';
    DECLARE cur CURSOR FOR
    SELECT
        f.title
    FROM
        film f
    JOIN inventory i ON
        f.film_id = i.film_id
    JOIN rental r ON
        i.inventory_id = r.inventory_id
    GROUP BY
        f.title
    ORDER BY
        COUNT(r.rental_id) DESC
    LIMIT 3;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO film_title;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF result IS NOT NULL AND result != '' THEN
            SET result = CONCAT(result, ', ');
        END IF;
        
        SET result = CONCAT(result, film_title);
    END LOOP;

    CLOSE cur;

    RETURN result;
END;

-- procédure avec débogage, fonctionne car l'initialisation du result est déplacé au bon endroit
BEGIN
    DECLARE
        done INT DEFAULT 0 ; 
    DECLARE film_title TEXT ; 
    DECLARE cur CURSOR FOR
    SELECT
        f.title
    FROM
        film f
    JOIN inventory i ON
        f.film_id = i.film_id
    JOIN rental r ON
        i.inventory_id = r.inventory_id
    GROUP BY
        f.title
    ORDER BY
        COUNT(r.rental_id)
    DESC
LIMIT 2 ; 
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1 ; 
SET result = ''; --=>il faut initialiser le résultat ici 
OPEN cur ; 
read_loop: LOOP 
	FETCH cur INTO film_title ; 
    IF done THEN LEAVE read_loop ;
	END IF ; 
    SELECT film_title AS "Titre récupéré";
    IF result IS NOT NULL AND result != '' THEN
            SET result = CONCAT(result, ', ');
        END IF;

        
        SET result = CONCAT(result, film_title);
        SELECT result AS "Résultat intermédiaire";
END LOOP ; 
CLOSE cur ;
SELECT result AS "Résultat final";
END
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------


-- Ecrire une procédure qui renvoie la médiane de la durée des films
-- Indice sur le développement : https://www.1keydata.com/fr/sql/sql-mediane.php
-- requête :
SELECT length median FROM 
(SELECT l1.film_id, l1.length, COUNT(l1.length) Rank
 FROM `film` l1, `film` l2
 WHERE l1.length < l2.length OR (l1.length = l2.length AND l1.film_id <= l2.film_id)
 GROUP BY l1.film_id, l1.length
 ORDER BY l1.length DESC) l3
 WHERE Rank  = (SELECT (COUNT(*)+1) DIV 2 FROM `film`);
--   retourne median = 114
-- procédure median_length sans paramètres
BEGIN

SELECT length AS median 
FROM (
SELECT l1.film_id, l1.length, COUNT(l1.length) AS Rank
 FROM `film` l1, `film` l2
 WHERE l1.length < l2.length OR (l1.length = l2.length AND l1.film_id <= l2.film_id)
 GROUP BY l1.film_id, l1.length
 ORDER BY l1.length DESC) AS l3
 WHERE Rank  = (SELECT (COUNT(*)+1) DIV 2 FROM `film`);

END