package gameObjects;

import com.gEngine.display.Layer;
import com.collision.platformer.Sides;
import com.helpers.FastPoint;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;

class Platform extends Entity {
    var display:Sprite;
    public var collision:CollisionBox;
    var start:FastPoint;
    var end:FastPoint;
    
    
    public function new (start:FastPoint,end:FastPoint,layer:Layer) {
        super();
        display=new Sprite("platform");
        display.smooth=false;
        layer.addChild(display);
        collision=new CollisionBox();
        collision.width=display.width();
        collision.height=display.height();
        collision.staticObject = true;
        this.start=start;
        this.end=end;
        collision.x=start.x;
        collision.y=start.y;
        collision.userData=this;
       collision.collisionAllow=Sides.TOP;
        collision.velocityY=100;
        collision.bounce=0;

    }
    override function update(dt:Float) {
        super.update(dt);
       lerpPosition(dt);
        collision.update(dt);
    }
    var time:Float=0;
    var direction:Int=1;
    function lerpPosition(dt:Float){
        time+=dt*direction;
        var s = time/4;
        if(s>1){
            s=1;
            direction=-1;
        }else 
        if(s<0){
            s=0;
            direction=1;
        }
        collision.x=Std.int(start.x+(end.x-start.x)*s);
        collision.y=Std.int(start.y+(end.y-start.y)*s);
       /* if(collision.y>end.y){
            collision.velocityY=-60;
        }else 
        if(collision.y<start.y){
            collision.velocityY=60;
        }*/
       // collision.velocityY=60*direction;
    }
    override function render() {
        super.render();
        display.x = Std.int(collision.x);
        display.y = Std.int(collision.y);
    }
}