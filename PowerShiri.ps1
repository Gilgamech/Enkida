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
#"If I leave now, what time will the bus get me to Bellevue?" (Make a daily checkin thing so I can start recording stats. )
#Have her check email.
#Set up a Gilgamech.com email address to route to my PC, test out receiving email with...IIS? Then make a Powershell job that watches for email and parses and stuff?
#
################################################################

#This is the name to which the PowerShiri module will respond:
#This can be changed with Add-SpeechCommands. 
$Script:SpeechModuleComputerName = "Enkida"; 
[string]$PowerShiriFolder = "C:\Dropbox\www\PS1\PowerShiri"
[console]::Title = "Windows PowerShell - $($Script:SpeechModuleComputerName)"
 

Function Start-PowerShiri {
	[Reflection.Assembly]::LoadWithPartialName("System.Speech");
	[Reflection.Assembly]::LoadWithPartialName("recognition");
	[Reflection.Assembly]::LoadWithPartialName("System.Speech.Recognition");
	cd .\www\PS1\PowerShiri\
	ipmo .\PowerShiri.ps1 -Force
	$Global:SpeechModuleListener = New-Object System.Speech.Recognition.SpeechRecognizer;
	ipmo .\PowerShiriGrammarConvert.ps1 -Force
	ipmo .\PowerShiriVoiceCommands.ps1 -Force
	$script:SpeechModuleMacros
	$Script:SpeechModuleMacros.Add("Stop Listening", { $script:listen =$false; Suspend-Listening; }) ;
	$script:SpeechModuleMacros
	$Global:SpeechModuleSpeaker = New-Object System.Speech.Synthesis.SpeechSynthesizer;
}; #end Start-PowerShiri

