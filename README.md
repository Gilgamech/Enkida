# PowerShiri
#This is a set of modules to support basic voice recognition input. Designed and tested with Powershell 3.0.
#Basic POC, uess key/value store, recognizes keys and the executes the command in the value.
#Vocal responses are just a value with a variable, function, or string piped to Out-Speech.

#Powershiri.ps1 - Base module, maintains the listener and speaker.
#PowerShiriVoiceCommands.ps1 - Keeps long list of commands added to the Voice Recogntion key/value table. 
#PowerShiriGrammarConvert.ps1 - Functions and filter to clean up strings, so they are spoken  more clearly.


#Original code from this SO page, but should be widely-available.
#http://stackoverflow.com/questions/9361594/powershell-can-speak-but-can-it-write-if-i-speak
