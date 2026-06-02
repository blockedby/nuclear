<p align="center">
  <picture>
    <source alt="Nuclear Music Player"  srcset="packages/docs/.gitbook/assets/readme-banner.png">
    <img alt="Nuclear Music Player"  srcset="packages/docs/.gitbook/assets/readme-banner.png">
  </picture>


</p>

<div align="center">

# Nuclear 

</div>

<div align="center">

  Nuclear is a free, open-source music player without ads or tracking. Search for any song or artist, build playlists, and start listening.<br>
  Runs on Windows, macOS, and Linux.
  
</div>


## Arch Nuclear fork

This repository is `blockedby/arch-nuclear`, a maintained Arch/Wayland-focused fork of Nuclear Music Player. The fork keeps Nuclear's app name, icons, plugin model, and user-facing product identity mostly intact, but carries packaging and desktop-integration work that is useful for Arch Linux users.

What is different from upstream Nuclear:

- Arch-first packaging is published from this repository as the fork-specific `arch-nuclear-bin` package.
- The Arch package installs the executable as `/usr/bin/nuclear-music-player-arch` so it can coexist with upstream-style Nuclear binaries.
- The packaged desktop launcher uses that renamed executable while keeping the existing app metadata/icon identity sane.
- Wayland tray and app-id fixes are maintained here for Arch/KDE/GNOME users; larger integrations such as MPRIS2/KDE Connect are tracked separately before implementation.
- Release artifacts are distributed from GitHub Releases in this repository only. This fork does not publish to upstream package feeds.

Upstream policy: this fork follows upstream Nuclear where practical, but fork-specific code and packaging changes are not sent as upstream PRs or code contributions unless that policy is explicitly revisited.

## Screenshots

<p align="center">
  <img src="packages/docs/.gitbook/assets/dashboard-main.png" alt="Nuclear Music Player - Dashboard" width="100%">
</p>

Nuclear comes with multiple built-in themes:

<p align="center">
  <img src="packages/docs/.gitbook/assets/dashboard-green.png" alt="Green theme" width="32%">
  <img src="packages/docs/.gitbook/assets/dashboard-aqua.png" alt="Aqua theme" width="32%">
  <img src="packages/docs/.gitbook/assets/dashboard-mint.png" alt="Mint theme" width="32%">
</p>
<p align="center">
  <img src="packages/docs/.gitbook/assets/dashboard-orange.png" alt="Orange theme" width="32%">
  <img src="packages/docs/.gitbook/assets/dashboard-red.png" alt="Red theme" width="32%">
  <img src="packages/docs/.gitbook/assets/dashboard-violet.png" alt="Violet theme" width="32%">
</p>

| | |
|:---:|:---:|
| ![Search artists](packages/docs/.gitbook/assets/search-artists.png) | ![Search albums](packages/docs/.gitbook/assets/search-albums.png) |
| Artist search | Album search |
| ![Playlists](packages/docs/.gitbook/assets/playlists.png) | ![Plugin store](packages/docs/.gitbook/assets/plugin-store.png) |
| Playlists | Plugin store |
| ![Installed plugins](packages/docs/.gitbook/assets/installed-plugins.png) | ![Preferences](packages/docs/.gitbook/assets/preferences.png) |
| Installed plugins | Preferences |
| ![What's new](packages/docs/.gitbook/assets/whats-new.png) | ![Log viewer](packages/docs/.gitbook/assets/log-viewer.png) |
| What's new | Log viewer |

## Download

Grab Arch Nuclear fork artifacts from the [blockedby/arch-nuclear Releases page](https://github.com/blockedby/arch-nuclear/releases). Upstream Nuclear releases remain available from `nukeop/nuclear`, but this fork publishes its own GitHub Releases-only Arch artifacts.

| Platform | Formats |
|----------|---------|
| Windows | `.exe` installer, `.msi` |
| macOS | `.dmg` (Apple Silicon and Intel) |
| Linux | Arch package `arch-nuclear-bin-*.pkg.tar.zst`, plain binary `nuclear-music-player-arch`; upstream formats may still be built separately |

## Features

- Search for music and stream it from any source
- Browse artist pages with biographies, discographies, and similar artists
- Browse album pages with track listings
- Queue management with shuffle, repeat, and drag-and-drop reordering
- Favorites (albums, artists, and tracks)
- Playlists (create, import, export, import from varous services)
- Powerful plugin system with a built-in plugin store
- Themes (built-in and custom CSS themes)
- MCP server lets your AI agent drive the player
- Auto-updates
- Keyboard shortcuts
- Localized in multiple languages

## Plugins

Nuclear has a powerful plugin system now! Every functionality has been redesigned to be driven by plugins.

Plugins can provide streaming sources, metadata, playlists, dashboard content, and more. Browse and install plugins from the built-in plugin store, or write your own using the [@nuclearplayer/plugin-sdk](https://www.npmjs.com/package/@nuclearplayer/plugin-sdk).

## MCP

You can enable the MCP server in Settings → Integrations.

Then to add it to **Claude Code:**

```bash
claude mcp add nuclear --transport http http://127.0.0.1:8800/mcp
```

**Codex CLI:**

```bash
codex mcp add nuclear --url http://127.0.0.1:8800/mcp
```

**OpenCode:**

```json
{
  "mcp": {
    "nuclear": {
      "type": "remote",
      "url": "http://127.0.0.1:8800/mcp"
    }
  }
}
```

**Claude Desktop / Cursor / Windsurf:**

```json
{
  "mcpServers": {
    "nuclear": {
      "url": "http://127.0.0.1:8800/mcp"
    }
  }
}
```

The MCP is designed to be discoverable, but there's a skill you can load to get your AI up to speed: [Nuclear MCP Skill](./packages/docs/public/skills/nuclear-mcp.zip)

## Development

Nuclear is a pnpm monorepo managed with Turborepo. The main app is built with Tauri (Rust + React).

### Prerequisites

- Node.js >= 22
- pnpm >= 9
- Rust (stable)
- Platform-specific Tauri dependencies ([see Tauri docs](https://v2.tauri.app/start/prerequisites/))

### Getting started

```bash
git clone https://github.com/blockedby/arch-nuclear.git
cd arch-nuclear
pnpm install
pnpm dev
```


### Pull request workflow

Create repository PRs as drafts by default so CI does not run for every small work-in-progress push:

```bash
gh pr create --repo blockedby/arch-nuclear --base master --head <branch> --draft --title "<title>" --body "<summary>"
```

When the branch is ready for review and CI, mark it ready:

```bash
gh pr ready --repo blockedby/arch-nuclear <pr-number-or-url>
```

The CI and Coverage workflows skip draft PR jobs and run for non-draft PRs, including when a draft is marked ready for review. Pushes to `master`, release/tag workflows, and manual workflow dispatches remain available. Ready PRs still run on synchronized branch pushes; keep a PR in draft while iterating if you want to avoid CI on every small push.

### Useful commands

```bash
pnpm dev            # Run the player in dev mode
pnpm dev:remote     # Same, but binds Vite to 0.0.0.0 so you can open the remote control UI from other devices on your LAN
pnpm build          # Build all packages
pnpm test           # Run all tests
pnpm lint           # Lint all packages
pnpm type-check     # TypeScript checks
pnpm storybook      # Run Storybook
```

## Community

- [Discord](https://discord.gg/JqPjKxE)
- [Mastodon](https://fosstodon.org/@nuclearplayer)
- [Discussions](https://github.com/nukeop/nuclear/discussions)

## License

AGPL-3.0. See [LICENSE](LICENSE).
