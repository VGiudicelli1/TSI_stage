/* DEBUT CODE BURGER (bouton menu) */
// Récupération des éléments pour le menu du bouton
var sidenav = document.getElementById("mySidenav");
var openCloseBtn = document.getElementById("openBtn");

openCloseBtn.onclick = openNav;

/**
 * Permet d'ajouter la classe active au bouton, ou de la retirer
 */
function openNav() {
  if (sidenav.classList.contains("active")) {
    sidenav.classList.remove("active");
  } else {
    sidenav.classList.add("active");
  }
}
/* FIN CODE BURGER */

// Importation des layers de OSM
// Tiles OSM
var PlanOSM = L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
  maxZoom: 19,
  attribution:
    '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
});

// Instanciation de la carte
var map = L.map("map", {
  center: [48.84109788690544, 2.5872660385494566],
  zoom: 4,
  layers: [PlanOSM],
  zoomControl: false,
});

// Création et instanciation de la variable globale des frontières affichées
var bounds = null;
addEventListener("load", function (e) {
  bounds = map.getBounds();
});

// Ajout et déclaration des contrôles sur la carte (zoom, échelle et légendes)
new L.control.scale({ position: "bottomright", imperial: false }).addTo(map);
new L.control.zoom({ position: "bottomright" }).addTo(map);
var legend_act = L.control({ position: "bottomright" });
var legend_vit = L.control({ position: "bottomright" });
var legend_car = L.control({ position: "bottomright" });

// Cluster pour les affichages des zones
var cluster = new L.MarkerClusterGroup();

// Ajout couche de points WFS

/// Définition de l'URL du service WFS
var wfsUrl = window.location.protocol // http: or https:
  + "//" + window.location.hostname	// domain name (or ip adress)
  + ":8080/geoserver" // geoserver
  + "/stages/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=stages%3Avue_stage&maxFeatures=50&outputFormat=application%2Fjson";
requestPoints(wfsUrl);

/// Requête au WFS création des points et clusterisation
function requestPoints(url) {
  fetch(url)
    .then(function (response) {
      return response.json();
    })
    .then(function (data) {
        //Cas où la réponse est vide 
        if (data.totalFeatures==0){
            alert("Aucun stage ne correspond à votre recherche");
        }
        //Cas où la réponse n'est pas vide
        else{
          // Boucle sur la réponse
          data.features.forEach(function (feature) {
        // Extraction de la latitude et la longitude
        var latlng = L.latLng(
          feature.geometry.coordinates[1],
          feature.geometry.coordinates[0]
        );

        // Création d'un marker au point en question, avec une couleur de marker dépendant de l'activité
        var marker = L.marker(latlng, { icon: redIcon });

        // Construction du lien vers la page des détails du stage avec les données spécifiques du stage
        var detailsLink =
          "<a href='details_stage.html?title=" +
          feature.properties.title +
          "&begin=" +
          encodeURIComponent(feature.properties.debut) +
          "&end=" +
          encodeURIComponent(feature.properties.fin) +
          "&organization_contact=" +
          encodeURIComponent(feature.properties.mail_contact) +
          "&gratification=" +
          encodeURIComponent(feature.properties.gratification) +
          "&organization_name=" +
          encodeURIComponent(feature.properties.nom_entreprise) +
          "&adress=" +
          encodeURIComponent(feature.properties.adresse) +
          "&city=" +
          encodeURIComponent(feature.properties.ville) +
          "&country=" +
          encodeURIComponent(feature.properties.pays) +
          "'>Détails du stage</a>";

        // Initialisation des popups
        marker.bindPopup(
          "<h3>" +
            feature.properties.titre +
            "</h3><p>" +
            feature.properties.nom_entreprise +
            "</p><p>" +
            detailsLink +
            "</p>"
        );

        // Ajout du marker au cluster
        cluster.addLayer(marker);
      });
      // Ajout du cluster sur la carte
      cluster.addTo(map);
        }
    })
    .catch(function (error) {
      console.error("Error fetching WFS data:", error);
      alert("Flux WFS non disponible");
    });
}

// Filtres
var start = document.getElementById("start");
var end = document.getElementById("end");
var loc_fr = document.getElementById("france");
var loc_et = document.getElementById("etranger");
var mot_cle= document.getElementById("mot_cle");

var bouton = document.getElementById("applique_filtres");
bouton.addEventListener("click", testFormulaire);

function testFormulaire() {
     // Nettoyage du cluster
     cluster.clearLayers();
     // Retrait du cluster sur la carte
     map.removeLayer(cluster);
     // Initialisation de l'url avec un filtre toujours vrai (utile pour la syntaxe ensuite)
     var url = wfsUrl + "&cql_filter=1=1"
     /// dates
     if (start.value!=""){
        url=url+ "AND debut>='"+start.value+"'";
     }
     if (end.value!="") {
        url=url+ " AND fin<='"+end.value+"'";
     }
     /// localisations
     if (loc_fr.checked && !loc_et.checked){
        url = url + " AND pays='France'";
     }
     else if (!loc_fr.checked && loc_et.checked){
        url = url + " AND NOT pays='France'";
     }
     else if (!loc_fr.checked && !loc_et.checked){
        alert("Sélectionner une localisation")
     }
     /// mot clé
     if (mot_cle.value!=""){
        url = url + " AND titre ILIKE '%25" + mot_cle.value + "%25'";
     }
    //Requête au WFS et création des points
    requestPoints(url);
}
