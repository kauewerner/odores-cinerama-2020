s.boot;
s.plotTree;
s.meter;
(
MIDIClient.init;
MIDIIn.connectAll;
MIDIIn.disconnectAll
)
(
y = MIDIdef.cc(\ccTest,{
	arg vel, nn, chan, src;
	[vel , nn, chan , src].postln;

});
)

MIDIIn.findPort("nanoKONTROL2",0)

MIDIClient.sources

Quarks.gui

n = NanoKontrol2();


// register a function to be evaluted when fader1 is changed
n.fader1.onChange = {|val| (val/127).postln; }

// overwrite the previous assignment
n.fader1.onChange = {|val| val.linexp(0, 127, 20, 20000).postln; }

n.rBtn1.onPress = { "Hello, ".post; };
n.sBtn1.onRelease = { "NanoKONTROL2!".postln; };


(
n.faders.do {|fader, i|
    fader.onChange = {|val|
        "This is fader % its value is %\n".postf(i+1, val);
    }
};

n.knobs.do {|knob, i|
    knob.onChange = {|val|
        "This is knob % its value is %\n".postf(i+1, val);
    }
};

n.rBtns.do {|rBtn, i|
    rBtn.onChange = {|val|
        "This is rBtn % its value is %\n".postf(i+1, val);
    }
};
)


// assign faders 1 .. 4
n.faders[..3].do {|fader, i|
    fader.onChange = {|val|
        "This is fader % its value is %\n".postf(i+1, val);
    }
};