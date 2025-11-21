# 张飞吃豆芽 - 阿里云部署指南

## 项目概述

**张飞吃豆芽** (Zhang Fei Eats Bean Sprouts) 是一个基于Flask的AI驱动文章生成器，集成了Google Gemini API。支持批量生成、自动图像插入、自定义样式和直接Word文档输出。

## 阿里云服务器环境配置

### 1. 服务器准备

#### 选择ECS实例类型
- 推荐配置：2核CPU，4GB内存，40GB系统盘
- 操作系统：Ubuntu 22.04 LTS 或 CentOS 7+
- 安全组：开放80、443、5000端口

#### 创建安全组规则
- HTTP：端口80 （可选）
- HTTPS：端口443 （可选）
- 应用：端口5000 （必须）
- SSH：端口22 （调试用，建议限制IP访问）

### 2. 系统初始化

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装基础依赖
sudo apt install -y python3 python3-pip python3-venv git curl nginx supervisor
```

### 3. 安装Pandoc（必需）

```bash
# 安装Pandoc - 文档转换工具
sudo apt install -y pandoc

# 验证安装
pandoc --version
```

### 4. 安装Python依赖

```bash
# 检查Python版本（需要Python 3.8+）
python3 --version

# 安装pip（如果没有）
sudo apt install python3-pip -y
```

## 应用部署

### 1. 获取项目代码

```bash
# 创建应用目录
sudo mkdir -p /var/www/zhangfei-eat-douya
sudo chown ubuntu:ubuntu /var/www/zhangfei-eat-douya

# 切换到应用目录
cd /var/www/zhangfei-eat-douya

# 克隆项目（如果有代码仓库）
# git clone <repository-url> .
# 或者上传代码包后解压
```

### 2. 创建虚拟环境并安装依赖

```bash
# 创建虚拟环境
python3 -m venv venv

# 激活虚拟环境
source venv/bin/activate

# 升级pip
pip install --upgrade pip

# 安装项目依赖
pip install -r requirements.txt
```

### 3. 配置应用

#### 创建配置文件
```bash
# 复制配置模板并修改
cp config.example.json config.json

# 编辑配置文件
nano config.json
```

#### 配置文件参数说明
```json
{
  "aliyun_api_key": "YOUR_ALIYUN_API_KEY",           // 阿里云API密钥
  "aliyun_base_url": "https://dashscope.aliyuncs.com", // 阿里云API基础URL
  "unsplash_access_key": "YOUR_UNSPLASH_ACCESS_KEY", // Unsplash访问密钥（可选）
  "pexels_api_key": "YOUR_PEXELS_API_KEY",          // Pexels API密钥（可选）
  "pixabay_api_key": "YOUR_PIXABAY_API_KEY",        // Pixabay API密钥（可选）
  "default_model": "qwen-plus",                     // 默认模型
  "max_concurrent_tasks": 3,                        // 最大并发任务数
  "pandoc_path": "",                                // Pandoc路径（可选）
  "output_directory": "output",                     // 输出目录
  "image_source_priority": [                        // 图像源优先级
    "comfyui",
    "user_uploaded",
    "pexels",
    "unsplash",
    "pixabay",
    "local"
  ]
}
```

### 4. 创建应用目录结构

```bash
# 创建必要的目录
mkdir -p /var/www/zhangfei-eat-douya/output
mkdir -p /var/www/zhangfei-eat-douya/uploads
mkdir -p /var/www/zhangfei-eat-douya/pic
```

### 5. 配置Supervisor管理进程

创建supervisor配置文件：
```bash
sudo nano /etc/supervisor/conf.d/zhangfei-eat-douya.conf
```

配置内容：
```ini
[program:zhangfei-eat-douya]
command=/var/www/zhangfei-eat-douya/venv/bin/python /var/www/zhangfei-eat-douya/app.py
directory=/var/www/zhangfei-eat-douya
user=ubuntu
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/zhangfei-eat-douya.log
environment=PATH="/var/www/zhangfei-eat-douya/venv/bin"
```

重载Supervisor配置：
```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start zhangfei-eat-douya
```

## 6. 配置Nginx反向代理（可选）

创建网站配置：
```bash
sudo nano /etc/nginx/sites-available/zhangfei-eat-douya
```

配置内容：
```nginx
server {
    listen 80;
    server_name your-domain.com;  # 替换为您的域名

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # 静态文件缓存
    location /static {
        alias /var/www/zhangfei-eat-douya/static;
        expires 1d;
        add_header Cache-Control "public";
    }
}
```

启用网站配置：
```bash
sudo ln -s /etc/nginx/sites-available/zhangfei-eat-douya /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## SSL配置（推荐）

