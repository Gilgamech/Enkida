# .\PowerShiri.ps1 Build: 27 2016-05-02T20:46:57 Copyright Gilgamech Technologies   

################################################################
#Stuff to add:
#Compliments/insults/jokes
#Popular things - Front page of Imgur, News sites, Twitter, etc.
#Trivia or random things.
#System monitoring?
#Replace Out-Speech with Say-This?
#Make all the PowerShiri modules talk to each other?
#Config file, where names and file locations etc are stored.
#First run "Introduce me to yourself" mode to populate the config file.
#"Main module" - this is the voice module.
#Make her sing. (Also put in music conversion in main PowerGIL.)
#Have her queue notifications (brush your teeth, do X now to leave for the bus on time,)
#Avoid sexual stuffs? 
#"If I leave now, what time will the bus get me to Bellevue?" (Make a daily checkin thing so I can start recording stats. )
#Have her check email.
#Set up a Gilgamech.com email address to route to my PC, test out receiving email with...IIS? Then make a Powershell job that watches for email and parses and stuff?
#
################################################################

#This is the name to which the PowerShiri module will respond:
[string]$PowerShiriName = "Enkida"; #This can be changed with Add-SpeechCommands. 
write-host -f y "Closing this window will make $PowerShiriName stop listening."

[string]$PowerShiriFolder = "C:\Dropbox\repos\PowerShiri"
 
 #$null =Add-Type -AssemblyName System.Speech
$null =[Reflection.Assembly]::LoadWithPartialName("System.Speech");

#Create the two main objects we need for speech recognition and synthesis
if(!$Global:SpeechModuleListener){## For XP's sake, don't create them twice...
	#$Global:SpeechModuleSpeaker = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
	$Global:SpeechModuleSpeaker = New-Object System.Speech.Synthesis.SpeechSynthesizer;
	$Global:SpeechModuleListener = New-Object System.Speech.Recognition.SpeechRecognizer; 
};
$Script:SpeechModuleMacros = @{};
#Add a way to turn it off
$Script:SpeechModuleMacros.Add("Stop Listening", { $script:listen =$false; Suspend-Listening; }) ;
$Script:SpeechModuleComputerName = $PowerShiriName 


<#
	if($VerbosePreference -ne"SilentlyContinue") {
		$Script:SpeechModuleMacros.Keys | ForEach-Object { 
			Write-Host"$Computer, $_" -Fore Cyan 
		}; #end ForEach-Object
	}; #end if
#>	

<# .Synopsis
 Recreate the speech recognition grammar
.Description
 This parses out the speech module macros, 
 and recreates the speech recognition grammar and semantic results, 
 and then updates the SpeechRecognizer with the new grammar, 
 and makes sure that the ObjectEvent is registered.
#>
function Update-SpeechCommands {
	$choices = New-Object System.Speech.Recognition.Choices;

	foreach($choice in $Script:SpeechModuleMacros.GetEnumerator()) {
		New-Object System.Speech.Recognition.SemanticResultValue $choice.Key, $choice.Value.ToString() |ForEach-Object { $choices.Add( 
				$_.ToGrammarBuilder()); #end choices.Add
		}; #end foreach 
	}; #end outer foreach

	$builder = New-Object System.Speech.Recognition.GrammarBuilder "$Computer, ";
$builder.Append((New-Object System.Speech.Recognition.SemanticResultKey "Commands", $choices.ToGrammarBuilder()));
<#
	$builder.Append(
		(New-Object System.Speech.Recognition.SemanticResultKey "Commands", $choices.	ToGrammarBuilder())
	);
#>
	$grammar = New-Object System.Speech.Recognition.Grammar $builder;
	$grammar.Name = "Power VoiceMacros";
	
	## Take note of the events, but only once (make sure to remove the old one)
	Unregister-Event "SpeechModuleCommandRecognized" -ErrorAction SilentlyContinue;
	$null = Register-ObjectEvent $grammar SpeechRecognized -SourceIdentifier "SpeechModuleCommandRecognized" -Action { 
		Invoke-Expression $event.SourceEventArgs.Result.Semantics.Item("Commands").Value;
	};
	
	$Global:SpeechModuleListener.UnloadAllGrammars();
	$Global:SpeechModuleListener.LoadGrammarAsync($grammar);
};



