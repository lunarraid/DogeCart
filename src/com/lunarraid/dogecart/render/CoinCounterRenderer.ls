package com.lunarraid.dogecart.render
{
    import loom2d.Loom2D;
    import loom2d.display.Image;
	import loom2d.ui.TextureAtlasManager;
    import loom2d.display.DisplayObject;
    import loom2d.display.DisplayObjectContainer;
    import loom2d.display.Sprite;
	import loom.gameframework.AnimatedComponent;
	
    import com.lunarraid.dogecart.controller.GameStateManager;
	
    public class CoinCounterRenderer extends BaseRenderComponent
    {
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        [Inject]
        public var gameStateManager:GameStateManager;
        
        //--------------------------------------
        // PUBLIC
        //--------------------------------------
        
        public var showAnimations:Boolean = true;
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _container:Sprite;
        private var _coinIcon:Image;
        private var _digits:Vector.<DigitRenderer>;
        private var _digitWidth:int;
        private var _count:Number = 0;
        private var _rangeStart:int = 1;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        //--------------------------------------
        // GETTERS / SETTERS
        //--------------------------------------
        
        public function get count():int { return _count; }
        
        public function set count( value:int ):void
        {
            if ( _count == value ) return;
            
            if ( value >= _rangeStart * 10 || value < _rangeStart )
            {
                var digitCount:int = Math.floor( value ).toString().length;
                _rangeStart = Math.pow( 10, digitCount - 1 );
                updateDigitPositions( digitCount );
            }
            
            var loopCount:int = Math.floor( value );
            
            for ( var i:int = 0; i < _digits.length; i++ )
            {
                var digit:DigitRenderer = _digits[ i ];
                if ( _count < value ) digit.incrementTo( loopCount );
                else digit.decrementTo( loopCount );
                loopCount = Math.floor( loopCount / 10 );
            }
            
            _count = value;
        }
        
        override protected function get parentViewComponent():DisplayObjectContainer
        {
            return viewManager.uiLayer;
        }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        override public function onFrame( deltaTime:Number ):void
        {
            super.onFrame( deltaTime );
            count = gameStateManager.coinsCollected;
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        override protected function onAdd():Boolean
        {
            if ( !super.onAdd() ) return false;
            
            _digits = [];
            updateDigitPositions( 1 );

            return true;
        }
        
        override protected function createViewComponent():DisplayObject
        {
            _container = new Sprite();
            _coinIcon = new Image( TextureAtlasManager.getTexture( "track", "dogecoin-icon" ) );
            _container.addChild( _coinIcon );
            return _container;
        }
                
        private function updateDigitPositions( digitCount:int ):void
        {
            while ( _digits.length > digitCount )
            {
                var oldDigit:DigitRenderer = _digits.pop();
                oldDigit.removeFromParent();
                oldDigit.dispose();
            }
                
            while ( _digits.length < digitCount )
            {
                var newDigit:DigitRenderer = new DigitRenderer( "assets/fonts/comic-sans.fnt" );
                newDigit.x = 45 + newDigit.digitWidth * 0.6 * _digits.length;
                newDigit.y = 7;
                _digits.push( newDigit );
                _container.addChildAt( newDigit, 1 );
            }
            
            for ( var i:int = 1; i <= digitCount; i++ )
            {
                var digit:DigitRenderer = _digits[ digitCount - i ];
                Loom2D.juggler.tween( digit, 0.25, { x: 45 + digit.digitWidth * 0.6 * i } );
            }
        }
    }
}