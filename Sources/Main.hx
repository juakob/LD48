package;


import states.GameState;
import kha.WindowMode;
import com.framework.Simulation;
import kha.System;
import kha.System.SystemOptions;
import kha.FramebufferOptions;
import kha.WindowOptions;


class Main {
    public static function main() {
			var windowsOptions=new WindowOptions("LD48",0,0,1280,720,null,true,WindowFeatures.FeatureResizable,WindowMode.Windowed);
		var frameBufferOptions=new FramebufferOptions();
		System.start(new SystemOptions("LD48",1280,720,windowsOptions,frameBufferOptions), function (w) {
			new Simulation(GameState,320,180,1);
        });
    }
}

