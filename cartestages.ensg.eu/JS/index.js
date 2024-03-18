/* DEBUT CODE BURGER (bouton menu) */
// Récupération des éléments pour le menu du bouton
var sidenav = document.getElementById("mySidenav");
var openCloseBtn = document.getElementById("openBtn");

openCloseBtn.onclick = openNav;

/**
 * Permet d'ajouter la classe active au bouton, ou de la retirer
 */
function openNav() {
    if(sidenav.classList.contains("active")) {
       sidenav.classList.remove("active");
    } else {
       sidenav.classList.add("active");
    }
 }
/* FIN CODE BURGER */

// Importation des layers de OSM
// Tiles OSM
var PlanOSM = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
});

// Instanciation de la carte
var map = L.map('map',{
    center: [48.84109788690544, 2.5872660385494566],
    zoom: 4,
    layers: [PlanOSM],
    zoomControl :false
});

// Création et instanciation de la variable globale des frontières affichées
var bounds = null;
addEventListener('load' , function (e) {
    bounds = map.getBounds();
});

// Ajout et déclaration des contrôles sur la carte (zoom, échelle et légendes)
new L.control.scale({position : 'bottomright', imperial:false}).addTo(map);
new L.control.zoom({position :'bottomright'}).addTo(map);
var legend_act = L.control({position: 'bottomright'});
var legend_vit = L.control({position: 'bottomright'});
var legend_car = L.control({position: 'bottomright'});


// Cluster pour les affichages des zones
var cluster = new L.MarkerClusterGroup();

// Ajout couche de points WFS

/// Définition de l'URL du service WFS
var wfsUrl = 'http://172.31.58.191:8080/geoserver/stages/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=Stages%3Aview_internship&maxFeatures=50&outputFormat=application%2Fjson';
requestPoints(wfsUrl);

/// Requête au WFS création des points et clusterisation
function requestPoints(url){
    fetch(url)
    .then(function(response) {
        return response.json();
    })
    .then(function(data) {
        // Boucle sur la réponse
        data.features.forEach(function(feature) {
            // Extraction de la latitude et la longitude
            var latlng = L.latLng(feature.geometry.coordinates[1], feature.geometry.coordinates[0]);
    
            // Création d'un marker au point en question, avec une couleur de marker dépendant de l'activité
            var marker = L.marker(latlng, {icon : redIcon});
            
            // Initialisation des popups
            marker.bindPopup("<h3>" + feature.properties.title+"</h3><p>"+ feature.properties.organization_name+"<\p>")
        
            // Ajout du marker au cluster
            cluster.addLayer(marker)
        })
        // Ajout du cluster sur la carte
        cluster.addTo(map);
    })
    .catch(function(error) {
        console.error('Error fetching WFS data:', error);
        alert("Flux WFS non disponible");
    });
}


// Filtres 
var start= document.getElementById("start");
var end= document.getElementById("end");
var loc_fr= document.getElementById("france");
var loc_et= document.getElementById("etranger");

var bouton = document.getElementById("applique_filtres");
bouton.addEventListener('click', testFormulaire);


function testFormulaire() {
    console.log (start.value + " " + end.value + " " + loc_fr.checked)
     // Nettoyage du cluster
     cluster.clearLayers();
     // Retrait du cluster sur la carte
     map.removeLayer(cluster);
     var url = wfsUrl + "&cql_filter=begin>='"+start.value+"' AND end<='"+end.value+"'";
     if (loc_fr.checked && !loc_et.checked){
        url = url + " AND country='France'";
     }
     else if (!loc_fr.checked && loc_et.checked){
        url = url + " AND NOT country='France'";
     }
     else if (!loc_fr.checked && !loc_et.checked){
        alert("Sélectionner une localisation")
     }
    requestPoints(url);
}


