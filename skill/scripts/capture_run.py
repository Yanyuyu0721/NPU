"""Bounded command evidence capture; a token is not a substitute for a checker."""
import argparse
import datetime
import json
import os
import re
import subprocess
import time
import sys
from pathlib import Path
sys.dont_write_bytecode = True
from file_manifest import snapshot, digest, verify


def capture(root, manifest, output, command, timeout, pass_line):
    if not 0 < timeout <= 86400 or not command or not pass_line:
        raise ValueError('Finite timeout, command and exact PASS line required')
    root = root.resolve(strict=True)
    verify(root, manifest)
    output = output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    expected = manifest['sha256']
    before = snapshot(root, expected)
    if before != expected:
        raise ValueError('Pre-run source binding mismatch')
    result = dict(scope='SOURCE_COMMAND_LOG_TOKEN_ONLY', passed=False, command=command,
                  started_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                  source_before=before, timeout_seconds=timeout, required_pass_line=pass_line)
    receipt = output / 'result.json'
    def save():
        receipt.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    save()
    start = time.monotonic()
    try:
        with (output / 'stdout.log').open('wb') as log:
            process = subprocess.Popen(command, cwd=root, stdout=log, stderr=subprocess.STDOUT,
                creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0,
                start_new_session=os.name != 'nt')
            result['pid'] = process.pid
            save()
            try:
                code = process.wait(timeout)
            except subprocess.TimeoutExpired:
                result['timed_out'] = True
                if os.name == 'nt':
                    killed = subprocess.run(['taskkill', '/PID', str(process.pid), '/T', '/F'], capture_output=True, timeout=5)
                    result['owned_tree_taskkill_exit'] = killed.returncode
                    if killed.returncode:
                        process.kill()
                else:
                    import signal
                    os.killpg(process.pid, signal.SIGKILL)
                process.wait(5)
                code = 124
        text = (output / 'stdout.log').read_text(encoding='utf-8', errors='replace')
        after = snapshot(root, expected)
        result.update(exit=code, source_after=after, source_unchanged=before == after,
            log_sha256=digest(output / 'stdout.log'), pass_count=text.splitlines().count(pass_line),
            failure_markers=bool(re.search(r'(?im)^.*(?:\bFATAL\b|\bERROR\b|\bTIMEOUT\b|\bREJECTED\b|\bFAIL\b)', text)))
        result['passed'] = code == 0 and before == after and result['pass_count'] == 1 and not result['failure_markers']
    except Exception as error:
        result['error'] = repr(error)
    result.update(seconds=time.monotonic() - start, finished_utc=datetime.datetime.now(datetime.timezone.utc).isoformat())
    save()
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--manifest', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--timeout', type=float, required=True)
    parser.add_argument('--pass-line', required=True)
    parser.add_argument('command', nargs=argparse.REMAINDER)
    args = parser.parse_args()
    command = args.command[1:] if args.command[:1] == ['--'] else args.command
    result = capture(args.root, json.loads(args.manifest.read_text()), args.out, command, args.timeout, args.pass_line)
    print(json.dumps({k: v for k, v in result.items() if k not in ('source_before', 'source_after')}, indent=2))
    return 0 if result['passed'] else 1


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, TypeError) as error:
        raise SystemExit('REJECTED: ' + str(error))
