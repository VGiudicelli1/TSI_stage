-- use postgis to manipule geometries
CREATE EXTENSION postgis;

-- ------------------------------------------------------------------ --
-- --  Tables and constraints                                      -- --
-- ------------------------------------------------------------------ --
CREATE TABLE public.student
(
	id serial NOT NULL,
	name character varying(256) NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (name)
);

ALTER TABLE IF EXISTS public.student
	OWNER to postgres;


CREATE TABLE public.organization
(
	id serial NOT NULL,
	name character varying(256) NOT NULL,
	adress character varying(1024) NOT NULL,
	coords Geometry(Point, 4326) NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (name, adress)
);

ALTER TABLE IF EXISTS public.organization
	OWNER to postgres;


CREATE TABLE public.internship
(
	id serial NOT NULL,
	id_student bigint,
	id_organization bigint NOT NULL,
	student_cycle character varying(64) NOT NULL,
	title text NOT NULL,
	begin date NOT NULL,
	"end" date NOT NULL,
	organization_contact character varying(256) NOT NULL,
	gratification boolean,
	rapport_url character varying(1024) NOT NULL,
	diapo_url character varying(1024) NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (id_student)
        REFERENCES public.student (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
        NOT VALID,
    FOREIGN KEY (id_organization)
        REFERENCES public.organization (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

ALTER TABLE IF EXISTS public.internship
	OWNER to postgres;

-- ------------------------------------------------------------------ --
-- --  Views                                                       -- --
-- ------------------------------------------------------------------ --
CREATE VIEW public.view_internship AS
	SELECT
		i.id, i.title, i.begin, i.end, i.organization_contact, 
		i.gratification, i.rapport_url, i.diapo_url,
		o.name AS organization_name, o.adress, o.coords,
		s.name AS student
	FROM internship AS i
	LEFT JOIN organization AS o ON i.id_organization = o.id
	LEFT JOIN student AS s ON i.id_student = s.id;

ALTER TABLE public.view_internship
    OWNER TO postgres;

-- ------------------------------------------------------------------ --
-- --  load data                                                   -- --
-- ------------------------------------------------------------------ --

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
	contact_mail
FROM internship_tmp;


INSERT INTO student (name)
	SELECT nom_eleve FROM internship_tmp2;

INSERT INTO organization (name, adress, coords)
	SELECT entreprise_nom, adresse, coords FROM internship_tmp2;

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
