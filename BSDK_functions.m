%% Description
% This class was developed for MATLAB by Sven Nießner .
% With this class you can easily develop programs for the gentec BEAMAGE
% 3.0 beam profiler.
% No toolboxes are required.
% Please keep the SDL.dll and the *.img file in the same order. 
% Without the dll, the function cannot be executed.
% without the *.img the camera will not start.

%Have Fun and Good Luck ;)

classdef (Sealed) BSDK_functions < handle
%%
    properties 
        BSDK = [];
        image_si = [];
        Connected = false;
        Running = false;
        autoexptime = true;
        exptime = 45;
    end
  

    methods
%%
        function [isconnected,BSDK_error,CAMiD] = initiateCAM(obj)
            if obj.Running
                error('Error: CAM is running!');
            end
            isconnected = false;
            SDK_name = 'BeamageSDK';
            asm = System.AppDomain.CurrentDomain.GetAssemblies;
            if ~any(arrayfun(@(n) strncmpi(char(asm.Get(n-1).FullName), SDK_name, length(SDK_name)), 1:asm.Length))
                    DLL_location = cd + "\BeamageSDK.dll";        
                    NET.addAssembly(DLL_location);
                    disp("BeamageSDL.dll was loaded");
            end
            try
                obj.BSDK = BeamageApi.BSDK;
            catch ME
                obj.BSDK = [];
                BSDK_error = char(ME.message);
                disp(ME);
                return;
            end
            obj.Connected = false;
            try
                obj.BSDK.AutoConnect;
            catch ME
                obj.BSDK = [];
                BSDK_error = {'No device is not aktiv','Make sure that the green light on the device is on','If not, start the camera via the PCBeamage SW'};
                CAMiD = '0';
                disp(ME);
                return;
            end
            BSDK_error = char(obj.BSDK.errorManager.Error);
            try
                CAMiD = char(obj.BSDK.camera.camProperties.GetSerialNumber());
            catch ME
                CAMiD = '0';
                obj.BSDK = [];
                BSDK_error = {'No device is not aktiv','Make sure that the green light on the device is on','If not, start the camera via the PCBeamage SW'};
                disp(ME);
                return;
            end
            isconnected = true;
            obj.BSDK.camera.SetCameraManualExposureTime(obj.exptime);
            obj.autoexptime = true;
            obj.BSDK.camera.SetToAutoExposure(true);
            obj.Connected = true;
        end
%%
        function Start(obj)
            if obj.Connected
                obj.BSDK.camera.Run();
                obj.Running = true;
            else
                error('Initiate CAM first');
            end
        end
%%
        function Stop(obj)
            if obj.Connected
                obj.BSDK.camera.StopRun();
                obj.Running = false;
            else
                error('Initiate CAM first');
            end
        end
%%
        function [image_r,image_w,image_h,centerj] = grap_image(obj)
            image_o = obj.BSDK.camera.camImg.GetLastImageArray();
            image_w = obj.BSDK.camera.camImg.width;
            image_h = obj.BSDK.camera.camImg.height;
            Data_image = double(image_o);
            image_r = zeros(image_h,image_w);
            for j = 1:1:double(image_h)
                for i = 1:1:double(image_w)
                    image_r(j,i) = Data_image(i + ((j-1)*double(image_w)));
                end
            end
            obj.image_si = image_r;
            centerj = [(double(image_h)+1)/2, (double(image_w)+1)/2];
        end
%%
        function set_exptime(obj, exptime)
           obj.BSDK.camera.SetCameraManualExposureTime(exptime);
           obj.exptime = exptime;
        end
%%
        function set_autoexptime(obj, autoexptime)
            if ~isnumeric(autoexptime)
                obj.autoexptime = autoexptime > 0;
            end
            obj.BSDK.camera.SetToAutoExposure(autoexptime);
            obj.autoexptime = autoexptime;
        end
%%
        function Disconnect(obj)
            if obj.Running
                error('Error: CAM is running!');
            end
            obj.BSDK.Dispose
            obj.Connected = false;
            obj.BSDK = [];
        end
    end
end