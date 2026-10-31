"""Stdlib, relocatable exact-file manifests. Exit nonzero on mismatch."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath


def digest(path):
    with path.open('rb') as stream:
        h = hashlib.sha256()
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
        return h.hexdigest()


def contained(root, name):
    key = PurePosixPath(name)
    if not name or '\\' in name or ':' in name or key.is_absolute() or '..' in key.parts:
        raise ValueError('Unsafe manifest path: ' + name)
    path = (root / key).resolve()
    if not path.is_relative_to(root) or not path.is_file():
        raise ValueError('Missing file or escaped root: ' + name)
    return path


def snapshot(root, names):
    root = root.resolve(strict=True)
    return {name: digest(contained(root, name)) for name in sorted(set(names))}


def verify(root, manifest):
    if manifest.get('schema') != 'exact_files_v1' or not manifest.get('sha256'):
        raise ValueError('Unsupported or empty manifest')
    expected = manifest['sha256']
    actual = snapshot(root, expected)
    failures = [name for name in expected if actual[name] != expected[name]]
    if failures:
        raise ValueError('Hash mismatch: ' + ', '.join(failures[:8]))
    return {'passed': True, 'scope': 'LISTED_FILE_IDENTITY_ONLY', 'files': len(actual)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=('create', 'verify'))
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--manifest', type=Path, required=True)
    parser.add_argument('--files', nargs='+', help='Root-relative files, create only')
    args = parser.parse_args()
    if args.mode == 'create':
        if not args.files:
            parser.error('--files required for create')
        data = {'schema': 'exact_files_v1', 'sha256': snapshot(args.root, args.files)}
        with args.manifest.open('x', encoding='utf-8') as stream:
            json.dump(data, stream, indent=2)
            stream.write('\n')
        print(json.dumps({'created': str(args.manifest), 'files': len(data['sha256'])}))
    else:
        print(json.dumps(verify(args.root.resolve(), json.loads(args.manifest.read_text(encoding='utf-8')))))


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError) as error:
        raise SystemExit('REJECTED: ' + str(error))
