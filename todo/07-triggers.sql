-----------------------------------------------------------------------------------------------
-- Implémentation de triggers                                                                --
--                                                                                           --
-- Complétez ce fichier avec vos propositions de triggers.                                   --
-- Dans le cas où du code vous est déjà fourni, bien faire attention de compléter les "????" --
--                                                                                           --
-- Plus d'informations sur les triggers :                                                    --
-- + https://www.mariadbtutorial.com/mariadb-triggers/mariadb-create-trigger/                --
--                                                                                           --
-- Attention de ne pas oublier "delimiter //" lors de la création de triggers.               --
--                                                                                           --
-- Bon courage !                                                                             --
-----------------------------------------------------------------------------------------------

-------- Cas d'utilisation : empêcher la suppression d'enregistrement --------
-- 
-- On considère que Mike Hillyer est le super administrateur de l'application (en plus d'être un excellent loueur).
-- Vous allez mettre en place une trigger pour empêcher la suppression de cet utilisateur.
--
-- Vous allez procéder en plusieurs étapes :
-- 1. Cibler quand le trigger doit se déclencher
-- 2. Cibler la table à utiliser
-- 3. Implémenter l'empêchement de suppression
--
-- Compléter les ????? de ce trigger
delimiter //
CREATE OR REPLACE TRIGGER `stop_delete_admin` ??????? ON ????? FOR EACH ROW
BEGIN
    -- Insérer ici le code de vérification d'identité
    -- Il est possible de faire référenc à l'enregistrement que l'on tente de supprimer en utilisant le mot clé OLD
    if ????? then
        -- La ligne suivante permet d'interrompre le traitement et ainsi d'empêcher la suppression
        -- Faire évoluer cette ligne pour afficher le message 'Impossible de supprimer l'utilisateur super admin : <prenom-identifiant-1> <nom-identifiant-1>
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = ???????;
    end f;
END;
// 
-- code : 
DELIMITER //

CREATE OR REPLACE TRIGGER `stop_delete_admin` 
BEFORE DELETE ON `staff` 
FOR EACH ROW
BEGIN
    
    IF OLD.first_name = 'Mike' AND OLD.last_name = 'Hillyer' THEN
        
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Impossible de supprimer l''utilisateur super admin : Mike Hillyer';
    END IF;
END;
//

DELIMITER ;

-- essai de suppression :  #1644 - Impossible de supprimer l'utilisateur super admin : Mike Hillyer

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------



--
-- Il vous est demandé d'écrire un trigger qui empêche la suppression de tous les enregistrements de "rental" pour lesquels il n'y a pas de dates de retour.
-- Cette fois-ci, aucun code n'est fourni.
-- You can do it!
-->
DELIMITER //
CREATE OR REPLACE TRIGGER `stop_delete_rental_no_return_date` 
BEFORE DELETE ON `rental` 
FOR EACH ROW
BEGIN
    
    IF OLD.return_date IS NULL THEN
        
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Impossible de supprimer les enregistrements pour lesquels il n''y a pas de dates de retour';
    END IF;
END;
//

DELIMITER ;

--essai de suppression de l'enregistrement rental_id=14098 dont return_date=null 
--=>  #1644 - Impossible de supprimer les enregistrements pour lesquels il n'y a pas de dates de retour


-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

-------- Cas d'utilisation : mettre à jour des informations d'une table --------
--
-- Mettre en place un trigger permettant de mettre à jour la "last_update" de la table "rental" dans le cas où la colonne "return_date" est mise à jour.
-- "last_update" doit donc être mis à jour lors de la modification de "return_date"
--
-- En SQL la date actuelle peut être retrouvée en utilisant le fonction "now()"
delimiter //
CREATE OR REPLACE TRIGGER `update_last_update` 
AFTER  UPDATE ON `rental`
FOR EACH ROW
BEGIN
IF NEW.return_date <> OLD.return_date THEN 
	UPDATE rental SET last_update=NOW();  --> remaque : à priori Dans un trigger AFTER, tu ne peux pas utiliser UPDATE sur la même table (rental) car cela créerait une boucle infinie. 
END IF;
END
//

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- Mettre en place un trigger permettant de mettre à jour une table de suivi des dépenses totales des clients.
-- Chaque total devra être rattaché au membre du staff qui a encaissé le paiement.
--
-- Etapes de développement :
-- 1. Créer une table "total_payment" avec la structure suivante (données fictives)
--  __________________________
--  |     total_payment      |
--  | id | amount | staff_id |
--  |  1 |  1212  |     1    |
--  |  2 |  5465  |     2    |
--  ▔▔▔▔▔▔▔▔▔▔▔▔▔▔

