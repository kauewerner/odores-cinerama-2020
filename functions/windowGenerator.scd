(
~windowDict = Dictionary.new;
~activationDict = Dictionary.new;
~playButtonDict = Dictionary.new;
~durationDict = Dictionary.new;
~notesDict = Dictionary.new;
~currentValues = Dictionary.new;
~parameterRange = Dictionary.new;
~initialValue = Dictionary.new;
~parameterRange[\attack] = [0.001,5];
~parameterRange[\release] = [0.001,5];
~parameterRange[\steps] = [1,20];
~parameterRange[\duration] = [1,16];
~parameterRange[\octave] = [-4,2];
~bpm = 120;
~moleculeNames.do{arg idx; ~activationDict[idx.asSymbol] = false};

//// BEGIN -> generate window function ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ////
~generate_window = {
	arg moleculeName;
	var wi, he, atKnob, reKnob, durKnob, knobSize, windowSize,
	themeColor,stepKnobValue,stepNB,octNB,octValue,activeSeq;
	activeSeq = [];
	stepKnobValue = 1;
	octValue = 1;
	themeColor = Color.new(0.5.rand + 0.5,0.5.rand + 0.5,0.5.rand + 0.5);
	windowSize = Rect(Window.screenBounds.width/4,
			Window.screenBounds.height/4,
			Window.screenBounds.width/5,
			Window.screenBounds.height/1.5
	);

	//// initialize parameters (if not imported from file) ================================================== ////
	if(~flagLoadFile == False,{
		~initialValue[moleculeName.asSymbol] = Dictionary.new;
		~initialValue[moleculeName.asSymbol][\octave] = 0;
		~initialValue[moleculeName.asSymbol][\volume] = 0.015;
		~initialValue[moleculeName.asSymbol][\attack] = 0.01;
		~initialValue[moleculeName.asSymbol][\release] = 0.1;
		~initialValue[moleculeName.asSymbol][\pan] = 0;
		~initialValue[moleculeName.asSymbol][\notes] = [0];
		~initialValue[moleculeName.asSymbol][\duration] = [1];
		~initialValue[moleculeName.asSymbol][\steps] = 1;
	});

	//// initialize dictionaries to save current values ================================================== ////
	~currentValues[moleculeName.asSymbol] = Dictionary.new;
	~currentValues[moleculeName.asSymbol] = ~initialValue[moleculeName.asSymbol];

	//// initialize patterns ============================================================================= ////
	Pbindef(moleculeName.asSymbol,\instrument,moleculeName);
	// Pbindef(moleculeName.asSymbol,\freq,Pseq(~scaleDict[moleculeName.asSymbol],inf));
	Pbindef(moleculeName.asSymbol,\freq,Pseq(((2**~initialValue[moleculeName.asSymbol][\octave])/(2**2))*~scaleDict[moleculeName.asSymbol][~initialValue[moleculeName.asSymbol][\notes]],inf));
	Pbindef(moleculeName.asSymbol,\dur,Pseq((60/~bpm)*(1.0/(~initialValue[moleculeName.asSymbol][\duration])),inf));
	Pbindef(moleculeName.asSymbol,\at,~initialValue[moleculeName.asSymbol][\attack]);
	Pbindef(moleculeName.asSymbol,\re,~initialValue[moleculeName.asSymbol][\release]);
	Pbindef(moleculeName.asSymbol,\main_amp,~initialValue[moleculeName.asSymbol][\volume]);
	Pbindef(moleculeName.asSymbol,\pan,~initialValue[moleculeName.asSymbol][\pan]);

	//// molecule window ================================================================================ ////
	~windowDict[moleculeName.asSymbol] = Window.new(moleculeName.asString,windowSize)
	.front
	.background_(themeColor)
	.alwaysOnTop_(true);
	wi = ~windowDict[moleculeName.asSymbol].bounds.width;
	he = ~windowDict[moleculeName.asSymbol].bounds.height;
	knobSize = 0.15;

	//// play/stop button =============================================================================== ////
	~playButtonDict[moleculeName.asSymbol] = Button(~windowDict[moleculeName.asSymbol],Rect(0.1*wi,0.1*he,75,50))
	.states_([
		["play",Color.black,Color.white],
		["stop",Color.white,Color.black],
	])
	.action_({
		arg obj;
		if(obj.value == 1,{
			Pbindef(moleculeName.asSymbol).play;
			if(~playStopAll.value != 1,{~playStopAll.value_(1)});
		},
			{
			Pbindef(moleculeName.asSymbol).stop;
		});

	});

	//// pan slider =================================================================================== ////
	Slider(~windowDict[moleculeName.asSymbol],Rect(0.2*wi,0.425*he,0.6*wi,0.05*he))
	.background_(Color.white)
	.knobColor_(Color.black)
	.valueAction_(~initialValue[moleculeName.asSymbol][\pan].linlin(-1.0,1.0,0,1.0))
	.action_({
		arg obj;
		Pbindef(moleculeName.asSymbol,\azi,obj.value.linlin(0,1.0,-1.0,1.0));
		~currentValues[moleculeName.asSymbol]['pan'] = obj.value.linlin(0,1.0,-1.0,1.0);

	});
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.45*wi,0.475*he,0.8*wi,50))
	.string_("pan");
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.125*wi,0.425*he,0.05*wi,0.05*he))
	.string_("L");
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.85*wi,0.425*he,0.05*wi,0.05*he))
	.string_("R");

	//// volume knob =================================================================================== ////
	Knob(~windowDict[moleculeName.asSymbol],Rect(0.15*wi,0.25*he,knobSize*wi,knobSize*wi))
	.valueAction_(~initialValue[moleculeName.asSymbol][\volume].linlin(0,0.05,0,1.0))
	.action_({
		arg obj;
		Pbindef(moleculeName.asSymbol,\main_amp,obj.value.linlin(0,1.0,0,0.5));
		~currentValues[moleculeName.asSymbol]['volume'] = obj.value.linlin(0,1.0,0,0.5);
	});
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.15*wi,0.325*he,80,50))
	.align_(\center)
	.string_("volume");

	//// attack knob =================================================================================== ////
	Knob(~windowDict[moleculeName.asSymbol],Rect(0.45*wi,0.25*he,knobSize*wi,knobSize*wi))
	.valueAction_(~initialValue[moleculeName.asSymbol][\attack].explin(~parameterRange[\attack][0],~parameterRange[\attack][1],0.0,1.0))
	.action_({
		arg obj;
		Pbindef(moleculeName.asSymbol,\at,obj.value.linexp(0,1,~parameterRange[\attack][0],~parameterRange[\attack][1]));
		~currentValues[moleculeName.asSymbol]['attack'] = obj.value.linexp(0,1,~parameterRange[\attack][0],~parameterRange[\attack][1]);
	});
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.45*wi,0.325*he,80,50))
	.align_(\center)
	.string_("attack");

	//// release knob =================================================================================== ////
	Knob(~windowDict[moleculeName.asSymbol],Rect(0.75*wi,0.25*he,knobSize*wi,knobSize*wi))
	.valueAction_(~initialValue[moleculeName.asSymbol][\release].explin(~parameterRange[\release][0],~parameterRange[\release][1],0.0,1.0))
	.action_({
		arg obj;
		Pbindef(moleculeName.asSymbol,\re,obj.value.linexp(0,1,0.01,5));
		~currentValues[moleculeName.asSymbol]['release'] = obj.value.linexp(0,1,~parameterRange[\release][0],~parameterRange[\release][1]);
	});
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.75*wi,0.325*he,80,50))
	.align_(\center)
	.string_("release");

	//// notes multislider =================================================================================== ////
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.1*wi,0.55*he,0.125*wi,0.125*he))
	.string_("\+ \n notes \n \-")
	.stringColor_(Color.white)
	.background_(Color.black)
	.align_(\center);
	~notesDict[moleculeName.asSymbol] = MultiSliderView(~windowDict[moleculeName.asSymbol],Rect(0.225*wi,0.55*he,0.675*wi,0.125*he))
	.valueAction_(Pbindef(moleculeName.asSymbol,\freq,Pseq(((2**octValue.asInteger)/(2**2))*~scaleDict[moleculeName.asSymbol][~initialValue[moleculeName.asSymbol][\notes].asInteger],inf));)
	.size_(~initialValue[moleculeName.asSymbol][\steps])
	.action_({
		arg obj;
		obj.value.linlin(0,1,0,~scaleDict[moleculeName.asSymbol].size - 1).asInteger.postln;
		~currentValues[moleculeName.asSymbol]['notes'] = obj.value.linlin(0,1,0,~scaleDict[moleculeName.asSymbol].size - 1).asInteger;
		Pbindef(moleculeName.asSymbol,\freq,Pseq(((2**octValue.asInteger)/(2**2))*~scaleDict[moleculeName.asSymbol][obj.value.linlin(0,1,0,(~scaleDict[moleculeName.asSymbol].size - 1)).asInteger],inf));
	})
	.strokeColor_(Color.black)
	.fillColor_(themeColor)
	.drawLines_(true)
	.showIndex_(true)
	.elasticMode_(1);

	//// octave selector =================================================================================== ////
	octNB = NumberBox(~windowDict[moleculeName.asSymbol],Rect(0.8*wi,0.1*he,0.1*wi,0.05*he))
	.valueAction_(~initialValue[moleculeName.asSymbol][\octave])
	.align_('center')
	.background_(Color.black)
	.normalColor_(Color.white);
	Knob(~windowDict[moleculeName.asSymbol],Rect(0.6*wi,0.09*he,knobSize*wi,knobSize*wi))
	.valueAction_(~initialValue[moleculeName.asSymbol][\octave].asFloat.linlin(~parameterRange[\octave][0],~parameterRange[\octave][1],0,1))
	.action_({
		arg obj;
		octValue = obj.value.asFloat.linlin(0,1,~parameterRange[\octave][0],~parameterRange[\octave][1]);
		octValue.postln;
		octNB.valueAction_(octValue.asInteger);
		Pbindef(moleculeName.asSymbol,\freq,Pseq(((2**octValue.asInteger)/(2**2))*~scaleDict[moleculeName.asSymbol][~notesDict[moleculeName.asSymbol].value.linlin(0,1,0,(~scaleDict[moleculeName.asSymbol].size - 1)).asInteger],inf));
		~currentValues[moleculeName.asSymbol]['octave'] = octValue.asInteger;
	});
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.35*wi,0.1*he,0.25*wi,0.05*he))
	.align_(\center)
	.stringColor_(Color.black)
	.string_("octave #");

	//// duration multislider =================================================================================== ////
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.1*wi,0.7*he,0.125*wi,0.125*he))
	.string_("\- \n dur \n \+")
	.stringColor_(Color.white)
	.background_(Color.black)
	.align_(\center);
	~durationDict[moleculeName.asSymbol] = MultiSliderView(~windowDict[moleculeName.asSymbol],Rect(0.225*wi,0.7*he,0.675*wi,0.125*he))
	.valueAction_(~initialValue[moleculeName.asSymbol][\duration].value.linlin(~parameterRange[\duration][0],~parameterRange[\duration][1],0,1))
	.size_(~initialValue[moleculeName.asSymbol][\steps])
	.action_({
		arg obj;
		((60/~bpm)*(1.0/(obj.value.linlin(0,1,~parameterRange[\duration][0],~parameterRange[\duration][1]).asInteger))).postln;
		Pbindef(moleculeName.asSymbol,\dur,Pseq((60/~bpm)*(1.0/(obj.value.linlin(0,1,~parameterRange[\duration][0],~parameterRange[\duration][1]).asInteger)),inf));
		~currentValues[moleculeName.asSymbol]['duration'] = ((60/~bpm)*(1.0/(obj.value.linlin(0,1,~parameterRange[\duration][0],~parameterRange[\duration][1]).asInteger)));
	})
	.strokeColor_(Color.black)
	.fillColor_(themeColor)
	.drawLines_(true)
	.showIndex_(true)
	.elasticMode_(1);

	//// number of steps knob =================================================================================== ////
	stepNB = NumberBox(~windowDict[moleculeName.asSymbol],Rect(0.6*wi,0.89*he,0.1*wi,0.05*he))
	.valueAction_(~initialValue[moleculeName.asSymbol][\steps])
	.align_('center')
	.background_(Color.black)
	.normalColor_(Color.white);
	Knob(~windowDict[moleculeName.asSymbol],Rect(0.4*wi,0.875*he,knobSize*wi,knobSize*wi))
	.action_({
		arg obj;
		stepKnobValue = obj.value.asFloat.linlin(0,1,~parameterRange[\steps][0],~parameterRange[\steps][1]).asInteger;
		stepNB.valueAction_(stepKnobValue);
		// dstep = stepKnobValue - ~durationDict[moleculeName.asSymbol].value.size;
		~durationDict[moleculeName.asSymbol].size_(stepKnobValue)
		/*.valueAction_({
			var len = ~currentValues[moleculeName.asSymbol]['duration'].size, tmpArray = ~currentValues[moleculeName.asSymbol]['duration'];
			if(len < stepKnobValue,{
				(stepKnobValue - len).do{
					// ~currentValues[moleculeName.asSymbol]['duration'] = ~currentValues[moleculeName.asSymbol]['duration'].add((60/~bpm)*(1.0/(~parameterRange[\duration][0].asInteger)))
					tmpArray = tmpArray.add(0.5);
				};
				~currentValues[moleculeName.asSymbol]['duration'] = tmpArray;
			});
			if(len > stepKnobValue,{
				~currentValues[moleculeName.asSymbol]['duration'] = ~currentValues[moleculeName.asSymbol]['duration'][0..(stepKnobValue - 1)];
			});
			Pbindef(moleculeName.asSymbol,\dur,Pseq(~currentValues[moleculeName.asSymbol]['duration'],inf));
		})*/;
		~notesDict[moleculeName.asSymbol].size_(stepKnobValue)
		/*.valueAction_({
			var len = ~currentValues[moleculeName.asSymbol]['notes'].size, tmpArray = ~currentValues[moleculeName.asSymbol]['notes'];
			if(len < stepKnobValue,{
				(stepKnobValue - len).do{
					tmpArray = tmpArray.add(0);
				};
				~currentValues[moleculeName.asSymbol]['notes'] = tmpArray;
			});
			if(len > stepKnobValue,{
				~currentValues[moleculeName.asSymbol]['notes'] = ~currentValues[moleculeName.asSymbol]['notes'][0..(stepKnobValue - 1)];
			});
			Pbindef(moleculeName.asSymbol,\freq,Pseq(((2**~currentValues[moleculeName.asSymbol]['octave'].asInteger)/(2**2))*~scaleDict[moleculeName.asSymbol][~currentValues[moleculeName.asSymbol]['notes'].asInteger],inf));
		})*/;
		~currentValues[moleculeName.asSymbol]['steps'] = stepKnobValue;
	});
	StaticText(~windowDict[moleculeName.asSymbol],Rect(0.15*wi,0.89*he,0.25*wi,0.05*he))
	.align_(\center)
	.stringColor_(Color.black)
	.string_("# of steps");

	~windowDict[moleculeName.asSymbol].onClose_({
			Pbindef(moleculeName.asSymbol).stop;
			Pbindef(moleculeName.asSymbol).clear;
		});


};
//// END -> generate window function +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ////

