SET SERVEROUTPUT ON;
SET LINESIZE 200;

/* 1 */ 
DECLARE CURSOR cr 
IS SELECT c.NUM_CHAMBRE,s.NOM_SERVICE,count(h.lit) as nbr_lit_occp,c.nb_lits-count(h.lit) as nbr_lit_libre
from chambre c, service s , hospitalisation h
where c.code_service = s.code_service
and c.num_chambre = h.num_chambre
and c.code_service = h.code_service
group by c.num_chambre,s.nom_service,c.nb_lits
order by s.nom_service;
begin 
for item in cr loop
DBMS_OUTPUT.put_line('la chambre n '||item.NUM_CHAMBRE||' de service '||item.NOM_SERVICE||
'possed '||item.nbr_lit_occp||' lit occupe et'||item.nbr_lit_libre||' lit libre');
end loop;

exception
	when NO_DATA_FOUND THEN DBMS_OUTPUT.put_line('aucune donnee');
end;
/

/* 2 */ 
ALTER TABLE INFIRMIER
DISABLE CONSTRAINT  CHK_Sallaire;

DECLARE CURSOR cr 
IS SELECT *
from infirmier i,employe e
where i.num_inf = e.num_emp;
	nv infirmier.salaire%type := 0;
begin 
for item in cr loop
	if(item.rotation = 'NUIT') then
		UPDATE INFIRMIER
		SET SALAIRE = item.salaire + (item.salaire * 0.6)
		WHERE NUM_INF = item.NUM_INF;
	else
		UPDATE INFIRMIER
		SET SALAIRE = item.salaire + (item.salaire * 0.5)
		WHERE NUM_INF = item.NUM_INF;
	end if; 	
	
	select salaire into nv
	from infirmier
	where num_inf = item.num_inf;
	
	DBMS_OUTPUT.put_line('L infirmier '||item.nom_emp||' de rotation '||item.rotation
	||'son ancien salaire : '||item.salaire||' est son nv salaire : '||nv);
end loop;	
	
end;
/

/* 3 */

create or replace procedure verification(salaire infirmier.salaire%type) is
begin
	if(salaire > 30000 or salaire < 20000) then 
		DBMS_OUTPUT.put_line('Verification negative');
	else
		DBMS_OUTPUT.put_line('Verification positive');
	end if;
end;
/

DECLARE CURSOR cr 
IS SELECT *
from infirmier;
begin 
for item in cr loop
	verification(item.salaire);
end loop;	
	
end;
/

/* 4  JE C PAS*/

create or replace procedure nombremedecin(specialite medecin.specialite%type) is
nbr is integer;
begin
	select count(*) into nbr 
	from medecin m
	where m.specialite = specialite;
	
	DBMS_OUTPUT.put_line('nbr des medecins de la specialite '||specialite||' 
	est : '||nbr);
end;
/

DECLARE CURSOR cr 
IS SELECT distinct(specialite)
from medecin;
begin 
for item in cr loop
	nombremedecin(item);
end loop;	
	
end;
/
