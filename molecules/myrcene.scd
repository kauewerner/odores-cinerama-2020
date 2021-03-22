//// MYRCENE
//
n = NanoKontrol2();
~pNamesMyrcene = [\myrcene_A, \myrcene_B];
~tempoBPM = TempoClock.new;
//
//// Primeiros odores (Louro e Manjericão)
~pMyrceneA = ();
~pMyrceneA[\attack] = 2;
~pMyrceneA[\release] = 4;
~pMyrceneA[\volume] = 0.0001;
~pMyrceneA[\octave] = -3;
~pMyrceneA[\pan] = 0;
~pMyrceneA[\notes] = [0 , 5, 4, 1 ];
~pMyrceneA[\duration] = [1, 2, 6, 3];
~pMyrceneA[\bpm] = 25;
~createPattern.value(\myrcene_A, \myrcene, ~pMyrceneA);
//
//// Segunda parte (Tomilho)
~pMyrceneB = ();
~pMyrceneB[\attack] = 0.001;
~pMyrceneB[\release] = 1;
~pMyrceneB[\volume] = 0.15;
~pMyrceneB[\octave] = 1;
~pMyrceneB[\pan] = 0;
~pMyrceneB[\notes] = [2, 6, 4, 0, 3, 0, 0, 0];
~pMyrceneB[\duration] = [1, 4, 1, 1, 1, 1, 1, 1];
~pMyrceneB[\bpm] = 133;
~createPattern.value(\myrcene_B, \myrcene, ~pMyrceneB);
//
//// MIDI Control
//
n.playBtn.onPress = {~tempoBPM.tempo_(~pMyrceneA[\bpm]/60); Pbindef(\myrcene_A).play(~tempoBPM,quant:[1,0,0])};
n.recBtn.onPress = {~tempoBPM.tempo_(~pMyrceneB[\bpm]/60); Pbindef(\myrcene_B).play(~tempoBPM,quant:[1,0,0]); Pbindef(\myrcene_A).stop};
n.knob1.onChange = {|val| Pbindef(\myrcene_A,\at,val.linlin(0,127,0.001,2)).quant(1)};
n.knob2.onChange = {|val| Pbindef(\myrcene_A,\re,val.linlin(0,127,0.1,5)).quant(1)};
n.fader1.onChange = {|val| Pbindef(\myrcene_A,\main_amp,val.linlin(0,127,0.00001,0.2)).quant(1)};
n.fader2.onChange = {|val| ~pMyrceneA[\octave] = val.linlin(0,127,-4,2).asInteger; Pbindef(\myrcene_A,\freq,Pseq(((2**~pMyrceneA[\octave])/(2**2))*~scaleDict[\myrcene][~pMyrceneA[\notes]],inf)).quant(~pMyrceneA[\notes].size); Pbindef(\myrcene_A,\dur,Pseq((1.0/(~pMyrceneA[\duration])),inf)).quant(~pMyrceneA[\notes].size)};
n.knob3.onChange = {|val| Pbindef(\myrcene_B,\at,val.linlin(0,127,0.001,0.1)).quant(1)};
n.knob4.onChange = {|val| Pbindef(\myrcene_B,\re,val.linlin(0,127,0.01,2)).quant(1)};
n.fader3.onChange = {|val| Pbindef(\myrcene_B,\main_amp,val.linlin(0,127,0.00001,0.25)).quant(1)};
n.fader4.onChange = {|val| ~pMyrceneB[\octave] = val.linlin(0,127,-4,2).asInteger; Pbindef(\myrcene_B,\freq,Pseq(((2**~pMyrceneB[\octave])/(2**2))*~scaleDict[\myrcene][~pMyrceneB[\notes]],inf)).quant(~pMyrceneB[\notes].size); Pbindef(\myrcene_B,\dur,Pseq((1.0/(~pMyrceneB[\duration])),inf)).quant(~pMyrceneB[\notes].size)};
n.stopBtn.onPress = {~pNamesMyrcene.do{arg pidx; Pbindef(pidx).stop}};

