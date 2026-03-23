FROM nginx:alpine

# Копируем все файлы приложения в директорию Nginx для статических файлов
COPY . /usr/share/nginx/html/

# Открываем порт 80
EXPOSE 80

# Запускаем Nginx
CMD ["nginx", "-g", "daemon off;"]