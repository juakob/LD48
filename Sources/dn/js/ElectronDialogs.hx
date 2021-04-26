package dn.js;

#if !electron
#error "HaxeLib \"electron\" is required";
#end

import electron.main.IpcMain;
import electron.renderer.IpcRenderer;

class ElectronDialogs {
	static function isWindows() {
		return js.Node.process.platform.toLowerCase().indexOf("win")==0;
	}


	public static function initMain(browserWindow:electron.main.BrowserWindow) {
		if( IpcMain==null )
			throw "Should only be called in Electron Main";

		IpcMain.handle("openDialog", function(event, options) {
			var filePaths = electron.main.Dialog.showOpenDialogSync(browserWindow, options);
			return filePaths==null ? null : filePaths[0];
		});

		IpcMain.handle("saveAsDialog", function(event, options) {
			var filePaths = electron.main.Dialog.showSaveDialogSync(browserWindow, options);
			return filePaths==null ? null : filePaths;
		});
	}

	public static function openFile(?extWithDots:Array<String>, rootDir:String, onLoad:(filePath:String)->Void) {
		if( isWindows() )
			rootDir = FilePath.convertToBackslashes(rootDir);

		var options = {
			filters: extWithDots==null
				? [{ name:"Any file type", extensions:["*"] }]
				: [{ name:"Supported file types", extensions:extWithDots.map( function(ext) return ext.substr(1) ) }],
			defaultPath: rootDir,
		}
		IpcRenderer.invoke("openDialog", options).then( function(res) {
			if( res!=null )
				onLoad( Std.string(res) );
		});
	}


	public static function saveFileAs(?extWithDots:Array<String>, rootDir:String, onFileSelect:(filePath:String)->Void) {
		if( isWindows() )
			rootDir = FilePath.convertToBackslashes(rootDir);

		var options = {
			filters: extWithDots==null
				? [{ name:"Any file type", extensions:["*"] }]
				: [{ name:"Supported file types", extensions:extWithDots.map( function(ext) return ext.substr(1) ) }],
			defaultPath: rootDir,
		}
		IpcRenderer.invoke("saveAsDialog", options).then( function(res) {
			if( res!=null )
				onFileSelect( Std.string(res) );
		});
	}
}
