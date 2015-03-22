package com.lunarraid.dogecart.render 
{
    import loom2d.display.DisplayObject;
    import loom2d.display.DisplayObjectContainer;
    import loom2d.display.Sprite;
    import loom2d.display.QuadBatch;
    
    import loom2d.text.BitmapFont;
	
	import com.lunarraid.dogecart.spatial.TrackSpatialManager;
	
    public class DistanceCounterRenderer extends BaseRenderComponent
    {
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        [Inject]
        public var trackManager:TrackSpatialManager;
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _container:Sprite;
        private var _label:QuadBatch;
        private var _quadBatch:QuadBatch;
        private var _bitmapFont:BitmapFont;
        private var _displayedValue:String;
        private var _count:Number;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        //--------------------------------------
        // GETTERS / SETTERS
        //--------------------------------------
        
        public function get count():Number { return _count; }
        
        public function set count( value:Number ):void
        {
            _count = value;
            var newDisplayedValue:String = _count.toFixed( 1 );
            if ( newDisplayedValue == _displayedValue ) return;
            _quadBatch.reset();
            _bitmapFont.fillQuadBatch( _quadBatch, NaN, 50, newDisplayedValue, 42, 0xffff00, "left", "bottom" );
            _displayedValue = newDisplayedValue;
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
            count = trackManager.position / 100;
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        override protected function createViewComponent():DisplayObject
        {
            _bitmapFont = BitmapFont.load( "assets/fonts/comic-sans.fnt" );
            
            _label = new QuadBatch();
            _bitmapFont.fillQuadBatch( _label, 150, 46, "distance:", 42, 0xffffff, "left", "bottom" );
            
            _quadBatch = new QuadBatch();
            _quadBatch.x = 150;
            count = 0;
            
            _container = new Sprite();
            _container.addChild( _label );
            _container.addChild( _quadBatch );
            
            return _container;
        }
    }
}