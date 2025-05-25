# Stage 1: Build
FROM node:18-alpine AS builder

WORKDIR /app

# Копируем package.json и package-lock.json (если есть)
COPY package*.json ./

# Устанавливаем зависимости с флагом, чтобы избежать конфликтов
RUN npm install --legacy-peer-deps

# Копируем весь код
COPY . .

# Собираем проект
RUN npm run build

# Stage 2: Production
FROM node:18-alpine

WORKDIR /app

# Копируем из билд-стейджа необходимые файлы и папки
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.js ./

# Настройки окружения
ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

# Запуск сервера
CMD ["npm", "start"]
