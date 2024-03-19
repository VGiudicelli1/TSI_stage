-- use postgis to manipule geometries
CREATE EXTENSION IF NOT EXISTS postgis;

-- ------------------------------------------------------------------ --
-- --  Tables and constraints                                      -- --
-- ------------------------------------------------------------------ --
CREATE TABLE public.gite
(
	id SERIAL NOT NULL,
	nom CHARACTER VARYING(256) NOT NULL,
	adresse CHARACTER VARYING(1024) NOT NULL,
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


-- ------------------------------------------------------------------ --
-- --  Views                                                       -- --
-- ------------------------------------------------------------------ --

CREATE VIEW public.vue_gite AS 
	SELECT g.id, g.nom, g.adresse, g.nb_chambre, g.nb_lit, g.mail_contact, g.telephone, g.coords,
	(MAX(ARRAY[l.annee, l.loyer_moyen::int]) FILTER (WHERE l.loyer_moyen > 0))[2] AS dernier_loyer
	FROM public.gite AS g 
	LEFT JOIN public.location AS l ON g.id = l.id_gite
	GROUP BY g.id;

CREATE VIEW public.vue_gite_comment AS 
	SELECT id_gite, annee, commentaire, loyer_moyen 
	FROM public.location;


-- ------------------------------------------------------------------ --
-- --  load data                                                   -- --
-- ------------------------------------------------------------------ --

CREATE TEMP TABLE gite_tmp (
	nom_gite TEXT,
	adresse TEXT,
	lat FLOAT,
	lng FLOAT,
	nb_chambre INT,
	nb_lit INT,
	mail_contact TEXT,
	telephone TEXT,
	annee INT,
	commentaire TEXT,
	loyer_moyen INT
);

COPY gite_tmp
FROM '/docker-entrypoint-initdb.d/gite_forca.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO public.gite (nom, adresse, nb_chambre, nb_lit, coords, mail_contact, telephone) 
	SELECT DISTINCT ON (nom_gite) nom_gite, adresse, nb_chambre, nb_lit, 
	ST_POINT(lat, lng), mail_contact, telephone
	FROM gite_tmp;

INSERT INTO public.location (id_gite, annee, commentaire, loyer_moyen) 
	SELECT g.id, annee, commentaire, loyer_moyen
	FROM gite_tmp JOIN public.gite AS g ON gite_tmp.nom_gite = g.nom;

DROP TABLE gite_tmp;

