/* == By Amor Oussama == */
/* == TP 5 == */
/* 1 */
CREATE OR REPLACE TRIGGER affichage
AFTER INSERT OR DELETE OR UPDATE 
ON INFIRMIER 
BEGIN 
	IF(INSERTING) THEN 
		DBMS_OUTPUT.put_line('INFIRMIER INSERE');
	END IF;	
	IF (DELETING) THEN	
		DBMS_OUTPUT.put_line('INFIRMIER SUPPRIME');
	END IF;
	IF (UPDATING) THEN	
		DBMS_OUTPUT.put_line('INFIRMIER MISE A JOUR');
	END IF;
END;
/	

/* 2 */
CREATE OR REPLACE TRIGGER nv_inf_affecte
AFTER INSERT  
ON INFIRMIER 
FOR EACH ROW
BEGIN 
	DBMS_OUTPUT.put_line('UN NOUVEAU EMPLOYE EST AFFECTE A '
	||:NEW.CODE_SERVICE);
END;
/

/* 3 */
CREATE OR REPLACE TRIGGER verif_code_service
BEFORE UPDATE  
ON INFIRMIER 
FOR EACH ROW
DECLARE
	N INTEGER; 
BEGIN 
	SELECT COUNT(*) INTO N
	FROM SERVICE S
	WHERE S.CODE_SERVICE = :NEW.CODE_SERVICE;
	
	IF( N = 0) THEN
		RAISE_APPLICATION_ERROR(-20555, 'CODE SERVICE NON VALIDE !');
	END IF;
END;
/
/* 4 */
CREATE OR REPLACE TRIGGER salaire_inf_precedent
BEFORE UPDATE  
OF SALAIRE
ON INFIRMIER 
FOR EACH ROW
BEGIN 
	IF(:OLD.SALAIRE > :NEW.SALAIRE) THEN
		RAISE_APPLICATION_ERROR(-20555, 'SALAIRE INFERIEUR A LA PRECEDENTE !');
	END IF;
END;
/

/* 5 */
/*a*/
ALTER TABLE SERVICE
ADD total_salaire_service NUMBER(10,2);

UPDATE SERVICE S
SET total_salaire_service = (SELECT SUM(SALAIRE)
							FROM INFIRMIER I
							GROUP BY I.CODE_SERVICE
							HAVING S.CODE_SERVICE = I.CODE_SERVICE);

	
/*b*/	
CREATE OR REPLACE TRIGGER maj_service_insertion_inf
AFTER INSERT  
ON INFIRMIER 
FOR EACH ROW
BEGIN 
	UPDATE SERVICE S
	SET total_salaire_service = S.total_salaire_service + :NEW.SALAIRE
	WHERE S.CODE_SERVICE = :NEW.CODE_SERVICE;
END;
/
/*c*/
CREATE OR REPLACE TRIGGER TotalSalaireUpdate_trigger
AFTER UPDATE
OF SALAIRE  
ON INFIRMIER 
FOR EACH ROW
BEGIN 
	UPDATE SERVICE S
	SET total_salaire_service = S.total_salaire_service + :NEW.SALAIRE
	WHERE S.CODE_SERVICE = :NEW.CODE_SERVICE;
END;
/
UPDATE INFIRMIER
SET SALAIRE = 150000
WHERE NUM_INF = 194;

/* 6 */


CREATE OR REPLACE TRIGGER TotalSalaireUpdate2_trigger
AFTER UPDATE
OF CODE_SERVICE  
ON INFIRMIER 
FOR EACH ROW
BEGIN 
	UPDATE SERVICE S
	SET total_salaire_service = S.total_salaire_service + :NEW.SALAIRE
	WHERE S.CODE_SERVICE = :NEW.CODE_SERVICE;
	
	UPDATE SERVICE S
	SET total_salaire_service = S.total_salaire_service - :OLD.SALAIRE
	WHERE S.CODE_SERVICE = :OLD.CODE_SERVICE;
END;
/

UPDATE INFIRMIER
SET CODE_SERVICE = 'REA'
WHERE NUM_INF = 194;
/* 7 */


