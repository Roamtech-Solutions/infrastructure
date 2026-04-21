ARG NODE_VERSION=20
ARG APP_PORT=8080

FROM node:${NODE_VERSION}-alpine AS base
RUN apk add --no-cache libc6-compat dumb-init
RUN corepack enable


RUN addgroup --system --gid 1001 appgroup \
  && adduser --system --uid 1001 --ingroup appgroup appuser

WORKDIR /app
FROM base AS deps
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* .npmrc* ./

RUN \
  if [ -f yarn.lock ]; then \
    yarn install --frozen-lockfile; \
  elif [ -f package-lock.json ]; then \
    npm ci; \
  elif [ -f pnpm-lock.yaml ]; then \
    pnpm install --frozen-lockfile; \
  else \
    echo "ERROR: No lockfile found. Commit a lockfile to ensure reproducible builds." && exit 1; \
  fi


FROM base AS development
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Vite's default dev port
ENV PORT=5173
ENV HOST=0.0.0.0
ENV NODE_ENV=development
EXPOSE 5173
ENTRYPOINT ["dumb-init", "--"]

CMD \
  if [ -f yarn.lock ]; then \
    yarn dev --host; \
  elif [ -f package-lock.json ]; then \
    npm run dev -- --host; \
  elif [ -f pnpm-lock.yaml ]; then \
    pnpm dev --host; \
  else \
    echo "ERROR: No lockfile found." && exit 1; \
  fi


FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ARG VITE_APP_ENV=production
ENV VITE_APP_ENV=${VITE_APP_ENV}
ENV NODE_ENV=production

RUN \
  if [ -f yarn.lock ]; then \
    yarn build; \
  elif [ -f package-lock.json ]; then \
    npm run build; \
  elif [ -f pnpm-lock.yaml ]; then \
    pnpm build; \
  else \
    echo "ERROR: No lockfile found." && exit 1; \
  fi


FROM base AS production
ARG APP_PORT=8080

ENV PORT=${APP_PORT}
ENV HOST=0.0.0.0
ENV NODE_ENV=production


RUN npm install -g serve@14
COPY --from=builder /app/dist ./dist
USER appuser
EXPOSE ${APP_PORT}


HEALTHCHECK \
  --interval=30s \
  --timeout=5s \
  --start-period=10s \
  --retries=3 \
  CMD wget -qO- http://localhost:${PORT}/ || exit 1


ENTRYPOINT ["dumb-init", "--"]
CMD ["sh", "-c", "serve -s dist -l tcp://${HOST}:${PORT}"]
