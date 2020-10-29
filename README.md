# PS-Discord

PS-Discord is a lightweight PowerShell Module for invoking, and saving pre-set Discord Webhooks.

## Usage

```PowerShell
Import-Module .\PS-Discord.psm1

New-DiscordHook -Name "MyDiscordHook" -URL "<DiscordHookUrl>"
Invoke-DiscordHook -Name "MyDiscordHook" -Value "Hello, World!"
Invoke-DiscordHook -URL "<DiscordHookUrl>" -Value "Hello, World!"

```

## License
[MIT](https://choosealicense.com/licenses/mit/)