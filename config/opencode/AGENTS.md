# AGENTS.md

## Environment Considerations

### Sudo Policy
**CRITICAL**: Never run commands requiring `sudo` directly in agent sessions. Instead:
- Output the command for manual execution
- Explain why sudo is needed
- Provide the exact command to run outside the session

Example:
```bash
# DON'T DO THIS:
sudo pacman -S package

# DO THIS INSTEAD:
echo "Run manually: sudo pacman -S package"
```

## Best Practices for Agents

For agents working on this system: Always respect the sudo policy. When in doubt, output commands for manual execution rather than attempting privileged operations.
