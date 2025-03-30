#!/bin/bash

# Exit on error
set -e

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "\e[${color}m${message}\e[0m"
}

# Function to check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_status "31" "Error: AWS CLI is not installed. Please install it first."
        exit 1
    fi
}

# Function to check if AWS credentials are configured
check_aws_credentials() {
    if ! aws sts get-caller-identity &> /dev/null; then
        print_status "31" "Error: AWS credentials are not configured. Please configure them first."
        exit 1
    fi
}

# Function to get stack status
get_stack_status() {
    local stack_name=$1
    aws cloudformation describe-stacks --stack-name "$stack_name" --query 'Stacks[0].StackStatus' --output text
}

# Function to wait for stack creation/update
wait_for_stack() {
    local stack_name=$1
    local status
    local dots=""
    
    print_status "33" "Waiting for stack creation/update to complete"
    while true; do
        status=$(get_stack_status "$stack_name")
        if [[ "$status" == "CREATE_COMPLETE" || "$status" == "UPDATE_COMPLETE" ]]; then
            print_status "32" "\nStack operation completed successfully!"
            return 0
        elif [[ "$status" == "CREATE_FAILED" || "$status" == "UPDATE_FAILED" || "$status" == "ROLLBACK_COMPLETE" ]]; then
            print_status "31" "\nStack operation failed!"
            return 1
        fi
        
        # Show progress dots
        dots="${dots}."
        if [ ${#dots} -gt 3 ]; then
            dots=""
        fi
        echo -ne "\r\033[KWaiting for stack operation to complete${dots}"
        sleep 10
    done
}

# Main script
main() {
    # Check prerequisites
    check_aws_cli
    check_aws_credentials

    # Get parameters from user
    read -p "Enter environment name (default: turnstile): " environment_name
    environment_name=${environment_name:-turnstile}
    
    # Construct stack name
    stack_name="${environment_name}-network"

    # Check if stack exists
    if aws cloudformation describe-stacks --stack-name "$stack_name" &> /dev/null; then
        print_status "33" "Stack '$stack_name' already exists. Updating..."
        operation="update"
    else
        print_status "33" "Creating new stack '$stack_name'..."
        operation="create"
    fi

    # Deploy the stack
    print_status "33" "Deploying stack..."
    if aws cloudformation deploy \
        --template-file network.yaml \
        --stack-name "$stack_name" \
        --parameter-overrides "EnvironmentName=$environment_name" \
        --capabilities CAPABILITY_IAM; then
        
        # Wait for stack operation to complete
        if wait_for_stack "$stack_name"; then
            # Get stack outputs
            print_status "32" "\nStack outputs:"
            aws cloudformation describe-stacks \
                --stack-name "$stack_name" \
                --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' \
                --output table
        else
            # Get stack events for debugging
            print_status "31" "\nStack events:"
            aws cloudformation describe-stack-events \
                --stack-name "$stack_name" \
                --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`||ResourceStatus==`UPDATE_FAILED`].[LogicalResourceId,ResourceStatus,ResourceStatusReason]' \
                --output table
        fi
    else
        print_status "31" "Failed to deploy stack"
        exit 1
    fi
}

# Run main function
main 