# Muistin

## Development

To start the development server:

* Run `podman-compose up`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

The application runs only within a container, so all `mix` etc. commands should be run within the container.
For example to run precommit tasks, it's something like:

```bash
podman-compose exec -e MIX_ENV=test app mix precommit
```

### Localization

precommit checks if localization template files (.pot) are out-of-sync.

To update all the localization files:

```bash
mix gettext.extract --merge
```

That runs both `mix gettext.extract` and `mix gettext.merge`.
They can also be run separtely to get more control over what happens.
