# pwgen

[![build](https://github.com/kojix2/pwgen.cr/actions/workflows/build.yml/badge.svg)](https://github.com/kojix2/pwgen.cr/actions/workflows/build.yml)
[![Lines of Code](https://img.shields.io/endpoint?url=https%3A%2F%2Ftokei.kojix2.net%2Fbadge%2Fgithub%2Fkojix2%2Fpwgen.cr%2Flines)](https://tokei.kojix2.net/github/kojix2/pwgen.cr)

A password generation tool written in Crystal.

It is a port of the C-language pwgen utility, but the options have been modified to kojix2's preferences, and the output is colorized.

## Build

```bash
shards build --release
```

Binary: `bin/pwgen`

## Usage

```bash
pwgen [length] [count]
```

Generate 5 passwords of 12 characters:
```bash
pwgen 12 5
```

Options:
```
  -C, --no-capitals         Don't include capital letters
  -N, --no-numerals         Don't include numbers
  -S, --no-symbols          Don't include special symbols
  -A, --no-ambiguous        Don't include ambiguous characters
  -V, --no-vowels           Don't include vowels
  -E, --exclude CHARS       Remove given characters
  -r, --random              Generate completely random passwords
  -1, --one                 Single column
  -m, --no-color            Disable ANSI color output
  -n, --num NUM             Number of passwords to generate
  -H, --sha1 FILE[#seed]    Use sha1 hash of given file
  -h, --help                Print this help message
  -v, --version             Print version
```

## Examples


Deterministic generation:
```bash
pwgen -H /path/to/file#seed 12 5
```

## Implementation

- Default: phoneme-based pronounceable passwords
- Output is colorized by default: uppercase letters, digits, and symbols use ANSI colors
- `--no-color`: disable ANSI color output when piping or saving plain text is preferred
- `-r`: cryptographically secure random (Random::Secure)
- `-H`: SHA1-based PRNG for reproducible output
- Uses Crystal's `Random::Secure` backed by the OS CSPRNG

## Tests

```bash
crystal spec
```

## Acknowledgements

This project is a Crystal port of the original C `pwgen` utility by Theodore Ts'o.
The original implementation and design are available at:
https://github.com/tytso/pwgen

## License

MIT
