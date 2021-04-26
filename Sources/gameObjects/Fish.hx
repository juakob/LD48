package gameObjects;

import com.collision.platformer.Sides;
import com.collision.platformer.CollisionGroup;
import kha.math.FastVector2;
import com.gEngine.display.Layer;
import com.gEngine.display.Sprite;
import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;
import levelData.LevelData;

class Fish extends Entity {
	var collision:CollisionBox;
	var display:Sprite;
	var start:FastVector2;
	var end:FastVector2;
	var time:Float = 0;
	var totalTime:Float = 0;
	var dir:Int = 1;
	var collisionGroup:CollisionGroup;

	var damageTime:Float = 0;
	var totalDamageTime:Float = 1;
	var totalWaitTime:Float = 4;
	var attacking:Bool = false;

	public function new(worldOffsetX:Float, worldOffsetY:Float, data:Entity_Fish, layer:Layer, enemyCollision:CollisionGroup) {
		super();
		display = new Sprite("fish");
		display.timeline.gotoAndStop(1);
		layer.addChild(display);
		collision = new CollisionBox();
		collision.width = 10;
		collision.height = 10;
		display.offsetX = -3;
		display.offsetY = -3;
		display.pivotX = display.width() * 0.5;
		
		collisionGroup=enemyCollision;


		this.start = new FastVector2(worldOffsetX + data.cx * 16, worldOffsetY + data.cy * 16);
		var end = data.f_End;
		this.end = new FastVector2(worldOffsetX + end.cx * 16, worldOffsetY + end.cy * 16);
		totalTime = this.end.sub(this.start).length / data.f_velocity;
		
	}

	override function update(dt:Float) {
		super.update(dt);
		time += dt * dir;
		var s = time / totalTime;
		if (s > 1) {
			s = 1;
			dir = -1;
			time = totalTime;
		} else if (s < 0) {
			s = 0;
			dir = 1;
			time = 0;
		}
		collision.update(0);
		var pos = start.add(end.sub(start).mult(s));
		collision.x = pos.x + 3;
		collision.y = pos.y + 3;
		display.scaleX = -dir;

		damageTime += dt;
		if (attacking) {
			collision.collisionAllow = Sides.ALL;
			if (damageTime > totalDamageTime) {
				attacking = false;
				damageTime = 0;
				collision.removeFromParent();
			}
		} else {
			collision.collisionAllow = Sides.NONE;
			if (damageTime > totalWaitTime) {
				attacking = true;
				damageTime = 0;
				collisionGroup.add(collision);
			}
		}
	}

	override function render() {
		super.render();
		if (attacking) {
			display.timeline.gotoAndStop(0);
		} else {
			display.timeline.gotoAndStop(1);
		}
		display.x = collision.x;
		display.y = collision.y;
	}
}
