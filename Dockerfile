# This dockerfile and the associated .dockerignore was adapted from https://pnpm.io/docker
# Some SvelteKit specific changes had to be made
FROM node:20-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
COPY . /app
WORKDIR /app

FROM base AS prod-deps
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile

FROM base AS build
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm run build

# IIUC, this is where we define the actual container that runs the code; the other two that also extend base (via FROM base ...) are just for building
FROM base

# copy the prod dependencies and the build output
COPY --from=prod-deps /app/node_modules /app/node_modules
COPY --from=build /app/build /app/build

# run in production mode
ENV NODE_ENV=production

# per default, built SvelteKit runs on port 3000, hence this port should be exposed to the host when running the container
EXPOSE 3000

# run the built app
CMD [ "pnpm", "serve" ]