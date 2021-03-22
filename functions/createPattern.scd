~createPattern = {
	arg patternName, moleculeName, parameters;
	Pbindef(patternName,\instrument, moleculeName);
	Pbindef(patternName,\freq,Pseq(((2**parameters[\octave])/(2**2))*~scaleDict[moleculeName][parameters[\notes]],inf));
	Pbindef(patternName,\dur,Pseq((1.0/(parameters[\duration])),inf));
	Pbindef(patternName,\at,parameters[\attack]);
	Pbindef(patternName,\re,parameters[\release]);
	Pbindef(patternName,\main_amp,parameters[\volume]);
	Pbindef(patternName,\azi,parameters[\pan]);
};