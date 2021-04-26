package gameObjects;

import com.gEngine.display.Layer;
import com.collision.platformer.CollisionGroup;
import com.gEngine.display.Sprite;
import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;

class Sprint extends Entity {
	public var collision = new CollisionBox();

	var display:Sprite;
	var collisionGroup:CollisionGroup;

	public var isPointingUp(default, null):Bool;

	public var isActive:Bool;

	public function new(x:Float, y:Float, flipY:Bool, layer:Layer, collisionGroup:CollisionGroup) {
		super();
		display = new Sprite("sprint");
		display.timeline.gotoAndStop(0);
		collision.width = 16 ;
		collision.height = 16 ;
		collision.userData = this;
		display.pivotY = display.height() * 0.5;
		display.scaleY = flipY ? -1 : 1;
		collision.x = display.x = x;
		collision.y = display.y = y;
		isPointingUp = !flipY;
		collision.userData=this;

		layer.addChild(display);
		collisionGroup.add(collision);
		this.collisionGroup = collisionGroup;
	}
}
