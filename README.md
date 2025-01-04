# bunnyhop.nvim
Bunny hop across your code at lightning speed ⚡️⚡️⚡️


## Development

### Run tests


Running tests requires either

- [luarocks][luarocks]
- or [busted][busted] and [nlua][nlua]

to be installed[^1].

[^1]: The test suite assumes that `nlua` has been installed
      using luarocks into `~/.luarocks/bin/`.

You can then run:

```bash
luarocks test --local
# or
busted
```

Or if you want to run a single test file:

```bash
luarocks test tests/path_to_file.lua --local
# or
busted tests/path_to_file.lua
```

If you see an error like `module 'busted.runner' not found`:

```bash
eval $(luarocks path --no-bin)
```

For this to work you need to have Lua 5.1 set as your default version for
luarocks. If that's not the case you can pass `--lua-version 5.1` to all the
luarocks commands above.

[rockspec-format](https://github.com/luarocks/luarocks/wiki/Rockspec-format)
[luarocks]: https://luarocks.org
[luarocks-api-key](https://luarocks.org/settings/api-keys)
[gh-actions-secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository)
[busted]: https://lunarmodules.github.io/busted/
[nlua]: https://github.com/mfussenegger/nlua
[use-this-template](https://github.com/new?template_name=nvim-lua-plugin-template&template_owner=nvim-lua)