//// BEGIN -> molecule selection window +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ////
~molIdx = 0;
~activeMolecules = [];
Window.closeAll;
w = Window.new("Molecule selector",Rect.new(Window.screenBounds.width*0.35,Window.screenBounds.height*0.6,Window.screenBounds.width/4,Window.screenBounds.height/4))
.front
.background_(Color.white)
.alwaysOnTop_(true);
//// END -> molecule selection window +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ////

//// BEGIN -> selection menu +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //////
StaticText(w,Rect(w.bounds.width/3,w.bounds.height*0.05,2*w.bounds.width/3,w.bounds.height/6))
.font_(Font.new(Font.defaultSansFace,22,true))
.string_("Choose a molecule:");
PopUpMenu.new(w,Rect(w.bounds.width/5,0.2*w.bounds.height,w.bounds.width/2,w.bounds.height/6))
.items_(~moleculeNames)
.action_({
	arg obj;
	~molIdx = obj.value;
});
Button(w,Rect(w.bounds.width*0.7,0.2*w.bounds.height,0.1*w.bounds.width,w.bounds.height/6))
.states_([
["ok",Color.black,Color.new(0,1,0.5)]
])
.action_({
	arg obj;
	if(obj.value == 0,{
		~generate_window.value(~moleculeNames[~molIdx]);
		~activeMolecules = ~activeMolecules.add(~moleculeNames[~molIdx]);
		/*~windowDict[~moleculeNames[~molIdx].asSymbol].onClose_({
			Pbindef(~moleculeNames[~molIdx].asSymbol).stop;
			Pbindef(~moleculeNames[~molIdx].asSymbol).clear;
		});*/
	});
});
//// END -> selection menu +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //////

