// extract IR data from files ======================================
(
var pathEntries;
pathEntries = PathName(~path++"IR_data").entries;
~database = ();
~numberOfMolecules = pathEntries.size;
~moleculeNames = []!~numberOfMolecules;
pathEntries.do{arg pIdx;
	/*~database = Array.fill(
		~numberOfMolecules,{arg i;
			[pIdx.fileNameWithoutExtension,TabFileReader.read(pIdx.fullPath,true)];
		};
	);*/
	~database.put(pIdx.fileNameWithoutExtension.asSymbol,TabFileReader.read(pIdx.fullPath,true));
};
(0..(~numberOfMolecules-1)).do{arg i;
	~moleculeNames[i] = pathEntries[i].fileNameWithoutExtension;
};
"IR data sucessfully extracted from database...";
)
