# Contributing

## Libraries

This repository does not include libraries under `Libs/`.  
Release builds fetch pinned copies from `.pkgmeta` `externals` when packaging for addon platforms.

For local development:

1. Create `Libs/` at the addon root if it does not exist.
2. Open `.pkgmeta` and install each path listed under `externals` into the `Libs/` folder.
3. You can also install the libraries as standalone addons and/or symlink them into the `Libs/` folder.

Tip: You can fetch all externals at once by running the [BigWigs packager](https://github.com/BigWigsMods/packager) locally against this checkout.

When updating library versions, bump the `tag` or `commit` on the matching `externals` entry in `.pkgmeta`.

## Code

- Lua 5.1 — follow `.editorconfig` and `.luarc.json`
- Open issues and pull requests on GitHub
