package gameObjects;

import com.collision.platformer.Sides;
import kha.graphics5_.TextureFilter;
import com.gEngine.display.Blend;
import com.gEngine.shaders.ShMirage;
import com.gEngine.Filter;
import com.helpers.FastPoint;
import com.soundLib.SoundManager;
import com.gEngine.display.BlendMode;
import com.gEngine.display.Layer;
import kha.input.KeyCode;
import com.framework.utils.Input;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;

class Player extends Entity {
	public var display:Sprite;

	public var collision:CollisionBox;

	var facing:Int = 1;
	var jumpPower:Float = -400;
	var isInWater:Bool;
	public var gravitySign:Int=1;
	public var dying:Bool;

	public var swimUnlock:Bool;
	public var gravityUnlock:Bool;

	public function new(x:Float, y:Float, gameLayer:Layer) {
		super();
		display = new Sprite("ninja");
		display.smooth = false;
		display.offsetX = -5;
		display.offsetY = -2;
		display.pivotX = display.width() * 0.5;
		display.pivotY = display.height()*0.5;
		display.timeline.playAnimation("idle");
		gameLayer.addChild(display);

		collision = new CollisionBox();
		collision.width = 6;
		collision.height = 14;
		collision.userData = this;

		collision.x = x;
		collision.y = y;
		collision.bounce = 0;
		collision.userData=this;
		
		outOfWater();
		
	}
	public function startDie() {
		collision.velocityY=-200*gravitySign;
		dying=true;
	}
	public function reset(x:Float,y:Float) {
		dying=false;
		invertGravity(false);
		collision.x=x;
		collision.y=y;
		collision.velocityY=0;
		collision.velocityX=0;
	}

	override function update(dt:Float) {
		super.update(dt);
		if(dying){
			if(collision.isTouching(Sides.BOTTOM)){
				display.timeline.playAnimation("deadFloor");
			}else{
				display.timeline.playAnimation("deadAir");
			}
			collision.update(dt);
			return;
		}
		collision.accelerationX = 0;
		if (Input.i.isKeyCodeDown(KeyCode.Left)) {
			collision.velocityX -= collision.maxVelocityX;
			facing = 1;
		}
		if (Input.i.isKeyCodeDown(KeyCode.Right)) {
			collision.velocityX += collision.maxVelocityX;
			facing = -1;
		}
		if (gravityUnlock && (Input.i.isKeyCodePressed(KeyCode.E)||Input.i.isKeyCodePressed(KeyCode.X))) {
			invertGravity(gravitySign>0);
		}

		if (collision.velocityY > 0) {
			stick = false;
		}
		if (stick) {
			collision.x = platform.collision.x + stickOffset.x;
			collision.y = platform.collision.y + stickOffset.y;
			collision.velocityY = 0;
		}
		if (Input.i.isKeyCodePressed(KeyCode.Space)) {
			//   SoundManager.playFx("jump").volume=0.5;
			stick = false;
			if(isInWater){

				display.timeline.playAnimation("swim",false,true);
				display.timeline.frameRate = 1 / 10;
				collision.velocityY = -jumpPower*gravitySign;
				
			}else
			if(collision.isTouching(Sides.BOTTOM|Sides.TOP)){
				collision.velocityY = -jumpPower*gravitySign;
			}
		}
		if (Input.i.isKeyCodeReleased(KeyCode.Space)) {
			collision.velocityY = collision.velocityY / 2;
		}
		collision.update(dt);
	}

	public function invertGravity(value:Bool) {
		gravitySign=value?-1:1;
		display.scaleY=gravitySign;
	}

	public function inWater() {
		collision.accelerationY = 60*gravitySign;
		jumpPower = 100;
		collision.maxVelocityX = 30;
		collision.maxVelocityY = 80;
		
		collision.dragX = 0.2;
		if(!isInWater&&display.timeline.currentAnimation!="swim"){
			display.timeline.playAnimation("swim",false);
		}
		display.timeline.frameRate = 1 / 10;
		isInWater=true;
	}

	public function outOfWater() {
		collision.accelerationY = 600*gravitySign;
		collision.maxVelocityX = 100;
		collision.maxVelocityY = 400;

		collision.dragX = 0.5;
		jumpPower = 250;
		if(isInWater&&collision.velocityY*gravitySign<0){
			collision.velocityY=-jumpPower*gravitySign;
		}
		
		isInWater=false;

	}

	override function render() {
		super.render();
		
		if(!isInWater&&!dying){
			if (collision.velocityY != 0) {
				display.timeline.playAnimation("roll");
				display.timeline.frameRate = 1 / 10;
			} else if (collision.velocityX != 0) {
				display.timeline.playAnimation("run");
				display.timeline.frameRate = 1 / 10;
			} else {
				display.timeline.playAnimation("idle");
				display.timeline.frameRate = 1 / 0.4;
			}
		}
		display.scaleX = facing;
		display.x = Std.int(collision.x);
		display.y = Std.int(collision.y);
	}

	var stick:Bool;
	var platform:Platform;
	var stickOffset:FastPoint = new FastPoint();

	public function addPlatform(platform:Platform) {
		stick = true;
		this.platform = platform;
		stickOffset.setTo(collision.x - platform.collision.x, collision.y - platform.collision.y);
	}
}
