-- use postgis to manipule geometries
CREATE EXTENSION IF NOT EXISTS postgis;

-- ------------------------------------------------------------------ --
-- --  Tables and constraints                                      -- --
-- ------------------------------------------------------------------ --
CREATE TABLE public.gite
(
	id SERIAL NOT NULL,
	nom CHARACTER VARYING(256) NOT NULL,
	nb_chambre INTEGER NOT NULL,
	nb_lit INTEGER NOT NULL,
	coords GEOMETRY(Point, 4326) NOT NULL,
	mail_contact CHARACTER VARYING(256) DEFAULT NULL,
	telephone CHARACTER VARYING(32) DEFAULT NULL,
	
	PRIMARY KEY (id),
	UNIQUE (nom)
);

ALTER TABLE IF EXISTS public.gite
	OWNER to postgres;


CREATE TABLE public.location
(
	id_gite INTEGER NOT NULL,
	annee INTEGER NOT NULL,
	commentaire TEXT DEFAULT NULL,
	loyer_moyen INTEGER DEFAULT NULL,
	
	PRIMARY KEY (id_gite, annee),
	FOREIGN KEY (id_gite)
		REFERENCES public.gite (id) MATCH SIMPLE
		ON UPDATE NO ACTION
		ON DELETE SET NULL
		NOT VALID
);

ALTER TABLE IF EXISTS public.location
	OWNER to postgres;


CREATE VIEW vue_gite AS SELECT g.id, g.nom, g.nb_chambre, g.nb_lit, g.mail_contact, g.telephone, g.coords,
	(MAX(ARRAY[l.annee, l.loyer_moyen::int]) FILTER (WHERE l.loyer_moyen > 0))[2] AS dernier_loyer
	FROM gite AS g 
	LEFT JOIN location AS l ON g.id = l.id_gite
	GROUP BY g.id;

CREATE VIEW vue_gite_comment AS SELECT id_gite, annee, commentaire, loyer_moyen from location;

-- ------------------------------------------------------------------ --
-- --  load data                                                   -- --
-- ------------------------------------------------------------------ --

/*
-- INSERTS FOR TESTS --
INSERT INTO gite (nom, nb_chambre, nb_lit, coords) VALUES 
('gite1', 5, 5, St_Point(1,1)),
('gite2', 3, 2, St_Point(2,0)),
('gite3', 7, 10, St_Point(3,3)),
('gite4', 1, 1, St_Point(4,4)),
('gite5', 8, 3, St_Point(5,7));

INSERT INTO location (id_gite, annee, commentaire, loyer_moyen) VALUES
(1, 2022, 'tres bon gite', 123),
(1, 2023, 'bon gite', 125),
(1, 2024, 'gite interessant', 136),
(2, 2022, 'bien', 251),
(2, 2023, 'ok', 269),
(2, 2024, 'oui', 297),
(3, 2021, 'trop loin', 71),
(3, 2023, 'sympa', NULL),
(4, 2022, 'non', 59),
(5, 2026, 'un peu cher', 8559);
*/



/*
CREATE TEMP TABLE internship_tmp (
	geometry TEXT,
	id_eleve TEXT,
	nom_eleve TEXT,
	cycle_eleve TEXT,
	prof_referent TEXT,
	id_stage TEXT,
	etat_fiche TEXT,
	refuse_par TEXT,
	titre TEXT,
	date_debut TEXT,
	date_fin TEXT,
	entreprise_nom TEXT,
	entreprise_adresse TEXT,
	entreprise_zip TEXT,
	entreprise_ville TEXT,
	entreprise_pays TEXT,
	contact_nom TEXT,
	contact_prenom TEXT,
	contact_mail TEXT
);

COPY internship_tmp
FROM '/docker-entrypoint-initdb.d/stages.csv'
DELIMITER ','
CSV HEADER;

-- reformate and extract data
CREATE TEMP TABLE internship_tmp2 AS SELECT
	ST_GeomFromText(
		'POINT (' || SPLIT_PART(geometry, ',', 2)  || ' ' || SPLIT_PART(geometry, ',', 1) || ')', 
		4326
	) AS coords,
	id_eleve,
	nom_eleve,
	cycle_eleve,
	prof_referent,
	id_stage,
	titre, 
	date_debut,
	date_fin,
	entreprise_nom,
	entreprise_adresse || ', ' || entreprise_ville || ', ' || entreprise_pays AS adresse,
	entreprise_ville AS ville,
	entreprise_pays AS pays,
	contact_mail
FROM internship_tmp;


INSERT INTO student (name)
	SELECT nom_eleve FROM internship_tmp2;

INSERT INTO organization (name, adress, city, country, coords)
	SELECT entreprise_nom, adresse, ville, pays, coords FROM internship_tmp2;

INSERT INTO internship (id_student, id_organization, student_cycle, title,
	"begin", "end", organization_contact, 
	gratification, rapport_url, diapo_url)
	SELECT
		s.id, o.id, i.cycle_eleve, i.titre,
		to_date(i.date_debut, 'dd/mm/yyyy'), to_date(i.date_fin, 'dd/mm/yyyy'), i.contact_mail, 
		NULL, '', ''
	FROM internship_tmp2 AS i 
	LEFT JOIN student AS s ON i.nom_eleve = s.name
	LEFT JOIN organization AS o ON o.name = entreprise_nom AND o.adress = adress
;

-- remove temp tables
DROP TABLE internship_tmp, internship_tmp2;
*/
