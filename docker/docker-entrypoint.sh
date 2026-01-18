#!/bin/bash
set -e

echo "Vibecraft Docker Container Starting..."
echo ""

# Configure Vibecraft hooks for Claude Code
echo "🔧 Configuring Vibecraft hooks..."
node bin/cli.js setup

echo ""
echo "Starting tmux server..."
# Start tmux server in the background (ignore errors if already running)
tmux start-server || true

echo ""
echo "Initialization complete!"
echo ""
echo "Vibecraft server will start on port ${VIBECRAFT_PORT}"
echo "Access the UI at: http://localhost:${VIBECRAFT_PORT}"
echo ""
echo "Authentication options:"
echo "  - API Key: Set ANTHROPIC_API_KEY environment variable"
echo "  - Pro/Max: Run 'docker exec -it vibecraft claude auth login'"
echo ""
echo "To attach to a Claude session: docker exec -it vibecraft tmux attach -t <session-name>"
echo ""

# Start Vibecraft server (exec replaces shell with node process for proper signal handling)
echo "Starting Vibecraft server..."
exec node dist/server/server/index.js
