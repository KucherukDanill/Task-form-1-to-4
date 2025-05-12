# CI/CD Pipeline для Nginx приложения

Этот проект содержит CI/CD пайплайна для сборки и доставки Nginx приложения с использованием GitHub Actions.

## Результат 

![изображение](https://github.com/user-attachments/assets/7a30da26-ee2c-46e8-84d2-bfc2e0597f53)


CI:
![изображение](https://github.com/user-attachments/assets/cc27daaf-561a-4d86-a6cf-05f93b730563)

CD:
![изображение](https://github.com/user-attachments/assets/dd8ef4a5-ee0b-4d60-813f-38ce9bcfb2db)



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
[github_cicd.txt](https://github.com/user-attachments/files/20154474/github_cicd.txt)

## Сам пайалайн

```yaml
name: Docker CI/CD Pipeline with Docker Compose

on:
  push:[github_cicd.txt](https://github.com/user-attachments/files/20154483/github_cicd.txt)

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
          DOCKER_USERNAME=${{ secrets.DOCKER_HUB_USERNAME }}
          DOCKER_IMAGE=${{ env.DOCKER_IMAGE }}
          VERSION=${{ env.VERSION }}
          
          IMAGE_FULL_NAME=${DOCKER_USERNAME}/${DOCKER_IMAGE}
          
          echo "Собираем образ: ${IMAGE_FULL_NAME}:${VERSION}"
          
          docker build -t "${IMAGE_FULL_NAME}:${VERSION}" -t "${IMAGE_FULL_NAME}:latest" .
          
          docker push "${IMAGE_FULL_NAME}:${VERSION}"
          docker push "${IMAGE_FULL_NAME}:latest"
          
          echo "DEPLOY_VERSION=${IMAGE_FULL_NAME}:${VERSION}" >> $GITHUB_ENV

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
          
          echo "DOCKER_USERNAME: $DOCKER_USERNAME"
          echo "DOCKER_IMAGE: $DOCKER_IMAGE"
          echo "DOCKER_TAG: $DOCKER_TAG"
          
          docker-compose down
          docker-compose up -d
          docker-compose ps

      - name: Verify Deployment
        run: |
          sleep 10
          curl -k http://localhost:80 || echo "Service may need more time to start"
```
