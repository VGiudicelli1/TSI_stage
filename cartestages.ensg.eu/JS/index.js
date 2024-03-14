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
    center: [47.5603325724831, -2.877608907719759],
    zoom: 9,
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