Function Get-RandomSpeech {
	[CmdletBinding()]
	Param(
		[String]$MACAddress,
		[String]$UserName = "Stephen",
		[int]$SleepMin = 15,
		[int]$SleepMax = 60,
		[int]$Chattyness = 1,
		[String]$PromotedSpeechFile = "C:\Dropbox\www\PS1\PowerShiri\PromotedSpeech.txt",
		[String]$RandomSpeechFile = "C:\Dropbox\www\PS1\PowerShiri\RandomSpeech.txt",
		[String]$OutputHTML = "$WebPath\Enkida.html",
		[IPAddress]$IPAddress = ((((arp -a) -split "`n" | Select-String $MACAddress) -split " "| %{try {[ipaddress]$_}catch{}}))
	); #end Param
	
	$NightVolume = .1
	$DayVolume = .35
	$EveningVolume = .2
	
	#ipmo "C:\Dropbox\www\PS1\PowerShiri\PowerShiriGrammarConvert.ps1"
	$SleepMin = $SleepMin / $Chattyness
	$SleepMax = $SleepMax / $Chattyness
	
	while ($true) {
		$OutHTML =  @()
		$SleepTime = (Get-Random -Minimum $SleepMin -Maximum $SleepMax)

		#'<link rel="stylesheet" type="text/css" charset="utf-8" href="//gilgamech.com/gilgamech.css">' > $OutputHTML
		if (Test-Connection  $IPAddress.IPAddressToString -Quiet -Count 1){
			#say-this "You are here."
			$OutHTML += "$UserName's device detected, announcing locally.<br>"
			
			$j=$i;
			[int]$i = (Get-Random -Minimum 0 -Maximum 6);
			if($j -eq $i) {
				#"I = $i and J = $j<br>" >> $OutputHTML
				[int]$i = (Get-Random -Minimum 0 -Maximum 5);
			}; #end if j 
			#"I = $i<br>" >> $OutputHTML
			
			switch ($i) { 
				0 {
					$OutHTML +=  "Announce random promotion of length $($InputText.Length).<br>" 
					[array]$InputText = (GC $PromotedSpeechFile)
					[string]$InputText = Get-Random $InputText
					[string]$InputText = Get-OrderedSentence $InputText
					$SayTxt = $InputText

				}; #end 0
				1 { 
					$OutHTML +=  "Lookup random item from clipboard.<br>"
					[array]$InputText = Get-Clipboard 
					[array]$InputText = ($InputText | Convert-SymbolsToUnderscore -Symbol " ") -split " " -replace (9|Flip-BytesToText),"" | select -Unique | where {$_.length -gt 3} | where {$_.length -lt 8}
					
					if ($InputText) {
						[string]$OutputText = Get-Random $InputText
						$Source,$AnswerText = ((Invoke-RandomAPI $OutputText -AbstractOnly) -split ":") #| Convert-SymbolsToUnderscore -Symbol " "
					}; #end if InputText
					if ($AnswerText.length -gt 2) {
						#[array]$RandomAnswers = (i -t words).word
						#[array]$RandomSpeech = (GC $RandomSpeechFile)
					[string]$OutputText = Get-OrderedSentence $OutputText
						$OutputText -replace " ","" -split "`n" | select -unique | where {$_.length -gt 1} | %{i "insert into words (word) values ('$_')" }
						i "insert into meanings (WordID,SourceID,Meaning) values ('$OutputText','$Source','$AnswerText')"
						
					}else{
						#[array]$RandomSpeech = (GC $RandomSpeechFile)
						#[array]$InputText = (i -t words).word
						$OutHTML +=  "Couldn't find anything under $OutputText at $Source, saying random phrase.<br>"
						[string]$AnswerText = Get-OrderedSentence
						#[string]$AnswerText = Get-Random ($RandomSpeech)
						#[string]$AnswerText = (Invoke-RandomAPI $OutputText2 -AbstractOnly) | ConvertVoice-CleanSpeech  -Symbol " "
					}; #end if AnswerText  
					$SayTxt = (($AnswerText | ConvertVoice-CleanSpeech) -split " ")[0..100]
					#$RandomSpeech += $AnswerText
					#$RandomSpeech -replace "  "," " -split "`n" | select -unique > $RandomSpeechFile
				}; #end 1
				2 {
				$SayTxt = Get-OrderedSentence $Error[0].exception
<#
					[array]$InputText = ((Get-Clipboard) -split "`n" | ConvertVoice-CleanSpeech  -Symbol " " | select -unique)
					#[array]$RandomSpeech = (GC $RandomSpeechFile)
					if ($OldClipboard -eq $InputText) {
						[string]$InputText = Get-RandomMeaning
						#[string]$InputText = Get-Random $RandomSpeech
					}; #end if InputText
					if ($InputText.length -gt 10) {
						$InputText = $InputText[0..10]	
					}; #end if InputText
					$OldClipboard = $InputText
					[string]$InputText = Get-OrderedSentence $InputText
					#$RandomSpeech += $InputText
					$OutHTML +=  "Read clipboard of length $($InputText.length)<br>"
					$SayTxt = ($InputText -split " ")[0..100]
					#$RandomSpeech -replace "  "," " -split "`n" | select -unique > $RandomSpeechFile
					i "insert into meanings (WordID,SourceID,Meaning) values ('Clipboard','Clipboard','$InputText')"
#>
				}; #end 2 
				3 {
					$m2 = ""
					$m3 = i -t meanings | select wordid,sourceid,@{n='meaning';e={$_.meaning  -replace "`n ",""}} | sort meaning -u
					$meaning = get-random $m3.meaning
					$w1 = ($m3 | where {$_.meaning -eq $meaning}).wordid
					$OutHTML +=  "Madlibbing $w1.<br>"
					$OutHTML +=  "Base phrase: $meaning <br>"
					foreach ($word in ($meaning -split " ")) {
						$OutHTML +=  "Looking up word : $word <br>"
						write-host "Word: $word"
						$mm = Define-Word $word| ConvertVoice-CleanSpeech
						write-host "meaning: $mm"
						$OutHTML +=  "Found meaning: $mm <br>"
						if ($mm) {
								$m2 += " $mm "
								#$meaning = $meaning -replace " $word "," $mm "
						}; #end foreach word
					}; #end foreach word

					$m2 = Get-OrderedSentence (($m2 -split "`n" -split "[.]" | select -unique | ConvertVoice-CleanSpeech)  -join "." )
					#say-this $meaning
					$OutHTML +=  "Synthesized phrase: $m2 <br>"
					$SayTxt = ($m2 -split " ")[0..100]
					i "insert into meanings (WordID,SourceID,Meaning) values ('$w1','Synthesis','$meaning')"
				}; #end 3
				4 {
					$OutHTML +=  "Playing Trivia."
					$OutHTML += (Get-RandomTrivia -SleepTime 2 -NumberOfQuestions 2) -join "`n"
				}; #end 2 
				Default {
					$OutHTML +=  "Announce time and upcoming agenda.<br>"
					$GetDate = Get-Date
					$GetDateT = Get-Date -f t
					$SayTxt = "$UserName, the time is $GetDateT. "
					$ChasStatus = (Invoke-EmlalockAPI)
					if ($ChasStatus.sessionactive) {
						$SayTxt += "You are currently in an active Emlalock session. "
						if (($StillLocked = $false) -AND ((($ChasStatus.startdate + $ChasStatus.maxduration) - (get-date)).totalminutes -le 120)) {
							$SayTxt += "$UserName, you failed to achieve release today. Please try again tomorrow."
							Invoke-EmlalockAPI -Job addMaximum -Time 86400
							Invoke-EmlalockAPI -Job addRandom -From 43200 -to 64800
							$StillLocked = $true
						}; #end if ChasStatus
					}; #end if ChasStatus
					switch ($getdate.Hour) {
						4 {
							$SayTxt += "You have $(60 - $getdate.minute) minutes to get to the gym."
						}
						5 {
							$SayTxt += "You are $($getdate.minute) minutes late to the gym."
						}
						6 {
							$SayTxt += "You have $(60 - $getdate.minute) minutes to get to work." 
							[audio]::Volume = $NightVolume
						}
						7 {
							$SayTxt += "You are $($getdate.minute) minutes late to work."
							[audio]::Volume = $EveningVolume
						}
						8 {
							[audio]::Volume = $DayVolume
						}
						9 {
						}
						18 {
							$SayTxt += "Your bedtime is in $(120 -$getdate.minute) minutes."
						}
						19 {
							$SayTxt += "Your bedtime is in $(60 -$getdate.minute) minutes."
						}
						20 {
							$SayTxt += "Your bedtime was $($getdate.minute) minutes ago."
							[audio]::Volume = $EveningVolume
						}
						21 {
							[audio]::Volume = $NightVolume
						}
						22 {
						}
						23 {
						}
						default {
							$SayTxt +=  ""
						}; #end Default
					}; #end Switch Get-Date
						[string]$SayTxt = Get-OrderedSentence $SayTxt
				}; #end Default
			}; #end Switch i
			
		Write-Verbose "$SayTxt"
		Say-This "$SayTxt"
			

		}else{
			$InputText = Get-RandomMeaning
			[string]$OutputText = $InputText -split " " | Get-Random
			$OutHTML +=  "$UserName's device not detected, looking up '$OutputText'.<br>"
			$Source,$AnswerText = ((Invoke-RandomAPI $OutputText -AbstractOnly | ConvertVoice-CleanSpeech) -split ":" )| ConvertVoice-CleanSpeech  -Symbol " "
			if ($AnswerText.length -gt 2) {
				$OutHTML +=  "From $($Source):<br>"
				$OutputText -replace " ","" -split "`n" | select -unique | where {$_.length -gt 1} | %{i "insert into words (word) values ('$_')" }
				i "insert into meanings (WordID,SourceID,Meaning) values ('$OutputText','$Source','$AnswerText')"
				
				$AnswerText = $AnswerText -replace "`n",""
				
				$OutHTML +=  '<script>window.speechSynthesis.onvoiceschanged = function() {SayThis("{0}")};</script><br>' -f $AnswerText
				$OutHTML +=  "$AnswerText<br>"
			}else{
					$m3 = i -t meanings | select wordid,sourceid,@{n='meaning';e={$_.meaning  -replace "`n ",""}} | sort meaning -u
					$meaning = get-random $m3.meaning
					$w1 = ($m3 | where {$_.meaning -eq $meaning}).wordid
					$OutHTML +=  "Madlibbing $w1.<br>"
					$OutHTML +=  "Base phrase: $meaning <br>"
					foreach ($word in ($meaning -split " ")) {
						$OutHTML +=  "Looking up word : $word <br>"
						$word
						#$mm = $m3 | where {$_.wordid -eq $word} | select -ExpandProperty meaning | get-random
						$mm = Define-Word $word| ConvertVoice-CleanSpeech
						write-host $mm
						$OutHTML +=  "Found meaning: $mm <br>"
						if ($mm) {
								$meaning = $meaning -replace " $word "," $mm "| ConvertVoice-CleanSpeech
						}; #end foreach word
					}; #end foreach word
					
<#
#>
					$meaning = Define-Word $meaning 
					write-host $meaning
				
				$OutHTML +=  "Synthesized phrase: $meaning <br>"
				$OutHTML +=  '<script>window.speechSynthesis.onvoiceschanged = function() {SayThis("{0}")};</script><br>' -f ($meaning -split "`n" )
				i "insert into meanings (WordID,SourceID,Meaning) values ('$w1','Synthesis','$meaning')"
			}; #end if AnswerText
		}; #end if ping
			

	$OutHTML = $OutHTML -split "`n" -join "`n"
	
	
'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
<meta http-equiv="refresh" content="{0}">
<title>Gilgamech Technologies</title>
<link rel="shortcut icon" href="//gilgamech.com/favicon.ico" type="image/x-icon"/ >
<link rel="stylesheet" type="text/css" charset="utf-8" href="//gilgamech.com/gilgamech.css">
<link rel="stylesheet" type="text/css" charset="utf-8" href="//gilgamech.com/gilgamechm.css">
<script src="/js/Gil.js" type="text/javascript" charset="UTF-8"></script>
</head>

<body>
<div class = "top">
<a href="/">Gilgamech</a> <a href="/">Technologies</a>
</div>
<nav>
    <a href="/">Home</a> |
	<a href="/ARKData/index.html">ARKdata!</a> |
	<a href="/robot-fruit-hunt/Index.html">Fruitbot!</a> 
<!-- | 
	<a href="minecraft.html">Minecraft!</a> | 
    <a href="game.html">Game Page (under development)</a> | 
	<a href="video.html">Video (under development)</a> |
	<a href="clock.html">Concept clock (under development)</a> | -->
</nav>
<div class="content">
<br>
<br>
<img height=132 width=128 src="/images/Enkida.png" />
<p>Hello, my name is Enkida Zira AI-Heart. I look up random words on the internet.</p>
<br>
Next refresh in {0} seconds.<br>
{1} 
</div>
<p class="banner">
    <a href=http://www.duckduckgo.com><img src=//gilgamech.com/images/BannerImage.jpg height=135 width=320 title="C1ick h34r ph0r m04r inph0" /></a>
</p>

<p class="copyright">(c) 2013-2017 Gilgamech. Making Techology Great Again.</p>

</body>
</html>'  -f $SleepTime,$OutHTML > $OutputHTML

		sleep $SleepTime
	}; #end While True

	[console]::Title = "Windows PowerShell"
}; #end Get-RandomSpeech

