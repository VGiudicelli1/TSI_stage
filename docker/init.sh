curl -v -u admin:geoserver -XPOST -d "<workspace><name>stages</name></workspace>" -H "Content-type: text/xml"  http://localhost:8080/geoserver/rest/workspaces
curl -v -u admin:geoserver -XPOST -d "<dataStore><name>postgres</name><connectionParameters><host>postgres</host><port>5432</port><database>postgres</database><user>postgres</user><passwd>tsi23lesboss</passwd><dbtype>postgis</dbtype></connectionParameters></dataStore>" -H "Content-type: text/xml" http://localhost:8080/geoserver/rest/workspaces/stages/datastores
curl -v -u admin:geoserver -XPOST -H "Content-type: text/xml" -d "<featureType><name>view_internship</name></featureType>" http://localhost:8080/geoserver/rest/workspaces/stages/datastores/postgres/featuretypes
curl -v -u admin:geoserver -XPOST -H  "accept: application/json" -H  "content-type: application/xml" -d "<rules><rule resource=\"stages.view_internship.r\">*</rule></rules>" http://localhost:8080/geoserver/rest/security/acl/layers
