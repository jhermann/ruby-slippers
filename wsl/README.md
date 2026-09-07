# Win11 and WSL2 Information and Config <!-- omit from toc -->

**Contents**

- [VS Code Customization](#vs-code-customization)
- [Windows / Linux Interoperability](#windows--linux-interoperability)
- [Windows Terminal Custom Keybindings](#windows-terminal-custom-keybindings)

## VS Code Customization

See the [vs-code-config](./vs-code-config.md) document for details on VS Code customization.

## Windows / Linux Interoperability

This ensures you can call native Windows binaries (like `explorer.exe`) directly in a WSL shell.

```sh
sudo apt install binfmt-support
echo ":WSLInterop:M::MZ::/init:PF" | sudo tee /usr/lib/binfmt.d/WSLInterop.conf
```

It might also require `/etc/wsl.conf` additions:

```
[interop]
enabled = true
appendWindowsPath = true
```

## Windows Terminal Custom Keybindings

Add them to the config (`Ctrl+,`).

```json
    "keybindings":
    [
        {
            "id": "Terminal.CopyToClipboard",
            "keys": "ctrl+c"
        },
        {
            "id": null,
            "keys": "ctrl+tab"
        },
        {
            "id": null,
            "keys": "ctrl+shift+tab"
        },
        {
            "id": "Terminal.FindText",
            "keys": "ctrl+shift+f"
        },
        {
            "id": "Terminal.PasteFromClipboard",
            "keys": "ctrl+v"
        },
        {
            "id": "Terminal.DuplicatePaneAuto",
            "keys": "alt+shift+d"
        },
        {
            "id": "Terminal.NextTab",
            "keys": "ctrl+pgdn"
        },
        {
            "id": "Terminal.PrevTab",
            "keys": "ctrl+pgup"
        }
    ],
```
