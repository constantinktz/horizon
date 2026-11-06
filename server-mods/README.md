# Server mods

The mods the Coolify server (`docker-compose.yml`, `packaging/coolify/`) is built with. Commit a mod here and push:
Coolify rebuilds the image with it and restarts the server.

```
server-mods/
  native/<mod>/horizon-mixin.toml     native Rust mods (docs/native-mods.md): compiled into the server's game
  content/<mod>/horizon-mod.toml      content mods from source (docs/mods.md): built into an .hmod
  content/<name>.hmod                 content mods already built
```

- **Native mods** are horizon-mixins bundles: Rust that hooks into the game's own functions (server tick,
  commands, block breaking, players...). Start one with `cargo horizon-mod new <path> --template native` or from
  [horizon-native-mod-template](https://github.com/horizon-rust/horizon-native-mod-template). They run unsandboxed
  on the server: only add code you have read. Bundles with their own `[api]` trait crate need the launcher's
  build (`horizon-launcher native-build --server-output`); this image applies plain bundles with
  `horizon-mixins apply` only. Post-build steps are not run.
- **Content mods** (blocks, items, recipes, loot...) are copied to `/data/horizon-mods/` and turned on at every
  start. A mod with `side = "both"` must be installed in the same version on every player's Horizon too, or the
  server refuses the join and names the mod.

Players join with the Horizon client (Multiplayer > the server's address). Native server-side mods need nothing
on the players' side.
