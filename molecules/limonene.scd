//// LIMONENE
//
n = NanoKontrol2();
~tempoBPM = TempoClock.new;
~bpmScale = (~scale[\limonene]*60/(2**10)).asInteger.reverse;
~bpmList = [49, 93, 130, 192];
//
// Progressão
~pLimonene = ();
~pLimonene[\attack] = 0.001;
~pLimonene[\release] = 0.1;
~pLimonene[\volume] = 0.01;
~pLimonene[\octave] = -4;
~pLimonene[\pan] = 0;
~pLimonene[\notes] = 0!8;
~pLimonene[\duration] = 1!8;
~pLimonene[\bpm] = ~bpmList[0];
~tempoBPM.tempo_(~pLimonene[\bpm]/60);
~createPattern.value(\pLimonene, \limonene, ~pLimonene);
//
// MIDI Control
//
n.playBtn.onPress = {Pbindef(\pLimonene).play(~tempoBPM,quant:[1,0,0])};
n.stopBtn.onPress = {Pbindef(\pLimonene).stop};
n.knob1.onChange = {|val| Pbindef(\pLimonene,\at,val.linlin(0,127,0.001,2)).quant(1)};
n.knob2.onChange = {|val| Pbindef(\pLimonene,\re,val.linlin(0,127,0.1,5)).quant(1)};
n.knob3.onChange = {|val| Pbindef(\pLimonene,\main_amp,val.linlin(0,127,0.00001,0.01)).quant(1)};
n.knob4.onChange = {|val| ~pLimonene[\octave] = val.linlin(0,127,-4,2).asInteger; Pbindef(\pLimonene,\freq,Pseq(((2**~pLimonene[\octave])/(2**2))*~scaleDict[\limonene][~pLimonene[\notes]],inf)).quant(8)};
n.sBtns[..3].do {|sBtn, i| sBtn.onChange = {~tempoBPM.tempo_(~bpmList[i]/60)}};
n.faders.do{|fader, i|
	fader.onChange = {|val|
		~pLimonene[\duration][i] = val.linlin(0,127,1,16).asInteger;
		Pbindef(\pLimonene,\dur,Pseq((1.0/(~pLimonene[\duration])),inf)).quant(8);
	}
};
n.rBtns.do {|rBtn, i|
	rBtn.onChange = {
		~pLimonene[\notes][i] = (0..(~scale[\limonene].size - 1)).choose;
		Pbindef(\pLimonene,\freq,Pseq(((2**~pLimonene[\octave])/(2**2))*~scaleDict[\limonene][~pLimonene[\notes]],inf)).quant(8);
	}
};
