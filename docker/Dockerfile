# Vibecraft Docker Image
# Runs Vibecraft server with tmux for managing multiple Claude Code instances

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

# Install Claude Code CLI using official installer
# See: https://code.claude.com/docs/en/setup
RUN curl -fsSL https://claude.ai/install.sh | bash

# Add Claude to system PATH (installer puts it in /root/.local/bin)
ENV PATH="/root/.local/bin:${PATH}"

# Create non-root user for running Vibecraft
RUN useradd -m -s /bin/bash vibecraft

# Switch to vibecraft user
USER vibecraft
WORKDIR /home/vibecraft

# Copy package files
COPY --chown=vibecraft:vibecraft package*.json ./

# Install dependencies (production only)
RUN npm ci --omit=dev

# Copy source code
COPY --chown=vibecraft:vibecraft . .

# Build Vibecraft (both client and server)
RUN npm run build

# Create data directories
RUN mkdir -p /home/vibecraft/.vibecraft/data \
             /home/vibecraft/.vibecraft/hooks \
             /home/vibecraft/.claude

# Copy entrypoint script from docker/ subdirectory
COPY --chown=vibecraft:vibecraft docker/docker-entrypoint.sh /home/vibecraft/docker-entrypoint.sh
RUN chmod +x /home/vibecraft/docker-entrypoint.sh

# Set environment variables
ENV VIBECRAFT_PORT=4003 \
    VIBECRAFT_DATA_DIR=/home/vibecraft/.vibecraft/data \
    NODE_ENV=production

# Expose Vibecraft server port
EXPOSE 4003

# Run entrypoint script
ENTRYPOINT ["/home/vibecraft/docker-entrypoint.sh"]
CMD []
