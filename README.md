<div align="center">

# asdf-opentofu [![Build](https://github.com/virtualroot/asdf-opentofu/actions/workflows/build.yml/badge.svg)](https://github.com/virtualroot/asdf-opentofu/actions/workflows/build.yml) [![Lint](https://github.com/virtualroot/asdf-opentofu/actions/workflows/lint.yml/badge.svg)](https://github.com/virtualroot/asdf-opentofu/actions/workflows/lint.yml)

Official [opentofu](https://opentofu.org/) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `unzip`
  - `cosign`: (optional) If installed, asdf will perform signature verification

# Install

Plugin:

```shell
asdf plugin add opentofu
# or
asdf plugin add opentofu https://github.com/virtualroot/asdf-opentofu.git
```

OpenTofu:

```shell
# Show all installable versions
asdf list-all opentofu

# Install a specific version
asdf install opentofu latest

# Set a version globally (on your ~/.tool-versions file)
asdf global opentofu latest

# Now OpenTofu commands are available
tofu version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Environment Variable Options

* `ASDF_OPENTOFU_SKIP_VERIFY`: skip verifying checksums and signatures (default: `false`)
* `ASDF_OPENTOFU_VERSION_FILE`: Which .tofu-file to examine for version constraints when using the `legacy_version_file` option in `~/.asdfrc`. (default: `main.tofu`)

# Contributing

Contributions of any kind are welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/virtualroot/asdf-opentofu/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Alejandro Lazaro](https://github.com/virtualroot/)
