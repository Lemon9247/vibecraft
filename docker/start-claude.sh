#!/bin/bash
# Helper script to start Claude with Vibecraft hooks configured

set -e

echo "Starting Claude with Vibecraft..."
echo ""
echo "Note: Vibecraft hooks are configured at container startup."
echo ""

# Check if tmux session already exists
if tmux has-session -t claude 2>/dev/null; then
  echo "Claude session 'claude' already exists"
  echo "To attach: tmux attach -t claude"
  echo "To kill and restart: tmux kill-session -t claude && $0"
  exit 1
fi

# Start Claude in tmux
echo "Starting Claude in tmux session 'claude'..."

if [ -n "${ANTHROPIC_API_KEY}" ]; then
  echo "Using ANTHROPIC_API_KEY from environment"
  tmux new-session -d -s claude -e ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}" "claude --cwd /home/vibecraft/workspace || bash"
else
  tmux new-session -d -s claude "claude --cwd /home/vibecraft/workspace || bash"
fi

echo ""
echo "Claude started successfully!"
echo ""
echo "To attach to the session:"
echo "  tmux attach -t claude"
echo ""
echo "To detach from the session: Press Ctrl+B, then D"
echo ""
