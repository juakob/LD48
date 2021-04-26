package states;

import gameObjects.TitleScreen;
import ldtk.Point;
import gameObjects.Trigger;
import com.loading.basicResources.ImageLoader;
import gameObjects.Sprint;
import gameObjects.LifeFountain;
import gameObjects.Fish;
import gameObjects.Saw;
import com.loading.basicResources.SpriteSheetLoader;
import com.gEngine.display.extra.MultiTileMapDisplay;
import com.loading.basicResources.TilesheetLoader;
import com.gEngine.display.Sprite;
import com.gEngine.display.extra.TileMapDisplay;
import com.collision.platformer.CollisionTileMap;
import kha.math.FastVector2;
import kha.Canvas;
import com.collision.platformer.CollisionGroup;
import gameObjects.Bullet;
import com.loading.basicResources.JoinAtlas;
import com.loading.basicResources.SparrowLoader;
import com.loading.Resources;
import com.collision.platformer.ICollider;
import com.collision.platformer.CollisionEngine;
import gameObjects.Invader;
import com.gEngine.display.Layer;
import gameObjects.Player;
import com.framework.utils.State;
import states.EndGame;
import levelData.LevelData;

class GameState extends State {
	var simulationLayer:Layer;
	var player:Player;
	var enemyCollision:CollisionGroup = new CollisionGroup();
	var maps:CollisionGroup;
	var water:CollisionGroup;
	var spikes:CollisionGroup;
	var fountains:CollisionGroup;
	var triggers:CollisionGroup;
	var sprints:CollisionGroup;
	var levelData:LevelData;

	var activeFountain:LifeFountain;

	override function load(resources:Resources) {
		var atlas:JoinAtlas = new JoinAtlas(1024, 1024);
		atlas.add(new TilesheetLoader("tiles", 16, 16, 0));
		atlas.add(new TilesheetLoader("saw", 16, 16, 0));
		atlas.add(new TilesheetLoader("lifeFountain", 16 * 2, 16 * 2, 0));
		atlas.add(new TilesheetLoader("fish", 16, 16, 0));
		atlas.add(new TilesheetLoader("sprint", 16, 16, 0));
		atlas.add(new TilesheetLoader("bomb", 16, 16, 0));
		atlas.add(new ImageLoader("swimInfo"));
		atlas.add(new ImageLoader("gravityInfo"));
		atlas.add(new ImageLoader("titleScreen"));
		atlas.add(new SpriteSheetLoader("ninja", 16, 16, 0, ninjaAnimations()));
		resources.add(atlas);
	}

	function ninjaAnimations():Array<Sequence> {
		var sequence = new Array<Sequence>();
		sequence.push(new Sequence("run", [2, 0, 3]));
		sequence.push(new Sequence("roll", [7, 8, 9, 10]));
		sequence.push(new Sequence("idle", [1]));
		sequence.push(new Sequence("deadFloor", [5]));
		sequence.push(new Sequence("deadAir", [18]));
		sequence.push(new Sequence("swim1", [15, 16, 17, 17, 17, 17, 17, 17, 17]));
		sequence.push(new Sequence("swim", [12, 13, 14, 14, 14, 14, 14, 14, 14]));
		sequence.push(new Sequence("duck", [11]));
		return sequence;
	}