<# .Synopsis
 Add one or more commands to the speech-recognition macros, and update the recognition
.Parameter CommandText
 The string key for the command to remove
#[CmdletBinding()]
#>

function Add-SpeechCommands {
	Param(
	   [hashtable]$VoiceMacros,
	   [string]$Computer=$Script:SpeechModuleComputerName
	);

	## Add the new macros
	$Script:SpeechModuleMacros +=$VoiceMacros;

	## Update the default if they change it, so they only have to do that once.
	$Script:SpeechModuleComputerName= $Computer;
	 Update-SpeechCommands; 
 };


<# .Synopsis
 Remove one or more command from the speech-recognition macros, and update the recognition
.Parameter CommandText
 The string key for the command to remove
#>
 
function Remove-SpeechCommands {
	Param([string[]]$CommandText);
	foreach($command in $CommandText){$Script:SpeechModuleMacros.Remove($Command)};
	Update-SpeechCommands; 
};



<# .Synopsis
 Removes all commands from the speech-recognition macros, and update the recognition
.Parameter CommandText
 The string key for the command to remove
#>
function Clear-SpeechCommands {
$Script:SpeechModuleMacros = @{};
## Default value: A way to turn it off
$Script:SpeechModuleMacros.Add("End Listening", { Suspend-Listening });
Update-SpeechCommands;
 };

<# .Synopsis
 Sets the SpeechRecognizer to Enabled
#>

function Start-Listening {
$Global:SpeechModuleListener.Enabled= $true;
Say "Speech Macros are $($Global:SpeechModuleListener.State)";
Write-Host "Speech Macros are $($Global:SpeechModuleListener.State)" ;
};

<# .Synopsis
 Sets the SpeechRecognizer to Disabled
#>
function Suspend-Listening {
$Global:SpeechModuleListener.Enabled= $false;
Say "Speech Macros are disabled";
Write-Host "Speech Macros are disabled" ;
};



<# .Synopsis
 Speaks the input object
.Description
 Uses the default SpeechSynthesizer settings to speak the string representation of the InputObject
.Parameter InputObject
 The object to speak 
 NOTE: this should almost always be a pre-formatted string, #most objects don't render to very speakable text.
#>
function Out-Speech {
	#Could replace with Say-This? Nah, no reason for dependency. Has to hit ConvertVoice-CleanSpeech anyway.
	#Need to rename to Out-PowerShiriSpeech as this is tightly-coupled to PowerShiri
	Param(
	   [Parameter(ValueFromPipeline=$true)]
	   [string]$InputObject 
	);
	#Trying to make it not listen to itself. This pauses PowerShiri listening, but the overall speech recognition is still on.
	$Global:SpeechModuleListener.Enabled= $false;
	$null = $Global:SpeechModuleSpeaker.SpeakAsync( ( $InputObject | ConvertVoice-CleanSpeech | Out-String ) );
	$Global:SpeechModuleListener.Enabled= $true;
} #end Out-Speech




<# .Synopis
 Dispose of the SpeechModuleListener and SpeechModuleSpeaker
  #>

function Remove-SpeechXP {
	$Global:SpeechModuleListener.Dispose();
	$Global:SpeechModuleListener = $null;
	$Global:SpeechModuleSpeaker.Dispose();
	$Global:SpeechModuleSpeaker = $null ;
};

#Module for easy voice module adding
ipmo "$PowerShiriFolder\PowerShiriVoiceCommands.ps1"
#module for grammar - like converting "True" "Yes, it is"
ipmo "$PowerShiriFolder\PowerShiriGrammarConvert.ps1"
set-alias asc Add-SpeechCommands; 
set-alias rsc Remove-SpeechCommands; 
set-alias csc Clear-SpeechCommands; 


#Dunno what this is all about, and it seems to work fine without it. I'm leaving it here until I figure out what it's for.
#Export-ModuleMember -Function * -Alias * -Variable SpeechModuleListener, SpeechModuleSpeaker;

#Minimize the window so we don't mess with it.
Set-PSWindowStyle MINIMIZE;
#sleep 86400;


