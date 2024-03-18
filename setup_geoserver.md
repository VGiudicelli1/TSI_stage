### Initialisation Geoserver

 - Toutes les actions décrites dans ce document sont des requêtes envoyées à l'API REST du Geoserver, passées par la commande curl de debian.
Lors du démarrage du conteneur, on veut connecter ce dernier à la BDD. 
Pour cela il faut d'abord créer un espace de travail: 
```bash
curl -v -u admin:geoserver -XPOST -d "<workspace><name>stages</name></workspace>" -H "Content-type: text/xml"  http://localhost:8080/geoserver/rest/workspaces
```

On crée ensuite un entrepôt, en donnant les informations de connexion à la BDD Postgres:
```bash
curl -v -u admin:geoserver -XPOST -d "<dataStore><name>postgres</name><connectionParameters><host>postgres</host><port>5432</port><database>postgres</database><user>postgres</user><passwd>tsi23lesboss</passwd><dbtype>postgis</dbtype></connectionParameters></dataStore>" -H "Content-type: text/xml" http://localhost:8080/geoserver/rest/workspaces/stages/datastores
```

On publie en tant que couche la vue *view_internship* :
```bash
curl -v -u admin:geoserver -XPOST -H "Content-type: text/xml" -d "<featureType><name>view_internship</name></featureType>" http://localhost:8080/geoserver/rest/workspaces/stages/datastores/postgres/featuretypes
```

Enfin on autorise tous les rôles en lecture de la couche:
```bash
curl -v -u admin:geoserver -XPOST -H "Content-type: text/xml" -d "<rules><rule><@resource>stages.view_internship.r</@resource><text>*</text></rule></rules>" http://localhost:8080/geoserver/rest/security/acl/layers
```
