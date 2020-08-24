echo 'Enter a username for the keycloak database.'
read -p 'Username: ' varKeycloakDb

echo 'Enter a username for the keycloak realm administrator'
read -p 'Username: ' varKeycloak

echo 'Enter a username for the API database.'
read -p 'Username: ' varApiDb

# Generate a random password.
passvar=$(date +%s | sha256sum | base64 | head -c 32)

# Set environment variables.
if test -f "./auth/keycloak/.env"; then
    echo "./auth/keycloak/.env exists"
else
echo \
"PROXY_ADDRESS_FORWARDING=true
# DB_VENDOR=POSTGRES
# DB_ADDR=keycloak-db
# DB_DATABASE=keycloak
# DB_USER=$varKeycloakDb
# DB_PASSWORD=$passvar
KEYCLOAK_USER=$varKeycloak
KEYCLOAK_PASSWORD=$passvar
KEYCLOAK_IMPORT=/tmp/realm-export.json -Dkeycloak.profile.feature.scripts=enabled -Dkeycloak.profile.feature.upload_scripts=enabled
KEYCLOAK_LOGLEVEL=WARN
ROOT_LOGLEVEL=WARN" >> ./auth/keycloak/.env
fi

if test -f "./db/mssql/.env"; then
    echo "./db/mssql/.env exists"
else
echo \
"ACCEPT_EULA=Y
MSSQL_SA_PASSWORD=$passvar
MSSQL_PID=Developer
TZ=America/Los_Angeles
DB_NAME=pims
DB_USER=admin
DB_PASSWORD=$passvar
TIMEOUT_LENGTH=120" >> ./db/mssql/.env
fi

if test -f "./api/src/.env"; then
    echo "./api/src/.env exists"
else
echo \
"ASPNETCORE_ENVIRONMENT=Development
ASPNETCORE_URLS=http://*:8080
DB_PASSWORD=$passvar
Keycloak__Secret=
Keycloak__ServiceAccount__Secret=" >> ./api/src/.env
fi

if test -f "./app/.env"; then
    echo "./app/.env exists"
else
echo \
"NODE_ENV=development
API_URL=http://backend:8080/
CHOKIDAR_USEPOLLING=true" >> ./app/.env
fi
