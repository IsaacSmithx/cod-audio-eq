param(
    [string]$RepoName = "cod-audio-eq",
    [ValidateSet("public", "private")]
    [string]$Visibility = "public"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI is not installed. Install it from https://cli.github.com/ and try again."
}

gh auth status | Out-Null

$description = "Call of Duty audio EQ and OBS streaming setup workspace for repeatable tuning, config notes, and cloud coding sessions."

gh repo create $RepoName `
    "--$Visibility" `
    --source . `
    --remote origin `
    --push `
    --description $description
