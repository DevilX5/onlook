# Build Onlook web client
FROM oven/bun:1
WORKDIR /app

# Set build and production environment
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV STANDALONE_BUILD=true
ENV HOSTNAME=0.0.0.0
ENV PORT=3000

# 跳过 t3-env 的环境变量校验
ENV SKIP_ENV_VALIDATION=true

# 提供 NEXT_PUBLIC_* 构建时占位值（运行时可以覆盖）
ENV NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
ENV NEXT_PUBLIC_SUPABASE_ANON_KEY=placeholder
ENV CSB_API_KEY=placeholder
ENV SUPABASE_DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres
ENV SUPABASE_SERVICE_ROLE_KEY=placeholder
ENV OPENROUTER_API_KEY=placeholder

# Copy everything (monorepo structure)
COPY . .

# Install dependencies and build
RUN bun install
RUN cd apps/web/client && bun run build:standalone

# Expose the application port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD bun -e "fetch('http://localhost:3000').then(r => r.ok ? process.exit(0) : process.exit(1)).catch(() => process.exit(1))"

# Start the Next.js server
CMD ["bun", "apps/web/client/server.js"]
