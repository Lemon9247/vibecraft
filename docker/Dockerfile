# Vibecraft Docker Image
# Runs Vibecraft server with tmux for managing multiple Claude Code instances
#
# Environment variables:
#   ANTHROPIC_API_KEY - Claude API key for authentication
#   AUTO_START_CLAUDE - Set to 'true' to auto-start Claude in tmux on boot
#   VIBECRAFT_PORT    - Server port (default: 4003)
#
# Usage:
#   docker run -p 4003:4003 -e ANTHROPIC_API_KEY=your_key -e AUTO_START_CLAUDE=true vibecraft

FROM node:18-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    jq \
    curl \
    tmux \
    git \
    vim \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for running Vibecraft
RUN useradd -m -s /bin/bash vibecraft

# Switch to vibecraft user for Claude installation
USER vibecraft
WORKDIR /home/vibecraft

# Install Claude Code CLI as vibecraft user
# See: https://code.claude.com/docs/en/setup
RUN curl -fsSL https://claude.ai/install.sh | bash

# Add Claude to PATH for vibecraft user
ENV PATH="/home/vibecraft/.local/bin:${PATH}"

# Copy package files
COPY --chown=vibecraft:vibecraft package*.json ./

# Install all dependencies (needed for build)
RUN npm ci

# Copy source code
COPY --chown=vibecraft:vibecraft . .

# Build Vibecraft (both client and server)
RUN npm run build

# Remove dev dependencies to reduce image size
RUN npm prune --production

# Create data directories
RUN mkdir -p /home/vibecraft/.vibecraft/data \
             /home/vibecraft/.vibecraft/hooks \
             /home/vibecraft/.claude \
             /home/vibecraft/workspace

# Copy entrypoint and helper scripts from docker/ subdirectory
COPY --chown=vibecraft:vibecraft docker/docker-entrypoint.sh /home/vibecraft/docker-entrypoint.sh
COPY --chown=vibecraft:vibecraft docker/start-claude.sh /home/vibecraft/start-claude.sh
RUN chmod +x /home/vibecraft/docker-entrypoint.sh /home/vibecraft/start-claude.sh

# Set environment variables
ENV VIBECRAFT_PORT=4003 \
    VIBECRAFT_DATA_DIR=/home/vibecraft/.vibecraft/data \
    NODE_ENV=production \
    USER=vibecraft

# Expose Vibecraft server port
EXPOSE 4003

# Run entrypoint script
ENTRYPOINT ["/home/vibecraft/docker-entrypoint.sh"]
CMD []
