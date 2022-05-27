# -------------------------------------------------------------------
# RemoveDisabledMailboxFromAllTeams.ps1 - Remove as caixas de e-mail 
# desabilitadas de todos as equipes do MS Teams
# Criado em: 27/05/2022
# Revisao: 00
# Copyright (c) 2022 by Alan Lopes
# -------------------------------------------------------------------

# Inicia conexao com Azure Active Directory.
Connect-MsolService -Credential $var_credential

# Inicia conexao com Exchange Online
Connect-ExchangeOnline -Credential $var_credential -ShowProgress $true

# Inicia conexao com Teams
Connect-MicrosoftTeams -Credential $var_credential

# Lista todos as caixas de emails compartilhada (SharedMailbox)
$var_mailbox = Get-MsolUser -All | Where {$_.BlockCredential -eq $True} | Select UserPrincipalName

# Variaveis de controle
$var_count_total = ($var_mailbox).Count
$var_count = 1

#Excluir caixa de email compartilhda das equipes do MS Teams
Foreach ($var_user in $var_mailbox) {
    If ((Get-Team -User $var_user.UserPrincipalName) -ne $null) {
        $teams = Get-Team -User $var_user.UserPrincipalName
            foreach ($team in $teams){
                Remove-TeamUser -GroupId $team.GroupId -User $var_user.UserPrincipalName
                Write-Output "$var_count/$var_count_total - $($var_user.UserPrincipalName) is removed from team $($team.DisplayName)"
			}
        Write-Output "$var_count/$var_count_total - $($var_user.UserPrincipalName) has been removed from $($teams.Count)"
	}else{
        Write-Output "$var_count/$var_count_total - $($var_user.UserPrincipalName) is not member of a team"
	}
	$var_count++
}
