-----------------------------------------------------------------------------------
-- Entraînement LMD : Langage de manipulation des données                        --
--                                                                               --
-- Requêtes DELETE :                                                             --
-- 1. Prendre connaissance de la ressource : https://sql.sh/cours/delete         --
-- 2. Compléter ce fichier avec vos propositions de requêtes                     --
-- 3. Pousser votre code sur votre Git                                           --
--                                                                               --
-- Merry query!                                                                  --
-----------------------------------------------------------------------------------

-- Le magasin qui avait été ouvert près de chez vous (si, si, souvenez vous... Et regardez le fichier "queries-insert.sql") ferme ses portes, ainsi va la vie.
--
-- Ecrire une requête qui supprime ce magasin.
--> 
DELETE FROM `store` WHERE `store_id`=3 --> impossible : #1451 - Cannot delete or update a parent row: 
                -->a foreign key constraint fails (sakila.customer, CONSTRAINT fk_customer_store FOREIGN KEY (store_id) 
                -->REFERENCES store (store_id) ON UPDATE CASCADE)

--> d'abord supprimer les customers dont le store_id =3
DELETE FROM `customer` WHERE `store_id`=3;
--> modifier le store_id du staff lié au store_id=3 dans la table staff (store_id ne peut être null et la ligne ne peut être effacée)
DELETE FROM store WHERE `store`.`store_id` = 3 --=> ligne supprimée via la commande 'Supprimer' de phpMyAdmin


-- L'utilisatrice Sharon Robinson décide de supprimer son compte.
-- En vertu du droit à l'effacement du Réglement Général pour la Protection des Données (RGPD) toutes ses informations personnelles 
-- devront être supprimées : https://www.cnil.fr/fr/comprendre-mes-droits/le-droit-leffacement-supprimer-vos-donnees-en-ligne
--
-- Ecrire une requête permettant de supprimer l'utilisatrice et toutes ses données associées.
--
-- Disclaimer : vous allez rencontrer un blocage lors de la suppression.
-- Renseignez vous sur la notion de "DELETE CASCADE" pour solutionner le problème : https://www.mysqltutorial.org/mysql-basics/mysql-on-delete-cascade/
-- Dans ce cas vous allez devoir passer par une modification des contraintes de clé étrangère.
-->
SELECT * FROM `customer` WHERE `first_name`="Sharon";-->customer_id=20
DELETE FROM `customer` WHERE `customer_id`=20 -->#1451 - Cannot delete or update a parent row: a foreign key constraint fails (`sakila`.`payment`, 
-->CONSTRAINT `fk_payment_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON UPDATE CASCADE)
DELETE FROM `payment` WHERE `customer_id`=20;
DELETE FROM `customer` WHERE `customer_id`=20 --> #1451 - Cannot delete or update a parent row: a foreign key constraint fails (`sakila`.`rental`, 
-->CONSTRAINT `fk_rental_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON UPDATE CASCADE)
DELETE FROM `rental` WHERE `customer_id`=20;
DELETE FROM `customer` WHERE `customer_id`=20; --> suppression réussie