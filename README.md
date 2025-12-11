# pwgen

[![build](https://github.com/kojix2/pwgen.cr/actions/workflows/build.yml/badge.svg)](https://github.com/kojix2/pwgen.cr/actions/workflows/build.yml)
[![Lines of Code](https://img.shields.io/endpoint?url=https%3A%2F%2Ftokei.kojix2.net%2Fbadge%2Fgithub%2Fkojix2%2Fpwgen.cr%2Flines)](https://tokei.kojix2.net/github/kojix2/pwgen.cr)

Password generator written in Crystal. Port of the C pwgen utility.

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
  -c, --capitalize          Include at least one capital letter
  -A, --no-capitalize       Don't include capital letters
  -n, --numerals            Include at least one number
  -0, --no-numerals         Don't include numbers
  -y, --symbols             Include at least one special symbol
  -B, --ambiguous           Don't include ambiguous characters
  -v, --no-vowels           Don't include vowels
  -r, --remove-chars CHARS  Remove given characters
  -s, --secure              Generate completely random passwords
  -C                        Print the generated passwords in columns
  -1                        Don't print the generated passwords in columns
  -N, --num-passwords NUM   Number of passwords to generate
  -H, --sha1 FILE[#seed]    Use sha1 hash of given file
  -h, --help                Print this help message
  -V, --version             Print version
```

## Examples

Random passwords:
```bash
pwgen -s 16 3
```

No ambiguous characters:
```bash
pwgen -B 12
```

Include symbols:
```bash
pwgen -y 14 3
```

Deterministic generation:
```bash
pwgen -H /path/to/file#seed 12 5
```

## Implementation

- Default: phoneme-based pronounceable passwords
- `-s`: cryptographically secure random (Random::Secure)
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
