package gameObjects;

import states.GlobalGameData;
import kha.math.FastVector2;
import com.collision.platformer.CollisionGroup;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Layer;
import com.helpers.Rectangle;
import com.gEngine.helpers.RectangleDisplay;
import com.framework.utils.Entity;

class Invader extends Entity {
	var display:RectangleDisplay;

	public var collision:CollisionBox;
	public var facingDir:FastVector2;
	public var SPEED:Float = 80;

	public function new(x:Float, y:Float, layer:Layer, collisionGroup:CollisionGroup) {
		super();
		display = new RectangleDisplay();
		display.scaleX = 50;
		display.scaleY = 50;
		display.pivotX = 0.5;
		display.pivotY = 0.5;

		display.x = x;
		display.y = y;
		display.setColor(0, 255, 0);
		layer.addChild(display);

		collision = new CollisionBox();
		collision.width = 40;
		collision.height = 40;
		collision.x = x;
		collision.y = y;
		collisionGroup.add(collision);
		collision.userData = this;
		facingDir = new FastVector2(1, 0);
	}

	override function update(dt:Float) {
		super.update(dt);
		collision.update(dt);
		facingDir.x = GlobalGameData.player.collision.x - collision.x;
		facingDir.y = GlobalGameData.player.collision.y - collision.y;
		facingDir.setFrom(facingDir.normalized());

		collision.velocityX = facingDir.x * SPEED;
		collision.velocityY = facingDir.y * SPEED;

		display.rotation = Math.atan2(facingDir.y, facingDir.x);
	}

	override function render() {
		super.render();
		display.x = collision.x + collision.width * 0.5;
		display.y = collision.y + collision.height * 0.5;
	}

	override function destroy() {
		super.destroy();
		display.removeFromParent();
		collision.removeFromParent();
	}
}
