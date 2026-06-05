## Day 26 — GitHub CLI (gh)

### Install & Auth

```bash
sudo dnf install -y gh
gh auth login
gh auth status
```

### Key Commands

```bash
# Repos
gh repo create my-repo --public --add-readme
gh repo clone username/repo
gh repo list
gh repo view username/repo
gh repo view --web
gh repo delete my-repo --confirm

# Issues
gh issue create --title "Bug fix" --body "Details" --label bug
gh issue list
gh issue view 1
gh issue close 1

# Pull Requests
git checkout -b feature-test
git push origin feature-test
gh pr create --title "New feature" --body "Details" --base main
gh pr list
gh pr view 1
gh pr merge 1 --merge    # merge commit
gh pr merge 1 --squash   # squash
gh pr merge 1 --rebase   # rebase

# Workflow runs
gh run list
gh run view <RUN_ID>
gh run watch <RUN_ID>

# Other
gh api repos/owner/repo
gh gist create file.md --public
gh release create v1.0.0 --title "Release" --notes "Notes"
gh alias set prl 'pr list'
gh search repos devops --limit 5
```
