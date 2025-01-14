# bunnyhop.nvim
Hop across your code at lightning speed ⚡️⚡️⚡️

> [!Note]
> This plugin is in alpha version, expect bugs, lacking features and documentation.
> If you found a bug, reporting it would be appriciated, while fixing it via a pull request would be greatly appriciated.

## Features

#### Predicts your next desired cursor position a preview window, allowing you to hop to it via your chosen keybinding.

![bunnyhop_feature_1](https://github.com/user-attachments/assets/9d9be27e-c8b7-4d02-9c64-4ba7a860f922)

## Installation

### Prerequisites

The only provider supported currently is Hugging Face's [Serverless](https://huggingface.co/docs/api-inference/en/index).
Hence, Hugging Face's API key is required. Learn how to set it up [here](https://huggingface.co/docs/api-inference/en/getting-started).
Once you have you're API key, create an enviornment variable for the key, eg. `export HF_API_KEY=************`

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "PLAZMAMA/bunnyhop.nvim",
    lazy = false, -- This plugin does not support lazy loading for now
    -- Setting the keybinding for hopping to the predicted location.
    -- Change it to whatever suits you.
    keys = {
        {
            "<C-h>",
            function()
                require("bunnyhop").hop()
            end,
            desc = "[H]op to predicted location.",
        },
    },
    -- The only options currently required is the api_key.
    -- Set it to the enviornment variable name of your hugging face API key.
    opts = { api_key = "HF_API_KEY" },
},
```

## Configuration

Bunnyhop is configured via the setup() function. The default configuration values can be found [here](lua/bunnyhop/init.lua).

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
luarocks test spec/path_to_file.lua --local
# or
busted spec/path_to_file.lua
```

## Common Errors with Local Testing

> [!Note]
> For The local testing to work you need to have Lua 5.1 set as your default version for luarocks.
> If that's not the case you can pass `--lua-version 5.1` to all the luarocks commands above.

1. If you see an error like `module 'busted.runner' not found` run the following command:

This sets the correct luarocks path.
```bash
eval $(luarocks path --no-bin)
```

[rockspec-format]: https://github.com/luarocks/luarocks/wiki/Rockspec-format
[luarocks]: https://luarocks.org
[luarocks-api-key]: https://luarocks.org/settings/api-keys
[gh-actions-secrets]: https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository
[busted]: https://lunarmodules.github.io/busted/
[nlua]: https://github.com/mfussenegger/nlua
[use-this-template]: https://github.com/new?template_name=nvim-lua-plugin-template&template_owner=nvim-lua
