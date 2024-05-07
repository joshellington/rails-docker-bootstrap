#!/bin/bash -e

# Usage: ./bootstrap.sh --name YOUR_APP_NAME -- --skip-system-tests

# Default value for $APP_NAME
APP_NAME="my_app"

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --name) APP_NAME="$2"; shift 2 ;;  # Shift by 2 to move past the argument value
        --) shift; break ;;  # End of script options, following are command options
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
done

# Step 0: Prompt and remove .git directory if it exists and is a git repository
echo "🟢 Cleaning .git directory..."
if [ -d ".git" ] && (cd .git && git rev-parse --git-dir > /dev/null 2>&1); then
    read -p "This will remove the existing .git directory, are you sure? (y/N) " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "Removing .git directory..."
        rm -rf ./.git
    else
        echo "Aborted by user."
        exit 1
    fi
else
    echo ".git directory not found or not a git repository."
fi

# Step 1: Build the Docker image
echo "🟢 Building Dockerfile.bootstrap..."
docker build -t $APP_NAME-rails-bootstrap -f Dockerfile.bootstrap .

# Step 2: Run the Rails new commands
echo "🟢 Running rails new..."
docker run --rm -v $(pwd):/rails $APP_NAME-rails-bootstrap rails new . --force --name=$APP_NAME --database=postgresql --javascript=esbuild --css=tailwind "$@"

# Step 3: Check for existing .env and COMPOSE_PROJECT_NAME variable, set .env
echo "🟢 Checking and updating .env COMPOSE_PROJECT_NAME..."
if [ -f ".env" ]; then
    if grep -q "^export COMPOSE_PROJECT_NAME=" .env; then
        echo ".env exists and COMPOSE_PROJECT_NAME is already set."
    else
        echo "Setting COMPOSE_PROJECT_NAME in existing .env."
        echo "export COMPOSE_PROJECT_NAME=$APP_NAME" >> .env
    fi
else
    echo "Copying .env.example to .env and setting COMPOSE_PROJECT_NAME."
    cp .env.example .env
    # Detect OS and apply correct sed command
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^export COMPOSE_PROJECT_NAME=.*$/export COMPOSE_PROJECT_NAME=$APP_NAME/" .env
    else
        sed -i "s/^export COMPOSE_PROJECT_NAME=.*$/export COMPOSE_PROJECT_NAME=$APP_NAME/" .env
    fi
fi

# Step 4: Update Procfile.dev
echo "🟢 Updating Procfile.dev..."
if [ -f "Procfile.dev" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' 's/^web: env RUBY_DEBUG_OPEN=true bin\/rails server$/web: env RUBY_DEBUG_OPEN=true bin\/rails server -b 0.0.0.0/' Procfile.dev
    else
        sed -i 's/^web: env RUBY_DEBUG_OPEN=true bin\/rails server$/web: env RUBY_DEBUG_OPEN=true bin\/rails server -b 0.0.0.0/' Procfile.dev
    fi
else
    echo "Procfile.dev not found."
fi

# Step 5: Cleanup Docker image
echo "🟢 Cleaning up bootstrap Docker image..."
docker rmi $APP_NAME-rails-bootstrap

echo "✅ $APP_NAME created successfully!"
