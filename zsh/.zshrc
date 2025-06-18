# Generic .zshrc that sources OS-specific configuration

# Detect OS and source appropriate config
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    source "$ZDOTDIR/.zshrc.mac"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    source "$ZDOTDIR/.zshrc.ubuntu"
else
    echo "⚠️  Unknown OS type: $OSTYPE"
    echo "Falling back to macOS config"
    source "$ZDOTDIR/.zshrc.mac"
fi