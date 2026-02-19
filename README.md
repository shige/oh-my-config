# oh-my-config

macOS development environment configuration managed in one place.

## Setup

### Homebrew

```bash
bash homebrew/install.sh
```

### mise (Runtime Version Manager)

Manages runtime versions for Node.js, Python, Ruby, Bun, and Deno.

```bash
bash mise/install.sh
```

This will:

1. Create `~/.config/mise/` directory
2. Symlink `mise/config.toml` to `~/.config/mise/config.toml`
3. Trust the config file
4. Install all tool versions defined in `config.toml`