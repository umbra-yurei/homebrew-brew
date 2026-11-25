"""Release guard: the Homebrew casks are Apple Silicon only.

Runs the real release entry point (`g.sh --os macos`) for both channels with
downloads stubbed, then checks the cask it wrote. Run from the repo root:

    python3 -m unittest discover -s tests
"""

from __future__ import annotations

import hashlib
import pathlib
import re
import struct
import sys
import tempfile
import unittest

from test_linux_formula import CHANNELS, REPO, VERSION, GeneratorRun

sys.path.insert(0, str(REPO))

import generate_cask  # noqa: E402


def stub_sha256(url: str) -> str:
    return hashlib.sha256(f"stub artifact for {url}".encode()).hexdigest()


def cask_field(cask: str, pattern: str) -> str:
    match = re.search(pattern, cask, re.MULTILINE)
    assert match, f"{pattern!r} not found in:\n{cask}"
    return match.group(1)


def thin_macho(cpu_type: int) -> bytes:
    return b"\xcf\xfa\xed\xfe" + struct.pack("<I", cpu_type) + bytes(24)


def fat_macho(*cpu_types: int) -> bytes:
    entries = b"".join(struct.pack(">5I", cpu, 0, 4096, 4096, 12) for cpu in cpu_types)
    return b"\xca\xfe\xba\xbe" + struct.pack(">I", len(cpu_types)) + entries


