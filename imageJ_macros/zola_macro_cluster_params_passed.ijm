//*
//* @Debayan MPI-CBG
//*

args = getArgument();

parameters = split(args, ",");

file_path = parameters[0];
plugin_string = parameters[1];
//  spaces are causing problems when passed to command line, so use "Q" as a spacer
//  the > is also problematic, replace with R
// unreplace space for "Q" and ">" for "R"
plugin_parameters_with_spaces = replace(plugin_string, "Q", " ");
plugin_parameters = replace(plugin_parameters_with_spaces, "R", ">");

print("In macro");
print("***args***");
print(args);
print("***plugin_string***");
print(plugin_string);
print("***file_path***");
print(file_path);
print("***plugin_parameters***");
print(plugin_parameters);

processFolder(file_path); 

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	start = getTime();
	print(input);
	list = getFileList(input);
	list = Array.sort(list);
	print(list.length)
	for (i = 0; i < list.length; i++) {
		print(list[i]);
		if(File.isDirectory(input + File.separator + list[i])){
			l = substring(list[i], 0, lengthOf(list[i])-1);
			processFolder(input + File.separator + l + File.separator);
		}
		if(endsWith(list[i], ".tif")){
			processFile(input, list[i]);
		}
	}
	print("Total Time: "+(getTime()-start)/1000);   
}

function processFile(input, file) {
	print("Processing: "+ input + File.separator + file);
	if (indexOf(input, "patches") > 0) {
		if (!File.exists(File.getParent(input) + File.separator + "zola_raw")){
			File.makeDirectory(File.getParent(input) + File.separator + "zola_raw"); 
		}
	output = File.getParent(input) + File.separator + "zola_raw"+ File.separator + substring(file, 0, indexOf(file, '.tif'))+'.json';
	print(output);

	open(input + File.separator + file);
	setSlice((nSlices+1)/2); 
	makePoint(getWidth()/2, getHeight()/2);
//	wid = 64;
//  run(" Calibration: PSF modeling", "run_on_gpu gain=1 pixel_size=100 z_step=50 bead_moving=[far -> close to objective] numerical_aperture=1.2 immersion_refractive=1.33 wavelength=0.515 patch_size="+wid+" zernike_coefficient=[Zernike 15 coefs] iteration=100 result_calibration_file="+output);
    print(" Calibration: PSF modeling", ""+plugin_parameters+output);
    run(" Calibration: PSF modeling", ""+plugin_parameters+output);

	run("Close All");
	}
	else{print("No patches");
	}
}
