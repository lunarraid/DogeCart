package com.lunarraid.dogecart.render
{
	import loom2d.display.Sprite;
	import loom.gameframework.ILoomManager;
    import com.lunarraid.dogecart.time.SimpleTimeManager;
    import com.lunarraid.dogecart.time.IDeltaAnimated;
    import com.lunarraid.dogecart.time.IPrioritizable;

	import loom2d.math.Rectangle;
    import loom2d.ui.TextureAtlasManager;
    import loom2d.math.Point;
    
    import com.lunarraid.util.PerlinNoise;
    
    import com.lunarraid.dogecart.spatial.TrackSpatialManager;
    import com.lunarraid.dogecart.spatial.CartSpatialData;
    
    delegate ViewDelegate();
    
    public class TrackViewManager implements IDeltaAnimated, IPrioritizable, ILoomManager
    {
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        [Inject]
        public var timeManager:SimpleTimeManager;
    
        [Inject]
        public var spatialManager:TrackSpatialManager;
    
        //--------------------------------------
        // PUBLIC
        //--------------------------------------
        
        public const resized:ViewDelegate;
        
        public var cameraOffset:Point;
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _lastTime:int;
        private var _viewPort:Rectangle;
        
        private var _backgroundLayer:Sprite;
        private var _trackLayer:Sprite;
        private var _foregroundLayer:Sprite;
        private var _uiLayer:Sprite;
        private var _viewComponent:Sprite;
        
        private var _cartSpatialData:CartSpatialData;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        public function TrackViewManager( viewPort:Rectangle = null )
        {
            this.viewPort = viewPort ? viewPort : new Rectangle();
        }
        
        //--------------------------------------
        //  GETTERS / SETTERS
        //--------------------------------------
        
        public function get viewPort():Rectangle { return _viewPort; }
        
        public function set viewPort( value:Rectangle ):void
        {
            if ( !value ) return;
            _viewPort = value;
            resized();
        }
        
        public function get backgroundLayer():Sprite { return _backgroundLayer; }
        
        public function get trackLayer():Sprite { return _trackLayer; }
        
        public function get foregroundLayer():Sprite { return _foregroundLayer; }
        
        public function get uiLayer():Sprite { return _uiLayer; }
        
        public function get viewComponent():Sprite { return _viewComponent; }
        
        override public function get priority():Number { return 3; }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        public function initialize():void
        {
            timeManager.addAnimatedObject( this );
            
            _backgroundLayer = new Sprite();
            _backgroundLayer.touchable = false;
            
            _trackLayer = new Sprite();
            _trackLayer.touchable = false;
            
            _foregroundLayer = new Sprite();
            _foregroundLayer.touchable = false;
            
            _uiLayer = new Sprite();
            
            _viewComponent = new Sprite();
            _viewComponent.addChild( _backgroundLayer );
            _viewComponent.addChild( _trackLayer );
            _viewComponent.addChild( _foregroundLayer );
            _viewComponent.addChild( _uiLayer );
        }
        
        public function destroy():void
        {
            timeManager.removeAnimatedObject( this );
        }
        
        public function onFrame():void
        {
            var currentTime:int = timeManager.virtualTime;
            
            _cartSpatialData = spatialManager.getCartSpatialDataAt( spatialManager.position );
            
            _viewPort.x = spatialManager.position + cameraOffset.x;
            _viewPort.y = ( _cartSpatialData.isFlatTrack ? _cartSpatialData.flatHeight : _cartSpatialData.height ) + cameraOffset.y;

            _trackLayer.x = -_viewPort.x;
            _trackLayer.y = -_viewPort.y;
            
            _foregroundLayer.x = -_viewPort.x;
            _foregroundLayer.y = -_viewPort.y;

            _lastTime = currentTime;
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
    }
}