	override function init() {
		simulationLayer = new Layer();
		stage.addChild(simulationLayer);
		maps = new CollisionGroup();
		water = new CollisionGroup();
		spikes = new CollisionGroup();
		fountains = new CollisionGroup();
		sprints = new CollisionGroup();
		triggers = new CollisionGroup();
		var background:Layer = new Layer();
		simulationLayer.addChild(background);

		GlobalGameData.simulationLayer = simulationLayer;

		levelData = new LevelData();
		for (section in levelData.levels) {
			var layer = section.l_Collisions;
			var mapIds = new Array<Int>();
			var waterIds = new Array<Int>();
			var spikesIds = new Array<Int>();
			var needToAddWater:Bool = false;
			var needToAddSpikes:Bool = false;
			for (cy in 0...layer.cHei) {
				for (cx in 0...layer.cWid) {
					var id = layer.getInt(cx, cy);
					if (id == 2) {
						id = 0;
						waterIds.push(1);
						needToAddWater = true;
						spikesIds.push(0);
					} else if (id == 3) {
						id = 0;
						spikesIds.push(1);
						needToAddSpikes = true;
						waterIds.push(0);
					} else {
						waterIds.push(0);
						spikesIds.push(0);
					}
					mapIds.push(id);
				}
			}

			var map = new CollisionTileMap(mapIds, layer.tileset.tileGridSize, layer.tileset.tileGridSize, layer.cWid, layer.cHei, 1);
			map.x = section.worldX;
			map.y = section.worldY;
			maps.add(map);

			if (needToAddWater) {
				var waterMap = new CollisionTileMap(waterIds, layer.tileset.tileGridSize, layer.tileset.tileGridSize, layer.cWid, layer.cHei, 1);
				waterMap.x = section.worldX;
				waterMap.y = section.worldY;
				water.add(waterMap);
			}
			if (needToAddSpikes) {
				var spikeMap = new CollisionTileMap(spikesIds, layer.tileset.tileGridSize, layer.tileset.tileGridSize, layer.cWid, layer.cHei, 1);
				spikeMap.x = section.worldX;
				spikeMap.y = section.worldY;
				spikes.add(spikeMap);
			}

			var display = new MultiTileMapDisplay(new Sprite("tiles"), layer.cWid, layer.cHei, 16, 16);
			display.x = section.worldX;
			display.y = section.worldY;
			for (tile in section.l_Collisions.autoTiles) {
				var x = Std.int(tile.renderX / 16);
				var y = Std.int(tile.renderY / 16);
				var id = display.getTile(0, x, y);
				var depth:Int = id == -1 ? 0 : display.depth(x, y);
				display.setTile(depth, x, y, tile.tileId, tile.flips == 1 || tile.flips == 3, tile.flips == 2 || tile.flips == 3);
			}
			background.addChild(display);

			var display = new MultiTileMapDisplay(new Sprite("tiles"), layer.cWid, layer.cHei, 16, 16);
			display.x = section.worldX;
			display.y = section.worldY;
			for (cy in 0...layer.cHei) {
				for (cx in 0...layer.cWid) {
					if (section.l_Tiles.hasAnyTileAt(cx, cy)) {
						var tiles = section.l_Tiles.getTileStackAt(cx, cy);
						var depth:Int = 0;
						for (tile in tiles) {
							display.setTile(depth++, cx, cy, tile.tileId, tile.flipBits == 1 || tile.flipBits == 3, tile.flipBits == 2 || tile.flipBits == 3);
						}
					}
				}
			}
			background.addChild(display);

			for (entity in section.l_Entities.all_Player) {
				player = new Player(section.worldX + entity.cx * 16, section.worldY + entity.cy * 16, simulationLayer);
				addChild(player);
			}

			for (entityData in section.l_Entities.all_Saw) {
				var saw = new Saw(section.worldX, section.worldY, entityData, simulationLayer, enemyCollision);
				addChild(saw);
			}
			for (entityData in section.l_Entities.all_Fish) {
				var fish = new Fish(section.worldX, section.worldY, entityData, simulationLayer, enemyCollision);
				addChild(fish);
			}
			for (entityData in section.l_Entities.all_LifeFountain) {
				var fountain = new LifeFountain(section.worldX + entityData.cx * 16, section.worldY + entityData.cy * 16, simulationLayer, fountains,
					!entityData.f_hide, entityData.f_String);
				addChild(fountain);
			}
			for (entityData in section.l_Entities.all_Sprint) {
				var sprint = new Sprint(section.worldX + entityData.cx * 16, section.worldY + entityData.cy * 16, entityData.f_inverted, simulationLayer,
					sprints);
				addChild(sprint);
			}
			for (entityData in section.l_Entities.all_Ending1) {
				var ending1 = new Trigger(section.worldX + entityData.cx * 16, section.worldY + entityData.cy * 16, entityData.width,entityData.height);
				ending1.collision.userData=endGame1;
				triggers.add(ending1.collision);
				endEnd=new FastVector2(section.worldX +entityData.f_endPos.cx* 16, section.worldY +entityData.f_endPos.cy* 16);
				endStart=new FastVector2(section.worldX + entityData.cx * 16, section.worldY + entityData.cy * 16);
				//addChild(sprint);
			}
		}

		// stage.defaultCamera().setDeadZone(88, 32, 16 * 4, 24 * 2);
	}

