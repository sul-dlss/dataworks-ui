# DataWorks UI

[![CI status](https://github.com/sul-dlss/dataworks-ui/actions/workflows/ruby.yml/badge.svg)](https://github.com/sul-dlss/dataworks-ui/actions/workflows/ruby.yml)

Discovery application for **DataWorks**, Stanford University Libraries' catalog of research datasets. It is a [Blacklight](https://github.com/projectblacklight/blacklight) application that provides search and browse of dataset metadata indexed into [Apache Solr](https://solr.apache.org/).

DataWorks UI is the front-end half of the DataWorks system. Dataset metadata is harvested from providers (Redivis, OpenAlex, and others), normalized, and indexed by the companion ETL pipeline in [sul-dlss/dataworks-etl](https://github.com/sul-dlss/dataworks-etl). This repository is responsible only for the search and display of the resulting Solr index.

## Requirements

- Ruby (see the version in the CI matrix in
  [`.github/workflows/ruby.yml`](.github/workflows/ruby.yml))
- A JavaScript runtime
- [Apache Solr](https://solr.apache.org/), run locally via
  [solr_wrapper](https://github.com/cbeer/solr_wrapper) or Docker (see below)
- PostgreSQL (production only; local development uses SQLite by default)

Assets are served with [Propshaft](https://github.com/rails/propshaft) and JavaScript is managed with [importmap-rails](https://github.com/rails/importmap-rails), so there is no separate asset build step.

## Local development

### 1. Clone the repository

```sh
git clone git@github.com:sul-dlss/dataworks-ui.git
cd dataworks-ui
```

### 2. Install dependencies and prepare the database

```sh
bin/setup --skip-server
```

This installs gems and runs the database migrations. (see [Running the application](#5-running-the-application) below.)

### 3. Start Solr

Choose one of the following.

**With solr_wrapper**:  starts a self-contained Solr using the config in [`solr/conf`](solr/conf) and [`.solr_wrapper.yml`](.solr_wrapper.yml):

```sh
solr_wrapper
```

**With Docker**: defined in [`docker-compose.yml`](docker-compose.yml):

```sh
docker compose up solr
```

Both options serve Solr at `http://127.0.0.1:8983/solr/blacklight-core`, which is the default the app expects. Override it with the `SOLR_URL` environment variable or by editing [`config/blacklight.yml`](config/blacklight.yml).

### 4. Load some data

The app has nothing to display until the Solr index is populated. To index the test fixtures in [`spec/fixtures/solr_documents`](spec/fixtures/solr_documents):

```sh
bin/rake dataworks_ui:index:seed
```

For a full, production-like index, run the ETL pipeline in [dataworks-etl](https://github.com/sul-dlss/dataworks-etl).

### 5. Running the application

```sh
bin/rails server
```

Then visit <http://localhost:3000>

## Configuration

Application configuration is managed with the [config](https://github.com/rubyconfig/config) gem. Defaults live in [`config/settings.yml`](config/settings.yml) and are overridden per environment in [`config/settings/`](config/settings).

In deployed environments, these settings are supplied as environment variables set via Puppet, which override the checked-in defaults using the config gem's [environment variable conventions](https://github.com/rubyconfig/config#environment-variables) (e.g. `SETTINGS__SOURCES__REDIVIS__ACCESS_TOKEN`).

## Testing

Run RuboCop and the full RSpec suite (this starts Solr, seeds the fixtures, and runs the specs):

```sh
bin/rake ci
```

You can also run the pieces individually:

```sh
bin/rubocop        # linting
bin/rspec          # specs (requires a running, seeded Solr)
```

## Solr configuration

The Solr schema and config used by both solr_wrapper and Docker live in [`solr/conf`](solr/conf). The fields the application searches, facets, and displays are declared in [`app/controllers/catalog_controller.rb`](app/controllers/catalog_controller.rb).

## Monitoring

Health checks are provided by [okcomputer](https://github.com/sportngin/okcomputer):

- `/status` — basic "up" check
- `/status/all` — all checks, including database and a Solr ping
- `/status/<check>` — a single named check (e.g. `/status/solr`)

Errors are reported to [Honeybadger](https://www.honeybadger.io/).

## Deployment

Deployment is handled with [Capistrano](https://capistranorb.com/). Deploy to a stage with:

```sh
cap stage deploy
```

Available stages are defined in [`config/deploy/`](config/deploy) (`dev`, `stage`, `prod`, `test`). Deploys require VPN access. See the [DevOpsDocs](https://github.com/sul-dlss/DevOpsDocs) for infrastructure details.

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE).
