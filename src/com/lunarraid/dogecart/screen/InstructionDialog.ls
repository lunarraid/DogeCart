package com.lunarraid.dogecart.screen
{
	import loom2d.display.Quad;
	import system.platform.Platform;
	import loom2d.events.EnterFrameEvent;
	import loom2d.Loom2D;
	import loom2d.events.Event;
	import loom2d.textures.Texture;
	import loom2d.ui.TextureAtlasManager;
	import loom2d.display.Image;
    import loom2d.display.Sprite;
    
    public class InstructionDialog extends Sprite
    {
        //--------------------------------------
        // CONSTANTS
        //--------------------------------------
        
        private static const UPDATE_INTERVAL:uint = 400;
        
        //--------------------------------------
        // PUBLIC
        //--------------------------------------
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _tapAnimation:Image;
        
        private var _texture1:Texture;
        private var _texture2:Texture;
        
        private var _lastUpdate:Number;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        public function InstructionDialog()
        {
            super();
            
            touchable = false;
            
            var bgQuad:Quad = new Quad( 420, 200, 0x000000 );
            bgQuad.alpha = 0.5;
            addChild( bgQuad );
            
            var textImage:Image = new Image( TextureAtlasManager.getTexture( "track", "tap-to-jump" ) );
            textImage.x = 50;
            textImage.y = 50;
            addChild( textImage );
            
            _texture1 = TextureAtlasManager.getTexture( "track", "tap-up" );
            _texture2 = TextureAtlasManager.getTexture( "track", "tap-down" );
            _tapAnimation = new Image( _texture1 );
            _tapAnimation.x = 280;
            _tapAnimation.y = 35;
            addChild( _tapAnimation );
            
            addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
            addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage );
        }
        
        //--------------------------------------
        // GETTERS / SETTERS
        //--------------------------------------
        
        
        //--------------------------------------
        // PUBLIC METHODS
        //--------------------------------------
        
        //--------------------------------------
        // PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        private function onAddedToStage( e:Event ):void
        {
            _lastUpdate = Platform.getTime();
            Loom2D.stage.addEventListener( Event.ENTER_FRAME, onFrame );
        }
        
        private function onRemovedFromStage( e:Event ):void
        {
            Loom2D.stage.removeEventListener( Event.ENTER_FRAME, onFrame );
        }
        
        private function onFrame( e:EnterFrameEvent ):void
        {
            var currentTime:Number = Platform.getTime();
            if ( currentTime - _lastUpdate < UPDATE_INTERVAL )  return;
            _lastUpdate = currentTime;
            if ( _tapAnimation.texture == _texture1 ) _tapAnimation.texture = _texture2;
            else _tapAnimation.texture = _texture1;
        }
    }
}