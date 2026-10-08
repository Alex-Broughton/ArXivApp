"""Start the Streamlit server fully detached and print its PID.

AppleScript's `do shell script` blocks until every descendant process lets go
of its session, even with `nohup ... < /dev/null > log 2>&1 &`. A new session
plus closed fds lets the launcher return immediately.
usage: start_server.py <repo_dir> <port> <log_path>
"""

import subprocess
import sys

repo, port, log = sys.argv[1:4]
with open(log, "ab") as out:
    proc = subprocess.Popen(
        [
            f"{repo}/.venv/bin/streamlit", "run", "main.py",
            "--server.headless", "true",
            "--server.address", "127.0.0.1",
            "--server.port", port,
            "--browser.gatherUsageStats", "false",
            "--server.fileWatcherType", "none",
        ],
        cwd=repo,  # repo root: real data/ library and .env
        stdin=subprocess.DEVNULL,
        stdout=out,
        stderr=subprocess.STDOUT,
        start_new_session=True,
        close_fds=True,
    )
print(proc.pid)