### 使用Let's Encrypt
```bash
# 安装Certbot
sudo apt install certbot python3-certbot-nginx -y

# 获取SSL证书
sudo certbot --nginx -d your-domain.com
```

## 防火墙配置

```bash
# 启用UFW防火墙
sudo ufw enable

# 允许必要端口
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw allow 5000

# 查看状态
sudo ufw status
```

## 运行时维护

### 日志管理
```bash
# 查看应用日志
sudo tail -f /var/log/zhangfei-eat-douya.log

# 查看Supervisor状态
sudo supervisorctl status zhangfei-eat-douya
```

### 应用重启
```bash
# 重启应用
sudo supervisorctl restart zhangfei-eat-douya

# 停止应用
sudo supervisorctl stop zhangfei-eat-douya

# 启动应用
sudo supervisorctl start zhangfei-eat-douya
```

## 备份策略

### 定期备份脚本
```bash
# 创建备份目录
sudo mkdir -p /var/backups/zhangfei-eat-douya

# 创建备份脚本
sudo nano /usr/local/bin/backup-zhangfei.sh
```

备份脚本内容：
```bash
#!/bin/bash
BACKUP_DIR="/var/backups/zhangfei-eat-douya"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="zhangfei_backup_$DATE.tar.gz"

# 停止应用
sudo supervisorctl stop zhangfei-eat-douya

# 备份配置和数据
tar -czf $BACKUP_DIR/$BACKUP_NAME \
  -C /var/www/zhangfei-eat-douya \
  config.json output uploads

# 重启应用
sudo supervisorctl start zhangfei-eat-douya

# 清理30天前的备份
find $BACKUP_DIR -type f -mtime +30 -delete
```

设置执行权限并定时执行：
```bash
sudo chmod +x /usr/local/bin/backup-zhangfei.sh

# 添加到crontab（每天凌晨2点执行）
sudo crontab -e
# 添加以下行
0 2 * * * /usr/local/bin/backup-zhangfei.sh
```

## 健康检查和监控

### 确认应用状态
```bash
# 检查端口监听
sudo netstat -tlnp | grep 5000

# 检查应用是否正在运行
ps aux | grep python | grep zhangfei
```

### 性能监控
```bash
# 安装htop
sudo apt install htop -y

# 查看系统资源使用情况
htop
```

## 故障排除

### 常见问题及解决方案

1. **端口被占用**: 确认5000端口是否被其他应用占用
   ```bash
   sudo netstat -tlnp | grep 5000
   ```

2. **权限问题**: 确认应用目录权限正确
   ```bash
   sudo chown -R ubuntu:ubuntu /var/www/zhangfei-eat-douya
   ```

3. **API Key问题**: 确认config.json中的API Key配置正确

4. **Pandoc未安装**: 确认Pandoc已安装
   ```bash
   pandoc --version
   ```

### 应用启动测试
```bash
# 进入应用目录
cd /var/www/zhangfei-eat-douya
source venv/bin/activate

# 临时启动测试
python app.py
```

## 安全建议

1. **API Key安全**: 不要在代码中硬编码API Key，使用环境变量或配置文件
2. **访问控制**: 限制服务器访问IP，使用SSH密钥登录
3. **定期更新**: 定期更新系统和Python包
4. **备份**: 定期备份配置文件和重要数据
5. **监控**: 设置应用监控和告警