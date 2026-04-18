ARG NODE_VERSION=20

# ─── Build Stage ─────────────────────────────────────────────────────────────
FROM node:${NODE_VERSION}-alpine AS build
WORKDIR /app

# Enable corepack for yarn and pnpm support
RUN corepack enable

# Copy package.json and all possible lockfiles
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* .npmrc* ./

# Install dependencies based on which lockfile exists
RUN \
  if [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then pnpm install --frozen-lockfile; \
  else echo "Lockfile not found." && exit 1; \
  fi

# Copy the entire project
COPY . ./

# Build the project based on which lockfile exists
RUN \
  if [ -f yarn.lock ]; then yarn run build; \
  elif [ -f package-lock.json ]; then npm run build; \
  elif [ -f pnpm-lock.yaml ]; then pnpm run build; \
  else echo "Lockfile not found." && exit 1; \
  fi

# Detect Nuxt version and normalize output into /app/final_output
# Nuxt 3 → .output/   |   Nuxt 2 → .nuxt/ + node_modules
RUN \
  if [ -d ".output" ]; then \
    echo "nuxt3" > /tmp/NUXT_VERSION; \
    cp -r .output /app/final_output; \
  elif [ -d ".nuxt" ]; then \
    echo "nuxt2" > /tmp/NUXT_VERSION; \
    mkdir -p /app/final_output; \
    cp -r .nuxt /app/final_output/.nuxt; \
    cp -r node_modules /app/final_output/node_modules; \
    cp package.json /app/final_output/package.json; \
  else \
    echo "ERROR: Could not detect Nuxt build output." && exit 1; \
  fi

# ─── Production Stage ─────────────────────────────────────────────────────────
FROM node:${NODE_VERSION}-alpine
WORKDIR /app

# Copy normalized output from build stage
COPY --from=build /app/final_output ./
COPY --from=build /tmp/NUXT_VERSION /tmp/NUXT_VERSION

ENV PORT=8080
ENV HOST=0.0.0.0
EXPOSE 8080

# Start command differs between Nuxt versions:
#   Nuxt 3 → node server/index.mjs  (inside .output)
#   Nuxt 2 → node node_modules/.bin/nuxt start
CMD ["/bin/sh", "-c", "\
  NUXT_VERSION=$(cat /tmp/NUXT_VERSION); \
  if [ \"$NUXT_VERSION\" = \"nuxt3\" ]; then \
    exec node /app/server/index.mjs; \
  else \
    exec node /app/node_modules/.bin/nuxt start; \
  fi"]