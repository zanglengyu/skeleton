﻿package 
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.Event;
		
	import akdcl.skeleton.ConnectionData;
	
	import akdcl.skeleton.export.TextureMix;
	
	import starling.core.Starling;
	
	/**
	 * ...
	 * @author Akdcl
	 */
    [SWF(width="800", height="600", nodeRate="2", backgroundColor="#999999")]
	public class Example06 extends flash.display.Sprite {
        [Embed(source="resource/example06_skeleton.xml", mimeType="application/octet-stream")]
        private static const skeletonData:Class;
		
        [Embed(source="resource/example06_texture.xml", mimeType="application/octet-stream")]
        private static const textureData:Class
		
        [Embed(source="resource/example06.png")]
        private static const imageData:Class;
		
		public static const textureImage:BitmapData = new imageData().bitmapData;
		
		public static const skeletonXML:XML = XML(new skeletonData());
		
		public static const textureXML:XML = XML(new textureData());
		
		public function Example06() {
			init();
		}
		
		private function init():void {
			for each(var _skeletonXML:XML in skeletonXML.skeleton) {
				ConnectionData.addData(_skeletonXML);
			}
			
			StarlingGame.texture = new TextureMix(textureImage, textureXML);
			
			//starling
			var _starling:Starling = new Starling(StarlingGame, stage);
			_starling.antiAliasing = 1;
			_starling.showStats = true;
			_starling.start();
		}
	}
}


import starling.display.Sprite;
import starling.events.EnterFrameEvent;

import akdcl.skeleton.Armature;
import akdcl.skeleton.Animation;
import akdcl.skeleton.BaseCommand;
import akdcl.skeleton.StarlingCommand;

import akdcl.skeleton.export.TextureMix;

class StarlingGame extends Sprite {
	public static var texture:TextureMix;
	public static var instance:StarlingGame;
	
	private static var enemysID:Array = ["enemy0", "enemy1", "enemy2", "enemy3", "enemy4", "enemy5", "enemy6"];
	
	private var armatures:Vector.<ArmatureExample>;
	public function StarlingGame() {
		instance = this;
		BaseCommand.armatureFactory = armatureFactory;
		
		var _id:String;
		armatures = new Vector.<ArmatureExample>;
		var _armature:ArmatureExample;
		for (var _i:uint = 0; _i < 100; _i++ ) {
			_id = enemysID[int(Math.random() * enemysID.length)];
			_armature = StarlingCommand.createArmature(_id, _id, texture) as ArmatureExample;
			_armature.randomRun();
			addChild(_armature.getDisplay() as Sprite);
			armatures.push(_armature);
		}
		
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
	}
	
	private function armatureFactory(_name:String, _aniName:String, _display:Object):Armature {
		return new ArmatureExample(_display);
	}
	
	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		var _armature:ArmatureExample;
		for each(_armature in armatures) {
			_armature.update();
		}
		armatures.sort(sortDepth);
		
		for each(_armature in armatures) {
			addChild(_armature.getDisplay() as Sprite);
		}
	}
	
	private function sortDepth(_a1:ArmatureExample, _a2:ArmatureExample):int {
		return _a1.depth > _a2.depth?1: -1;
	}
	
	
}

class ArmatureExample extends Armature {
	private var speedX:Number;
	private var speedY:Number;
	private var face:int;
	
	public function get depth():Number {
		return display.y;
	}
	
	public function ArmatureExample(_display:Object) {
		super(_display,true);
		face = Math.random() > 0.5?1: -1;
		
		display.x = -100 * Math.random() - 100;
		display.y = 200 + Math.random() * 300;
		display.scaleX = face;
		
		animation.onAnimation = animationHandler;
	}
	
	override public function update():void {
		super.update();
		
		display.x += speedX * face;
		display.y += speedY;
		if (face > 0) {
			if (display.x > StarlingGame.instance.stage.stageWidth + 100) {
				display.x = -100;
			}
		}else {
			if (display.x < 0 - 100) {
				display.x = StarlingGame.instance.stage.stageWidth + 100;
			}
		}
		
		if (display.y < 200) {
			display.y = 200;
			speedY = Math.random() * 2;
		}else if (display.y > StarlingGame.instance.stage.stageHeight) {
			speedY = -Math.random() * 2;
		}
	}
	
	public function randomRun():void {
		var _scale:Number = Math.random() * 0.3 + 0.7;
		speedX = _scale * 5;
		speedY = Math.random() * 2;
		animation.setAnimationScale(_scale);
		animation.playTo("run", 5, 20, true, 2);
	}
	
	private function animationHandler(_aniType:String, _aniID:String, _frameID:String = null):void {
		switch(_aniType) {
			case Animation.LOOP_COMPLETE:
				switch(_aniID) {
					case "run":
						if (Math.random() > 0.90) {
							speedX = 0;
							speedY = 0;
							animation.playTo("stand", 4, 20, true, 2);
						}
						break;
					case "stand":
						if (Math.random() > 0.60) {
							randomRun();
						}
						break;
				}
				break;
		}
	}
}