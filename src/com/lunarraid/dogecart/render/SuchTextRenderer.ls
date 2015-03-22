package com.lunarraid.dogecart.render
{
    import loom.gameframework.LoomComponent;
	
    import loom2d.Loom2D;
    import loom2d.display.Quad;
    import loom2d.display.QuadBatch;
    import loom2d.display.Image;
    import loom2d.display.Sprite;
    import loom2d.text.BitmapFont;
    import loom2d.math.Rectangle;
    
    import com.lunarraid.dogecart.controller.GameEvents;
    import com.lunarraid.dogecart.controller.GameStateManager;
	
    public class SuchTextRenderer extends LoomComponent
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
        
        protected static const _colors:Vector.<Number> = [ 0x00ff00, 0xbed3ff, 0xffffcc, 0x00ffff, 0xffff00, 0xffccff ];
        protected static const _scratchBounds:Rectangle = new Rectangle();
        
        protected static var _bitmapFont:BitmapFont;
        
        protected var _boundsDictionary:Dictionary.<QuadBatch, Rectangle> = {};
        
        //--------------------------------------
        //  GETTERS / SETTERS
        //--------------------------------------
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        public function showText( text:String, color:uint = 0 ):void
        {
            var quadBatch:QuadBatch = new QuadBatch();
            if ( color == 0) color = _colors[ Math.randomRangeInt( 0, _colors.length - 1 ) ];
            _bitmapFont.fillQuadBatch( quadBatch, NaN, 50, text, 42, color, "left", "bottom" );
            quadBatch.getBounds( quadBatch, _scratchBounds );
            
            var needsNewPosition:Boolean = true;
            var tryCount:int = 10; // attempts at finding unfilled text location
            
            while ( tryCount > 0 && needsNewPosition )
            {
                needsNewPosition = false;
                _scratchBounds.x = Math.randomRangeInt( 0, viewManager.viewPort.width - _scratchBounds.width );
                _scratchBounds.y = Math.randomRangeInt( viewManager.viewPort.height * 0.25, viewManager.viewPort.height * 0.75 );
                for each ( var bounds:Rectangle in _boundsDictionary )
                {
                    needsNewPosition = Rectangle.intersects( bounds, _scratchBounds );
                    if ( needsNewPosition ) break;
                }
                tryCount--;
            }
            
            quadBatch.x = _scratchBounds.x;
            quadBatch.y = _scratchBounds.y;
            viewManager.uiLayer.addChild( quadBatch );
            
            _boundsDictionary[ quadBatch ] = _scratchBounds.clone();
            
            Loom2D.juggler.tween( quadBatch, 0.5, {
                alpha: 0,
                delay: 2,
                onComplete: function():void
                {
                    _boundsDictionary.deleteKey( quadBatch );
                    if ( quadBatch.nativeDeleted() ) return;
                    quadBatch.removeFromParent();
                    quadBatch.dispose();
                }
            } );
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        override protected function onAdd():Boolean
        {
            if ( !super.onAdd() ) return false;
            if ( !_bitmapFont ) _bitmapFont = BitmapFont.load( "assets/fonts/comic-sans.fnt" );
            gameStateManager.gameEvent += onGameEvent;
            return true;
        }
        
        override protected function onRemove():void
        {
            gameStateManager.gameEvent -= onGameEvent;
            super.onRemove();
        }
        
        protected function onGameEvent( type:String, payload:Object ):void
        {
            if ( type == GameEvents.SHOW_TEXT ) showText( payload as String );
            else if ( type == GameEvents.SHOW_RED_TEXT ) showText( payload as String, 0xff0000 );
        }
    }
}