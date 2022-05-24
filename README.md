# Datacosmos
gentec-eo BEAMAGE-3.0 MATLAB usage

---------------------- MATLAB CODE for using ------------------
%% Define Object
beamage3 = BSDK_functions;
%View Methodes
methods(beamage3);

%% initiate CAM
beamage3.initiateCAM;

%% Start Image Acquisition
beamage3.Start;

%% Capture Image
image1 = beamage3.grap_image; %#ok<NASGU>
%or
beamage3.grap_image;
image1 = beamage3.image_si;
%display image
image(image1);

%% Change Exposure Time
beamage3.set_autoexptime(false);
beamage3.set_exptime(45);

%Capture and display image
image1 = beamage3.grap_image;
image(image1);

%% Stop Image Acquisition
beamage3.Stop;

%% Disconnect CAM
beamage3.Disconnect;
