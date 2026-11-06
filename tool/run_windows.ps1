param(
  [string]$EnvFile = ".env"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $EnvFile)) {
  throw "Missing $EnvFile. Copy .env.example to .env and fill in the Supabase values."
}

$values = @{}
Get-Content -LiteralPath $EnvFile | ForEach-Object {
  $line = $_.Trim()
  if ($line -and -not $line.StartsWith("#")) {
    $parts = $line -split "=", 2
    if ($parts.Count -eq 2) {
      $values[$parts[0].Trim()] = $parts[1].Trim().Trim('"').Trim("'")
    }
  }
}

foreach ($required in @("NEWCARE_CLOUD", "SUPABASE_URL", "SUPABASE_PUBLISHABLE_KEY")) {
  if (-not $values.ContainsKey($required) -or [string]::IsNullOrWhiteSpace($values[$required])) {
    throw "Missing $required in $EnvFile."
  }
}

flutter run -d windows `
  "--dart-define=NEWCARE_CLOUD=$($values.NEWCARE_CLOUD)" `
  "--dart-define=SUPABASE_URL=$($values.SUPABASE_URL)" `
  "--dart-define=SUPABASE_PUBLISHABLE_KEY=$($values.SUPABASE_PUBLISHABLE_KEY)"
