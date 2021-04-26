package states;

import com.gEngine.display.Sprite;
import com.loading.basicResources.ImageLoader;
import kha.input.KeyCode;
import com.framework.utils.Input;
import com.gEngine.helpers.Screen;
import com.gEngine.GEngine;
import com.gEngine.display.Text;
import com.loading.basicResources.FontLoader;
import com.loading.basicResources.JoinAtlas;
import com.loading.Resources;
import com.framework.utils.State;
import states.GameState;

class EndGame extends State {

    var winState:Bool;
    public function new(winState:Bool){
        this.winState = winState;
        super();
    }
    override function load(resources:Resources) {
        var atlas=new JoinAtlas(512,512);
        atlas.add(new FontLoader("Kenney_Thick",20));
        atlas.add(new ImageLoader("gameOver"));
        resources.add(atlas);
    }

    override function init() {
        this.stageColor(0.5,0.5,0.5);
         var text=new Text("Kenney_Thick");
         text.smooth=true;
           text.x = Screen.getWidth()*0.5-50;
           text.y = Screen.getHeight()*0.5;
           text.text="win"; 
           stage.addChild(text);
        if(winState){
          
        }else{
           var image=new Sprite("gameOver");
            image.scaleX=4;
            image.scaleY=4;
            image.smooth=false;
           image.x=200;
           image.y=200;
           stage.addChild(image);
        }
       
    }
    override function update(dt:Float) {
        super.update(dt);
        if(Input.i.isKeyCodePressed(KeyCode.Space)){
           this.changeState(new GameState());
        }
    }
}