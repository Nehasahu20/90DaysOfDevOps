## Day 27 — GitHub Profile Makeover

### Profile README

```bash
gh repo create YOUR_USERNAME --public
git clone https://github.com/YOUR_USERNAME/YOUR_USERNAME.git
cd YOUR_USERNAME

cat > README.md << 'EOF'
# Hi, I'm [Your Name]

Learning DevOps — Linux | Git | Docker | Python | Shell Scripting
Currently: #90DaysOfDevOps challenge

## My Repos
- [90DaysOfDevOps](link)
- [shell-scripts](link)
- [devops-notes](link)

## Connect
- LinkedIn: your-link
EOF

git add README.md && git commit -m "add profile README" && git push origin main
```

### Organize Repos

```bash
gh repo create shell-scripts --public --description "Bash scripts from DevOps journey"
gh repo create python-scripts --public --description "Python projects"
gh repo create devops-notes --public --description "Cheat sheets and references"

# Check for secrets
git log -p | grep -i "password\|secret\|api_key\|token"
```
