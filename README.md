# BYOKEY Docker

自动打包 [AprilNEA/BYOKEY](https://github.com/AprilNEA/BYOKEY) 到 Docker 镜像。

当上游发布新 release 时，GitHub Actions 会自动检测并构建多平台 Docker 镜像推送到 Docker Hub。

## 功能

- **自动检测**: 每 30 分钟检查上游是否有新 release
- **多平台**: 同时构建 `linux/amd64` 和 `linux/arm64`
- **去重**: 已构建过的版本不会重复构建
- **手动触发**: 支持手动指定版本构建

## 快速开始

### Docker Compose (推荐)

```bash
docker compose up -d
```

### Docker Run

```bash
docker run -d \
  --name byokey \
  -p 8018:8018 \
  -v byokey-data:/data \
  aqrk/byokey-docker:latest
```

### 使用自定义配置

1. 创建 `settings.yaml`:

```yaml
port: 8018
host: 0.0.0.0

providers:
  claude:
    api_key: "sk-ant-..."
  codex:
    enabled: true
```

2. 挂载配置文件运行:

```bash
docker run -d \
  --name byokey \
  -p 8018:8018 \
  -v byokey-data:/data \
  -v ./settings.yaml:/data/settings.yaml:ro \
  aqrk/byokey-docker:latest \
  serve --host 0.0.0.0 --port 8018 --config /data/settings.yaml
```

## 认证

BYOKEY 需要先通过 OAuth 登录各个 Provider。在 Docker 中使用时，可以通过以下方式:

1. **API Key 直通** — 在 `settings.yaml` 中直接设置 API Key，跳过 OAuth
2. **本地登录后挂载** — 在本机运行 `byokey login` 后，将 `~/.byokey/` 目录挂载到容器中

## 手动构建

```bash
# 构建最新版
docker build --build-arg BYOKEY_VERSION=v0.9.2 -t byokey .

# 运行
docker run -d -p 8018:8018 -v byokey-data:/data byokey
```

## GitHub Actions

Workflow 会在以下情况触发:
- **定时**: 每 30 分钟检查上游新 release
- **手动**: 在 Actions 页面手动触发，可指定版本号，勾选 `force` 可强制覆盖已发布的同版本镜像

### 设置

1. Fork 本仓库
2. 确保 GitHub Actions 已启用
3. 在仓库 Settings → Secrets and variables → Actions 中添加：
   - `DOCKERHUB_USERNAME` — Docker Hub 用户名
   - `DOCKERHUB_TOKEN` — Docker Hub Access Token

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `BYOKEY_HOST` | `0.0.0.0` | 监听地址 |
| `BYOKEY_PORT` | `8018` | 监听端口 |

## License

MIT