class MacosCaskReleaseGuard(unittest.TestCase):
    def setUp(self) -> None:
        self.gen = GeneratorRun()
        self.addCleanup(self.gen.cleanup)

    def test_cask_is_apple_silicon_only_for_both_channels(self) -> None:
        for channel, (name, flags) in CHANNELS.items():
            with self.subTest(channel=channel):
                result = self.gen.run("bash", "g.sh", VERSION, *flags, "--os", "macos")
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertFalse((self.gen.dir / "Formula").exists(), "--os macos wrote a formula")
                cask = (self.gen.dir / "Casks" / f"{name}.rb").read_text()

                url = generate_cask.expected_dmg_url(VERSION, name)
                self.assertEqual(self.gen.downloads(), [url])

                self.assertIn("depends_on arch: :arm64", cask)
                self.assertNotIn("x86_64", cask)
                self.assertNotRegex(cask, r"(?i)intel|on_intel|\barch (arm|intel)")
                self.assertEqual(len(re.findall(r'^  url ', cask, re.MULTILINE)), 1)
                self.assertEqual(len(re.findall(r'^\s*sha256 ', cask, re.MULTILINE)), 1)
                self.assertEqual(cask_field(cask, r'^\s*version "([^"]+)"'), VERSION)
                template = cask_field(cask, r'^\s*url "([^"]+)"')
                self.assertEqual(template.replace("#{version}", VERSION), url)
                self.assertEqual(cask_field(cask, r'^\s*sha256 "([^"]+)"'), stub_sha256(url))
                self.assertIn('binary "#{appdir}/', cask)
                self.assertIn("  postflight_steps do\n", cask)
                self.assertNotRegex(cask, r"^  postflight do$|system_command", msg=cask)
                app_name = "Cruma Preview.app" if name.endswith("preview") else "Cruma.app"
                self.assertIn(
                    '    run "/System/Library/Frameworks/CoreServices.framework/Frameworks/" \\\n'
                    '        "LaunchServices.framework/Support/lsregister",\n'
                    f'        args: ["-f", "{{{{appdir}}}}/{app_name}"]\n',
                    cask,
                )
                self.assertIn(
                    '    run "/usr/bin/mdimport",\n'
                    f'        args: ["{{{{appdir}}}}/{app_name}"]\n',
                    cask,
                )
                self.assertIn(f'  version "{VERSION}"\n  sha256 "', cask)
                self.assertNotIn("\n\nend", cask)
                manifest = "preview" if name.endswith("preview") else "stable"
                self.assertIn(
                    f'  livecheck do\n    url "{generate_cask.ARTIFACT_BASE}/{manifest}.json"\n'
                    '    strategy :json do |json|\n      json["version"]\n    end\n  end\n',
                    cask,
                )
                self.gen.log.unlink()

    def test_generator_rejects_wrong_dmgs_before_downloading(self) -> None:
        for channel, (name, _) in CHANNELS.items():
            good = generate_cask.expected_dmg_url(VERSION, name)
            other_channel = "cruma.dmg" if name.endswith("preview") else "cruma-preview.dmg"
            bad = {
                "intel dmg": good.replace("aarch64-apple-darwin/", "x86_64-apple-darwin/"),
                "other channel": good.rsplit("/", 1)[0] + "/" + other_channel,
                "other version": good.replace(VERSION, "0.0.1"),
                "other host": good.replace("files.cruma.io", "example.com"),
                "linux binary": good.replace("aarch64-apple-darwin/", "aarch64-unknown-linux-gnu/"),
            }
            for case, url in bad.items():
                with self.subTest(case=case, channel=channel):
                    result = self.gen.run(
                        sys.executable, "generate_cask.py",
                        "--name", name, "--version", VERSION, "--url", url,
                        "--app-name", "Cruma.app", "--binary-name", "cruma",
                    )
                    self.assertNotEqual(result.returncode, 0, result.stdout)
                    self.assertIn("DMG URL must be", result.stderr)
                    self.assertFalse((self.gen.dir / "Casks" / f"{name}.rb").exists())
                    self.assertEqual(self.gen.downloads(), [])

    def test_generator_has_no_intel_options(self) -> None:
        result = self.gen.run(sys.executable, "generate_cask.py", "--help")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("--intel-url", result.stdout)
        self.assertNotIn("--arm-url", result.stdout)

    def test_quarantine_fallback_uses_structured_postflight_steps(self) -> None:
        cask = generate_cask.render_cask(
            cask_name="cruma",
            version=VERSION,
            sha256="0" * 64,
            app_name="Cruma.app",
            app_target="Cruma.app",
            binary_name="cruma",
            binary_target="cruma",
            desc="Tunnel agent",
            homepage="https://cruma.io/",
            clear_quarantine=True,
        )

        self.assertIn("  postflight_steps do\n", cask)
        self.assertNotRegex(cask, r"^  postflight do$|system_command", msg=cask)
        self.assertIn(
            '    run "/usr/bin/xattr",\n'
            '        args: ["-drs", "com.apple.quarantine", "{{appdir}}/Cruma.app"]\n',
            cask,
        )
        self.assertIn(
            '    run "/System/Library/Frameworks/CoreServices.framework/Frameworks/" \\\n'
            '        "LaunchServices.framework/Support/lsregister",\n',
            cask,
        )
        self.assertIn('    run "/usr/bin/mdimport",\n', cask)

    def test_macho_architecture_reader(self) -> None:
        x86, arm = 0x01000007, 0x0100000C
        cases = {
            "thin x86_64": (thin_macho(x86), {"x86_64"}),
            "thin arm64": (thin_macho(arm), {"arm64"}),
            "universal": (fat_macho(x86, arm), {"x86_64", "arm64"}),
        }
        with tempfile.TemporaryDirectory() as tmp:
            for case, (data, archs) in cases.items():
                with self.subTest(case=case):
                    path = pathlib.Path(tmp) / case.replace(" ", "-")
                    path.write_bytes(data)
                    self.assertEqual(generate_cask.macho_archs(path), archs)
            script = pathlib.Path(tmp) / "script"
            script.write_bytes(b"#!/bin/sh\necho hi\n")
            with self.assertRaises(RuntimeError):
                generate_cask.macho_archs(script)

            truncated_fat = pathlib.Path(tmp) / "truncated-fat"
            truncated_fat.write_bytes(fat_macho(x86)[:-1])
            with self.assertRaisesRegex(RuntimeError, "truncated Mach-O architecture table"):
                generate_cask.macho_archs(truncated_fat)

    def test_expected_architecture_is_arm64(self) -> None:
        self.assertEqual(generate_cask.EXPECTED_MACHO_ARCH, "arm64")


if __name__ == "__main__":
    unittest.main()
