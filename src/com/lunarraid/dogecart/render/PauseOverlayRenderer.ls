package com.lunarraid.dogecart.render
{
    import loom.gameframework.LoomComponent;
	
    import loom2d.display.Quad;
    import loom2d.display.Image;
    import loom2d.display.Sprite;
    
    import loom2d.events.TouchEvent;
    import loom2d.events.TouchPhase;
    import loom2d.events.Touch;
    
    import loom2d.ui.TextureAtlasManager;
    
    import com.lunarraid.dogecart.controller.GameStateManager;
	
    public class PauseOverlayRenderer extends LoomComponent
    {
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        [Inject]
        public var viewManager:TrackViewManager;
        
        [Inject]
        public var gameStateManager:GameStateManager;
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _viewComponent:Sprite;
        private var _pauseButton:Image;
        private var _resumeButton:Image;
        private var _background:Quad;
        
        //--------------------------------------
        //  GETTERS / SETTERS
        //--------------------------------------
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        override protected function onAdd():Boolean
        {
            if ( !super.onAdd() ) return false;
            
            _viewComponent = new Sprite();
            
            _background = new Quad( 10, 10, 0x000000 );
            _background.alpha = 0.5;
            
            _resumeButton = new Image( TextureAtlasManager.getTexture( "track", "play-button" ) );
            _resumeButton.addEventListener( TouchEvent.TOUCH, onResumeTouched );
            _resumeButton.center();
            
            _pauseButton = new Image( TextureAtlasManager.getTexture( "track", "pause-button" ) );
            _pauseButton.addEventListener( TouchEvent.TOUCH, onPauseTouched );
            viewManager.uiLayer.addChild( _pauseButton );
            
            _viewComponent.addChild( _background );
            _viewComponent.addChild( _resumeButton );
            
            viewManager.resized += resize;
            resize();
            
            gameStateManager.pause += onPause;
            gameStateManager.unpause += onUnpause;
            
            return true;
        }
        
        override protected function onRemove():void
        {
            viewManager.resized -= resize;
            gameStateManager.pause -= onPause;
            gameStateManager.unpause -= onUnpause;
            _resumeButton.removeEventListener( TouchEvent.TOUCH, onResumeTouched );
            _pauseButton.removeEventListener( TouchEvent.TOUCH, onPauseTouched );
            _pauseButton.removeFromParent();
            _pauseButton.dispose();
            _viewComponent.removeFromParent();
            _viewComponent.dispose();
            _background = null;
            _resumeButton = null;
            _viewComponent = null;
            super.onRemove();
        }
        
        private function onPause():void
        {
            viewManager.uiLayer.addChild( _viewComponent );
            _pauseButton.visible = false;
        }
        
        private function onUnpause():void
        {
            _viewComponent.removeFromParent();
            _pauseButton.visible = true;
        }
        
        private function resize():void
        {
            _pauseButton.x = viewManager.viewPort.width - _pauseButton.width - 40;
            _pauseButton.y = viewManager.viewPort.height - _pauseButton.height - 40;
            _viewComponent.x = viewManager.viewPort.width * 0.5;
            _viewComponent.y = viewManager.viewPort.height * 0.5;
            _background.width = viewManager.viewPort.width;
            _background.height = viewManager.viewPort.height;
            _background.center();
        }
        
        private function onResumeTouched( e:TouchEvent ):void
        {
            var touch:Touch = e.getTouch( _resumeButton, TouchPhase.BEGAN );
            if ( !touch ) return;
            
            e.stopImmediatePropagation();
            gameStateManager.paused = false;
        }
        
        private function onPauseTouched( e:TouchEvent ):void
        {
            var touch:Touch = e.getTouch( _pauseButton, TouchPhase.BEGAN );
            if ( !touch ) return;
            
            e.stopImmediatePropagation();
            gameStateManager.paused = true;
        }
    }
}