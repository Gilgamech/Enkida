# .\PowerShiriGrammarConvert.ps1 Build: 13 2016-05-01T21:23:29 Copyright Gilgamech Technologies   

#These are all different ways of converting text from what is stored in the system, and into what sounds good when said by the Speech-To-Text.

#Brute-force
filter ConvertVoice-CleanSpeech
{
if ($_){
$_ = $_.Replace("svc","service")
$_ = $_.Replace("dll","dee ell ell")
$_ = $_.Replace("LENOVO","Lenovo")
$_ = $_.Replace("(R)"," ")
$_ = $_.Replace("(TM)"," ")
$_ = $_.Replace# .\PowerShiriGrammarConvert.ps1 Build: 13 2016-05-01T21:23:29 Copyright Gilgamech Technologies   

#These are all different ways of converting text from what is stored in the system, and into what sounds good when said by the Speech-To-Text.

#Brute-force
filter ConvertVoice-CleanSpeech($Symbol = "") {
	if ($_){
		$_ = $_.Replace("svc","service")
		$_ = $_.Replace("dll","dee ell ell")
		$_ = $_.Replace("LENOVO","Lenovo")
		$_ = $_.Replace("(R)"," ")
		$_ = $_.Replace("(TM)"," ")
		$_ = $_.Replace("GHz","gigga Hz")

		#region Wikipedia
		#Remove HTML tags
		$_ = $_.Replace("`<B`>",$Symbol)
		$_ = $_.Replace("`<`/B`>",$Symbol)
		$_ = $_.Replace("`<I`>",$Symbol)
		$_ = $_.Replace("`<`/I`>",$Symbol)

		$_ = $_.Replace("`<A",$Symbol)
		$_ = $_.Replace("`<`/A`>",$Symbol)

		$_ = $_.Replace("</SPAN>",$Symbol)
		$_ = $_.Replace("<SPAN",$Symbol)
		$_ = $_.Replace("<SPAN",$Symbol)
		$_ = $_.Replace("<SUP>",$Symbol)
		$_ = $_.Replace("</SUP>",$Symbol)
		$_ = $_.Replace("<SUP id=cite_ref-",$Symbol)
		$_ = $_.Replace("<SUP class=",$Symbol)
		$_ = $_.Replace('href="/wiki/'," ")
		$_ = $_.Replace('&quot;','"')
		$_ = $_.Replace('&quot','"')
		$_ = $_.Replace('&#039;',"'")
		$_ = $_.Replace('&scaron;','s')
		$_ = $_.Replace('&#039;',"'")
		$_ = $_.Replace('&ldquo;','"')
		$_ = $_.Replace('&rdquo;','"')
		$_ = $_.Replace('">'," ")
		$_ = $_.Replace("title="," ")
		$_ = $_.Replace("class=",$Symbol)
		$_ = $_.Replace('href="#cite_note-',$Symbol)
		$_ = $_.Replace("reference>",$Symbol)
		$_ = $_.Replace('reference style="WHITE-SPACE: nowrap :',$Symbol)
		$_ = $_.Replace("noblp_20",$Symbol)
		#$_ = $_.Replace(' nowrap`> sortkey style`=`"DISPLAY: none',$Symbol) #This one didn't work, dunno why.
		$_ = $_.Replace(" nowrap`>",$Symbol)
		$_ = $_.Replace("sortkey style=",$Symbol)
		$_ = $_.Replace('"DISPLAY: none',$Symbol)
		$_ = $_.Replace('style="MARGIN-LEFT:',$Symbol)
		$_ = $_.Replace('"; MARGIN-RIGHT:',$Symbol) 


#endregion

		#$_ = $_ -replace(" ",$Symbol)
		$_ = $_ -replace("``",$Symbol)
		#$_ = $_ -replace("[~]",$Symbol)
		#$_ = $_ -replace("[!]",$Symbol)
		#$_ = $_ -replace("[@]",$Symbol)
		#$_ = $_ -replace("[#]",$Symbol)
		#$_ = $_ -replace("[$]",$Symbol)
		#$_ = $_ -replace("[%]",$Symbol)
		$_ = $_ -replace("[\^]",$Symbol)
		#$_ = $_ -replace("[&]",$Symbol)
		#$_ = $_ -replace("[*]",$Symbol)
		#$_ = $_ -replace("[(]",$Symbol)
		#$_ = $_ -replace("[)]",$Symbol)
		$_ = $_ -replace("[[]",$Symbol)
		$_ = $_ -replace("[]]",$Symbol)
		#$_ = $_ -replace("[-]",$Symbol)
		#$_ = $_ -replace("[=]",$Symbol)
		#$_ = $_ -replace("[+]",$Symbol)
		$_ = $_ -replace("[{]",$Symbol)
		$_ = $_ -replace("[}]",$Symbol)
		$_ = $_ -replace("\\",$Symbol)
		$_ = $_ -replace("[|]",$Symbol)
		#$_ = $_ -replace("[:]",$Symbol)
		$_ = $_ -replace("[;]",$Symbol)
		#$_ = $_ -replace('["]',$Symbol)
		#$_ = $_ -replace("[']",$Symbol)
		$_ = $_ -replace("[<]",$Symbol)
		#$_ = $_ -replace("[,]",$Symbol)
		$_ = $_ -replace("[>]",$Symbol)
		#$_ = $_ -replace("[.]",$Symbol)
		#$_ = $_ -replace("[?]",$Symbol)
		$_ = $_ -replace("[/]",$Symbol)
		#$_ = $_ -replace("_",$Symbol)
		#$_ = $_ -replace "Exists",("Exists" + $Symbol)
		#$_ = $_ -replace "Where",("Where" + $Symbol)

<#
	$_ = $_.Replace("",$Symbol)
	$_ = $_.Replace("",$Symbol)
#>

	} #end if - if it's null, dump it back out.
	return $_
} #end ConvertVoice-CleanSpeech


#Convert True to Yes, and False to No.  
function Convert-TrueToYes {
	Param(
		$textinput = $true
	); #end Param
	If ($textinput) { 
		return "Yes"
	} else { 
		return "No"
	}; #end If
}; #end Convert-TrueToYesItIs

#Convert True to a little more verbose Yes, and False into a longer No.
function Convert-TrueToYesItIs {
	Param(
		$textinput = $true
	); #end Param
	If ($textinput) { 
		return "Yes, it is"
	} else { 
		return "No, it is not"
	}; #end If
}; #end Convert-TrueToYesItIs


#Convert integer numbers into ordinal numbers.
Function Convert-Ordinal {
#http://powershell.org/wp/2013/04/12/friday-fun-get-anniversary-2/
Param([int]$i)

Switch ($i %100) {
 #handle special cases
 11 {$sfx = "th" } 
 12 {$sfx = "th" } 
 13 {$sfx = "th" } 
 default {
    Switch ($i % 10) {
        1  { $sfx = "st" }
        2  { $sfx = "nd" }
        3  { $sfx = "rd" }
        default { $sfx = "th" }
    } #inner switch
 } #default
} #outerswitch
 #write the result to the pipeline
 "$i$sfx"
} #end Get-Ordinal



<#
#Template 
Function Get-TupleName {
#http://powershell.org/wp/2013/04/12/friday-fun-get-anniversary-2/
Param([int]$i)

Switch ($i %100) {
 #handle special cases
 11 {$sfx = "th" } 
 12 {$sfx = "th" } 
 13 {$sfx = "th" } 
 default {
    Switch ($i % 10) {
        1  { $sfx = "st" }
        2  { $sfx = "nd" }
        3  { $sfx = "rd" }
        default { $sfx = "th" }
    } #inner switch
 } #default
} #outerswitch
 #write the result to the pipeline
 "$i$sfx"
} #end Get-Ordinal
#>

<#
#Template 
function Convert-TrueToYes {
Param(
    $textinput = $true
); #end Param
If ($textinput) { 
return "Yes"
} else { 
return "No"
}; #end If
}; #end Convert-TrueToYesItIs
#>



$_ = $_.Replace('href="/wiki/'," ")
$_ = $_.Replace('">'," ")
$_ = $_.Replace("title="," ")
$_ = $_.Replace("class=","")
$_ = $_.Replace('href="#cite_note-',"")
$_ = $_.Replace("reference>","")
$_ = $_.Replace('reference style="WHITE-SPACE: nowrap :',"")
$_ = $_.Replace("noblp_20","")
#$_ = $_.Replace(' nowrap`> sortkey style`=`"DISPLAY: none',"") #This one didn't work, dunno why.
$_ = $_.Replace(" nowrap`>","")
$_ = $_.Replace("sortkey style=","")
$_ = $_.Replace("`"DISPLAY: none","")
$_ = $_.Replace("style=`"MARGIN-LEFT:","")
$_ = $_.Replace("`; MARGIN-RIGHT:","")


#endregion
<#
$_ = $_.Replace("","")
$_ = $_.Replace("","")
#>

} #end if - if it's null, dump it back out.
return $_
} #end ConvertVoice-CleanSpeech


#Convert True to Yes, and False to No.  
function Convert-TrueToYes {
Param(
    $textinput = $true
); #end Param
If ($textinput) { 
return "Yes"
} else { 
return "No"
}; #end If
}; #end Convert-TrueToYesItIs

#Convert True to a little more verbose Yes, and False into a longer No.
function Convert-TrueToYesItIs {
Param(
    $textinput = $true
); #end Param
If ($textinput) { 
return "Yes, it is"
} else { 
return "No, it is not"
}; #end If
}; #end Convert-TrueToYesItIs


#Convert integer numbers into ordinal numbers.
Function Convert-Ordinal {
#http://powershell.org/wp/2013/04/12/friday-fun-get-anniversary-2/
Param([int]$i)

Switch ($i %100) {
 #handle special cases
 11 {$sfx = "th" } 
 12 {$sfx = "th" } 
 13 {$sfx = "th" } 
 default {
    Switch ($i % 10) {
        1  { $sfx = "st" }
        2  { $sfx = "nd" }
        3  { $sfx = "rd" }
        default { $sfx = "th" }
    } #inner switch
 } #default
} #outerswitch
 #write the result to the pipeline
 "$i$sfx"
} #end Get-Ordinal



<#
#Template 
Function Get-TupleName {
#http://powershell.org/wp/2013/04/12/friday-fun-get-anniversary-2/
Param([int]$i)

Switch ($i %100) {
 #handle special cases
 11 {$sfx = "th" } 
 12 {$sfx = "th" } 
 13 {$sfx = "th" } 
 default {
    Switch ($i % 10) {
        1  { $sfx = "st" }
        2  { $sfx = "nd" }
        3  { $sfx = "rd" }
        default { $sfx = "th" }
    } #inner switch
 } #default
} #outerswitch
 #write the result to the pipeline
 "$i$sfx"
} #end Get-Ordinal
#>

<#
#Template 
function Convert-TrueToYes {
Param(
    $textinput = $true
); #end Param
If ($textinput) { 
return "Yes"
} else { 
return "No"
}; #end If
}; #end Convert-TrueToYesItIs
#>