<#
set-alias asc Add-SpeechCommands; 
set-alias rsc Remove-SpeechCommands; 
set-alias csc Clear-SpeechCommands; 

#Dunno what this is all about, and it seems to work fine without it. I'm leaving it here until I figure out what it's for.
#Export-ModuleMember -Function * -Alias * -Variable SpeechModuleListener, SpeechModuleSpeaker;

#Minimize the window so we don't mess with it.
#Set-PSWindowStyle MINIMIZE;
#sleep 86400;

	if($VerbosePreference -ne"SilentlyContinue") {
		$Script:SpeechModuleMacros.Keys | ForEach-Object { 
			Write-Host"$Computer, $_" -Fore Cyan 
		}; #end ForEach-Object
	}; #end if
#>	

function Update-SpeechCommands {
	<# .Synopsis
		Recreate the speech recognition grammar
	.Description
		This parses out the speech module macros, 
		and recreates the speech recognition grammar and semantic results, 
		and then updates the SpeechRecognizer with the new grammar, 
		and makes sure that the ObjectEvent is registered.
	#>
	$choices = New-Object System.Speech.Recognition.Choices;

	foreach($choice in $Script:SpeechModuleMacros.GetEnumerator()) {
		New-Object System.Speech.Recognition.SemanticResultValue $choice.Key, $choice.Value.ToString() | ForEach-Object { 
			$choices.Add( $_.ToGrammarBuilder()); #end choices.Add
		}; #end foreach 
	}; #end outer foreach

# if($VerbosePreference -ne"SilentlyContinue") {$Script:SpeechModuleMacros.Keys | ForEach-Object { Write-Host"$Computer, $_" -Fore Cyan } };
	$builder = New-Object System.Speech.Recognition.GrammarBuilder "$Computer, ";
	$builder.Append((New-Object System.Speech.Recognition.SemanticResultKey "Commands", $choices.ToGrammarBuilder()));

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

function Add-SpeechCommands {
	<# .
	Synopsis
		Add one or more commands to the speech-recognition macros, and update the recognition.
	.Parameter CommandText
		The string key for the command to remove.
	#>
	[CmdletBinding()]
	Param(
		[hashtable]$VoiceMacros,
		[string]$Computer = ($Script:SpeechModuleComputerName),
		$Script:SpeechModuleComputerName= $Computer
	);
	$Script:SpeechModuleMacros += $VoiceMacros
	 Update-SpeechCommands; 
 };
 
function Remove-SpeechCommands {
	<# 
	.Synopsis
		Remove one or more command from the speech-recognition macros, and update the recognition
	.Parameter CommandText
		The string key for the command to remove
	#>
	Param([string[]]$CommandText);
	foreach($command in $CommandText){$Script:SpeechModuleMacros.Remove($Command)};
	Update-SpeechCommands; 
};

function Clear-SpeechCommands {
	<# 
	.Synopsis
		Removes all commands from the speech-recognition macros, and update the recognition
	.Parameter CommandText
		The string key for the command to remove
	#>
	$Script:SpeechModuleMacros = @{};
	## Default value: A way to turn it off
	$Script:SpeechModuleMacros.Add("End Listening", { Suspend-Listening });
	Update-SpeechCommands;
 };

function Start-Listening {
	<# 
	.Synopsis
		Sets the SpeechRecognizer to Enabled
	#>
	$Global:SpeechModuleListener.Enabled= $true;
	#Say "Speech Macros are $($Global:SpeechModuleListener.State)";
	Write-Host "Speech Macros are $($Global:SpeechModuleListener.State)" ;
};

function Suspend-Listening {
	<# 
	.Synopsis
		Sets the SpeechRecognizer to Disabled
	#>
	$Global:SpeechModuleListener.Enabled= $false;
	#Say "Speech Macros are disabled";
	Write-Host "Speech Macros are disabled" ;
};

function Out-Speech {
	<# 
	.Synopsis
		Speaks the input object
	.Description
		Uses the default SpeechSynthesizer settings to speak the string representation of the InputObject
	.Parameter InputObject
		The object to speak 
		NOTE: this should almost always be a pre-formatted string, #most objects don't render to very speakable text.
	#>
	Param(
	   [Parameter(ValueFromPipeline=$true)][string]$InputObject 
	);
	#Trying to make it not listen to itself. This pauses PowerShiri listening, but the overall speech recognition is still on.
		$Global:SpeechModuleListener.Enabled= $false;
		$null = $Global:SpeechModuleSpeaker.SpeakAsync( ( $InputObject | ConvertVoice-CleanSpeech | Out-String ) );
		$Global:SpeechModuleListener.Enabled= $true;
} #end Out-Speech

function Remove-SpeechXP {
	<# 
	.Synopis
		Dispose of the SpeechModuleListener and SpeechModuleSpeaker
	#>
	$Global:SpeechModuleListener.Dispose();
	$Global:SpeechModuleListener = $null;
	$Global:SpeechModuleSpeaker.Dispose();
	$Global:SpeechModuleSpeaker = $null ;
};



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


