//// SINTODRAMA-ODORES-CINERAMA 2020 ===================================////
//
//
//
//// INIT ============================================================= ////
//
(
// Get current working path
~path = PathName(thisProcess.nowExecutingPath).parentPath;
// Import specific IR data
this.executeFile(~path++"functions/extractIRfromFile.scd");
// Get Sound Parameters
this.executeFile(~path++"functions/getSoundParameters.scd");
// Create Synths
this.executeFile(~path++"functions/createSynthDefs.scd");
// Create Pattern function
this.executeFile(~path++"functions/createPattern.scd");
// Initialize MIDI
MIDIClient.init;
MIDIIn.connectAll;
n = NanoKontrol2();
// boot the server
s.latency  = 0.0125;
s.boot;
)
s.quit;
//
//// MYRCENE ========================================================== ////
//
this.executeFile(~path++"molecules/myrcene.scd");
//
//// LIMONENE ========================================================= ////
//
this.executeFile(~path++"molecules/limonene.scd");
//
//// PHELLANDRENE ===================================================== ////
//
this.executeFile(~path++"molecules/phellandrene.scd");
//