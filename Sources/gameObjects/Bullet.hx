package gameObjects;

import com.collision.platformer.CollisionGroup;
import states.GlobalGameData;
import kha.math.FastVector2;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.helpers.RectangleDisplay;
import com.framework.utils.Entity;

class Bullet extends Entity {
	var display:RectangleDisplay;
	var collision:CollisionBox;
	var width:Int = 3;
	var height:Int = 2;
	var speed:Float = 1000;
	var time:Float = 0;

	public function new(x:Float, y:Float, dir:FastVector2,collisionGroup:CollisionGroup) {
		super();
		display = new RectangleDisplay();
		display.setColor(255, 0, 0);
		display.scaleX = width;
		display.scaleY = height;
		GlobalGameData.simulationLayer.addChild(display);

		collision = new CollisionBox();
		collision.width = width;
		collision.height = height;
		collision.x = x - width * 0.5;
		collision.y = y - height * 0.5;
		collision.velocityX = dir.x * speed;
		collision.velocityY = dir.y * speed;
        collision.userData=this;
        collisionGroup.add(collision);
	}

	override function update(dt:Float) {
		time += dt;
		super.update(dt);
		collision.update(dt);
		if (time > 4) {
			die();
		}
	}

	override function render() {
		super.render();
		display.x = collision.x;
		display.y = collision.y;
	}

	override function destroy() {
		super.destroy();
		display.removeFromParent();
        collision.removeFromParent();
	}
}
