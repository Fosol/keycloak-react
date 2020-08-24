# Keycloak

Keycloak provides the authentication and claim based authorization services for PIMS.
It provides an OpenIdConnect architecture to allow for IDIR, BCeID, GitHub and private email accounts to authenticate and login to PIMS.

For local development it only currently supports private email accounts to authenticate.
You can extend this by modifying the Keycloak Realm and Client configuration.

## Host Name Configuration

When running the solution with **localhost** it is important to create a _host_ name in your _hosts_ file so that Keycloak will validate the JWT token against the correct issuers.

Add the following host to your _hosts_ file.

> `127.0.0.1 keycloak`

This will then allow your Keycloak configuration files in the _frontend_:app and _backend_:api to references `http://keycloak:8080` instead of `http://localhost:8080`.
Which will allow your docker containers to use a valid JWT token that can be proxied from the APP to the API to Keycloak.

---

### Chrome Cookie Issue and Workaround

Chrome is now pushing an update that invalidates cookies without the `SameSite` value. This will result in a rejection of the cookie and make it impossible to remain logged in.

To workaround this issue temporarily you can change the Chrome behaviour by **Disabling** the **SameSite by default cookies** setting here - `chrome://flags/#same-site-by-default-cookies`

> We will need to find a way to update Keycloak to include the property in the cookie in the near future.

---

## Docker Setup

To run Keycloak in a Docker container you will need to create two `.env` files, one in the `/auth/keycloak` folder, and the other in the `/auth/postgres` folder.

This will allow Keycloak to initialize with a new PostgreSQL database.

### Keycloak Environment Variables

