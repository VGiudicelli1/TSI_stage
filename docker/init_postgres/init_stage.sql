-- use postgis to manipule geometries
CREATE EXTENSION IF NOT EXISTS postgis;


-- ------------------------------------------------------------------ --
-- --  Tables and constraints                                      -- --
-- ------------------------------------------------------------------ --

CREATE TABLE public.entreprise
(
	id serial NOT NULL,
	nom_entreprise CHARACTER VARYING(256) NOT NULL,
	adresse CHARACTER VARYING(1024) NOT NULL,
	ville CHARACTER VARYING(256) NOT NULL,
	pays CHARACTER VARYING(256) NOT NULL,
	coords GEOMETRY(Point, 4326) NOT NULL,
	mail_contact CHARACTER VARYING(256) DEFAULT NULL,
	lien_site CHARACTER VARYING(256) DEFAULT NULL,

	PRIMARY KEY (id),
	UNIQUE (nom_entreprise, adresse)
);

ALTER TABLE IF EXISTS public.entreprise
	OWNER to postgres;


CREATE TABLE public.stage
(
	id serial NOT NULL,
	id_entreprise BIGINT NOT NULL,
	gratification BOOLEAN DEFAULT NULL,
	titre TEXT NOT NULL,
	domaine CHARACTER VARYING(256) NOT NULL,
	debut DATE NOT NULL,
	fin DATE NOT NULL,
	cycle CHARACTER VARYING(256) NOT NULL,

	PRIMARY KEY (id),
	FOREIGN KEY (id_entreprise)
		REFERENCES public.entreprise (id) MATCH SIMPLE
		ON UPDATE NO ACTION
		ON DELETE NO ACTION
		NOT VALID
);

ALTER TABLE IF EXISTS public.stage
	OWNER to postgres;


-- ------------------------------------------------------------------ --
-- --  Views                                                       -- --
-- ------------------------------------------------------------------ --

CREATE VIEW public.vue_stage AS
	SELECT
		s.id AS id_stage, 
		s.cycle AS cycle,
		s.titre AS titre,
		s.gratification AS gratification,
		1 AS annee,
		1 AS duree,
		e.nom_entreprise AS nom_entreprise,
		e.adresse AS adresse,
		e.ville AS ville,
		e.pays AS pays,
		e.coords AS coords,
		e.mail_contact AS mail_contact,
		e.lien_site AS lien_site
	FROM public.stage AS s
	LEFT JOIN public.entreprise AS e ON s.id_entreprise = e.id;

ALTER TABLE public.vue_stage
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
	ST_POINT(SPLIT_PART(geometry, ',', 2)::float, SPLIT_PART(geometry, ',', 1)::float) AS coords,
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


INSERT INTO public.entreprise (nom_entreprise, adresse, ville, pays, coords, mail_contact, lien_site)
	SELECT entreprise_nom, adresse, ville, pays, coords, contact_mail, NULL FROM internship_tmp2;

INSERT INTO stage (id_entreprise, gratification, titre, domaine, debut, fin, cycle)
	SELECT
		e.id, NULL, i.titre, '', to_date(i.date_debut, 'dd/mm/yyyy'), to_date(i.date_fin, 'dd/mm/yyyy'), i.cycle_eleve
	FROM internship_tmp2 AS i 
	LEFT JOIN public.entreprise AS e ON e.nom_entreprise = i.entreprise_nom AND e.adresse = i.adresse
;

-- remove temp tables
DROP TABLE internship_tmp, internship_tmp2;