	var gameEnding1:Bool;
	var endingTime:Float;
	var totalEndingTime:Float=6;
	var endStart:FastVector2;
	var endEnd:FastVector2;
	var titleScreenTime:Float=0;
	function endGame1(){
		gameEnding1=true;
		addChild(new TitleScreen(endEnd.x-100,endEnd.y,simulationLayer));
	}

	override function update(dt:Float) {
		super.update(dt);
		if(gameEnding1){
			endingTime+=dt;
			var s=endingTime/totalEndingTime;
			if(s>1){
				s=1;
				
			}
			var pos=endStart.add(endEnd.sub(endStart).mult(s));
			stage.defaultCamera().setTarget(pos.x,pos.y);
			return;
		}
		CollisionEngine.collide(maps, player.collision);
		CollisionEngine.overlap(player.collision, enemyCollision, playerVsEnemy);
		CollisionEngine.overlap(player.collision,triggers,playerVsTrigger);
		CollisionEngine.overlap(player.collision, fountains, playerVsFountain);
		CollisionEngine.overlap(player.collision, sprints, playerVsSprint);
		if (CollisionEngine.overlap(water, player.collision)) {
			if (!player.swimUnlock) {
				startDeath();
			} else {
				player.inWater();
			}
		} else {
			player.outOfWater();
		}
		if (CollisionEngine.overlap(player.collision, spikes)) {
			startDeath();
		}

		// CollisionEngine.overlap(player.bulletsCollision, enemyCollision, bulletVsInvader);

		var level = levelData.getLevelAt(Std.int(player.collision.middleX), Std.int(player.collision.middleY));
		if (level != null) {
			stage.defaultCamera().limits(level.worldX, level.worldY, level.pxWid, level.pxHei);
		}

		stage.defaultCamera().setTarget(Std.int(player.collision.x), Std.int(player.collision.y));
		if (timeDeath > 0) {
			timeDeath -= dt;
			if (timeDeath <= 0) {
				player.reset(activeFountain.collision.x, activeFountain.collision.y);
			}
		}
	}

	function playerVsFountain(playerC:ICollider, fountain:ICollider) {
		var fountain:LifeFountain = cast fountain.userData;

		if (!player.swimUnlock && fountain.unlockSwim) {
			player.swimUnlock = true;
			var info = new SubState("swimInfo");
			initSubState(info);
			addSubState(info);
		}
		if (!player.gravityUnlock && fountain.unlockGravity) {
			player.gravityUnlock = true;
			var info = new SubState("gravityInfo");
			initSubState(info);
			addSubState(info);
		}
		fountain.active();
		if (this.activeFountain != null) {
			this.activeFountain.deActive();
		}
		this.activeFountain = fountain;
	}

	var timeDeath:Float = 0;

	function playerVsEnemy(playerC:ICollider, invaderC:ICollider) {
		startDeath();
	}
	function playerVsTrigger(playerC:ICollider, triggerC:ICollider) {
		triggerC.userData();
	}

	function startDeath() {
		if (!player.dying) {
			timeDeath = 2;
			player.startDie();
		}
	}

	function playerVsSprint(playerC:ICollider, sprintC:ICollider) {
		// changeState(new EndGame(false));
		var player:Player = cast playerC.userData;
		var sprint:Sprint = cast sprintC.userData;
		player.invertGravity(sprint.isPointingUp);
	}

	function bulletVsInvader(bulletC:ICollider, invaderC:ICollider) {
		var enemey:Invader = invaderC.userData;
		enemey.die();
		var bullet:Bullet = cast bulletC.userData;
		bullet.die();
	}

	override function destroy() {
		super.destroy();
		GlobalGameData.destroy();
	}

	#if DEBUGDRAW
	override function draw(framebuffer:Canvas) {
		super.draw(framebuffer);
		CollisionEngine.renderDebug(framebuffer, stage.defaultCamera());
	}
	#end
}
