package states;

import gameObjects.Player;
import com.gEngine.display.Layer;

class GlobalGameData {
	static public var simulationLayer:Layer;
	static public var player:Player;

	static public function destroy() {
		simulationLayer = null;
		player=null;
	}
}
