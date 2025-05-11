# CI/CD Pipeline для Nginx приложения

Этот проект содержит CI/CD пайплайна для сборки и доставки Nginx приложения с использованием Docker и Docker Compose.

## Результат 



## Лог 



## CI/CD Пайплайн

Пайплайн состоит из двух основных этапов:

### 1. Этап сборки (CI)

- Checkout кода из репозитория
- Настройка Docker Buildx
- Авторизация в Docker Hub (используя секреты GitHub DOCKER_HUB_USERNAME и DOCKER_HUB_PASSWORD)
- Генерация версионного тега (на основе даты и хеша коммита)
- Сборка Docker образа
- Публикация образа в Docker Hub с тегами latest и версионным

### 2. Этап доставки (CD)

- Установка Docker Compose
- Передача переменных окружения (DOCKER_USERNAME, DOCKER_IMAGE, DOCKER_TAG)
- Остановка предыдущей версии контейнера (docker-compose down)
- Запуск новой версии контейнера (docker-compose up -d)
- Проверка статуса деплоя

## Сам пайалайн

```yaml
name: Docker CI/CD Pipeline with Docker Compose

on:
  push:
    branches: ["master"]
  pull_request:
    branches: ["master"]
  workflow_dispatch:

env:
  DOCKER_IMAGE: nginx-server 

jobs:
  build:
    name: CI - Build Docker Image
    runs-on: ubuntu-latest
    outputs:
      image_version: ${{ steps.version.outputs.version }}
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_HUB_USERNAME }}
          password: ${{ secrets.DOCKER_HUB_PASSWORD }}

      - name: Generate version tag
        id: version
        run: |
          VERSION=$(date +%Y%m%d%H%M%S)-${GITHUB_SHA::8}
          echo "version=$VERSION" >> $GITHUB_OUTPUT
          echo "VERSION=$VERSION" >> $GITHUB_ENV
          echo "Generated version: $VERSION"

      - name: Build and push Docker image
        run: |
          IMAGE_FULL_NAME=${{ secrets.DOCKER_HUB_USERNAME }}/${{ env.DOCKER_IMAGE }}
          docker build -t $IMAGE_FULL_NAME:${{ env.VERSION }} -t $IMAGE_FULL_NAME:latest .
          docker push $IMAGE_FULL_NAME:${{ env.VERSION }}
          docker push $IMAGE_FULL_NAME:latest
          echo "DEPLOY_VERSION=$IMAGE_FULL_NAME:${{ env.VERSION }}" >> $GITHUB_ENV

  deploy:
    name: CD - Deploy Application
    needs: build
    runs-on: ubuntu-latest
    env:
      DEPLOY_IMAGE: ${{ needs.build.outputs.image_version }}
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Docker
        run: |
          sudo apt-get update
          sudo apt-get install -y docker-compose
          docker --version

      - name: Deploy with Docker Compose
        run: |
          echo "=== Deploying $DEPLOY_IMAGE ==="
          export DOCKER_USERNAME=${{ secrets.DOCKER_HUB_USERNAME }}
          export DOCKER_IMAGE=${{ env.DOCKER_IMAGE }}
          export DOCKER_TAG=${DEPLOY_IMAGE##*:}  
          
          docker-compose down
          docker-compose up -d
          docker-compose ps

      - name: Verify Deployment
        run: |
          sleep 10
          curl -k http://localhost:80 || echo "Service may need more time to start"
```