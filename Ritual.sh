#!/bin/bash


# 脚本保存路径
SCRIPT_PATH="$HOME/Ritual.sh"

# 自动设置快捷键的功能
function check_and_set_alias() {
    local alias_name="rit"
    local shell_rc="$HOME/.bashrc"

    # 对于Zsh用户，使用.zshrc
    if [ -n "$ZSH_VERSION" ]; then
        shell_rc="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        shell_rc="$HOME/.bashrc"
    fi

    # 检查快捷键是否已经设置
    if ! grep -q "$alias_name" "$shell_rc"; then
        echo "设置快捷键 '$alias_name' 到 $shell_rc"
        echo "alias $alias_name='bash $SCRIPT_PATH'" >> "$shell_rc"
        # 添加提醒用户激活快捷键的信息
        echo "快捷键 '$alias_name' 已设置。请运行 'source $shell_rc' 来激活快捷键，或重新打开终端。"
    else
        # 如果快捷键已经设置，提供一个提示信息
        echo "快捷键 '$alias_name' 已经设置在 $shell_rc。"
        echo "如果快捷键不起作用，请尝试运行 'source $shell_rc' 或重新打开终端。"
    fi
}

# 节点安装功能
function install_node() {

# 更新系统包列表
sudo apt update

# 检查 Git 是否已安装
if ! command -v git &> /dev/null
then
    # 如果 Git 未安装，则进行安装
    echo "未检测到 Git，正在安装..."
    sudo apt install git -y
else
    # 如果 Git 已安装，则不做任何操作
    echo "Git 已安装。"
fi

# 克隆 ritual-net 仓库
git clone https://github.com/ritual-net/infernet-deploy

# 进入 infernet-deploy 目录
cd infernet-deploy/deploy

# 提示用户输入rpc_url
read -p "输入Base 主网Https RPC: " rpc_url

# 提示用户输入private_key
read -p "输入EVM 钱包私钥，必须是0x开头，建议使用新钱包: " private_key

# 提示用户输入设置端口
read -p "输入端口: " port1

# 使用cat命令将配置写入config.json
cat > config.json <<EOF
{
  "log_path": "infernet_node.log",
  "server": {
    "port": $port1
  },
  "chain": {
    "enabled": true,
    "trail_head_blocks": 5,
    "rpc_url": "$rpc_url",
    "coordinator_address": "0x8D871Ef2826ac9001fB2e33fDD6379b6aaBF449c",
    "wallet": {
      "max_gas_limit": 5000000,
      "private_key": "$private_key"
    }
  },
  "docker": {
    "username": "",
    "password": ""
  },
  "redis": {
    "host": "redis",
    "port": 6379
  },
  "forward_stats": true,
  "startup_wait": 1.0,
  "containers": [
    {
      "id": "service-1",
      "image": "org1/image1:tag1",
      "description": "Container 1 description",
      "external": true,
      "port": "4999",
      "allowed_ips": ["XX.XX.XX.XXX", "XX.XX.XX.XXX"],
      "allowed_addresses": [""],
      "allowed_delegate_addresses": [""],
      "command": "--bind=0.0.0.0:3000 --workers=2",
      "env": {
        "KEY1": "VALUE1",
        "KEY2": "VALUE2"
      },
      "gpu": true
    },
    {
      "id": "service-2",
      "image": "org2/image2:tag2",
      "description": "Container 2 description",
      "external": false,
      "port": "4998",
      "allowed_ips": ["XX.XX.XX.XXX", "XX.XX.XX.XXX"],
      "allowed_addresses": ["0x..."],
      "allowed_delegate_addresses": ["0x..."],
      "command": "--bind=0.0.0.0:3000 --workers=2",
      "env": {
        "KEY3": "VALUE3",
        "KEY4": "VALUE4"
      }
    }
  ]
}
EOF

echo "Config 文件设置完成"


# 安装基本组件
sudo apt install pkg-config curl build-essential libssl-dev libclang-dev -y

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null
then
    # 如果 Docker 未安装，则进行安装
    echo "未检测到 Docker，正在安装..."
    sudo apt-get install ca-certificates curl gnupg lsb-release

    # 添加 Docker 官方 GPG 密钥
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # 设置 Docker 仓库
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # 授权 Docker 文件
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    sudo apt-get update

    # 安装 Docker 最新版本
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y 
else
    echo "Docker 已安装。"
fi


# 启动容器
docker compose up

echo "=========================安装完成======================================"
echo "请使用cd infernet-deploy/deploy 进入目录后，再使用docker compose logs -f 查询日志 "

}

# 查看节点日志
function check_service_status() {
    cd infernet-deploy/deploy
    docker compose logs -f
}



# 主菜单
function main_menu() {
    clear
    echo "pangdong @shexiaodong "
    echo "================================================================"
    echo "请选择要执行的操作:"
    echo "1. 安装节点"
    echo "2. 查看节点日志"
    echo "3. 设置快捷键的功能"
    read -p "请输入选项（1-3）: " OPTION

    case $OPTION in
    1) install_node ;;
    2) check_service_status ;;
    3) check_and_set_alias ;;  
    *) echo "无效选项。" ;;
    esac
}

# 显示主菜单
main_menu
