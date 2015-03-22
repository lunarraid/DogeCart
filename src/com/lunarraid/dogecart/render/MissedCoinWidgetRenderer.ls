package com.lunarraid.dogecart.render
{
	import loom2d.Loom2D;
	import loom2d.textures.Texture;
	import loom2d.math.Matrix;
    import loom2d.display.Quad;
    import loom2d.display.QuadBatch;
    import loom2d.display.Image;
    import loom2d.display.Sprite;
    import loom2d.ui.TextureAtlasManager;
    
    import com.lunarraid.dogecart.controller.GameStateManager;
    import com.lunarraid.dogecart.time.DeltaAnimatedComponent;
    import com.lunarraid.dogecart.TrackConstants;
	
    public class MissedCoinWidgetRenderer extends DeltaAnimatedComponent
    {
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        [Inject]
        public var viewManager:TrackViewManager;
        
        [Inject]
        public var gameStateManager:GameStateManager;
        
        //--------------------------------------
        // CONSTANTS
        //--------------------------------------
        
        public static const TRAY_WIDTH:int = 100;
        
        private static const CLOSE_DELAY:Number = 2;
        
        private static const STATE_OPENING:String = "Opening";
        private static const STATE_CLOSING:String = "Closing";
        private static const STATE_OPEN:String = "Open";
        private static const STATE_CLOSED:String = "Closed";
        
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _viewComponent:Sprite;
        private var _trayContainer:QuadBatch;
        private var _coinImage:Image;
        private var _redQuad:Image;
        private var _matrix:Matrix;
        private var _coinsMissed:int;
        private var _rowHeight:int;
        private var _state:String = STATE_CLOSED;
        
        //--------------------------------------
        //  GETTERS / SETTERS
        //--------------------------------------
        
        public function get coinsMissed():int { return _coinsMissed; }
        
        public function set coinsMissed( value:int ):void
        {
            if ( _coinsMissed == value ) return;
            if ( _coinsMissed < value ) openTray();
            _coinsMissed = value;
            updateCoinDisplay();
        }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        override public function onFrame( deltaTime:Number ):void
        {
            super.onFrame( deltaTime );
            coinsMissed = gameStateManager.coinsMissed;
        }
        
        public function updateCoinDisplay():void
        {
            _trayContainer.reset();
            
            for ( var i:int = 0; i < TrackConstants.MAX_MISSED_COINS; i++ )
            {
                _redQuad.y = _coinImage.y = _rowHeight * i + _rowHeight * 0.5;
                
                if ( _coinsMissed > i )
                {
                    _coinImage.alpha = 0.5;
                    _trayContainer.addQuad( _coinImage );
                    _redQuad.rotation = Math.PI * 0.25;
                    _trayContainer.addQuad( _redQuad );
                    _redQuad.rotation = Math.PI * 0.75;
                    _trayContainer.addQuad( _redQuad );
                }
                else
                {
                    _coinImage.alpha = 1;
                    _trayContainer.addQuad( _coinImage );
                }
            }
        }
        
        public function openTray():void
        {
            if ( _state == STATE_OPENING ) return;
            
            Loom2D.juggler.removeTweens( _trayContainer );
            
            if ( _state == STATE_OPEN )
            {
                onTrayOpen();
            }
            else
            {
                _state = STATE_OPENING;
                Loom2D.juggler.tween( _trayContainer, 0.25, { x: -TRAY_WIDTH, onComplete: onTrayOpen } );
            }
        }
        
        public function closeTray( delay:Number = 0 ):void
        {
            if ( _state == STATE_CLOSING || _state == STATE_CLOSED ) return;
            Loom2D.juggler.removeTweens( _trayContainer );
            Loom2D.juggler.tween( _trayContainer, 0.25, { x: 0, delay: delay, onComplete: onTrayClose } );
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        override protected function onAdd():Boolean
        {
            if ( !super.onAdd() ) return false;
            
            _viewComponent = new Sprite();
            _trayContainer = new QuadBatch();
            
            _matrix = new Matrix();
            
            var coinTexture:Texture = TextureAtlasManager.getTexture( "track", "dogecoin-icon" );
            
            _coinImage = new Image( coinTexture );
            _coinImage.center();
            _coinImage.x = TRAY_WIDTH * 0.5;
            
            _rowHeight = coinTexture.height * 1.2;
            
            _redQuad = new Image( coinTexture );
            _redQuad.color = 0xff0000;
            _redQuad.width = 20;
            _redQuad.height = _rowHeight;
            _redQuad.center();
            _redQuad.rotation = Math.PI * 0.25;
            _redQuad.x = TRAY_WIDTH * 0.5;
            
            _viewComponent.addChild( _trayContainer );
            
            viewManager.uiLayer.addChild( _viewComponent );
            
            viewManager.resized += resize;
            resize();
            
            updateCoinDisplay();
            
            return true;
        }
        
        override protected function onRemove():void
        {
            viewManager.resized -= resize;
            _viewComponent.removeFromParent();
            _viewComponent.dispose();
            _viewComponent = null;
            super.onRemove();
        }
        
        private function resize():void
        {
            _viewComponent.x = viewManager.viewPort.width;
            _viewComponent.y = viewManager.viewPort.height * 0.25;
        }
        
        private function onTrayOpen():void
        {
            _state = STATE_OPEN;
            closeTray( CLOSE_DELAY );
        }
        
        private function onTrayClose():void
        {
            _state = STATE_CLOSED;
        }
    }
}