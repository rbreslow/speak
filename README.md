# Speak 💬 [![CI](https://github.com/rbreslow/speak/workflows/CI/badge.svg?branch=develop)](https://github.com/rbreslow/speak/actions?query=workflow%3ACI)

Speak is a drop-in replacement for the default chatbox in Garry's Mod, written in JavaScript and Lua.

![image](https://user-images.githubusercontent.com/1774125/119199893-e44c6680-ba59-11eb-8508-50b67432bda3.png)

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
