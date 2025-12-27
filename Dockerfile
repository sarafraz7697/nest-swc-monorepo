FROM node:20.11.0-alpine AS base

RUN npm i -g pnpm

FROM base AS dependencies

WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install

FROM dependencies AS development

WORKDIR /app
COPY . .

RUN pnpm build

FROM development AS build

WORKDIR /app
COPY . .

RUN pnpm prune --prod

FROM base AS deploy

WORKDIR /app
COPY --from=build /app/dist/ ./dist/
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/client ./dist/client
COPY --from=build /app/public ./dist/public
ENV NODE_ENV=production

WORKDIR /app/dist
CMD [ "node", "apps/api/main" ]
