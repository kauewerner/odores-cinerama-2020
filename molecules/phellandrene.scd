//// PHELLANDRENE
//
n = NanoKontrol2();
~pNamesPhellandrene = [\phellandrene_A, \phellandrene_B];
~tempoBPM = TempoClock.new;
//
//// Pimenta
~pPhellandreneA = ();
~pPhellandreneA[\attack] = 0.001;
~pPhellandreneA[\release] = 0.01;
~pPhellandreneA[\volume] = 0.0001;
~pPhellandreneA[\octave] = 4;
~pPhellandreneA[\pan] = 0;
~pPhellandreneA[\notes] = 3!20;
~pPhellandreneA[\duration] = [6,3,5,6,2,5,6,8,4,9,6,11,5,12,12,6,9,7,5,9];
~pPhellandreneA[\bpm] = 99;
~createPattern.value(\phellandrene_A, \phellandrene, ~pPhellandreneA);
//
//// Elemi
~pPhellandreneB = ();
~pPhellandreneB[\attack] = 0.001;
~pPhellandreneB[\release] = 0.5;
~pPhellandreneB[\volume] = 0.05;
~pPhellandreneB[\octave] = -1;
~pPhellandreneB[\pan] = 0;
~pPhellandreneB[\notes] = 0!7;
~pPhellandreneB[\duration] = [1,10,9,8,5,1,9];
~pPhellandreneB[\bpm] = 115;
~createPattern.value(\phellandrene_B, \phellandrene, ~pPhellandreneB);
//
//// MIDI Control
//
n.playBtn.onPress = {~tempoBPM.tempo_(~pPhellandreneA[\bpm]/60); Pbindef(\phellandrene_A).play(~tempoBPM,quant:[1,0,0])};
n.recBtn.onPress = {~tempoBPM.tempo_(~pPhellandreneB[\bpm]/60); Pbindef(\phellandrene_B).play(~tempoBPM,quant:[1,0,0]); Pbindef(\phellandrene_A).stop};
n.sBtn1.onPress = {~pPhellandreneA[\notes] = (5!20).rand; Pbindef(\phellandrene_A,\freq,Pseq(((2**~pPhellandreneA[\octave])/(2**2))*~scaleDict[\phellandrene][~pPhellandreneA[\notes]],inf)).quant(~pPhellandreneA[\notes].size)};
n.sBtn3.onPress = {~pPhellandreneB[\notes] = (5!7).rand; Pbindef(\phellandrene_B,\freq,Pseq(((2**~pPhellandreneB[\octave])/(2**2))*~scaleDict[\phellandrene][~pPhellandreneB[\notes]],inf)).quant(~pPhellandreneB[\notes].size)};
n.knob1.onChange = {|val| Pbindef(\phellandrene_A,\at,val.linlin(0,127,0.001,0.1)).quant(1)};
n.knob2.onChange = {|val| Pbindef(\phellandrene_A,\re,val.linlin(0,127,0.001,0.5)).quant(1)};
n.fader1.onChange = {|val| Pbindef(\phellandrene_A,\main_amp,val.linlin(0,127,0.00001,0.1)).quant(1)};
n.fader2.onChange = {|val| ~pPhellandreneA[\octave] = (val.linlin(0,127,-3,4).asInteger); Pbindef(\phellandrene_A,\freq,Pseq(((2**~pPhellandreneA[\octave])/(2**2))*~scaleDict[\phellandrene][~pPhellandreneA[\notes]],inf)).quant(~pPhellandreneA[\notes].size)};
n.knob3.onChange = {|val| Pbindef(\phellandrene_B,\at,val.linlin(0,127,0.001,0.1)).quant(1)};
n.knob4.onChange = {|val| Pbindef(\phellandrene_B,\re,val.linlin(0,127,0.001,1)).quant(1)};
n.fader3.onChange = {|val| Pbindef(\phellandrene_B,\main_amp,val.linlin(0,127,0.00001,0.1)).quant(1)};
n.fader4.onChange = {|val| ~pPhellandreneB[\octave] = (val.linlin(0,127,-3,2).asInteger); Pbindef(\phellandrene_B,\freq,Pseq(((2**~pPhellandreneB[\octave])/(2**2))*~scaleDict[\phellandrene][~pPhellandreneB[\notes]],inf)).quant(~pPhellandreneB[\notes].size)};
n.stopBtn.onPress = {~pNamesPhellandrene.do{arg pidx; Pbindef(pidx).stop}};

