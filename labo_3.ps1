#4.1)
#1ère possibilité
$PrefixLog = "PsLog" #préfixe ou vont se trouver mes logs
function RevertWord {
    param ( [string] $word)

    $charArrayWord = $word.ToCharArray()

    [array]::Reverse($charArrayWord) #[array]:: = méthode statique sur tableau pour un mot

    return -join ($charArrayWord) #return ensemble tableau sous forme d'un string
}

function RevertString {
    param ( [string] $stringToInvert)

    $InvertedString = @() #contient tout mot inversés sous fome tableau
    $stringToInvert.Split() | ForEach-Object {
        $InvertedString += RevertWord($_) #$_ = éléments courants (chaque élem de la boucle foreach)
    }
    return $InvertedString -join(" ")
}
#4.2)
function Menu {
    Write-Host """Voici les options possible: 
    1) Inverser une phrase
    2) Ajouter des clés de registre
    3) Fermer le programme """
}
function GetChoiceMenu{
    $choice = ""
    do
    {
    Menu
    $choice = Read-Host -prompt "Que voulez-vous?"

    }while ($choice -lt 1 -or $choice -gt 3)
    return $choice
}

function Write-Log{
    param(
    [Parameter(Mandatory=$true, valueFromPipeline=$true,Position=0)][string] $toLog, #rend param obligatoire
    [Parameter(Position=1)][validateSet("Debug","Info","Warning","Error","Critical")][string] $LogLevel= "Info"
    )

    $Datestring = Get-Date -Format "yyyyMMdd"
    $LogFileName = "${PrefixLog}-${DateString}.log" #va créer fichier log ici PsLog-Date.log

    $TimeString = Get-Date -Format "hh:mm:ss"
    $entryPrefix = "${DateString} - ${TimeString}" #préparation pour générer ligne

    $entryPrefix, $LogLevel, $toLog -join (">") | Out-File -FilePath $LogFileName -Append

}

function Set-RegKey {
    param(
    [Parameter(Mandatory=$true, valueFromPipeline=$true,Position=0)][string] $path,
    [Parameter(Mandatory=$true, valueFromPipeline=$true,Position=1)][string] $key,
    [Parameter(Mandatory=$true, valueFromPipeline=$true,Position=2)] $value)

    New-ItemProperty -Path $path -Name $key -Value $value -ErrorAction Stop
}

function Update_RegKey {
    param(
    [string] $path_up,
    [string] $key_up,
    $value_up )

    Set-ItemProperty -path $path_up -Name $key_up -value $value_up
}
Write-Log -toLog "Start Script" -LogLevel Info
#Get-ItemProperty -Path HKLM:\SOFTWARE

#Menu #Puisque pas de paramètres, pas besoin de (). Afficher juste le menu

#GetChoiceMenu
$stop = $false
do {
    Switch(GetChoiceMenu) {
    1 {
        #lire phrase
        Write-Log -toLog "Inversion de mot" -LogLevel Error
        $Phrase= Read-Host -Prompt "Quelle phrase ?"

        $phraseInvert=RevertString($Phrase)
        $phraseInvert | Write-Host
        RevertString($phraseInvert) | Write-Host -ForegroundColor Green -BackgroundColor Yellow
    }
    2 { Write-Host "Ajout clé de registre" 
        $Path= "HKLM:\SOFTWARE"
        $Key= Read-Host -Prompt "Quelle nom de clé?"
        $Value= Read-Host -Prompt "Valeur?"
        $HomeDir="HKEY_CURRENT_USER\Tom"
        

        try{
            if ( -Not ( Test-Path "Registry::$HomeDir") -eq $true){
                New-Item -Path "Registry::$HomeDir" -ItemType RegistryKey -Force
            elseif (
            $choice_up=Read-Host -Prompt "This value already exist, do you want to update it?(y/n)"
                if ($choice_up -eq "y")
                {
                    Update_RegKey -path_up $Path -key_up $Key -value_up $Value
                }
                else
                {
                    Write-Host "Fermeture du programme"
                    $stop=$strue
                }
            }
            else {
            Set-RegKey -path $Path -key $Key -value $Value
            }
        }
        catch {
              Write-Log -toLog "Error while processing" -LogLevel Critical
              $stop=$true
        }
        finally{
            Write-Log -toLog "Set key in system, on path:$Path , with the name: $Key and the value: $Value" -LogLevel Warning
        }
        }
    3 { Write-Host "Fermer le programme" 
        Write-Log -toLog "Fermeture du programme" -LogLevel Info
        $stop=$true
        }
    #default = valeur inconnue (= "?)" en bash) 
    }
} until($stop) #until >< while
#$true et $false sont considérés comme des variables et pas comme des valeurs booléennes

#lire phrase
#$Phrase= Read-Host -Prompt "Quelle phrase ?"

#$phraseInvert=RevertString($Phrase)
#$phraseInvert | Write-Host
#RevertString($phraseInvert) | Write-Host -ForegroundColor Green -BackgroundColor Yellow