//// BEGIN -> bpm knob +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //////
~bpmRange = [10,300];
~bpmNB = NumberBox(w,Rect(0.425*w.bounds.width,0.5*w.bounds.height,0.15*w.bounds.width,0.1*w.bounds.height))
.valueAction_(~bpm)
.align_('center')
.background_(Color.black)
.normalColor_(Color.white);
Knob(w,Rect(0.3*w.bounds.width,0.45*w.bounds.height,0.2*w.bounds.height,0.2*w.bounds.height))
.valueAction_((~bpm-~bpmRange[0])/(~bpmRange[1]-~bpmRange[0]))
.step_(1.0/(~bpmRange[1]-~bpmRange[0]))
.action_({
	arg obj;
    ~bpm = obj.value.asFloat.linlin(0,1,~bpmRange[0],~bpmRange[1]).asInteger;
	~bpmNB.valueAction_(obj.value.asFloat.linlin(0,1,~bpmRange[0],~bpmRange[1]).asInteger);
	~activeMolecules.do{arg idx;
		Pbindef(idx.asSymbol,\dur,Pseq((60/~bpm)*(1.0/(~durationDict[idx.asSymbol].value.linlin(0,1,~parameterRange[\duration][0],~parameterRange[\duration][1]).asInteger)),inf));
		if(~activationDict[idx.asSymbol],{
			Pbindef(idx.asSymbol).play;
		})
	};
});
StaticText(w,Rect(0.575*w.bounds.width,0.5*w.bounds.height,0.1*w.bounds.width,0.1*w.bounds.height))
.align_(\center)
.stringColor_(Color.black)
.string_("bpm");
//// END -> bpm knob +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //////

