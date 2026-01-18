# Vibecraft Docker Setup

Run Vibecraft in a Docker container for isolated deployment.

## Quick Start

**With API Key:**
```bash
cd docker
cp .env.example .env
# Edit .env and set ANTHROPIC_API_KEY=sk-ant-api03-...
docker-compose up -d
open http://localhost:4003
```

**With Pro/Max Account:**
```bash
cd docker
docker-compose up -d
docker exec -it vibecraft claude auth login  # Opens browser for OAuth
open http://localhost:4003
```

## Usage

```bash
docker-compose up -d              # Start
docker-compose logs -f            # View logs
docker-compose down               # Stop
docker-compose down -v            # Stop and delete all data
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

**API key not working:**
```bash
# Verify key is set
docker exec vibecraft env | grep ANTHROPIC_API_KEY

# Check it's in .env file
cat .env | grep ANTHROPIC_API_KEY
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

**Check tmux is running:**
```bash
docker exec vibecraft tmux ls
```

**Manually spawn a session:**
```bash
docker exec -it vibecraft tmux new-session -s test -d
docker exec -it vibecraft tmux attach -t test
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
