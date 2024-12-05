-----------------------------------------------------------------------------------
-- Entraînement LMD : Langage de manipulation des données                        --
--                                                                               --
-- Requêtes UPDATE :                                                             --
-- 1. Prendre connaissance de la ressource : https://sql.sh/cours/update         --
-- 2. Compléter ce fichier avec vos propositions de requêtes                     --
-- 3. Pousser votre code sur votre Git                                           --
--                                                                               --
-- Merry query!                                                                  --
-----------------------------------------------------------------------------------

-- Une erreur s'est glissée dans le prénom de l'utilisateur d'identifiant 98.
-- Ecrire une requête permettant de changer l'ortographe de "Lillian" en "Lilian"
-->
UPDATE `customer` 
SET `first_name`='Lilian'
WHERE customer_id=98

-- Le client Lee Hawks rend le film "DETECTIVE VISION" (des années après, il avait oublié, ne lui en voulez pas)
-- Il l'a rendu ce matin à 8h30.
-- Ecrire une requête qui met à jour la date et heure de retour pour sa location.
-->
SELECT * FROM `customer` WHERE `first_name`="Lee"; -->customer_id=421
SELECT * FROM `film` WHERE `title`="DETECTIVE VISION"; --> film_id=228
SELECT * FROM `rental` WHERE `customer_id`=421 ORDER BY `rental`.`return_date` ASC; --> 1 seul enregistrement non retourné, rental_id=15710
UPDATE `rental` SET `return_date` = CONCAT(CURRENT_DATE(), ' 08:30:00') WHERE `rental_id` = 15710;



-- Comme chacun le sait, "ACADEMY DINOSAUR" est un film hilarant. Le film n'a malheureusement que la catégorie "Documentary".
-- Il est important que les gens sachent qu'une importante dose d'humour les attend en louant ce film.
--
-- Ecrire une requête qui ajoute la catégorie "Comedy" au film "ACADEMY DINOSAUR".
-->"ACADEMY DINOSAUR": film_id=1, "Comedy" : `category_id`=5
INSERT INTO `film_category`(`film_id`, `category_id`, `last_update`) VALUES (1,5,NOW()); --=> "ACADEMY DINOSAUR" a 2 catégories 5 et 6



-- Le membre de l'équipe Jon Stephens met à jour son mot de passe (jusqu'alors manquant).
-- RÈGLE FONDAMENTALE : les mots de passe en base de données doivent être HACHÉS !!
-- Plus d'informations sur les fonctions de Hachage : https://youtu.be/OHXfKCH0b6s?si=XoQk2piTDPrxi6dO&t=32
--
-- Jon souhaite mettre son mot de passe à jour avec le mot de passe suivant : edgarCodd4Ever
--
-- Avant de l'insérer, hachez le en suivant les recommandations de OWasp : https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
-- Pour hacher des mots de passe vous pourrez utiliser des outils en ligne, par exemple pour Argon2id : https://argon2.online/
--
-- Ecrire la requête avec le hash calculé via l'outil en ligne.
-->

UPDATE `staff` SET `password`='c33f68ecd101bb3ed31d85b6229b5be39e721984' WHERE `first_name`="jon"

-- Que remarquez vous en comparant le hash du mot de passe de Mike et celui de Jon ? même longueur
-- Essayez de retrouver le mot de passe en clair de Jon en utilisant l'outil suivant : https://sha1.gromweb.com/?hash=8cb2237d0679ca88db6464eac60da96345513964
--> impossible : "Provided SHA-1 hash could not be reversed into a string: no reverse string was found."
-- Quelle est la morale de cette histoire ? :)
--> rien ne vaut un mot de passe solide
-- Re-calculez le hash du mot de passe de Mike en utilisant Argon2id puis écrivez une requête qui permet de le mettre à jour.
-->
UPDATE `staff` SET `password`='d9b7a58c17de00c4b68230c4b3f8be5648251b4f' WHERE `first_name`="mike"




-- Mettre à "null" les valeurs de la colonne "address2" de la table "address" dans le cas où "adress2" est vide (mais non "null")
--> 
UPDATE `address` SET `address2`= NULL WHERE `address2`="";

-- Le fournisseur a augmenté le coût des supports. Chaque DVD coûte maintenant 1 dollar de plus.
-- Modifiez le coût de remplacement de tous les films en augmentant la valeur d'un.
-->
UPDATE `film` 
SET `replacement_cost`=`replacement_cost`+1,`last_update`=NOW() 
WHERE 1

-- Le magasin d'identifiant 1 déménage, il ne sera plus situé au 47 MySakila Drive mais au 78 DataBase street (même ville, même département).
-- Ecrire une requête permettant de faire la modification.
--> store_id=1 a address_id=1
UPDATE `address` 
SET `address`='78 DataBase street'
`last_update`=NOW()
WHERE `address_id`=1