#!/bin/bash

BASE_DIR="/opt/remnanode"

check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "Docker is not installed. Installing Docker..."
        sudo curl -fsSL https://get.docker.com | sh
    else
        echo "Docker is already installed."
    fi
}

install_node() {
    check_docker

    mkdir -p "$BASE_DIR"
    cd "$BASE_DIR" || exit

    read -p "Enter the project path (e.g. /opt/remnanode/example): " NODE_PATH

    if [ -z "$NODE_PATH" ]; then
        echo "Path cannot be empty!"
        return
    fi

    if [ -d "$NODE_PATH" ]; then
        echo "This path already exists!"
        read -p "Do you want to continue anyway? (y/n): " CONFIRM
        if [ "$CONFIRM" != "y" ]; then
            return
        fi
    fi

    mkdir -p "$NODE_PATH"
    cd "$NODE_PATH" || return

    nano docker-compose.yml

    if [ ! -s docker-compose.yml ]; then
        echo "docker-compose.yml is empty. Aborting."
        return
    fi

    echo "Starting the node..."
    docker compose up -d && docker compose logs -f -t
}

remove_node() {
    read -p "Enter the node path to remove (e.g. /opt/remnanode/example): " NODE_PATH

    if [ ! -d "$NODE_PATH" ]; then
        echo "Path not found!"
        return
    fi

    cd "$NODE_PATH" || return
    docker compose down
    cd "$BASE_DIR" || return
    rm -rf "$NODE_PATH"
    echo "Node removed successfully."
}

update_node() {
    read -p "Enter the node path to update (e.g. /opt/remnanode/example): " NODE_PATH

    if [ ! -d "$NODE_PATH" ]; then
        echo "Path not found!"
        return
    fi

    cd "$NODE_PATH" || return
    docker compose down
    docker compose up -d
    echo "Node updated successfully."
}

list_nodes() {
    if [ ! -d "$BASE_DIR" ]; then
        echo "No nodes directory found at $BASE_DIR"
        return
    fi

    echo "Installed nodes:"
    ls -1 "$BASE_DIR" 2>/dev/null
}

show_menu() {
    echo ""
    echo "===== Node Manager ====="
    echo "1) Install Node"
    echo "2) Remove Node"
    echo "3) Update Node"
    echo "4) List Nodes"
    echo "0) Exit"
    echo "========================="
}

while true; do
    show_menu
    read -p "Select an option [1-5]: " CHOICE

    case $CHOICE in
        1) install_node ;;
        2) remove_node ;;
        3) update_node ;;
        4) list_nodes ;;
        0) echo "Bye!"; exit 0 ;;
        *) echo "Invalid option!" ;;
    esac
done
