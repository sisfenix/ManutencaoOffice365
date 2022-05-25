# ----------------------------------------------------------------------
# RemoveSharedMailboxFromAllTeams.ps1 - Remove as caixas compartilhada
# de todos os as equipes do MS Teams
# Criado em: 25/05/2022
# Revisao: 00
# Copyright (c) 2022 by Alan Lopes
# ----------------------------------------------------------------------

# Inicia conexao com Azure Active Directory.
Connect-MsolService -Credential $var_credential

# Inicia conexao com Exchange Online
Connect-ExchangeOnline -Credential $var_credential -ShowProgress $true

# Inicia conexao com Teams
Connect-MicrosoftTeams -Credential $var_credential

# Lista todos as caixas de emails compartilhada (SharedMailbox)
$var_sharedmailbox = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize:Unlimited | select primarysmtpaddress

# Variaveis de controle
$var_count_total = ($var_sharedmailbox).Count
$var_count = 1

#Excluir caixa de email compartilhda das equipes do MS Teams
Foreach ($var_user in $var_sharedmailbox) {
    If ((Get-Team -User $var_user.primarysmtpaddress) -ne $null) {
        $teams = Get-Team -User $var_user.primarysmtpaddress
            foreach ($team in $teams){
                Remove-TeamUser -GroupId $team.GroupId -User $var_user.PrimarySmtpAddress
                Write-Output "$var_count/$var_count_total - $($var_user.PrimarySmtpAddress) is removed from team $($team.DisplayName)"
			}
        Write-Output "$var_count/$var_count_total - $($var_user.PrimarySmtpAddress) has been removed from $($teams.Count)"
	}else{
        Write-Output "$var_count/$var_count_total - $($var_user.PrimarySmtpAddress) is not member of a team"
	}
	$var_count++
}