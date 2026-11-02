"""Canonical release-artifact URL helpers shared by the tap generators."""

ARTIFACT_BASE = "https://files.cruma.io/files/tunnel-agent"


def release_base(version: str) -> str:
    return f"{ARTIFACT_BASE}/v{version}"