-- création de la table total_payement avec les 3 colonnes puis insertion des données
SELECT staff_id, SUM(amount) AS total_amount FROM payment GROUP BY staff_id;
INSERT INTO total_payement (amount, staff_id) VALUES (33485.49, 1);
INSERT INTO total_payement (amount, staff_id) VALUES (33924.06, 2);

--  Pour créer une nouvelle table de base de données référez vous à la documentation suivante : https://www.mariadbtutorial.com/mariadb-basics/mariadb-create-table/
--  Pour les types de données à utiliser pour chaque colonne : https://mariadb.com/kb/en/data-types-numeric-data-types/
--
-- 2. Une fois la table créée, implémentez un trigger qui devra mettre à jour la colonne "amount" qui correspond au "staff_id" correct

CREATE OR REPLACE TRIGGER `update_total_payement` 
AFTER  INSERT ON `payment`
FOR EACH ROW
BEGIN
    DECLARE current_amount DECIMAL(10, 2);
    
    SELECT amount INTO current_amount
    FROM total_payement
    WHERE staff_id = NEW.staff_id;
   
    IF current_amount IS NOT NULL THEN
        UPDATE total_payement
        SET amount = current_amount + NEW.amount
        WHERE staff_id = NEW.staff_id;
    ELSE
        
        INSERT INTO total_payement (amount, staff_id)
        VALUES (NEW.amount, NEW.staff_id);
    END IF;
END
-- vérification :
INSERT INTO payment (amount, staff_id, customer_id) VALUES (100.00, 1,5);
-- mise à jour de la colonne amount +100,00 pour le staff_id=1

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-------- Cas d'utilisation : création de table d'audit --------
--
-- Implémentez une table d'audit de la table "staff".
-- Vous pourrez vous inspirer du tutoriel suivant : https://medium.com/@rajeshkumarraj82/mysql-table-audit-trail-using-triggers-bd32b772cce5
--
create table staff_audit_trail(id int NOT NULL AUTO_INCREMENT, 
staff_id tinyint(3) NOT NULL,
last_name_audit varchar(45),
old_value varchar(45),
new_value varchar(45),
done_by varchar(45) NOT NULL,
done_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (id));

DELIMITER
    $$
CREATE TRIGGER staff_change AFTER UPDATE
ON
    staff FOR EACH ROW
BEGIN
    IF OLD.first_name <> NEW.first_name THEN
        INSERT INTO staff_audit_trail(
            staff_id,
            last_name_audit,
            old_value,
            new_value,
            done_by
        )
        VALUES(
            NEW.staff_id,
            'FirstName',
            OLD.first_name,
            NEW.first_name,
            USER()
        );
    END IF;

    IF OLD.last_name <> NEW.last_name THEN
        INSERT INTO staff_audit_trail(
            staff_id,
            last_name_audit,
            old_value,
            new_value,
            done_by
        )
        VALUES(
            NEW.staff_id,
            'LastName',
            OLD.last_name,
            NEW.last_name,
            USER()
        );
    END IF;
    IF OLD.address_id <> NEW.address_id THEN
        INSERT INTO staff_audit_trail(
            staff_id,
            last_name_audit,
            old_value,
            new_value,
            done_by
        )
        VALUES(
            NEW.staff_id,
            'address_id',
            OLD.address_id,
            NEW.address_id,
            USER()
        );
    END IF;
    IF OLD.email <> NEW.email THEN
        INSERT INTO staff_audit_trail(
            staff_id,
            last_name_audit,
            old_value,
            new_value,
            done_by
        )
        VALUES(
            NEW.staff_id,
            'email',
            OLD.email,
            NEW.email,
            USER()
        );
    END IF;
    IF OLD.store_id <> NEW.store_id THEN
        INSERT INTO staff_audit_trail(
            staff_id,
            last_name_audit,
            old_value,
            new_value,
            done_by
        )
        VALUES(
            NEW.staff_id,
            'store_id',
            OLD.store_id,
            NEW.store_id,
            USER()
        );
    END IF;
    IF OLD.password <> NEW.password THEN
        INSERT INTO staff_audit_trail(
            staff_id,
            last_name_audit,
            old_value,
            new_value,
            done_by
        )
        VALUES(
            NEW.staff_id,
            'password',
            OLD.password,
            NEW.password,
            USER()
        );
    END IF;

   
END $$
DELIMITER
    ;

