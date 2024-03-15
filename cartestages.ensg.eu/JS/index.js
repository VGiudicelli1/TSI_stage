

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
let markers = [goldIcon, redIcon, blueIcon, greenIcon, blackIcon]


// fetch list des stages et géocodage des adresses
async function getStages() {
    const response = await fetch("http://localhost:3000/stages");
    const stages = await response.json();
    const locations = []
    for (const stage of stages) {
        locations.push(stage.entreprise_adresse + "," + stage.entreprise_ville+","+stage.entreprise_pays)
    }

    const geocodedLocations = await Promise.all(locations.map(async (location) => {
        return new Promise((resolve, reject) => {
            L.esri.Geocoding.geocode({apikey: 'esri leaflet token'}).text(location).run(function (err, results) {
                if (err) {
                    console.log(err);
                    reject(err);
                }
                resolve(results.results[0].latlng);
            });
        });
    }));
    stages.map((stage, index)=>{
        stage.location = geocodedLocations[index]
    })
    return stages
}
let stages = []
getStages().then(data => (stages = data));
console.log("liste des stages ", stages)
stages.map((stage => {
    let marker = new L.Marker([stage.location.lat, stage.location.lng]);
    marker.addTo(map)
}))

getStages().then(data => {
    stages = data;
    console.log("liste des stages ", stages);
    stages.map(stage => {
        // Use the color markers here
        let marker = new L.Marker([stage.location.lat, stage.location.lng], {icon: markers[Math.floor(Math.random()*5)]});
        marker.addTo(map);
    });
});