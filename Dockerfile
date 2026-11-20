# 1단계: Rust -> WebAssembly 빌드
FROM rust:latest AS wasm-builder
RUN rustup target add wasm32-unknown-unknown \
    && cargo install wasm-pack@0.15.0
WORKDIR /app
COPY src /app
RUN sh scripts/wasm-pack-locked.sh --target web

# 2단계: rhwp-studio 웹 프론트엔드 빌드
FROM node:20-alpine AS web-builder
WORKDIR /app
COPY --from=wasm-builder /app /app
WORKDIR /app/rhwp-studio
RUN (npm ci || npm install) && npm run build

# 3단계: 가벼운 Nginx 웹 서버에 결과물만 복사
FROM nginx:alpine
COPY --from=web-builder /app/rhwp-studio/dist /usr/share/nginx/html
EXPOSE 80
