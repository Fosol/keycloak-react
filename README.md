# Keycloak Basic Web Application with API

This mono-repo provides a quick way to get a containerized web application solution started that includes the following components;

- Keycloak
- React
- .NET Core API
- MSSQL DB

## Components

Each component requires an appropriate `.env` file created at the following locations.
Each component README describes the configuration requirements.

| Component                               | Path                   | Description                                                   |
| --------------------------------------- | ---------------------- | ------------------------------------------------------------- |
| [Keycloak](/auth/keycloak/README.md)    | `/auth/keycloak/.env`  | Provides authentication and authorization with Oauth and OIDC |
| [Application](/auth/keycloak/README.md) | `/app/.env`            | React web application with typescript                         |
| [API](/auth/keycloak/README.md)         | `/api/src/.env`        | .NET Core 3.1 RESTful API                                     |
| [Database](/auth/keycloak/README.md)    | `/database/mssql/.env` | MSSQL 2019 linux based database                               |