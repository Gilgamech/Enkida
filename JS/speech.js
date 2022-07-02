//Gil.JS

// wait on voices to be loaded before fetching list
  
window.speechSynthesis.onvoiceschanged = function() {
    // console.log(window.speechSynthesis.getVoices());
};

function SayThis(saythis) {
	var msg = new SpeechSynthesisUtterance();
	var voices = window.speechSynthesis.getVoices();
	
	msg.voice = voices[1]; // Note: some voices don't support altering params
	msg.voiceURI = 'native';
	msg.volume = 1; // 0 to 1
	msg.rate = 1; // 0.1 to 10
	msg.pitch = 0.5; //0 to 2
	msg.text = saythis;
	msg.lang = 'en-US';
	
	// console.log(msg);
	// console.log(speechSynthesis);
	// console.log(window.speechSynthesis.getVoices());
	// console.log(speechSynthesis.getVoices());
	// console.log(getVoices());
	speechSynthesis.speak(msg)
};

// SayThis("test")

/*
function SayThis(saythis) {
// voices = this.getVoices();
	var msg = new window.SpeechSynthesisUtterance(saythis);
	var voices = speechSynthesis.getVoices();
	msg.voice = voices[1]; // Note: some voices don't support altering params
	msg.voiceURI = 'native';
	msg.volume = 1; // 0 to 1
	msg.rate = 1; // 0.1 to 10
	msg.pitch = 1; //0 to 2
	// msg.text = saythis;
	msg.lang = 'en-US';
	speechSynthesis.addEventListener('voiceschanged', 	speechSynthesis.speak(msg));
};

*/ 

/*
let voices, msg;
  msg = new window.SpeechSynthesisUtterance('Hello World'); 
  console.log(voices)
  speechSynthesis.voice = voices[1];
  console.log(msg.voice);
  window.speechSynthesis.speak(msg);
*/ 

/*
function SayThis(saythis) {
	var msg = new window.SpeechSynthesisUtterance();
	var voices = window.speechSynthesis.getVoices();
	
	
	speechSynthesis.speak(msg);
};

*/ 

