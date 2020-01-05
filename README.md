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

First, rebuild the static asset bundle:

```bash
./scripts/cibuild
```

Then, launch the Source Dedicated Server (srcds) instance:

```bash
./scripts/server
```

### Ports

| Service                         | Port                                       |
|---------------------------------|--------------------------------------------|
| Source Dedicated Server (srcds) | [`27015`](steam://connect/localhost:27015) |

## Scripts

| Name      | Description                           |
|-----------|---------------------------------------|
| `server`  | Start Source Dedicated Server (srcds) |
| `test`    | Run tests                             |
| `cibuild` | Build addon for distribution          |