> The default import during initialization no longer works. Start the keycloak container and manually import - [details here](./keycloak/README.md#Import%20Realm).

```conf
  # Keycloak configuration
  PROXY_ADDRESS_FORWARDING=true
  KEYCLOAK_USER={username}
  KEYCLOAK_PASSWORD={password}
  # KEYCLOAK_IMPORT=/tmp/realm-export.json -Dkeycloak.profile.feature.scripts=enabled -Dkeycloak.profile.feature.upload_scripts=enabled
  KEYCLOAK_LOGLEVEL=WARN
  ROOT_LOGLEVEL=WARN
```

| Key                      | Value                                                                   | Description                                                                                                                    |
| ------------------------ | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| PROXY_ADDRESS_FORWARDING | [true\|false]                                                           | Informs Keycloak to handle proxy forwarded requests correctly.                                                                 |
| KEYCLOAK_USER            | {keycloak}                                                              | The name of the Keycloak Realm administrator.                                                                                  |
| KEYCLOAK_PASSWORD        | {password}                                                              | The password for the Keycloak Realm administrator.                                                                             |
| KEYCLOAK_IMPORT          | /tmp/real-export.json -Dkeycloak.profile.feature.upload_scripts=enabled | The path to the configuration file to initialize Keycloak with. This also includes an override to enable uploading the script. |
| KEYCLOAK_LOGLEVEL        | [WARN\|ERROR\|INFO]                                                     | The logging level for Keycloak.                                                                                                |
| ROOT_LOGLEVEL            | [WARN\|ERROR\|INFO]                                                     | The logging level for the root user of the container.                                                                          |

### Database Configuration

By default Keycloak will run a local database and the following is not required.  
If you would like to have a separate container hosting the database you can include the following;

```conf
  DB_VENDOR=POSTGRES
  DB_ADDR=keycloak-db
  DB_DATABASE=keycloak
  DB_USER={username}
  DB_PASSWORD={password}
```

| Key         | Value           | Description                                                         |
| ----------- | --------------- | ------------------------------------------------------------------- |
| DB_VENDOR   | [POSTGRES\|...] | The database that Keycloak will use.                                |
| DB_ADDR     | {keycloak-db}   | The host name of the Keycloak DB found in the `docker-compose.yaml` |
| DB_DATABASE | {keycloak}      | Name of the Keycloak database.                                      |
| DB_USER     | {keycloak}      | The name of the default database user administrator.                |
| DB_PASSWORD | {password}      | The password for the default database user administrator.           |

## Database Setup

When using a separate container to host the Keycloak database you will need to include the following `/.env` file.

### Keycloak Database Environment Variables

```conf
  POSTGRESQL_DATABASE=keycloak
  POSTGRESQL_USER={username}
  POSTGRESQL_PASSWORD={password}
```

| Key                 | Value      | Description                                                                                             |
| ------------------- | ---------- | ------------------------------------------------------------------------------------------------------- |
| POSTGRESQL_DATABASE | {keycloak} | The name of Keycloak database. Must be the same as the above **DB_DATABASE**                            |
| POSTGRESQL_USER     | {keycloak} | The name of the default database user administrator. Must be the same as the above **DB_USER**          |
| POSTGRESQL_PASSWORD | {password} | The password for the default database user administrator. Must be the same as the above **DB_PASSWORD** |

## Keycloak Administration

http://localhost:8080

## Keycloak Account Administration

http://localhost:8080/auth/realms/{realm}/account

## Export Realm Configuration

After configuring Keycloak you can export the configuration to a JSON file so that it can be used to initialize a new Keycloak instance. If you use the UI to export it will not contain all the necessary information and settings, thus the need for this CLI option.

More information [here](https://www.keycloak.org/docs/latest/server_admin/index.html#_export_import).

Once the keycloak container is running, ssh into it and execute the following commands;

```bash
docker exec -it keycloak bash
```

Once inside the container export the realm configuration.

```bash
/opt/jboss/keycloak/bin/standalone.sh \
  -Dkeycloak.migration.action=export \
  -Dkeycloak.migration.provider=singleFile \
  -Dkeycloak.migration.realmName=default \
  -Dkeycloak.migration.file=/tmp/realm-export.json \
  -Dkeycloak.migration.usersExportStrategy=REALM_FILE \
  -Dkeycloak.migration.strategy=OVERWRITE_EXISTING \
  -Djboss.http.port=8888 \
  -Djboss.https.port=9999 \
  -Djboss.management.http.port=7777
```

## Import Realm Configuration

There are two primary ways to import a realm configuration;

- Updating the `.env` configuration
- SSH into the keycloak container and run the command below

More information [here](https://www.keycloak.org/docs/latest/server_admin/index.html#_export_import).

### With Environment Variable Configuration

Using this method will import the realm configuration when the container is first started.

Update your `.env` file with the following;

```conf
    KEYCLOAK_IMPORT=/tmp/realm-export.json -Dkeycloak.profile.feature.scripts=enabled -Dkeycloak.profile.feature.upload_scripts=enabled
```

### With SSH Command

Once the keycloak container is running, ssh into it and execute the following commands;

```bash
docker exec -it keycloak bash
```

Once inside the container export the realm configuration.

```bash
opt/jboss/keycloak/bin/standalone.sh \
  -Djboss.socket.binding.port-offset=100 \
  -Dkeycloak.migration.action=import \
  -Dkeycloak.profile.feature.scripts=enabled \
  -Dkeycloak.profile.feature.upload_scripts=enabled \
  -Dkeycloak.migration.provider=singleFile \
  -Dkeycloak.migration.file=/tmp/realm-export.json
```

## Default User Accounts

When using the default realm configuration the following user accounts are created for you.

| Site                                                          | Username      | Password   | Description                                                                                |
| ------------------------------------------------------------- | ------------- | ---------- | ------------------------------------------------------------------------------------------ |
| [keycloak](http://localhost:8080)                             | {username}    | {password} | The configuration you entered in your `.env` `KEYCLOAK_USER, KEYCLOAK_PASSWORD` variables. |
| [account](http://localhost:8080/admin/realms/default/account) | administrator | password   | A user that belongs to the `Administrator` group.                                          |
| [account](http://localhost:8080/auth/realms/default/account)  | administrator | password   | A user that belongs to the `Administrator` group.                                          |
| [account](http://localhost:8080/auth/realms/default/account)  | user-01       | password   |                                                                                            |
| [account](http://localhost:8080/auth/realms/default/account)  | user-02       | password   |                                                                                            |
