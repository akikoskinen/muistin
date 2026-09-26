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

## Release and production

Production image can be built with:

```bash
podman build --target prod -t muistin:prod .
```

The production image needs some setup to run.

The database is stored in the `/app/data` directory within the container, so the contents of that directory should survive container restarts.
For example mount a directory from the host into the container.
The user within the container needs to have read and write permissions for that directory.

A secret value needs to be provided as a `SECRET_KEY_BASE` environment variable.
The value has some requirements, for example it needs to be long enough.
`mix phx.gen.secret` can be used to generate such a value.

Set the service's public hostname with a `PHX_HOST` environment variable.
This is used to generate absolute URLs to the service (for example in the emails the service might send) and some other purposes.
The value contains just the hostname, no protocol, no port.

The container running command could thus look something like this:

```bash
podman run -d --name muistin-prod     \
    -p 4000:4000                      \
    -v $(pwd)/data:/app/data          \
    -e SECRET_KEY_BASE=your_secret    \
    -e PHX_HOST=mymuistin.example     \
    muistin:prod
```
