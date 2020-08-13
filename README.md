# Speak

A Garry's Mod chatbox addon 💬.

- [Requirements](#requirements)
- [Development](#development)
  - [Ports](#ports)
- [Scripts](#scripts)

## Requirements

- [Docker Engine](https://docs.docker.com/install/) 17.12+
- [Docker Compose](https://docs.docker.com/compose/install/) 1.21+

## Development

First, make sure dependencies are up-to-date:

```bash
./scripts/update
```

Then, launch the Source Dedicated Server (SRCDS) instance:

```bash
./scripts/server
```

### Ports

| Service                         | Port                                       |
|---------------------------------|--------------------------------------------|
| Source Dedicated Server (SRCDS) | [`27015`](steam://connect/localhost:27015) |

## Scripts

| Name      | Description                                                              |
|-----------|--------------------------------------------------------------------------|
| `cibuild` | Build addon for distribution.                                            |
| `console` | Attach to the SRCDS console. Detach with <kbd>ctrl</kbd> + <kbd>d</kbd>. |
| `server`  | Start SRCDS.                                                             |
| `test`    | Run tests.                                                               |
| `update`  | Update dependencies and static asset bundle.                             |
