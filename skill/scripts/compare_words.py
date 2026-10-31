"""Compare complete dense hexadecimal or binary vectors, including zero slack."""
import argparse
import json
import re
from pathlib import Path


def load(path, bits, endian):
    if bits <= 0 or bits % 8 or bits > 1024:
        raise ValueError('word-bits must be a multiple of 8 in [8,1024]')
    if path.suffix.lower() == '.bin':
        data = path.read_bytes()
        size = bits // 8
        if not data:
            raise ValueError('Empty vector')
        if len(data) % size:
            raise ValueError('Binary length is not a whole number of words')
        return [int.from_bytes(data[i:i+size], endian) for i in range(0, len(data), size)]
    text = re.sub(r'//[^\n]*|#[^\n]*', '', path.read_text(encoding='ascii'))
    tokens = text.split()
    if not tokens:
        raise ValueError('Empty vector')
    if any(not re.fullmatch(r'[0-9a-fA-F]+', token) for token in tokens):
        raise ValueError('Dense hex only; sparse @ addresses and X/Z are rejected')
    words = [int(token, 16) for token in tokens]
    if any(word >= 1 << bits for word in words):
        raise ValueError('Word exceeds declared width')
    return words


def compare(expected, actual):
    if len(expected) != len(actual):
        raise ValueError('Length mismatch: expected %d, actual %d' % (len(expected), len(actual)))
    bad = [i for i, pair in enumerate(zip(expected, actual)) if pair[0] != pair[1]]
    return {'passed': not bad, 'scope': 'COMPLETE_VECTOR_BIT_EXACT', 'words': len(expected),
            'mismatches': len(bad), 'first_mismatches': [dict(index=i, expected=expected[i], actual=actual[i]) for i in bad[:16]]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('expected', type=Path)
    parser.add_argument('actual', type=Path)
    parser.add_argument('--word-bits', type=int, required=True)
    parser.add_argument('--endian', choices=('little', 'big'), default='little')
    args = parser.parse_args()
    result = compare(load(args.expected, args.word_bits, args.endian), load(args.actual, args.word_bits, args.endian))
    print(json.dumps(result, indent=2))
    return 0 if result['passed'] else 1


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (OSError, ValueError) as error:
        raise SystemExit('REJECTED: ' + str(error))
