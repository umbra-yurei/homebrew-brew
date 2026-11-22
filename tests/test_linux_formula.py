"""Release guard: the Linux formulas only ever point at the GNU GUI artifacts.

Runs the real release entry point (`g.sh --os linux`) for both channels with
downloads stubbed, then checks the formula it wrote. Run from the repo root:

    python3 -m unittest discover -s tests
"""

from __future__ import annotations

import os
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile
import unittest

REPO = pathlib.Path(__file__).resolve().parent.parent
STUB_DIR = pathlib.Path(__file__).resolve().parent / "stub_download"
sys.path.insert(0, str(REPO))

import generate_formula  # noqa: E402

VERSION = "9.8.7-rc.1"
TARGETS = {
    "on_arm": generate_formula.LINUX_ARM_TARGET,
    "on_intel": generate_formula.LINUX_X86_TARGET,
}
CHANNELS = {
    "stable": ("cruma", []),
    "preview": ("cruma-preview", ["--preview"]),
}


def arch_urls(formula: str) -> dict[str, str]:
    """Map each `on_arm` / `on_intel` block of a formula to its url."""
    return dict(re.findall(r'(on_arm|on_intel) do\s+url "([^"]+)"', formula))


def all_urls(formula: str) -> list[str]:
    return re.findall(r'^\s*url "([^"]+)"', formula, re.MULTILINE)


class GeneratorRun:
    """A scratch copy of the generator scripts with downloads stubbed."""

    def __init__(self) -> None:
        self.dir = pathlib.Path(tempfile.mkdtemp(prefix="brew-guard-"))
        for name in ("g.sh", "artifact_urls.py", "generate_formula.py", "generate_cask.py"):
            shutil.copy2(REPO / name, self.dir / name)
        self.log = self.dir / "downloads.log"
        self.env = dict(
            os.environ,
            PYTHONPATH=os.pathsep.join(filter(None, [str(STUB_DIR), os.environ.get("PYTHONPATH")])),
            STUB_DOWNLOAD_LOG=str(self.log),
        )

    def cleanup(self) -> None:
        shutil.rmtree(self.dir, ignore_errors=True)

    def run(self, *args: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            list(args), cwd=self.dir, env=self.env, capture_output=True, text=True
        )

    def downloads(self) -> list[str]:
        return self.log.read_text().split() if self.log.exists() else []


class LinuxFormulaReleaseGuard(unittest.TestCase):
    def setUp(self) -> None:
        self.gen = GeneratorRun()
        self.addCleanup(self.gen.cleanup)

    def test_release_script_emits_gnu_urls_for_both_channels(self) -> None:
        for channel, (name, flags) in CHANNELS.items():
            with self.subTest(channel=channel):
                result = self.gen.run("bash", "g.sh", VERSION, *flags, "--os", "linux")
                self.assertEqual(result.returncode, 0, result.stderr)
                formula = (self.gen.dir / "Formula" / f"{name}.rb").read_text()
                self.assertFalse((self.gen.dir / "Casks").exists(), "--os linux wrote a cask")

                urls = arch_urls(formula)
                self.assertEqual(set(urls), set(TARGETS), formula)
                for block, target in TARGETS.items():
                    self.assertEqual(
                        urls[block], generate_formula.expected_linux_url(VERSION, target)
                    )
                self.assertEqual(sorted(all_urls(formula)), sorted(urls.values()))
                self.assertNotIn("musl", formula)
                self.assertEqual(sorted(self.gen.downloads()), sorted(urls.values()))
                self.gen.log.unlink()

    def test_generator_rejects_non_gnu_artifacts_before_downloading(self) -> None:
        base = f"{generate_formula.ARTIFACT_BASE}/v{VERSION}"
        good_arm = generate_formula.expected_linux_url(VERSION, generate_formula.LINUX_ARM_TARGET)
        good_x86 = generate_formula.expected_linux_url(VERSION, generate_formula.LINUX_X86_TARGET)
        bad = {
            "arm musl": (f"{base}/aarch64-unknown-linux-musl/cruma", good_x86),
            "x86 musl": (good_arm, f"{base}/x86_64-unknown-linux-musl/cruma"),
            "arm/x86 swapped": (good_x86, good_arm),
            "appimage": (good_arm, f"{base}/x86_64-unknown-linux-gnu/appimage/Cruma-x86_64.AppImage"),
            "server artifact": (good_arm, f"https://files.cruma.io/files/cruma-server/v{VERSION}/x86_64-unknown-linux-gnu/cruma"),
            "other version": (good_arm, good_x86.replace(VERSION, "0.0.1")),
            "other host": (good_arm, good_x86.replace("files.cruma.io", "example.com")),
        }
        for case, (arm_url, x86_url) in bad.items():
            for channel, (name, _) in CHANNELS.items():
                with self.subTest(case=case, channel=channel):
                    result = self.gen.run(
                        sys.executable, "generate_formula.py",
                        "--name", name, "--version", VERSION,
                        "--linux-arm-url", arm_url, "--linux-x86-url", x86_url,
                        "--binary-name", "cruma", "--binary-target", name,
                        "--no-ad-hoc-sign",
                    )
                    self.assertNotEqual(result.returncode, 0, result.stdout)
                    self.assertIn("GNU GUI artifact", result.stderr)
                    self.assertFalse((self.gen.dir / "Formula" / f"{name}.rb").exists())
                    self.assertEqual(self.gen.downloads(), [])

    def test_committed_formulas_point_at_gnu_artifacts(self) -> None:
        for channel, (name, _) in CHANNELS.items():
            with self.subTest(channel=channel):
                formula = (REPO / "Formula" / f"{name}.rb").read_text()
                version = re.search(r'^\s*version "([^"]+)"', formula, re.MULTILINE).group(1)
                urls = arch_urls(formula)
                self.assertEqual(set(urls), set(TARGETS), formula)
                for block, target in TARGETS.items():
                    self.assertIsNone(
                        generate_formula.check_linux_url(urls[block], version, target)
                    )


if __name__ == "__main__":
    unittest.main()
