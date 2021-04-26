package gameObjects;

import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;

class Trigger extends Entity {
    public var collision:CollisionBox;
    public function new(x:Float,y:Float,width:Float,height:Float) {
        super();
        collision=new CollisionBox();
        collision.x=x;
        collision.y=y;
        collision.width=width;
        collision.height=height;
    }

    
}