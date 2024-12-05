-----------------------------------------------------------------------------------
-- Entraînement LMD : Langage de manipulation des données                        --
--                                                                               --
-- Requêtes INSERT :                                                             --
-- 1. Prendre connaissance de la ressource : https://sql.sh/cours/insert-into    --
-- 2. Compléter ce fichier avec vos propositions de requêtes                     --
--                                                                               --
-- Merry query!                                                                  --
-----------------------------------------------------------------------------------

-- Un magasin ouvre dans votre ville.
-- Insérer un nouveau magasin situé à une adresse proche de chez vous.
--> création des adresses pour le magasin (city_id=606) et pour le responsable du magasin (city_id=607)
--> création du responsable du magasin (staff_id=3) en lui affectant un magasin existant
--> création du magasin (store_id=3)
--> modification du responsable pour lui affecter le nouveau magasin

-- Insérer un nouveau client ayant les informations suivantes :
-- Prénom : "Inés"
-- Nom : Cuhelle
-- Email : ines.cuhelle@sgbd.com
-- Adresse : 3 boulevard de la Requête, 35600 Bretagne, Brest, France
-- Tél : 0656234556 
-->
INSERT INTO `address`(`address`, `district`, `city_id`, `postal_code`, `phone`) 
VALUES ("3 boulevard de la Requête","Bretagne", 92,"35600","0656234556"); --=>address_id=608
INSERT INTO `customer`(`store_id`, `first_name`, `last_name`, `email`, `address_id`, `create_date`, `last_update`) 
VALUES (3,"Inés","Cuhelle","ines.cuhelle@sgbd.com",608,NOW(),NOW()) -->customer_id=600
-- Insérer un enregistrement indiquant que Lisa Anderson a loué "Academy Dinosaur" au magasin 1. Le film a été loué par Mike Hillyer ? faut-il créer un nouveau customer ?
-->recherche des id nécessaires : customer_id, inventory_id, staff_id
SELECT * FROM `customer` 
WHERE customer.first_name="Lisa"; -->customer_id=11
SELECT `film_id`,`title` FROM `film`
WHERE title="Academy Dinosaur"; --> film_id=1
SELECT * FROM `inventory`
WHERE film_id=1 AND store_id=1; --> inventory_id=1,2,3,4
--> vérifier que le film est diponible dans le store 1
SELECT * FROM `rental`
WHERE `staff_id`=1 AND (`inventory_id`=1 OR `inventory_id`=2 OR`inventory_id`=3 OR `inventory_id`=4);
-->ajouter l'enregistrement
INSERT INTO `rental`( `rental_date`, `inventory_id`, `customer_id`,`staff_id`) 
VALUES (NOW(),1,11,1); -->rental_id=16050