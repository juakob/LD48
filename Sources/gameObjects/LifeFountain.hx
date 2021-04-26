package gameObjects;

import com.gEngine.display.Layer;
import com.collision.platformer.CollisionGroup;
import com.gEngine.display.Sprite;
import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;

class LifeFountain extends Entity {
	public var collision = new CollisionBox();

	var display:Sprite;
	var collisionGroup:CollisionGroup;

	public var isActive:Bool;

	public var unlockGravity:Bool;
	public var unlockSwim:Bool;

	public function new(x:Float, y:Float, layer:Layer, collisionGroup:CollisionGroup, visible:Bool, extraInfo:String) {
		super();
		display = new Sprite("lifeFountain");
		display.timeline.gotoAndStop(0);
		collision.width = 16 * 2;
		collision.height = 16 * 2;
		collision.userData = this;
		collision.x = display.x = x;
		collision.y = display.y = y;
		display.visible = visible;
		if (extraInfo == "swim") {
			display.timeline.gotoAndStop(2);
			unlockSwim = true;
		} else if (extraInfo == "gravity") {
			display.timeline.gotoAndStop(3);
			unlockGravity = true;
		}

		layer.addChild(display);
		collisionGroup.add(collision);
		this.collisionGroup = collisionGroup;
	}

	public function active() {
		display.timeline.gotoAndStop(1);
		isActive = true;
		collision.removeFromParent();
	}

	public function deActive() {
		display.timeline.gotoAndStop(0);
		isActive = false;
		collisionGroup.add(collision);
	}
}
