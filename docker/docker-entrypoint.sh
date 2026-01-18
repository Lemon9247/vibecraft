#!/bin/bash
set -e

echo "Vibecraft Docker Container Starting..."
echo ""

# Start tmux server
echo "Starting tmux server..."
tmux start-server || true

# Always configure hooks at startup (safe to run, just copies files)
echo "Configuring Vibecraft hooks..."
cd /home/vibecraft
node bin/cli.js setup
echo ""

# Function to check if Claude is authenticated
check_claude_auth() {
  if [ -n "${ANTHROPIC_API_KEY}" ]; then
    # API key is set, consider it authenticated
    return 0
  fi

  # Check if Pro/Max auth exists
  if [ -f "$HOME/.claude/config.json" ] || [ -f "$HOME/.claude/auth.json" ]; then
    return 0
  fi

  return 1
}

# Function to wait for Claude authentication
wait_for_claude_auth() {
  echo "Waiting for Claude authentication..."
  echo ""
  echo "Please authenticate Claude by running in another terminal:"
  echo "  docker exec -it vibecraft claude auth login"
  echo ""
  echo "Or set ANTHROPIC_API_KEY in .env and restart the container"
  echo ""

  # Poll for authentication (with timeout)
  for i in {1..60}; do
    if check_claude_auth; then
      echo "Claude authenticated!"
      return 0
    fi
    sleep 5
  done

  echo "Warning: Timeout waiting for authentication, continuing anyway..."
  return 1
}

# Auto-start Claude for initial authentication if needed
if [ "${AUTO_START_CLAUDE}" = "true" ]; then
  echo "Auto-start mode enabled"
  echo ""

  if check_claude_auth; then
    echo "Claude is already authenticated"
  else
    echo "Starting Claude for initial authentication..."
    echo ""

    if [ -n "${ANTHROPIC_API_KEY}" ]; then
      echo "Using ANTHROPIC_API_KEY from environment"
      # Start Claude with API key to trigger initial setup
      tmux new-session -d -s claude-init -e ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}" "claude --version && exit"
      sleep 2
      tmux kill-session -t claude-init 2>/dev/null || true
    else
      echo "No API key found. You need to authenticate Claude."
      echo "Run: docker exec -it vibecraft claude auth login"
      echo ""
      wait_for_claude_auth
    fi
  fi

  # Start Claude with hooks enabled (hooks already configured at startup)
  echo ""
  echo "Starting Claude session with Vibecraft hooks..."
  TMUX_CMD="claude --cwd /home/vibecraft/workspace || bash"

  if [ -n "${ANTHROPIC_API_KEY}" ]; then
    tmux new-session -d -s claude -e ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}" "${TMUX_CMD}"
  else
    tmux new-session -d -s claude "${TMUX_CMD}"
  fi

  echo "  Claude session started (tmux session: claude)"
  echo "  To attach: docker exec -it vibecraft tmux attach -t claude"
  echo ""
else
  # Manual mode - don't auto-start
  echo "Manual mode - Claude will not auto-start"
  echo ""

  if ! check_claude_auth; then
    echo "Claude is not authenticated yet."
    echo ""
  fi

  echo "To authenticate Claude:"
  echo "  docker exec -it vibecraft claude auth login"
  echo ""
  echo "To start a Claude session with Vibecraft:"
  echo "  docker exec -it vibecraft /home/vibecraft/start-claude.sh"
  echo ""
  echo "Or start manually:"
  echo "  docker exec -it vibecraft tmux new-session -s claude claude"
  echo ""
fi

echo "Vibecraft server will start on port ${VIBECRAFT_PORT}"
echo "Access the UI at: http://localhost:${VIBECRAFT_PORT}"
echo ""

# Start Vibecraft server (exec replaces shell with node process for proper signal handling)
echo "Starting Vibecraft server..."
exec node dist/server/server/index.js
