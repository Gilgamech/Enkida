# .\PowerShiriVoiceCommands.ps1 Build: 13 2016-05-01T21:23:19 Copyright Gilgamech Technologies   

# New-Powershell -E ; restart-Powershell
# Stop-Process (get-process sapisvr).Id ; exit
# ipmo .\PowerShiri.ps1

#How to add stuff by saying it?
#How to make her restart?
#Give her sudo? Or how to limit?




#Time one-liners
Add-SpeechCommands @{ "What time is it?" = { Out-Speech "It is $(Get-Date -f "HH:mm")" }; };
Add-SpeechCommands @{ "What day is it?"  = { Out-Speech $(Get-Date -f "dddd, MMMM dd") }; }; 
#File\Tool one-liners
Add-SpeechCommands @{ "Open Notepad" = { start-process $NppPath ; Out-Speech "Notepad plus plus opened."}; };
Add-SpeechCommands @{ "Open Explorer" = { Open-Explorer }; }; 
Add-SpeechCommands @{ "Open Powershell" = { New-Powershell }; }; 



#Audio one-liners
Add-SpeechCommands @{ "What is the system volume?" = { Out-Speech ([int]([audio]::Volume * 100)).tostring(); }; }; 
Add-SpeechCommands @{ "Set system volume mute." = { [audio]::Mute = $true }; }; 
Add-SpeechCommands @{ "Set system volume unmute." = { [audio]::Mute = $false ; Out-Speech "Unmuted."}; }; 
Add-SpeechCommands @{ "Set system volume low." = { SetVoice-AudioVolume 20 }; }; 
Add-SpeechCommands @{ "Set system volume medium." = { SetVoice-AudioVolume 50 }; }; 
Add-SpeechCommands @{ "Set system volume high." = { SetVoice-AudioVolume 100 }; }; 


#Add-SpeechCommands @{ "What was the last message?"  = { Speak-LastError }; }; 



<#
#Can't figure out why this doesn't work here, something about the unregister-event event not being there.
Add-SpeechCommands @{ 
"Repeat last error" = { 
[string]$lasterror = $error[0].ToString() ; 
Out-Speech $lasterror 
}; 
}; 
#>


#Add-SpeechCommands @{ "Write Output" = { Out-Speech $_ }; }; 

#More complex


#Demo function
Add-SpeechCommands @{
"Tell me about yourself." = {
Out-Speech "This is a PowerShiri Powershell module.";
$voice = $Global:SpeechModuleSpeaker.voice.Description
Out-Speech "My voice is $voice.";

#Some of these take a little bit to retrieve.
$computersystem = Get-WMIObject win32_computersystem;
$operatingsystem = ( Get-CimInstance Win32_OperatingSystem).Caption
$cpu = (gwmi win32_processor);
$ram = (Get-WMIObject win32_physicalmemory);
$ramcapacity = $ram.capacity / (1GB)
$bios = ($computersystem.Manufacturer);
Out-Speech "This hardware is a $bios device running $operatingsystem with a $($cpu.NumberOfCores) core processor $($cpu.name), and $ramcapacity gigabytes of $($ram.name).";


}; #End tell me about yourself.
}; #End Commands



Add-SpeechCommands @{ 
"What is the weather today? " = { 

#The API call takes a second.
Out-Speech "Checking Weather.gov,.." ; 

$usgweather = (Get-UsGovWeather)
$mintemp = ($usgweather[0].minTemp)
$maxtemp = ($usgweather[0].maxTemp) 
$summaryw = ($usgweather[0].summary) 
Out-Speech "Today's high is $maxtemp degrees Celsius, the low is $mintemp degrees Celsius, and the general forecast is for $summaryw"

}; #End What is the weather
}; #End Commands


#System
Add-SpeechCommands @{
"What's running?"  = {
$getprocess = get-process #(get-process).processname | group name | select name, count;
$notableprocesses = $getprocess | group name | select count, name | where {$_.count -gt 1} | sort count -Descending

Out-Speech "There are $($getprocess.Count) processes running, including";
#List out the processes with more than 1 running
foreach ($notaproc in $notableprocesses) { 
Out-Speech "$($notaproc.count) instances of $($notaproc.name)"
}; #end for 
$cpu = (gwmi win32_processor);
$ram = (Get-WMIObject win32_physicalmemory);
$os = (gwmi win32_operatingsystem)
$rampct = [math]::Round((($os.FreePhysicalMemory) / ($ram.Capacity / 1024)) * 100)/100;

Out-Speech "System CPU use is at $($cpu.LoadPercentage) percent and $rampct percent of $($ram.name) is in use. That last statistic is not accurate."

}; #end What's running
}; #end Add-SpeechCommands




