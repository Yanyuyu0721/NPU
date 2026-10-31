"""Real positive/negative controls for the reusable tools; no EDA claim."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile
sys.dont_write_bytecode = True
from file_manifest import snapshot, verify
from compare_words import compare, load
from capture_run import capture


def main():
    checks = []
    def record(name, predicate):
        if not predicate:
            raise AssertionError(name)
        checks.append(name)
    def reject(name, function):
        try:
            function()
        except (ValueError, OSError):
            checks.append(name)
        else:
            raise AssertionError('Negative accepted: ' + name)
    # Put temporary data under the caller's current directory, not outside its workspace.
    with tempfile.TemporaryDirectory(prefix='skill_check_', dir=Path.cwd()) as temp:
        root = Path(temp).resolve()
        code = root / 'design.sv'
        code.write_text('module design; endmodule\n')
        manifest = dict(schema='exact_files_v1', sha256=snapshot(root, ['design.sv']))
        record('file_identity_positive', verify(root, manifest)['passed'])
        code.write_text('module changed; endmodule\n')
        reject('changed_source_rejected', lambda: verify(root, manifest))
        reject('path_traversal_rejected', lambda: snapshot(root, ['../design.sv']))
        reject('windows_drive_rejected', lambda: snapshot(root, ['C:/design.sv']))
        reject('empty_manifest_rejected', lambda: verify(root, dict(schema='exact_files_v1', sha256={})))
        code.write_text('module design; endmodule\n')
        expected = root / 'reference.mem'
        actual = root / 'actual.bin'
        expected.write_text('00000001 ffffffff 00000000 00000000\n')
        actual.write_bytes(bytes.fromhex('01000000ffffffff0000000000000000'))
        words = load(expected, 32, 'little')
        record('hex_binary_bit_exact_positive', compare(words, load(actual, 32, 'little'))['passed'])
        actual.write_bytes(bytes.fromhex('01000000ffffffff0000000001000000'))
        mutation = compare(words, load(actual, 32, 'little'))
        record('zero_slack_mutation_rejected_at_word3', not mutation['passed'] and mutation['first_mismatches'][0]['index'] == 3)
        reject('short_vector_rejected', lambda: compare(words, words[:-1]))
        expected.write_text('@0 01\n')
        reject('sparse_memory_rejected', lambda: load(expected, 8, 'little'))
        actual.write_bytes(b'')
        reject('empty_binary_rejected', lambda: load(actual, 32, 'little'))
        def run(name, program, timeout=10):
            return capture(root, manifest, root/name, [sys.executable, '-c', program], timeout, 'CHECK_COMPLETE')
        record('command_capture_positive', run('positive', "print('CHECK_COMPLETE')")['passed'])
        record('partial_pass_rejected', not run('partial', "print('CHECK_COMPLETE partial')")['passed'])
        record('duplicate_pass_rejected', not run('duplicate', "print('CHECK_COMPLETE');print('CHECK_COMPLETE')")['passed'])
        record('error_then_pass_rejected', not run('error', "print('ERROR: failed');print('CHECK_COMPLETE')")['passed'])
        record('nonzero_exit_rejected', not run('nonzero', "print('CHECK_COMPLETE');raise SystemExit(3)")['passed'])
        record('source_changed_during_run_rejected', not run('mutate', "from pathlib import Path;Path('design.sv').write_text('changed');print('CHECK_COMPLETE')")['passed'])
        code.write_text('module design; endmodule\n')
        timeout = run('timeout', 'import time;time.sleep(30)', .2)
        record('finite_timeout_rejected', not timeout['passed'] and timeout['exit'] == 124 and timeout['timed_out'])
        # Also verify the CLI exits nonzero, rather than only returning a Boolean.
        expected.write_text('00000001 00000000\n')
        actual.write_bytes(bytes.fromhex('0100000001000000'))
        result = subprocess.run([sys.executable, str(Path(__file__).with_name('compare_words.py')), str(expected), str(actual), '--word-bits', '32'], capture_output=True, text=True)
        record('mismatch_cli_exit_nonzero', result.returncode == 1 and '"passed": false' in result.stdout)
    print(json.dumps(dict(passed=True, scope='REUSABLE_TOOL_CONTROLS_NOT_RTL', checks=checks), indent=2))


if __name__ == '__main__':
    main()