//// BEGIN -> play/stop all sequences +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //////
~playStopAll = Button(w,Rect(w.bounds.height/6,w.bounds.height*0.75,w.bounds.height/2.5,w.bounds.height/6))
.states_([
["play all",Color.black,Color.white],
["stop all",Color.white,Color.black],
])
.action_({
	arg obj;
	if(obj.value == 0,{
		~activeMolecules.do{arg mIdx;
			Pbindef(mIdx.asSymbol).stop;
			~playButtonDict[mIdx.asSymbol].valueAction_(0);
			~activationDict[mIdx.asSymbol] = false;
		};
	});
	if(obj.value == 1,{
		~activeMolecules.do{arg mIdx;
			Pbindef(mIdx.asSymbol).play;
			~playButtonDict[mIdx.asSymbol].valueAction_(1);
			~activationDict[mIdx.asSymbol] = true;
		};
	});
});
//// END -> play/stop all sequences +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //////

//// BEGIN -> close all windows +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //////
Button(w,Rect((w.bounds.width/1.25) - (w.bounds.height/6),w.bounds.height*0.75,w.bounds.height/3,w.bounds.height/6))
.states_([
["close all",Color.white,Color.red]
])
.action_({
	arg obj;
	if(obj.value == 0,{
		if(~saveFlag == True,{
			var f, date;
			date = Date.getDate;
			f = File(~path++"saved_sequences/saved_seq_"
				++date.day.asString++"_"
				++date.month.asString++"_"
				++date.year.asString++"_"
				++date.hour.asString++"_"
				++date.minute.asString++"_"
				++date.second.asString++".txt","w");
			f.write("molecule\toctave\tvolume\tattack\trelease\tpan\tnotes\tduration\tsteps\n");
			~activeMolecules.do{arg mIdx;
				f.write(mIdx++"\t");
				f.write(~currentValues[mIdx.asSymbol][\octave].asString++"\t");
				f.write(~currentValues[mIdx.asSymbol][\volume].asString++"\t");
				f.write(~currentValues[mIdx.asSymbol][\attack].asString++"\t");
				f.write(~currentValues[mIdx.asSymbol][\release].asString++"\t");
				f.write(~currentValues[mIdx.asSymbol][\pan].asString++"\t");
				f.write(~currentValues[mIdx.asSymbol][\notes].asString++"\t");
				f.write(~currentValues[mIdx.asSymbol][\duration].asString++"\t");
				f.write(~currentValues[mIdx.asSymbol][\steps].asString++"\n");
			};
			f.close
		});
		Window.closeAll;
		~activeMolecules.do{arg mIdx; Pbindef(mIdx.asSymbol).stop};
		~activeMolecules.do{arg mIdx; Pbindef(mIdx.asSymbol).clear};
		~activeMolecules.do{arg idx; ~activationDict[idx.asSymbol] = false};
		~activeMolecules = [];
	});
});
//// END -> close all windows +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ////

