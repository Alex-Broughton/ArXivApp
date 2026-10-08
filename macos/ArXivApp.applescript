-- ArXivApp Dock launcher (stay-open applet).
-- Click: start Streamlit (if not already up) and open the browser.
-- Click again while running: reopen the browser tab.
-- Quit (Cmd-Q / Dock > Quit): stop the server this launcher started.
-- build_app.sh replaces the two placeholders below.

property repoDir : "__REPO_DIR__"
property uvPath : "__UV_PATH__"
property appPort : "8501"

global startedPid

on run
	set startedPid to ""
	ensureServer()
	openBrowser()
end run

on reopen
	ensureServer()
	openBrowser()
end reopen

on quit
	if startedPid is not "" then
		do shell script "kill " & startedPid & " 2>/dev/null || true"
	end if
	continue quit
end quit

on appURL()
	return "http://127.0.0.1:" & appPort
end appURL

on logPath()
	return (POSIX path of (path to home folder)) & "Library/Logs/ArXivApp.log"
end logPath

on isUp()
	try
		do shell script "curl -fsS -m 2 " & quoted form of (appURL() & "/_stcore/health") & " >/dev/null"
		return true
	on error
		return false
	end try
end isUp

on ensureServer()
	if isUp() then return
	set streamlit to repoDir & "/.venv/bin/streamlit"
	try
		do shell script "test -x " & quoted form of streamlit
	on error
		-- First run: create the environment from the lock file.
		try
			do shell script "cd " & quoted form of repoDir & " && " & quoted form of uvPath & " sync --locked --python 3.12 >> " & quoted form of logPath() & " 2>&1"
		on error
			display alert "ArXivApp" message "Could not install dependencies. See " & logPath()
			error number -128
		end try
	end try
	-- macos/start_server.py detaches fully (a plain `nohup ... &` here hangs the applet)
	-- and runs from the repo root, so the app uses the real data/ library and .env.
	set startedPid to do shell script quoted form of (repoDir & "/.venv/bin/python") & " " & quoted form of (repoDir & "/macos/start_server.py") & " " & quoted form of repoDir & " " & appPort & " " & quoted form of logPath()
	repeat 90 times
		if isUp() then return
		delay 1
	end repeat
	display alert "ArXivApp" message "The server did not start within 90 seconds. See " & logPath()
end ensureServer

on openBrowser()
	open location appURL()
end openBrowser
