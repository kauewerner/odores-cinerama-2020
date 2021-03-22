// Create SynthDefs for molecules
(
~scaleDict = Dictionary.new;
~moleculeNames.do{arg molecule;
	~scaleDict.put(molecule.asSymbol,~scale[molecule.asSymbol]);
	// ~scaleDict.put(molecule.asSymbol,~frequency[molecule.asSymbol]);
	SynthDef.new(molecule,{
		arg freq = 400, main_amp = 0.01, at = 0.001, re = 0.5, azi = 0, elev = 0;
		var env, sig;
		sig = Klang.ar(`[~spectrum[molecule.asSymbol]*freq,~amplitude[molecule.asSymbol],(90.0!~spectrum[molecule.asSymbol].size).rand],1);
		env = EnvGen.ar(Env.perc(at,re),doneAction:2);
		sig = Pan2.ar(sig, azi);
		Out.ar(0, sig * env * main_amp);
	}).add;
};
"SynthDefs were created...";
)
