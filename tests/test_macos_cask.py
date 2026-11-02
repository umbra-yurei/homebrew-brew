"""Release guard: each Mac CPU architecture gets its own notarized DMG.

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

ARCH_TARGETS = {
    "arm": generate_cask.ARM_TARGET,
    "intel": generate_cask.INTEL_TARGET,
}


def stub_sha256(url: str) -> str:
    return hashlib.sha256(f"stub artifact for {url}".encode()).hexdigest()


def cask_field(cask: str, pattern: str) -> str:
    match = re.search(pattern, cask, re.MULTILINE)
    assert match, f"{pattern!r} not found in:\n{cask}"
    return match.group(1)


def resolve_url(cask: str, arch: str) -> str:
    """The url Homebrew fetches for `arch`: the template with version and arch substituted."""
    version = cask_field(cask, r'^\s*version "([^"]+)"')
    arches = dict(re.findall(r'(arm|intel): "([^"]+)"', cask_field(cask, r'^\s*(arch .*)$')))
    template = cask_field(cask, r'^\s*url "([^"]+)"')
    return template.replace("#{version}", version).replace("#{arch}", arches[arch])


def thin_macho(cpu_type: int) -> bytes:
    return b"\xcf\xfa\xed\xfe" + struct.pack("<I", cpu_type) + bytes(24)


def fat_macho(*cpu_types: int) -> bytes:
    entries = b"".join(struct.pack(">5I", cpu, 0, 4096, 4096, 12) for cpu in cpu_types)
    return b"\xca\xfe\xba\xbe" + struct.pack(">I", len(cpu_types)) + entries


class MacosCaskReleaseGuard(unittest.TestCase):
    def setUp(self) -> None:
        self.gen = GeneratorRun()
        self.addCleanup(self.gen.cleanup)

    def test_cask_selects_the_dmg_of_each_architecture_for_both_channels(self) -> None:
        for channel, (name, flags) in CHANNELS.items():
            with self.subTest(channel=channel):
                result = self.gen.run("bash", "g.sh", VERSION, *flags, "--os", "macos")
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertFalse((self.gen.dir / "Formula").exists(), "--os macos wrote a formula")
                cask = (self.gen.dir / "Casks" / f"{name}.rb").read_text()

                urls = {
                    arch: generate_cask.expected_dmg_url(VERSION, target, name)
                    for arch, target in ARCH_TARGETS.items()
                }
                self.assertEqual(sorted(self.gen.downloads()), sorted(urls.values()))
                self.assertNotEqual(urls["arm"], urls["intel"])

                self.assertIn(
                    f'arch arm: "{generate_cask.ARM_TARGET}", intel: "{generate_cask.INTEL_TARGET}"',
                    cask,
                )
                for arch, url in urls.items():
                    self.assertEqual(resolve_url(cask, arch), url)
                    self.assertRegex(cask, rf'{arch}:\s+"{stub_sha256(url)}"')
                self.assertEqual(len(re.findall(r'^\s*url ', cask, re.MULTILINE)), 1)
                self.assertIn('binary "#{appdir}/', cask)
                self.gen.log.unlink()

    def test_generator_rejects_wrong_dmgs_before_downloading(self) -> None:
        for channel, (name, _) in CHANNELS.items():
            good = {
                target: generate_cask.expected_dmg_url(VERSION, target, name)
                for target in ARCH_TARGETS.values()
            }
            arm, intel = good[generate_cask.ARM_TARGET], good[generate_cask.INTEL_TARGET]
            other_channel = "cruma.dmg" if name.endswith("preview") else "cruma-preview.dmg"
            bad = {
                "arm/intel swapped": (intel, arm),
                "intel reused for arm": (intel, intel),
                "other channel": (arm.rsplit("/", 1)[0] + "/" + other_channel, intel),
                "other version": (arm, intel.replace(VERSION, "0.0.1")),
                "other host": (arm.replace("files.cruma.io", "example.com"), intel),
                "linux binary": (arm, intel.replace("x86_64-apple-darwin/", "x86_64-unknown-linux-gnu/")),
            }
            for case, (arm_url, intel_url) in bad.items():
                with self.subTest(case=case, channel=channel):
                    result = self.gen.run(
                        sys.executable, "generate_cask.py",
                        "--name", name, "--version", VERSION,
                        "--arm-url", arm_url, "--intel-url", intel_url,
                        "--app-name", "Cruma.app", "--binary-name", "cruma",
                    )
                    self.assertNotEqual(result.returncode, 0, result.stdout)
                    self.assertIn("DMG URL must be", result.stderr)
                    self.assertFalse((self.gen.dir / "Casks" / f"{name}.rb").exists())
                    self.assertEqual(self.gen.downloads(), [])

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

    def test_expected_architecture_per_target(self) -> None:
        self.assertEqual(generate_cask.EXPECTED_MACHO_ARCH[generate_cask.ARM_TARGET], "arm64")
        self.assertEqual(generate_cask.EXPECTED_MACHO_ARCH[generate_cask.INTEL_TARGET], "x86_64")


if __name__ == "__main__":
    unittest.main()
