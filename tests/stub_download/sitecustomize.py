"""Loaded by the tests via PYTHONPATH: replaces downloads with fixed bytes.

Every requested URL is appended to the file named by STUB_DOWNLOAD_LOG, so a
test can assert on what the generator tried to fetch without any network.
"""

import io
import os
import urllib.request


def _stub_urlopen(url, *args, **kwargs):
    log = os.environ.get("STUB_DOWNLOAD_LOG")
    if log:
        with open(log, "a") as handle:
            handle.write(f"{url}\n")
    return io.BytesIO(f"stub artifact for {url}".encode())


urllib.request.urlopen = _stub_urlopen
