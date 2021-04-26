package gameObjects;

import com.gEngine.display.Layer;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;

class TitleScreen extends Entity {
    var display:Sprite;
    var time:Float=8;
    var alphaTime:Float=0;
    var alphaTransition:Float=3;
    public function new(x:Float,y:Float,layer:Layer) {
        super();
        display=new Sprite("titleScreen");
        display.alpha=0;
        display.x=x;
        display.y=y;
        layer.addChild(display);
    }
    override function update(dt:Float) {
        super.update(dt);
        time-=dt;
        if(time<0){
            alphaTime+=dt;
            var s=alphaTime/alphaTransition;
            if(s>1){
                s=1;
            }
            display.alpha=s;

        }
    }
}