//// BEGIN -> Load sequences from file +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ////
if(~flagLoadFile == True, {
	var inputFile, parameterList;
	inputFile = TabFileReader.read(~path++"saved_sequences/"++~inputFileName);
	parameterList = inputFile[0][(1..(inputFile[0].size-1))];
	parameterList.postln;
	(1..(inputFile.size - 1)).do{
		arg mIdx;
		~activeMolecules = ~activeMolecules.add(inputFile[mIdx][0]);
		~initialValue[inputFile[mIdx][0].asSymbol] = Dictionary.new;
		(1..(inputFile[mIdx].size - 1)).do{
			arg pIdx;
			if( ( (parameterList[pIdx - 1] == "notes") || (parameterList[pIdx - 1] == "duration") ),{
				var idxList, tempList, comaIndices;
				comaIndices = inputFile[mIdx][pIdx].findAll(",");
				idxList = (2,5..(inputFile[mIdx][pIdx].size - 2));
				idxList.postln;
				// comaIndices.postln;
				tempList = [];
				tempList = tempList.add(inputFile[mIdx][pIdx][2..(comaIndices[0]-1)].asString.asFloat);
				tempList.postln;
				(comaIndices.size - 1).do{
					arg sIdx;
					tempList.postln;
					tempList = tempList.add(inputFile[mIdx][pIdx][(comaIndices[sIdx]+2)..(comaIndices[sIdx+1]-1)].asString.asFloat)
				};
				tempList = tempList.add(inputFile[mIdx][pIdx][(comaIndices.last+2)..(inputFile[mIdx][pIdx].size - 2)].asString.asFloat);
				tempList.postln;
				~initialValue[inputFile[mIdx][0].asSymbol][parameterList[pIdx - 1].asSymbol] = tempList;
			},{
				~initialValue[inputFile[mIdx][0].asSymbol][parameterList[pIdx - 1].asSymbol] = inputFile[mIdx][pIdx].asString.asFloat;
		})
		};
		~initialValue[inputFile[mIdx][0].asSymbol].postln;
		/*~initialValue[moleculeName.asSymbol][\octave] = 0;
		~initialValue[moleculeName.asSymbol][\volume] = 0.015;
		~initialValue[moleculeName.asSymbol][\attack] = 0.01;
		~initialValue[moleculeName.asSymbol][\release] = 0.1;
		~initialValue[moleculeName.asSymbol][\pan] = 0;
		~initialValue[moleculeName.asSymbol][\notes] = [0,1,2,3];
		~initialValue[moleculeName.asSymbol][\duration] = [1,1,2,4];
		~initialValue[moleculeName.asSymbol][\steps] = 4;*/
		~generate_window.value(inputFile[mIdx][0].asSymbol);
	};
	~activeMolecules.postln;
});
)
//// END -> Load sequences from file +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ////