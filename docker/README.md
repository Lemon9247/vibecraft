# Vibecraft Docker Setup

Run Vibecraft in a Docker container for isolated deployment.

## Quick Start

**Option 1: With API Key (Fully Automated)**
```bash
cd docker
cp .env.example .env
# Edit .env and set:
#   ANTHROPIC_API_KEY=sk-ant-api03-...
#   AUTO_START_CLAUDE=true
docker-compose up -d

# Wait a few seconds for initialization, then open browser
open http://localhost:4003

# Claude session automatically started in tmux with hooks configured
```

**Option 2: With API Key (Manual Start)**
```bash
cd docker
cp .env.example .env
# Edit .env and set ANTHROPIC_API_KEY=sk-ant-api03-...
docker-compose up -d

# Start Claude with Vibecraft (configures hooks automatically)
docker exec -it vibecraft /home/vibecraft/start-claude.sh

open http://localhost:4003
```

**Option 3: With Pro/Max Account**
```bash
cd docker
docker-compose up -d

# Authenticate Claude
docker exec -it vibecraft claude auth login  # Opens browser for OAuth

# Start Claude with Vibecraft (configures hooks automatically)
docker exec -it vibecraft /home/vibecraft/start-claude.sh

open http://localhost:4003
```

## How It Works

The container startup follows this flow:

1. **Container starts** - Vibecraft server starts on port 4003
2. **Authentication check**:
   - If `ANTHROPIC_API_KEY` is set → Claude authenticates automatically
   - If Pro/Max → You need to run `claude auth login` manually
3. **Hook configuration** - After authentication, Vibecraft hooks are installed
4. **Claude starts** - Claude runs in tmux with hooks active, sending events to Vibecraft

**Important:** Hooks must be configured AFTER Claude is authenticated, which is why the setup happens in this order.

## Usage

```bash
docker-compose up -d              # Start
docker-compose logs -f            # View logs
docker-compose down               # Stop
docker-compose down -v            # Stop and delete all data
```

**Helper scripts inside container:**
```bash
# Start Claude with hooks (auto-configures if needed)
docker exec -it vibecraft /home/vibecraft/start-claude.sh

# Attach to existing Claude session
docker exec -it vibecraft tmux attach -t claude
```

## Working with Projects

**Default workspace:** `./workspace` → `/workspace` in container

```bash
mkdir -p workspace
cd workspace
git clone https://github.com/your/project.git
# In Vibecraft UI: create session with directory /workspace/project
```

**Mount custom directories** - Edit `docker-compose.yml`:
```yaml
volumes:
  - ~/my-projects:/workspace/my-projects
  - vibecraft-claude-auth:/home/vibecraft/.claude
  - vibecraft-data:/home/vibecraft/.vibecraft/data
```

**Git config:** Your `~/.gitconfig` is mounted read-only by default. To use SSH keys, add:
```yaml
volumes:
  - ~/.ssh:/home/vibecraft/.ssh:ro
```

## Data Persistence

Authentication, sessions, and events persist in Docker volumes. Your projects in `./workspace` are bind-mounted.

**Reset everything:**
```bash
docker-compose down -v
```

**Reset only sessions (keep auth):**
```bash
docker-compose down
docker volume rm vibecraft-data
docker-compose up -d
```

## Troubleshooting

### Container Won't Start

**Check logs:**
```bash
docker-compose logs -f
```

**Common issues:**
- Port 4003 already in use: Change `VIBECRAFT_PORT` in `.env`
- Build errors: Try `docker-compose build --no-cache`

### Authentication Issues

**API key not working (still getting login prompt):**
```bash
# 1. Verify key is set in container environment
docker exec vibecraft env | grep ANTHROPIC_API_KEY

# 2. Check it's in .env file
cat .env | grep ANTHROPIC_API_KEY

# 3. Verify AUTO_START_CLAUDE is set to true
cat .env | grep AUTO_START_CLAUDE

# 4. Restart container to apply changes
docker-compose down
docker-compose up -d

# 5. Check if Claude session started correctly
docker exec vibecraft tmux ls

# 6. Attach to Claude session to verify
docker exec -it vibecraft tmux attach -t claude
# (Press Ctrl+B then D to detach)
```

**If API key is set but Claude still prompts for login:**

The API key must be present when starting the tmux session. If you started Claude manually without AUTO_START_CLAUDE=true, restart with:

```bash
# Stop any existing Claude sessions
docker exec vibecraft tmux kill-session -t claude 2>/dev/null || true

# Restart container to auto-start with API key
docker-compose restart
```

**Pro/Max login fails:**
```bash
# Check auth status
docker exec -it vibecraft claude auth status

# Try signing out and back in
docker exec -it vibecraft claude auth logout
docker exec -it vibecraft claude auth login
```

### Sessions Not Spawning

**Check Claude Code is installed:**
```bash
docker exec vibecraft which claude
docker exec vibecraft claude --version
```

**Check if hooks are configured:**
```bash
docker exec vibecraft grep -q "vibecraft-hook" ~/.claude/settings.json && echo "Hooks configured" || echo "Hooks not configured"
```

**Check tmux sessions:**
```bash
docker exec vibecraft tmux ls
```

**Manually configure hooks and start Claude:**
```bash
# This helper script does everything
docker exec -it vibecraft /home/vibecraft/start-claude.sh

# Or do it step by step:
docker exec vibecraft node /home/vibecraft/bin/cli.js setup
docker exec -it vibecraft tmux new-session -s claude claude
```

### Browser UI Not Loading

**Verify server is running:**
```bash
curl http://localhost:4003/health
```

**Check if port is accessible:**
```bash
docker ps | grep vibecraft
# Look for "0.0.0.0:4003->4003/tcp"
```

### Volume Permission Issues

If you encounter permission errors with mounted directories:

```yaml
# Option 1: Use named volumes instead of bind mounts
volumes:
  - vibecraft-projects:/workspace

# Option 2: Match user IDs (advanced)
# Add to Dockerfile:
# ARG USER_ID=1000
# ARG GROUP_ID=1000
# RUN usermod -u $USER_ID vibecraft && groupmod -g $GROUP_ID vibecraft
```

## Advanced

**Environment variables** (set in `.env`):
- `ANTHROPIC_API_KEY` - API key
- `AUTO_START_CLAUDE` - Auto-start Claude in tmux on boot (default: false)
- `VIBECRAFT_PORT` - Server port (default: 4003)
- `VIBECRAFT_DEBUG` - Enable debug logging
- `DEEPGRAM_API_KEY` - Voice input (optional)

**Attach to tmux session:**
```bash
docker exec -it vibecraft tmux ls
docker exec -it vibecraft tmux attach -t vibecraft-abc123
# Detach: Ctrl+B, then D
```

**Inspect volumes:**
```bash
docker volume inspect vibecraft-data
docker run --rm -it -v vibecraft-data:/data alpine sh
```

---

**Issues**: https://github.com/anthropics/vibecraft/issues
