# 使用Python官方镜像作为基础镜像
FROM python:3.10-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV FLASK_ENV=production

# 安装系统依赖和Pandoc
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        pandoc \
        gcc \
        curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 复制 requirements.txt
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Create necessary directories
RUN mkdir -p output uploads pic

# Make start.sh script Docker-compatible by replacing 'open' command with 'echo' or conditional execution
RUN sed -i 's/open http:\/\/127.0.0.1:5000/# open command disabled in Docker environment/g' start.sh
RUN chmod +x start.sh

# 暴露端口
EXPOSE 5000

# 设置容器启动命令为使用start.sh
CMD ["./start.sh"]