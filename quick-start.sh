#!/bin/bash

# Sui Campus Todo System - Quick Reference
# =========================================

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Sui Campus Todo System - Quick Start ===${NC}\n"

# Check if sui is installed
if ! command -v sui &> /dev/null; then
    echo -e "${YELLOW}Sui CLI not found. Please install it first.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Sui CLI found${NC}"
echo -e "${BLUE}Active Network:${NC} $(sui client active-env)"
echo -e "${BLUE}Active Address:${NC} $(sui client active-address)"
echo ""

# Function to display menu
show_menu() {
    echo "What would you like to do?"
    echo ""
    echo "1) Build the contracts"
    echo "2) Publish to devnet"
    echo "3) Register a new student"
    echo "4) Create a todo list"
    echo "5) Add a todo item"
    echo "6) Mark item as done"
    echo "7) View my objects"
    echo "8) Request gas from faucet"
    echo "9) Show documentation"
    echo "0) Exit"
    echo ""
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice [0-9]: " choice
    
    case $choice in
        1)
            echo -e "\n${BLUE}Building contracts...${NC}"
            cd contracts/object_registry
            sui move build
            cd ../..
            ;;
        2)
            echo -e "\n${BLUE}Publishing to devnet...${NC}"
            echo -e "${YELLOW}Make sure you have enough gas!${NC}"
            cd contracts/object_registry
            sui client publish --gas-budget 100000000
            cd ../..
            echo -e "\n${GREEN}Remember to save the Package ID and Registry ID!${NC}"
            ;;
        3)
            echo -e "\n${BLUE}Registering a new student...${NC}"
            read -p "Enter Package ID: " pkg_id
            read -p "Enter Registry Object ID: " reg_id
            read -p "Enter student name: " name
            read -p "Enter department: " dept
            read -p "Enter registration number: " regnum
            
            sui client call \
                --package "$pkg_id" \
                --module campus_registry \
                --function register \
                --args "$reg_id" "$name" "$dept" "$regnum" \
                --gas-budget 10000000
            
            echo -e "\n${GREEN}Check your objects to find your RegistrationBadge!${NC}"
            ;;
        4)
            echo -e "\n${BLUE}Creating a todo list...${NC}"
            read -p "Enter Package ID: " pkg_id
            read -p "Enter your RegistrationBadge Object ID: " badge_id
            
            sui client call \
                --package "$pkg_id" \
                --module todo_list \
                --function create_list \
                --args "$badge_id" \
                --gas-budget 10000000
            
            echo -e "\n${GREEN}Check your objects to find your TodoList!${NC}"
            ;;
        5)
            echo -e "\n${BLUE}Adding a todo item...${NC}"
            read -p "Enter Package ID: " pkg_id
            read -p "Enter your TodoList Object ID: " list_id
            read -p "Enter task description: " desc
            
            sui client call \
                --package "$pkg_id" \
                --module todo_list \
                --function add_item \
                --args "$list_id" "$desc" \
                --gas-budget 10000000
            ;;
        6)
            echo -e "\n${BLUE}Marking item as done...${NC}"
            read -p "Enter Package ID: " pkg_id
            read -p "Enter your TodoList Object ID: " list_id
            read -p "Enter item ID (0 for first item): " item_id
            
            sui client call \
                --package "$pkg_id" \
                --module todo_list \
                --function mark_done \
                --args "$list_id" "$item_id" \
                --gas-budget 10000000
            ;;
        7)
            echo -e "\n${BLUE}Your objects:${NC}"
            sui client objects
            ;;
        8)
            echo -e "\n${BLUE}Requesting gas from faucet...${NC}"
            sui client faucet
            ;;
        9)
            echo -e "\n${BLUE}=== Documentation ===${NC}"
            echo ""
            echo "README.md         - Project overview"
            echo "DEPLOYMENT.md     - Detailed deployment guide"
            echo "ARCHITECTURE.md   - System architecture"
            echo "SUMMARY.md        - Quick summary"
            echo ""
            echo "View any file with: cat contracts/object_registry/<filename>"
            ;;
        0)
            echo -e "\n${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "\n${YELLOW}Invalid choice. Please try again.${NC}\n"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
    echo ""
done
