ARG NODE_VERSION=22

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

# Production Stage
FROM node:${NODE_VERSION}-alpine
WORKDIR /app

# Only `.output` folder is needed from the build stage
COPY --from=build /app/.output/ ./

# Change the port and host
ENV PORT=8080
ENV HOST=0.0.0.0
EXPOSE 8080

CMD ["node", "/app/server/index.mjs"]