// Fonction pour récupérer les paramètres de l'URL
function getQueryVariable(variable) {
  const query = new URLSearchParams(window.location.search);
  return query.get(variable);
}

// Récupération des informations du stage à partir des paramètres de l'URL
const title = getQueryVariable("title");
const begin = getQueryVariable("begin");
const end = getQueryVariable("end");
const organization_contact = getQueryVariable("organization_contact");
const gratification = getQueryVariable("gratification");
const rapport_url = getQueryVariable("rapport_url");
const diapo_url = getQueryVariable("diapo_url");
const organization_name = getQueryVariable("organization_name");
const adress = getQueryVariable("adress");
const city = getQueryVariable("city");
const country = getQueryVariable("country");
const student = getQueryVariable("student");

// Utilisation des données récupérées pour afficher les détails du stage dans votre page
document.getElementById("title").innerText = title;
document.getElementById("begin").innerText = formatDate(begin);
document.getElementById("end").innerText = formatDate(end);
document.getElementById("organization_contact").innerText =
  organization_contact;
document.getElementById("gratification").innerText = gratification;
document.getElementById("rapport_url").innerText = rapport_url;
document.getElementById("diapo_url").innerText = diapo_url;
document.getElementById("organization_name").innerText = organization_name;
document.getElementById("adress").innerText = adress;
document.getElementById("city").innerText = city;
document.getElementById("country").innerText = country;
document.getElementById("student").innerText = student;

// Fonction pour formater les dates
function formatDate(dateString) {
  const options = { year: "numeric", month: "long", day: "numeric" };
  const date = new Date(dateString);
  return date.toLocaleDateString("fr-FR", options);
}
