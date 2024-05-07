# Rails 7 Docker Bootstrap

An opinionated, convention over configuration way to start a new Rails 7.1+ app locally. Zero opinions on deployment.

Defaults:

- Rails 7.1
- Postgres
- esbuild
- Tailwind

Requirements:

- [OrbStack](https://orbstack.dev/) (highly recommended, free for personal use) or [Docker Desktop](https://www.docker.com/products/docker-desktop/)

## Usage

- Create your project directory and navigate to it (`mkdir your_app_name && cd your_app_name`)
- `git clone git@github.com:joshellington/rails-docker-bootstrap.git .` (same directory)
- `./bootstrap.sh --name your_app_name`

If you'd like to override any of the pre-configured `rails new` defaults, modify Step 2 in `bootstrap.sh` before running.

If you'd like to add additional arguments to `rails new`, pass them in like so (note the `--` separator):

`./bootstrap.sh --name your_app_name -- --skip-system-tests --skip-action-mailer`

---

Once you're bootstrapped, fire up: `docker compose up`

If you modify your dependencies (Gemfile, package.json), make sure to run: `docker compose up --build`

## ruby-lsp support

### Visual Studio Code

- Install `Shopify.ruby-lsp` extension
- Using your terminal with `ruby` available: `cd .ruby-lsp-gems && bundle install`
- Restart `Ruby LSP` server (CMD + SHIFT + P, Ruby LSP: Restart)

By default, `ruby-lsp` is setup to use `rubocop` default linting rules and formatter.

## OrbStack DNS support

If you're using OrbStack and want to use their automatic DNS/SSL, make sure to update your `config.hosts`. Couple ways to accomplish:

- Update `docker-compose.development.yml` environment variable `RAILS_DEVELOPMENT_HOSTS` to include your app host name (likely `web.APP_NAME.orb.local`)
- Add `config.hosts.clear` to `config/environments/development.rb`