#Time functions
Add-SpeechCommands @{
"Is it daylight savings time?" = { 
$isDST = [System.TimeZone]::CurrentTimeZone.IsDaylightSavingTime( (get-date) )
Out-Speech ((Convert-TrueToYesItIs $isDST) + (" Daylight Savings Time."))
}; #end is DST
}; #End Commands




#Help functions.
Add-SpeechCommands @{
"Help." = {
Out-Speech "This section is new and may be incomplete.";
Out-Speech "Try - 'List Commands'.";
#Out-Speech "What do you need help with?";
#Out-Speech "Available help topics:";

#Out-Speech "Help Audio.";
<#
Out-Speech "";
Out-Speech "";
Out-Speech "";
#>

}; #End Help
}; #End Commands


Add-SpeechCommands @{
"List Commands." = {

Out-Speech "I know how to respond to these commands:";
foreach ($command in  ($SpeechModuleMacros.keys | sort)) { Out-Speech $command }

}; #End tell me about yourself.
}; #End Commands




#Speech volume, still in progress.
Add-SpeechCommands @{  
"What is your speaking volume?"= {  

$volume = $SpeechModuleSpeaker.Volume; 
Out-Speech "My speech volume is $volume"; 

}; #End command. 
}; #End Commands




#Put the utility module somewhere until it's big enough to move somewhere permanent.
function SetVoice-AudioVolume {
Param(
   [ValidateRange(0,100)]
   [int]$volval = 50
);

[audio]::Volume = ($volval/100)
Out-Speech ([int]([audio]::Volume * 100)).tostring();

};


<#
Add-SpeechCommands @{
"Help Audio." = {
Out-Speech "This section is new and may be incomplete.";
Out-Speech "Several audio commands are available. You can tell me to mute or unmute the system audio just by saying - $($env:ComputerName) mute audio - or unmute audio. You can ask me for my speaking volume, and you can ask me for the audio volume of the whole system. You can tell me to set audio volume to a low setting, medium setting, or high setting which is maximum.";

}; #End Help
}; #End Commands
#>

#Some don't work, don't know why.
<#
function Speak-LastError 
{
Out-Speech $error[0].ToString().split("+")
}; #end Speak-LastError


Add-SpeechCommands @{  
"Speak faster."= {  
$SpeechModuleListener.rate++  #= 4
#$volume = $SpeechModuleSpeaker.Volume; 
Out-Speech "My speech rate is now  is $($SpeechModuleListener.rate)"; 

}; #End command. 
}; #End Commands


Add-SpeechCommands @{  
"Speak slower."= {  
$SpeechModuleListener.rate--  #= 4
#$volume = $SpeechModuleSpeaker.Volume; 
Out-Speech "My speech rate is now  is $($SpeechModuleListener.rate)"; 

}; #End command. 
}; #End Commands
#>

<#

Add-SpeechCommands @{
"Decrease speech volume"= {

if ($SpeechModuleSpeaker.Volume -gt 20) {
$SpeechModuleSpeaker.Volume -= 20
$volume = $SpeechModuleSpeaker.Volume
Out-Speech "My volume is reduced to $volume"
} else {
Out-Speech "My volume is already $volume"
}; #end if

}; #End command.
}; #End Commands


Add-SpeechCommands @{
"Increase speech volume"= {

if ($SpeechModuleSpeaker.Volume -lt 80) {
$SpeechModuleSpeaker.Volume += 20
$volume = $SpeechModuleSpeaker.Volume
Out-Speech "My volume is increased to $volume"
} else {
Out-Speech "My volume is already $volume"
}; #end if

}; #End command.
}; #End Commands



Add-SpeechCommands @{ 
"Repeat last error" = { 
$lasterror = $error[0].ToString() ; 
Out-Speech $lasterror 
}; 
}; 


"Get new voice commands." = { 
Remove-SpeechCommands; 
Import-Module -force "C:\Dropbox\Public\Scripts\Powershell\PowerShiriVoiceCommands.ps1" ; 
Out-Speech "Commands reloaded."
#>



