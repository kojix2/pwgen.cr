# pwgen

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
-c, --capitalize              Include at least one capital letter
-A, --no-capitalize           Don't include capital letters
-n, --numerals                Include at least one number
-0, --no-numerals             Don't include numbers
-y, --symbols                 Include at least one special symbol
-B, --ambiguous               Don't include ambiguous characters
-v, --no-vowels               Don't include vowels
-r CHARS, --remove-chars      Remove specific characters
-s, --secure                  Generate random passwords
-C                            Print in columns
-1                            Print one per line
-N NUM, --num-passwords       Number of passwords
-H FILE[#seed], --sha1        Use SHA1 hash of file
-h, --help                    Show help
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
