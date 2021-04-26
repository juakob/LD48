package states;

import kha.input.KeyCode;
import com.framework.utils.Input;
import com.gEngine.helpers.Screen;
import com.gEngine.GEngine;
import com.gEngine.display.Sprite;
import com.framework.utils.State;

class SubState extends State {
	var textInfo:String;

	public function new(textInfo:String) {
		super();
		this.textInfo = textInfo;
	}

	var display:Sprite;
    
	override function init() {
		display = new Sprite(textInfo);
		display.offsetX = -display.width() * 0.5;
		display.offsetY = -display.height() * 0.5;
		display.x = GEngine.virtualWidth * 0.5;
		display.y = GEngine.virtualHeight * 0.5;
		stage.addChild(display);
	}

    override function update(dt:Float) {
        super.update(dt);
        if(Input.i.isKeyCodePressed(KeyCode.Space)){
            parentState.removeSubState(this);
        }
    }
}
