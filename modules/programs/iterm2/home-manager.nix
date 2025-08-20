{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    ;

  cfg = config.soxincfg.programs.iterm2;
in
{
  config = mkIf cfg.enable {
    home.file.".config/iterm2/com.googlecode.iterm2.plist".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
      	<key>AllowClipboardAccess</key>
      	<true/>
      	<key>Custom Color Presets</key>
      	<dict>
      		<key>catppuccin-macchiato</key>
      		<dict>
      			<key>Ansi 0 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.39215686274509803</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30196078431372547</real>
      				<key>Red Component</key>
      				<real>0.28627450980392155</real>
      			</dict>
      			<key>Ansi 0 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.39215686274509803</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30196078431372547</real>
      				<key>Red Component</key>
      				<real>0.28627450980392155</real>
      			</dict>
      			<key>Ansi 0 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.46666666666666667</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.37254901960784315</real>
      				<key>Red Component</key>
      				<real>0.36078431372549019</real>
      			</dict>
      			<key>Ansi 1 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58823529411764708</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.52941176470588236</real>
      				<key>Red Component</key>
      				<real>0.92941176470588238</real>
      			</dict>
      			<key>Ansi 1 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58823529411764708</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.52941176470588236</real>
      				<key>Red Component</key>
      				<real>0.92941176470588238</real>
      			</dict>
      			<key>Ansi 1 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.058823529411764705</real>
      				<key>Red Component</key>
      				<real>0.82352941176470584</real>
      			</dict>
      			<key>Ansi 10 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58431372549019611</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85490196078431369</real>
      				<key>Red Component</key>
      				<real>0.65098039215686276</real>
      			</dict>
      			<key>Ansi 10 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58431372549019611</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85490196078431369</real>
      				<key>Red Component</key>
      				<real>0.65098039215686276</real>
      			</dict>
      			<key>Ansi 10 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.16862745098039217</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.62745098039215685</real>
      				<key>Red Component</key>
      				<real>0.25098039215686274</real>
      			</dict>
      			<key>Ansi 11 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.62352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83137254901960789</real>
      				<key>Red Component</key>
      				<real>0.93333333333333335</real>
      			</dict>
      			<key>Ansi 11 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.62352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83137254901960789</real>
      				<key>Red Component</key>
      				<real>0.93333333333333335</real>
      			</dict>
      			<key>Ansi 11 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.11372549019607843</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.55686274509803924</real>
      				<key>Red Component</key>
      				<real>0.87450980392156863</real>
      			</dict>
      			<key>Ansi 12 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.95686274509803926</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.54117647058823526</real>
      			</dict>
      			<key>Ansi 12 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.95686274509803926</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.54117647058823526</real>
      			</dict>
      			<key>Ansi 12 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.40000000000000002</real>
      				<key>Red Component</key>
      				<real>0.11764705882352941</real>
      			</dict>
      			<key>Ansi 13 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.90196078431372551</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.74117647058823533</real>
      				<key>Red Component</key>
      				<real>0.96078431372549022</real>
      			</dict>
      			<key>Ansi 13 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.90196078431372551</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.74117647058823533</real>
      				<key>Red Component</key>
      				<real>0.96078431372549022</real>
      			</dict>
      			<key>Ansi 13 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.79607843137254897</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.46274509803921571</real>
      				<key>Red Component</key>
      				<real>0.91764705882352937</real>
      			</dict>
      			<key>Ansi 14 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.792156862745098</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83529411764705885</real>
      				<key>Red Component</key>
      				<real>0.54509803921568623</real>
      			</dict>
      			<key>Ansi 14 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.792156862745098</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83529411764705885</real>
      				<key>Red Component</key>
      				<real>0.54509803921568623</real>
      			</dict>
      			<key>Ansi 14 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.59999999999999998</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.5725490196078431</real>
      				<key>Red Component</key>
      				<real>0.090196078431372548</real>
      			</dict>
      			<key>Ansi 15 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.79607843137254897</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.6470588235294118</real>
      			</dict>
      			<key>Ansi 15 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.79607843137254897</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.6470588235294118</real>
      			</dict>
      			<key>Ansi 15 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.80000000000000004</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.75294117647058822</real>
      				<key>Red Component</key>
      				<real>0.73725490196078436</real>
      			</dict>
      			<key>Ansi 2 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58431372549019611</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85490196078431369</real>
      				<key>Red Component</key>
      				<real>0.65098039215686276</real>
      			</dict>
      			<key>Ansi 2 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58431372549019611</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85490196078431369</real>
      				<key>Red Component</key>
      				<real>0.65098039215686276</real>
      			</dict>
      			<key>Ansi 2 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.16862745098039217</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.62745098039215685</real>
      				<key>Red Component</key>
      				<real>0.25098039215686274</real>
      			</dict>
      			<key>Ansi 3 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.62352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83137254901960789</real>
      				<key>Red Component</key>
      				<real>0.93333333333333335</real>
      			</dict>
      			<key>Ansi 3 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.62352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83137254901960789</real>
      				<key>Red Component</key>
      				<real>0.93333333333333335</real>
      			</dict>
      			<key>Ansi 3 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.11372549019607843</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.55686274509803924</real>
      				<key>Red Component</key>
      				<real>0.87450980392156863</real>
      			</dict>
      			<key>Ansi 4 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.95686274509803926</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.54117647058823526</real>
      			</dict>
      			<key>Ansi 4 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.95686274509803926</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.54117647058823526</real>
      			</dict>
      			<key>Ansi 4 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.40000000000000002</real>
      				<key>Red Component</key>
      				<real>0.11764705882352941</real>
      			</dict>
      			<key>Ansi 5 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.90196078431372551</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.74117647058823533</real>
      				<key>Red Component</key>
      				<real>0.96078431372549022</real>
      			</dict>
      			<key>Ansi 5 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.90196078431372551</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.74117647058823533</real>
      				<key>Red Component</key>
      				<real>0.96078431372549022</real>
      			</dict>
      			<key>Ansi 5 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.79607843137254897</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.46274509803921571</real>
      				<key>Red Component</key>
      				<real>0.91764705882352937</real>
      			</dict>
      			<key>Ansi 6 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.792156862745098</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83529411764705885</real>
      				<key>Red Component</key>
      				<real>0.54509803921568623</real>
      			</dict>
      			<key>Ansi 6 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.792156862745098</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83529411764705885</real>
      				<key>Red Component</key>
      				<real>0.54509803921568623</real>
      			</dict>
      			<key>Ansi 6 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.59999999999999998</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.5725490196078431</real>
      				<key>Red Component</key>
      				<real>0.090196078431372548</real>
      			</dict>
      			<key>Ansi 7 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.8784313725490196</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.75294117647058822</real>
      				<key>Red Component</key>
      				<real>0.72156862745098038</real>
      			</dict>
      			<key>Ansi 7 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.8784313725490196</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.75294117647058822</real>
      				<key>Red Component</key>
      				<real>0.72156862745098038</real>
      			</dict>
      			<key>Ansi 7 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.74509803921568629</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.69019607843137254</real>
      				<key>Red Component</key>
      				<real>0.67450980392156867</real>
      			</dict>
      			<key>Ansi 8 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.47058823529411764</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.37647058823529411</real>
      				<key>Red Component</key>
      				<real>0.35686274509803922</real>
      			</dict>
      			<key>Ansi 8 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.47058823529411764</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.37647058823529411</real>
      				<key>Red Component</key>
      				<real>0.35686274509803922</real>
      			</dict>
      			<key>Ansi 8 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.52156862745098043</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.43529411764705883</real>
      				<key>Red Component</key>
      				<real>0.42352941176470588</real>
      			</dict>
      			<key>Ansi 9 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58823529411764708</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.52941176470588236</real>
      				<key>Red Component</key>
      				<real>0.92941176470588238</real>
      			</dict>
      			<key>Ansi 9 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58823529411764708</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.52941176470588236</real>
      				<key>Red Component</key>
      				<real>0.92941176470588238</real>
      			</dict>
      			<key>Ansi 9 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.058823529411764705</real>
      				<key>Red Component</key>
      				<real>0.82352941176470584</real>
      			</dict>
      			<key>Background Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22745098039215686</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.15294117647058825</real>
      				<key>Red Component</key>
      				<real>0.14117647058823529</real>
      			</dict>
      			<key>Background Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22745098039215686</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.15294117647058825</real>
      				<key>Red Component</key>
      				<real>0.14117647058823529</real>
      			</dict>
      			<key>Background Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.94509803921568625</real>
      				<key>Red Component</key>
      				<real>0.93725490196078431</real>
      			</dict>
      			<key>Bold Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Bold Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Bold Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.41176470588235292</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30980392156862746</real>
      				<key>Red Component</key>
      				<real>0.29803921568627451</real>
      			</dict>
      			<key>Cursor Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.83921568627450982</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85882352941176465</real>
      				<key>Red Component</key>
      				<real>0.95686274509803926</real>
      			</dict>
      			<key>Cursor Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.83921568627450982</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85882352941176465</real>
      				<key>Red Component</key>
      				<real>0.95686274509803926</real>
      			</dict>
      			<key>Cursor Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.47058823529411764</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.54117647058823526</real>
      				<key>Red Component</key>
      				<real>0.86274509803921573</real>
      			</dict>
      			<key>Cursor Guide Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>0.070000000000000007</real>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Cursor Guide Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>0.070000000000000007</real>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Cursor Guide Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>0.070000000000000007</real>
      				<key>Blue Component</key>
      				<real>0.41176470588235292</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30980392156862746</real>
      				<key>Red Component</key>
      				<real>0.29803921568627451</real>
      			</dict>
      			<key>Cursor Text Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22745098039215686</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.15294117647058825</real>
      				<key>Red Component</key>
      				<real>0.14117647058823529</real>
      			</dict>
      			<key>Cursor Text Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22745098039215686</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.15294117647058825</real>
      				<key>Red Component</key>
      				<real>0.14117647058823529</real>
      			</dict>
      			<key>Cursor Text Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.94509803921568625</real>
      				<key>Red Component</key>
      				<real>0.93725490196078431</real>
      			</dict>
      			<key>Foreground Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Foreground Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Foreground Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.41176470588235292</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30980392156862746</real>
      				<key>Red Component</key>
      				<real>0.29803921568627451</real>
      			</dict>
      			<key>Link Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.8901960784313725</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.84313725490196079</real>
      				<key>Red Component</key>
      				<real>0.56862745098039214</real>
      			</dict>
      			<key>Link Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.8901960784313725</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.84313725490196079</real>
      				<key>Red Component</key>
      				<real>0.56862745098039214</real>
      			</dict>
      			<key>Link Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.89803921568627454</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.6470588235294118</real>
      				<key>Red Component</key>
      				<real>0.015686274509803921</real>
      			</dict>
      			<key>Selected Text Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Selected Text Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Selected Text Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.41176470588235292</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30980392156862746</real>
      				<key>Red Component</key>
      				<real>0.29803921568627451</real>
      			</dict>
      			<key>Selection Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.47058823529411764</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.37647058823529411</real>
      				<key>Red Component</key>
      				<real>0.35686274509803922</real>
      			</dict>
      			<key>Selection Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.47058823529411764</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.37647058823529411</real>
      				<key>Red Component</key>
      				<real>0.35686274509803922</real>
      			</dict>
      			<key>Selection Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.74509803921568629</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.69019607843137254</real>
      				<key>Red Component</key>
      				<real>0.67450980392156867</real>
      			</dict>
      		</dict>
      	</dict>
      	<key>Default Bookmark Guid</key>
      	<string>2F414D00-285D-4D3D-A82F-6D271BD3DB9B</string>
      	<key>HapticFeedbackForEsc</key>
      	<false/>
      	<key>HotkeyMigratedFromSingleToMulti</key>
      	<true/>
      	<key>IRMemory</key>
      	<integer>4</integer>
      	<key>New Bookmarks</key>
      	<array>
      		<dict>
      			<key>ASCII Anti Aliased</key>
      			<true/>
      			<key>Ambiguous Double Width</key>
      			<false/>
      			<key>Ansi 0 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.39215686274509803</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30196078431372547</real>
      				<key>Red Component</key>
      				<real>0.28627450980392155</real>
      			</dict>
      			<key>Ansi 0 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.39215686274509803</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30196078431372547</real>
      				<key>Red Component</key>
      				<real>0.28627450980392155</real>
      			</dict>
      			<key>Ansi 0 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.46666666666666667</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.37254901960784315</real>
      				<key>Red Component</key>
      				<real>0.36078431372549019</real>
      			</dict>
      			<key>Ansi 1 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58823529411764708</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.52941176470588236</real>
      				<key>Red Component</key>
      				<real>0.92941176470588238</real>
      			</dict>
      			<key>Ansi 1 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58823529411764708</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.52941176470588236</real>
      				<key>Red Component</key>
      				<real>0.92941176470588238</real>
      			</dict>
      			<key>Ansi 1 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.058823529411764705</real>
      				<key>Red Component</key>
      				<real>0.82352941176470584</real>
      			</dict>
      			<key>Ansi 10 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58431372549019611</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85490196078431369</real>
      				<key>Red Component</key>
      				<real>0.65098039215686276</real>
      			</dict>
      			<key>Ansi 10 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58431372549019611</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85490196078431369</real>
      				<key>Red Component</key>
      				<real>0.65098039215686276</real>
      			</dict>
      			<key>Ansi 10 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.16862745098039217</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.62745098039215685</real>
      				<key>Red Component</key>
      				<real>0.25098039215686274</real>
      			</dict>
      			<key>Ansi 11 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.62352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83137254901960789</real>
      				<key>Red Component</key>
      				<real>0.93333333333333335</real>
      			</dict>
      			<key>Ansi 11 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.62352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83137254901960789</real>
      				<key>Red Component</key>
      				<real>0.93333333333333335</real>
      			</dict>
      			<key>Ansi 11 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.11372549019607843</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.55686274509803924</real>
      				<key>Red Component</key>
      				<real>0.87450980392156863</real>
      			</dict>
      			<key>Ansi 12 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.95686274509803926</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.54117647058823526</real>
      			</dict>
      			<key>Ansi 12 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.95686274509803926</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.54117647058823526</real>
      			</dict>
      			<key>Ansi 12 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.40000000000000002</real>
      				<key>Red Component</key>
      				<real>0.11764705882352941</real>
      			</dict>
      			<key>Ansi 13 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.90196078431372551</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.74117647058823533</real>
      				<key>Red Component</key>
      				<real>0.96078431372549022</real>
      			</dict>
      			<key>Ansi 13 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.90196078431372551</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.74117647058823533</real>
      				<key>Red Component</key>
      				<real>0.96078431372549022</real>
      			</dict>
      			<key>Ansi 13 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.79607843137254897</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.46274509803921571</real>
      				<key>Red Component</key>
      				<real>0.91764705882352937</real>
      			</dict>
      			<key>Ansi 14 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.792156862745098</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83529411764705885</real>
      				<key>Red Component</key>
      				<real>0.54509803921568623</real>
      			</dict>
      			<key>Ansi 14 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.792156862745098</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83529411764705885</real>
      				<key>Red Component</key>
      				<real>0.54509803921568623</real>
      			</dict>
      			<key>Ansi 14 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.59999999999999998</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.5725490196078431</real>
      				<key>Red Component</key>
      				<real>0.090196078431372548</real>
      			</dict>
      			<key>Ansi 15 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.79607843137254897</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.6470588235294118</real>
      			</dict>
      			<key>Ansi 15 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.79607843137254897</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.6470588235294118</real>
      			</dict>
      			<key>Ansi 15 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.80000000000000004</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.75294117647058822</real>
      				<key>Red Component</key>
      				<real>0.73725490196078436</real>
      			</dict>
      			<key>Ansi 2 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58431372549019611</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85490196078431369</real>
      				<key>Red Component</key>
      				<real>0.65098039215686276</real>
      			</dict>
      			<key>Ansi 2 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58431372549019611</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85490196078431369</real>
      				<key>Red Component</key>
      				<real>0.65098039215686276</real>
      			</dict>
      			<key>Ansi 2 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.16862745098039217</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.62745098039215685</real>
      				<key>Red Component</key>
      				<real>0.25098039215686274</real>
      			</dict>
      			<key>Ansi 3 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.62352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83137254901960789</real>
      				<key>Red Component</key>
      				<real>0.93333333333333335</real>
      			</dict>
      			<key>Ansi 3 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.62352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83137254901960789</real>
      				<key>Red Component</key>
      				<real>0.93333333333333335</real>
      			</dict>
      			<key>Ansi 3 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.11372549019607843</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.55686274509803924</real>
      				<key>Red Component</key>
      				<real>0.87450980392156863</real>
      			</dict>
      			<key>Ansi 4 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.95686274509803926</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.54117647058823526</real>
      			</dict>
      			<key>Ansi 4 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.95686274509803926</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.54117647058823526</real>
      			</dict>
      			<key>Ansi 4 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.40000000000000002</real>
      				<key>Red Component</key>
      				<real>0.11764705882352941</real>
      			</dict>
      			<key>Ansi 5 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.90196078431372551</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.74117647058823533</real>
      				<key>Red Component</key>
      				<real>0.96078431372549022</real>
      			</dict>
      			<key>Ansi 5 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.90196078431372551</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.74117647058823533</real>
      				<key>Red Component</key>
      				<real>0.96078431372549022</real>
      			</dict>
      			<key>Ansi 5 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.79607843137254897</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.46274509803921571</real>
      				<key>Red Component</key>
      				<real>0.91764705882352937</real>
      			</dict>
      			<key>Ansi 6 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.792156862745098</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83529411764705885</real>
      				<key>Red Component</key>
      				<real>0.54509803921568623</real>
      			</dict>
      			<key>Ansi 6 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.792156862745098</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83529411764705885</real>
      				<key>Red Component</key>
      				<real>0.54509803921568623</real>
      			</dict>
      			<key>Ansi 6 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.59999999999999998</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.5725490196078431</real>
      				<key>Red Component</key>
      				<real>0.090196078431372548</real>
      			</dict>
      			<key>Ansi 7 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.8784313725490196</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.75294117647058822</real>
      				<key>Red Component</key>
      				<real>0.72156862745098038</real>
      			</dict>
      			<key>Ansi 7 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.8784313725490196</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.75294117647058822</real>
      				<key>Red Component</key>
      				<real>0.72156862745098038</real>
      			</dict>
      			<key>Ansi 7 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.74509803921568629</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.69019607843137254</real>
      				<key>Red Component</key>
      				<real>0.67450980392156867</real>
      			</dict>
      			<key>Ansi 8 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.47058823529411764</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.37647058823529411</real>
      				<key>Red Component</key>
      				<real>0.35686274509803922</real>
      			</dict>
      			<key>Ansi 8 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.47058823529411764</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.37647058823529411</real>
      				<key>Red Component</key>
      				<real>0.35686274509803922</real>
      			</dict>
      			<key>Ansi 8 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.52156862745098043</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.43529411764705883</real>
      				<key>Red Component</key>
      				<real>0.42352941176470588</real>
      			</dict>
      			<key>Ansi 9 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58823529411764708</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.52941176470588236</real>
      				<key>Red Component</key>
      				<real>0.92941176470588238</real>
      			</dict>
      			<key>Ansi 9 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58823529411764708</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.52941176470588236</real>
      				<key>Red Component</key>
      				<real>0.92941176470588238</real>
      			</dict>
      			<key>Ansi 9 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.058823529411764705</real>
      				<key>Red Component</key>
      				<real>0.82352941176470584</real>
      			</dict>
      			<key>BM Growl</key>
      			<true/>
      			<key>Background Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22745098039215686</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.15294117647058825</real>
      				<key>Red Component</key>
      				<real>0.14117647058823529</real>
      			</dict>
      			<key>Background Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22745098039215686</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.15294117647058825</real>
      				<key>Red Component</key>
      				<real>0.14117647058823529</real>
      			</dict>
      			<key>Background Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.94509803921568625</real>
      				<key>Red Component</key>
      				<real>0.93725490196078431</real>
      			</dict>
      			<key>Background Image Location</key>
      			<string></string>
      			<key>Badge Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>0.5</real>
      				<key>Blue Component</key>
      				<real>0.13960540294647217</real>
      				<key>Color Space</key>
      				<string>P3</string>
      				<key>Green Component</key>
      				<real>0.25479039549827576</real>
      				<key>Red Component</key>
      				<real>0.92929404973983765</real>
      			</dict>
      			<key>Badge Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>0.5</real>
      				<key>Blue Component</key>
      				<real>0.13960540294647217</real>
      				<key>Color Space</key>
      				<string>P3</string>
      				<key>Green Component</key>
      				<real>0.25479039549827576</real>
      				<key>Red Component</key>
      				<real>0.92929404973983765</real>
      			</dict>
      			<key>Badge Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>0.5</real>
      				<key>Blue Component</key>
      				<real>0.13960540294647217</real>
      				<key>Color Space</key>
      				<string>P3</string>
      				<key>Green Component</key>
      				<real>0.25479039549827576</real>
      				<key>Red Component</key>
      				<real>0.92929404973983765</real>
      			</dict>
      			<key>Blinking Cursor</key>
      			<false/>
      			<key>Blur</key>
      			<false/>
      			<key>Bold Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Bold Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Bold Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.41176470588235292</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30980392156862746</real>
      				<key>Red Component</key>
      				<real>0.29803921568627451</real>
      			</dict>
      			<key>Brighten Bold Text</key>
      			<true/>
      			<key>Brighten Bold Text (Dark)</key>
      			<true/>
      			<key>Brighten Bold Text (Light)</key>
      			<true/>
      			<key>Character Encoding</key>
      			<integer>4</integer>
      			<key>Close Sessions On End</key>
      			<true/>
      			<key>Columns</key>
      			<integer>80</integer>
      			<key>Command</key>
      			<string></string>
      			<key>Cursor Boost</key>
      			<real>0.0</real>
      			<key>Cursor Boost (Dark)</key>
      			<real>0.0</real>
      			<key>Cursor Boost (Light)</key>
      			<real>0.0</real>
      			<key>Cursor Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.83921568627450982</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85882352941176465</real>
      				<key>Red Component</key>
      				<real>0.95686274509803926</real>
      			</dict>
      			<key>Cursor Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.83921568627450982</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85882352941176465</real>
      				<key>Red Component</key>
      				<real>0.95686274509803926</real>
      			</dict>
      			<key>Cursor Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.47058823529411764</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.54117647058823526</real>
      				<key>Red Component</key>
      				<real>0.86274509803921573</real>
      			</dict>
      			<key>Cursor Guide Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>0.070000000000000007</real>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Cursor Guide Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>0.070000000000000007</real>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Cursor Guide Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>0.070000000000000007</real>
      				<key>Blue Component</key>
      				<real>0.41176470588235292</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30980392156862746</real>
      				<key>Red Component</key>
      				<real>0.29803921568627451</real>
      			</dict>
      			<key>Cursor Text Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22745098039215686</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.15294117647058825</real>
      				<key>Red Component</key>
      				<real>0.14117647058823529</real>
      			</dict>
      			<key>Cursor Text Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22745098039215686</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.15294117647058825</real>
      				<key>Red Component</key>
      				<real>0.14117647058823529</real>
      			</dict>
      			<key>Cursor Text Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.94509803921568625</real>
      				<key>Red Component</key>
      				<real>0.93725490196078431</real>
      			</dict>
      			<key>Custom Command</key>
      			<string>No</string>
      			<key>Custom Directory</key>
      			<string>No</string>
      			<key>Default Bookmark</key>
      			<string>No</string>
      			<key>Description</key>
      			<string>Default</string>
      			<key>Disable Window Resizing</key>
      			<false/>
      			<key>Faint Text Alpha</key>
      			<real>0.5</real>
      			<key>Faint Text Alpha (Dark)</key>
      			<real>0.5</real>
      			<key>Faint Text Alpha (Light)</key>
      			<real>0.5</real>
      			<key>Flashing Bell</key>
      			<true/>
      			<key>Foreground Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Foreground Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Foreground Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.41176470588235292</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30980392156862746</real>
      				<key>Red Component</key>
      				<real>0.29803921568627451</real>
      			</dict>
      			<key>Guid</key>
      			<string>2F414D00-285D-4D3D-A82F-6D271BD3DB9B</string>
      			<key>Horizontal Spacing</key>
      			<real>1</real>
      			<key>Idle Code</key>
      			<integer>0</integer>
      			<key>Jobs to Ignore</key>
      			<array>
      				<string>rlogin</string>
      				<string>ssh</string>
      				<string>slogin</string>
      				<string>telnet</string>
      			</array>
      			<key>Keyboard Map</key>
      			<dict/>
      			<key>Link Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.8901960784313725</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.84313725490196079</real>
      				<key>Red Component</key>
      				<real>0.56862745098039214</real>
      			</dict>
      			<key>Link Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.8901960784313725</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.84313725490196079</real>
      				<key>Red Component</key>
      				<real>0.56862745098039214</real>
      			</dict>
      			<key>Link Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.89803921568627454</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.6470588235294118</real>
      				<key>Red Component</key>
      				<real>0.015686274509803921</real>
      			</dict>
      			<key>Match Background Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>1</real>
      				<key>Blue Component</key>
      				<real>1</real>
      				<key>Color Space</key>
      				<string>P3</string>
      				<key>Green Component</key>
      				<real>1</real>
      				<key>Red Component</key>
      				<real>0.99999994039535522</real>
      			</dict>
      			<key>Match Background Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>1</real>
      				<key>Blue Component</key>
      				<real>1</real>
      				<key>Color Space</key>
      				<string>P3</string>
      				<key>Green Component</key>
      				<real>1</real>
      				<key>Red Component</key>
      				<real>0.99999994039535522</real>
      			</dict>
      			<key>Match Background Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>1</real>
      				<key>Blue Component</key>
      				<real>0.32116127014160156</real>
      				<key>Color Space</key>
      				<string>P3</string>
      				<key>Green Component</key>
      				<real>0.98600882291793823</real>
      				<key>Red Component</key>
      				<real>0.99697142839431763</real>
      			</dict>
      			<key>Minimum Contrast</key>
      			<real>0.0</real>
      			<key>Minimum Contrast (Dark)</key>
      			<real>0.0</real>
      			<key>Minimum Contrast (Light)</key>
      			<real>0.0</real>
      			<key>Mouse Reporting</key>
      			<true/>
      			<key>Name</key>
      			<string>Default</string>
      			<key>Non Ascii Font</key>
      			<string>Monaco 12</string>
      			<key>Non-ASCII Anti Aliased</key>
      			<true/>
      			<key>Normal Font</key>
      			<string>0xProtoNFM-Regular 12</string>
      			<key>Option Key Sends</key>
      			<integer>0</integer>
      			<key>Prompt Before Closing 2</key>
      			<false/>
      			<key>Right Option Key Sends</key>
      			<integer>0</integer>
      			<key>Rows</key>
      			<integer>25</integer>
      			<key>Screen</key>
      			<integer>-1</integer>
      			<key>Scrollback Lines</key>
      			<integer>1000</integer>
      			<key>Selected Text Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Selected Text Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Selected Text Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.41176470588235292</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30980392156862746</real>
      				<key>Red Component</key>
      				<real>0.29803921568627451</real>
      			</dict>
      			<key>Selection Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.47058823529411764</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.37647058823529411</real>
      				<key>Red Component</key>
      				<real>0.35686274509803922</real>
      			</dict>
      			<key>Selection Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.47058823529411764</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.37647058823529411</real>
      				<key>Red Component</key>
      				<real>0.35686274509803922</real>
      			</dict>
      			<key>Selection Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.74509803921568629</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.69019607843137254</real>
      				<key>Red Component</key>
      				<real>0.67450980392156867</real>
      			</dict>
      			<key>Send Code When Idle</key>
      			<false/>
      			<key>Shortcut</key>
      			<string></string>
      			<key>Silence Bell</key>
      			<true/>
      			<key>Smart Cursor Color</key>
      			<false/>
      			<key>Smart Cursor Color (Dark)</key>
      			<false/>
      			<key>Smart Cursor Color (Light)</key>
      			<false/>
      			<key>Sync Title</key>
      			<false/>
      			<key>Tags</key>
      			<array/>
      			<key>Terminal Type</key>
      			<string>xterm-256color</string>
      			<key>Transparency</key>
      			<real>0.0</real>
      			<key>Unlimited Scrollback</key>
      			<false/>
      			<key>Use Bold Font</key>
      			<true/>
      			<key>Use Bright Bold</key>
      			<true/>
      			<key>Use Bright Bold (Dark)</key>
      			<true/>
      			<key>Use Bright Bold (Light)</key>
      			<true/>
      			<key>Use Cursor Guide</key>
      			<false/>
      			<key>Use Cursor Guide (Dark)</key>
      			<false/>
      			<key>Use Cursor Guide (Light)</key>
      			<false/>
      			<key>Use Italic Font</key>
      			<true/>
      			<key>Use Non-ASCII Font</key>
      			<false/>
      			<key>Use Selected Text Color</key>
      			<true/>
      			<key>Use Selected Text Color (Dark)</key>
      			<true/>
      			<key>Use Selected Text Color (Light)</key>
      			<true/>
      			<key>Use Separate Colors for Light and Dark Mode</key>
      			<false/>
      			<key>Use Tab Color</key>
      			<false/>
      			<key>Use Tab Color (Dark)</key>
      			<false/>
      			<key>Use Tab Color (Light)</key>
      			<false/>
      			<key>Use Underline Color</key>
      			<false/>
      			<key>Use Underline Color (Dark)</key>
      			<false/>
      			<key>Use Underline Color (Light)</key>
      			<false/>
      			<key>Vertical Spacing</key>
      			<real>1</real>
      			<key>Visual Bell</key>
      			<true/>
      			<key>Window Type</key>
      			<integer>0</integer>
      			<key>Working Directory</key>
      			<string>/Users/wnasreddine</string>
      		</dict>
      		<dict>
      			<key>ASCII Anti Aliased</key>
      			<true/>
      			<key>Ambiguous Double Width</key>
      			<false/>
      			<key>Ansi 0 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.39215686274509803</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30196078431372547</real>
      				<key>Red Component</key>
      				<real>0.28627450980392155</real>
      			</dict>
      			<key>Ansi 0 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.39215686274509803</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30196078431372547</real>
      				<key>Red Component</key>
      				<real>0.28627450980392155</real>
      			</dict>
      			<key>Ansi 0 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.46666666666666667</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.37254901960784315</real>
      				<key>Red Component</key>
      				<real>0.36078431372549019</real>
      			</dict>
      			<key>Ansi 1 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58823529411764708</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.52941176470588236</real>
      				<key>Red Component</key>
      				<real>0.92941176470588238</real>
      			</dict>
      			<key>Ansi 1 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58823529411764708</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.52941176470588236</real>
      				<key>Red Component</key>
      				<real>0.92941176470588238</real>
      			</dict>
      			<key>Ansi 1 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.058823529411764705</real>
      				<key>Red Component</key>
      				<real>0.82352941176470584</real>
      			</dict>
      			<key>Ansi 10 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58431372549019611</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85490196078431369</real>
      				<key>Red Component</key>
      				<real>0.65098039215686276</real>
      			</dict>
      			<key>Ansi 10 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58431372549019611</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85490196078431369</real>
      				<key>Red Component</key>
      				<real>0.65098039215686276</real>
      			</dict>
      			<key>Ansi 10 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.16862745098039217</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.62745098039215685</real>
      				<key>Red Component</key>
      				<real>0.25098039215686274</real>
      			</dict>
      			<key>Ansi 11 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.62352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83137254901960789</real>
      				<key>Red Component</key>
      				<real>0.93333333333333335</real>
      			</dict>
      			<key>Ansi 11 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.62352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83137254901960789</real>
      				<key>Red Component</key>
      				<real>0.93333333333333335</real>
      			</dict>
      			<key>Ansi 11 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.11372549019607843</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.55686274509803924</real>
      				<key>Red Component</key>
      				<real>0.87450980392156863</real>
      			</dict>
      			<key>Ansi 12 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.95686274509803926</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.54117647058823526</real>
      			</dict>
      			<key>Ansi 12 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.95686274509803926</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.54117647058823526</real>
      			</dict>
      			<key>Ansi 12 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.40000000000000002</real>
      				<key>Red Component</key>
      				<real>0.11764705882352941</real>
      			</dict>
      			<key>Ansi 13 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.90196078431372551</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.74117647058823533</real>
      				<key>Red Component</key>
      				<real>0.96078431372549022</real>
      			</dict>
      			<key>Ansi 13 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.90196078431372551</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.74117647058823533</real>
      				<key>Red Component</key>
      				<real>0.96078431372549022</real>
      			</dict>
      			<key>Ansi 13 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.79607843137254897</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.46274509803921571</real>
      				<key>Red Component</key>
      				<real>0.91764705882352937</real>
      			</dict>
      			<key>Ansi 14 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.792156862745098</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83529411764705885</real>
      				<key>Red Component</key>
      				<real>0.54509803921568623</real>
      			</dict>
      			<key>Ansi 14 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.792156862745098</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83529411764705885</real>
      				<key>Red Component</key>
      				<real>0.54509803921568623</real>
      			</dict>
      			<key>Ansi 14 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.59999999999999998</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.5725490196078431</real>
      				<key>Red Component</key>
      				<real>0.090196078431372548</real>
      			</dict>
      			<key>Ansi 15 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.79607843137254897</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.6470588235294118</real>
      			</dict>
      			<key>Ansi 15 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.79607843137254897</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.6470588235294118</real>
      			</dict>
      			<key>Ansi 15 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.80000000000000004</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.75294117647058822</real>
      				<key>Red Component</key>
      				<real>0.73725490196078436</real>
      			</dict>
      			<key>Ansi 2 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58431372549019611</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85490196078431369</real>
      				<key>Red Component</key>
      				<real>0.65098039215686276</real>
      			</dict>
      			<key>Ansi 2 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58431372549019611</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85490196078431369</real>
      				<key>Red Component</key>
      				<real>0.65098039215686276</real>
      			</dict>
      			<key>Ansi 2 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.16862745098039217</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.62745098039215685</real>
      				<key>Red Component</key>
      				<real>0.25098039215686274</real>
      			</dict>
      			<key>Ansi 3 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.62352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83137254901960789</real>
      				<key>Red Component</key>
      				<real>0.93333333333333335</real>
      			</dict>
      			<key>Ansi 3 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.62352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83137254901960789</real>
      				<key>Red Component</key>
      				<real>0.93333333333333335</real>
      			</dict>
      			<key>Ansi 3 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.11372549019607843</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.55686274509803924</real>
      				<key>Red Component</key>
      				<real>0.87450980392156863</real>
      			</dict>
      			<key>Ansi 4 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.95686274509803926</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.54117647058823526</real>
      			</dict>
      			<key>Ansi 4 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.95686274509803926</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.67843137254901964</real>
      				<key>Red Component</key>
      				<real>0.54117647058823526</real>
      			</dict>
      			<key>Ansi 4 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.40000000000000002</real>
      				<key>Red Component</key>
      				<real>0.11764705882352941</real>
      			</dict>
      			<key>Ansi 5 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.90196078431372551</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.74117647058823533</real>
      				<key>Red Component</key>
      				<real>0.96078431372549022</real>
      			</dict>
      			<key>Ansi 5 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.90196078431372551</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.74117647058823533</real>
      				<key>Red Component</key>
      				<real>0.96078431372549022</real>
      			</dict>
      			<key>Ansi 5 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.79607843137254897</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.46274509803921571</real>
      				<key>Red Component</key>
      				<real>0.91764705882352937</real>
      			</dict>
      			<key>Ansi 6 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.792156862745098</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83529411764705885</real>
      				<key>Red Component</key>
      				<real>0.54509803921568623</real>
      			</dict>
      			<key>Ansi 6 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.792156862745098</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.83529411764705885</real>
      				<key>Red Component</key>
      				<real>0.54509803921568623</real>
      			</dict>
      			<key>Ansi 6 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.59999999999999998</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.5725490196078431</real>
      				<key>Red Component</key>
      				<real>0.090196078431372548</real>
      			</dict>
      			<key>Ansi 7 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.8784313725490196</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.75294117647058822</real>
      				<key>Red Component</key>
      				<real>0.72156862745098038</real>
      			</dict>
      			<key>Ansi 7 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.8784313725490196</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.75294117647058822</real>
      				<key>Red Component</key>
      				<real>0.72156862745098038</real>
      			</dict>
      			<key>Ansi 7 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.74509803921568629</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.69019607843137254</real>
      				<key>Red Component</key>
      				<real>0.67450980392156867</real>
      			</dict>
      			<key>Ansi 8 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.47058823529411764</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.37647058823529411</real>
      				<key>Red Component</key>
      				<real>0.35686274509803922</real>
      			</dict>
      			<key>Ansi 8 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.47058823529411764</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.37647058823529411</real>
      				<key>Red Component</key>
      				<real>0.35686274509803922</real>
      			</dict>
      			<key>Ansi 8 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.52156862745098043</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.43529411764705883</real>
      				<key>Red Component</key>
      				<real>0.42352941176470588</real>
      			</dict>
      			<key>Ansi 9 Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58823529411764708</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.52941176470588236</real>
      				<key>Red Component</key>
      				<real>0.92941176470588238</real>
      			</dict>
      			<key>Ansi 9 Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.58823529411764708</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.52941176470588236</real>
      				<key>Red Component</key>
      				<real>0.92941176470588238</real>
      			</dict>
      			<key>Ansi 9 Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22352941176470589</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.058823529411764705</real>
      				<key>Red Component</key>
      				<real>0.82352941176470584</real>
      			</dict>
      			<key>BM Growl</key>
      			<true/>
      			<key>Background Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22745098039215686</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.15294117647058825</real>
      				<key>Red Component</key>
      				<real>0.14117647058823529</real>
      			</dict>
      			<key>Background Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22745098039215686</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.15294117647058825</real>
      				<key>Red Component</key>
      				<real>0.14117647058823529</real>
      			</dict>
      			<key>Background Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.94509803921568625</real>
      				<key>Red Component</key>
      				<real>0.93725490196078431</real>
      			</dict>
      			<key>Background Image Location</key>
      			<string></string>
      			<key>Badge Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>0.5</real>
      				<key>Blue Component</key>
      				<real>0.13960540294647217</real>
      				<key>Color Space</key>
      				<string>P3</string>
      				<key>Green Component</key>
      				<real>0.25479039549827576</real>
      				<key>Red Component</key>
      				<real>0.92929404973983765</real>
      			</dict>
      			<key>Badge Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>0.5</real>
      				<key>Blue Component</key>
      				<real>0.13960540294647217</real>
      				<key>Color Space</key>
      				<string>P3</string>
      				<key>Green Component</key>
      				<real>0.25479039549827576</real>
      				<key>Red Component</key>
      				<real>0.92929404973983765</real>
      			</dict>
      			<key>Badge Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>0.5</real>
      				<key>Blue Component</key>
      				<real>0.13960540294647217</real>
      				<key>Color Space</key>
      				<string>P3</string>
      				<key>Green Component</key>
      				<real>0.25479039549827576</real>
      				<key>Red Component</key>
      				<real>0.92929404973983765</real>
      			</dict>
      			<key>Blinking Cursor</key>
      			<false/>
      			<key>Blur</key>
      			<false/>
      			<key>Bold Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Bold Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Bold Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.41176470588235292</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30980392156862746</real>
      				<key>Red Component</key>
      				<real>0.29803921568627451</real>
      			</dict>
      			<key>Bound Hosts</key>
      			<array/>
      			<key>Brighten Bold Text</key>
      			<true/>
      			<key>Brighten Bold Text (Dark)</key>
      			<true/>
      			<key>Brighten Bold Text (Light)</key>
      			<true/>
      			<key>Character Encoding</key>
      			<integer>4</integer>
      			<key>Close Sessions On End</key>
      			<true/>
      			<key>Columns</key>
      			<integer>80</integer>
      			<key>Command</key>
      			<string>/bin/bash --login</string>
      			<key>Cursor Boost</key>
      			<real>0.0</real>
      			<key>Cursor Boost (Dark)</key>
      			<real>0.0</real>
      			<key>Cursor Boost (Light)</key>
      			<real>0.0</real>
      			<key>Cursor Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.83921568627450982</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85882352941176465</real>
      				<key>Red Component</key>
      				<real>0.95686274509803926</real>
      			</dict>
      			<key>Cursor Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.83921568627450982</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.85882352941176465</real>
      				<key>Red Component</key>
      				<real>0.95686274509803926</real>
      			</dict>
      			<key>Cursor Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.47058823529411764</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.54117647058823526</real>
      				<key>Red Component</key>
      				<real>0.86274509803921573</real>
      			</dict>
      			<key>Cursor Guide Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>0.070000000000000007</real>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Cursor Guide Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>0.070000000000000007</real>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Cursor Guide Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>0.070000000000000007</real>
      				<key>Blue Component</key>
      				<real>0.41176470588235292</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30980392156862746</real>
      				<key>Red Component</key>
      				<real>0.29803921568627451</real>
      			</dict>
      			<key>Cursor Text Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22745098039215686</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.15294117647058825</real>
      				<key>Red Component</key>
      				<real>0.14117647058823529</real>
      			</dict>
      			<key>Cursor Text Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.22745098039215686</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.15294117647058825</real>
      				<key>Red Component</key>
      				<real>0.14117647058823529</real>
      			</dict>
      			<key>Cursor Text Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.94509803921568625</real>
      				<key>Red Component</key>
      				<real>0.93725490196078431</real>
      			</dict>
      			<key>Custom Command</key>
      			<string>Yes</string>
      			<key>Custom Directory</key>
      			<string>No</string>
      			<key>Default Bookmark</key>
      			<string>No</string>
      			<key>Description</key>
      			<string>Default</string>
      			<key>Disable Window Resizing</key>
      			<true/>
      			<key>Faint Text Alpha</key>
      			<real>0.5</real>
      			<key>Faint Text Alpha (Dark)</key>
      			<real>0.5</real>
      			<key>Faint Text Alpha (Light)</key>
      			<real>0.5</real>
      			<key>Flashing Bell</key>
      			<true/>
      			<key>Foreground Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Foreground Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Foreground Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.41176470588235292</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30980392156862746</real>
      				<key>Red Component</key>
      				<real>0.29803921568627451</real>
      			</dict>
      			<key>Guid</key>
      			<string>09494197-D757-47A6-A331-B9EB174AA659</string>
      			<key>Has Hotkey</key>
      			<false/>
      			<key>Horizontal Spacing</key>
      			<real>1</real>
      			<key>Idle Code</key>
      			<integer>0</integer>
      			<key>Jobs to Ignore</key>
      			<array>
      				<string>rlogin</string>
      				<string>ssh</string>
      				<string>slogin</string>
      				<string>telnet</string>
      			</array>
      			<key>Keyboard Map</key>
      			<dict/>
      			<key>Link Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.8901960784313725</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.84313725490196079</real>
      				<key>Red Component</key>
      				<real>0.56862745098039214</real>
      			</dict>
      			<key>Link Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.8901960784313725</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.84313725490196079</real>
      				<key>Red Component</key>
      				<real>0.56862745098039214</real>
      			</dict>
      			<key>Link Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.89803921568627454</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.6470588235294118</real>
      				<key>Red Component</key>
      				<real>0.015686274509803921</real>
      			</dict>
      			<key>Match Background Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>1</real>
      				<key>Blue Component</key>
      				<real>1</real>
      				<key>Color Space</key>
      				<string>P3</string>
      				<key>Green Component</key>
      				<real>1</real>
      				<key>Red Component</key>
      				<real>0.99999994039535522</real>
      			</dict>
      			<key>Match Background Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>1</real>
      				<key>Blue Component</key>
      				<real>1</real>
      				<key>Color Space</key>
      				<string>P3</string>
      				<key>Green Component</key>
      				<real>1</real>
      				<key>Red Component</key>
      				<real>0.99999994039535522</real>
      			</dict>
      			<key>Match Background Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<real>1</real>
      				<key>Blue Component</key>
      				<real>0.32116127014160156</real>
      				<key>Color Space</key>
      				<string>P3</string>
      				<key>Green Component</key>
      				<real>0.98600882291793823</real>
      				<key>Red Component</key>
      				<real>0.99697142839431763</real>
      			</dict>
      			<key>Minimum Contrast</key>
      			<real>0.0</real>
      			<key>Minimum Contrast (Dark)</key>
      			<real>0.0</real>
      			<key>Minimum Contrast (Light)</key>
      			<real>0.0</real>
      			<key>Mouse Reporting</key>
      			<true/>
      			<key>Name</key>
      			<string>Bash</string>
      			<key>Non Ascii Font</key>
      			<string>Monaco 12</string>
      			<key>Non-ASCII Anti Aliased</key>
      			<true/>
      			<key>Normal Font</key>
      			<string>0xProtoNFM-Regular 12</string>
      			<key>Option Key Sends</key>
      			<integer>0</integer>
      			<key>Prompt Before Closing 2</key>
      			<false/>
      			<key>Right Option Key Sends</key>
      			<integer>0</integer>
      			<key>Rows</key>
      			<integer>25</integer>
      			<key>Screen</key>
      			<integer>-1</integer>
      			<key>Scrollback Lines</key>
      			<integer>1000</integer>
      			<key>Selected Text Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Selected Text Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.96078431372549022</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.82745098039215681</real>
      				<key>Red Component</key>
      				<real>0.792156862745098</real>
      			</dict>
      			<key>Selected Text Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.41176470588235292</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.30980392156862746</real>
      				<key>Red Component</key>
      				<real>0.29803921568627451</real>
      			</dict>
      			<key>Selection Color</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.47058823529411764</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.37647058823529411</real>
      				<key>Red Component</key>
      				<real>0.35686274509803922</real>
      			</dict>
      			<key>Selection Color (Dark)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.47058823529411764</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.37647058823529411</real>
      				<key>Red Component</key>
      				<real>0.35686274509803922</real>
      			</dict>
      			<key>Selection Color (Light)</key>
      			<dict>
      				<key>Alpha Component</key>
      				<integer>1</integer>
      				<key>Blue Component</key>
      				<real>0.74509803921568629</real>
      				<key>Color Space</key>
      				<string>sRGB</string>
      				<key>Green Component</key>
      				<real>0.69019607843137254</real>
      				<key>Red Component</key>
      				<real>0.67450980392156867</real>
      			</dict>
      			<key>Send Code When Idle</key>
      			<false/>
      			<key>Shortcut</key>
      			<string></string>
      			<key>Silence Bell</key>
      			<true/>
      			<key>Smart Cursor Color</key>
      			<false/>
      			<key>Smart Cursor Color (Dark)</key>
      			<false/>
      			<key>Smart Cursor Color (Light)</key>
      			<false/>
      			<key>Sync Title</key>
      			<false/>
      			<key>Tags</key>
      			<array/>
      			<key>Terminal Type</key>
      			<string>xterm-256color</string>
      			<key>Transparency</key>
      			<real>0.0</real>
      			<key>Unlimited Scrollback</key>
      			<false/>
      			<key>Use Bold Font</key>
      			<true/>
      			<key>Use Bright Bold</key>
      			<true/>
      			<key>Use Bright Bold (Dark)</key>
      			<true/>
      			<key>Use Bright Bold (Light)</key>
      			<true/>
      			<key>Use Cursor Guide</key>
      			<false/>
      			<key>Use Cursor Guide (Dark)</key>
      			<false/>
      			<key>Use Cursor Guide (Light)</key>
      			<false/>
      			<key>Use Italic Font</key>
      			<true/>
      			<key>Use Non-ASCII Font</key>
      			<false/>
      			<key>Use Selected Text Color</key>
      			<true/>
      			<key>Use Selected Text Color (Dark)</key>
      			<true/>
      			<key>Use Selected Text Color (Light)</key>
      			<true/>
      			<key>Use Separate Colors for Light and Dark Mode</key>
      			<false/>
      			<key>Use Tab Color</key>
      			<false/>
      			<key>Use Tab Color (Dark)</key>
      			<false/>
      			<key>Use Tab Color (Light)</key>
      			<false/>
      			<key>Use Underline Color</key>
      			<false/>
      			<key>Use Underline Color (Dark)</key>
      			<false/>
      			<key>Use Underline Color (Light)</key>
      			<false/>
      			<key>Vertical Spacing</key>
      			<real>1</real>
      			<key>Visual Bell</key>
      			<true/>
      			<key>Window Type</key>
      			<integer>0</integer>
      			<key>Working Directory</key>
      			<string>/Users/wnasreddine</string>
      		</dict>
      	</array>
      	<key>PointerActions</key>
      	<dict>
      		<key>Button,1,1,,</key>
      		<dict>
      			<key>Action</key>
      			<string>kContextMenuPointerAction</string>
      		</dict>
      		<key>Button,2,1,,</key>
      		<dict>
      			<key>Action</key>
      			<string>kPasteFromClipboardPointerAction</string>
      		</dict>
      		<key>Gesture,ThreeFingerSwipeDown,,</key>
      		<dict>
      			<key>Action</key>
      			<string>kPrevWindowPointerAction</string>
      		</dict>
      		<key>Gesture,ThreeFingerSwipeLeft,,</key>
      		<dict>
      			<key>Action</key>
      			<string>kPrevTabPointerAction</string>
      		</dict>
      		<key>Gesture,ThreeFingerSwipeRight,,</key>
      		<dict>
      			<key>Action</key>
      			<string>kNextTabPointerAction</string>
      		</dict>
      		<key>Gesture,ThreeFingerSwipeUp,,</key>
      		<dict>
      			<key>Action</key>
      			<string>kNextWindowPointerAction</string>
      		</dict>
      	</dict>
      	<key>SoundForEsc</key>
      	<false/>
      	<key>TabStyleWithAutomaticOption</key>
      	<integer>4</integer>
      	<key>VisualIndicatorForEsc</key>
      	<false/>
      	<key>findMode_iTerm</key>
      	<integer>0</integer>
      </dict>
      </plist>
    '';
  };
}
