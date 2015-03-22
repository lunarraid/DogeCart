package com.lunarraid.dogecart.controller
{
	import loom2d.Loom2D;
	import loom2d.events.TouchPhase;
    import loom2d.events.TouchEvent;
    import loom2d.events.Touch;
	import loom.gameframework.LoomComponent;
	
    import com.lunarraid.dogecart.spatial.TrackSpatialManager;
    import com.lunarraid.dogecart.spatial.CartSpatialData;
    
    public class CartControllerComponent extends LoomComponent
    {
        //--------------------------------------
        // CONSTANTS
        //--------------------------------------
        
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        [Inject]
        public var gameStateManager:GameStateManager;
        
        [Inject]
        public var trackManager:TrackSpatialManager;
        
        //--------------------------------------
        // GETTERS / SETTERS
        //--------------------------------------
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _cartSpatialDataCache:CartSpatialData;
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        public function beginJump():void
        {
            owner.broadcast( "controllerBeginJump", null );
        }
        
        public function endJump():void
        {
            owner.broadcast( "controllerEndJump", null );
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        override protected function onAdd():Boolean
        {
            if ( !super.onAdd() ) return false;
            Loom2D.stage.addEventListener( TouchEvent.TOUCH, onTouch );
            owner.broadcast += onBroadcast;
            return true;
        }
        
        override protected function onRemove():void
        {
            Loom2D.stage.removeEventListener( TouchEvent.TOUCH, onTouch );
            owner.broadcast -= onBroadcast;
            super.onRemove();
        }
        
        private function onTouch( e:TouchEvent ):void
        {
            var touches:Vector.<Touch> = e.getTouches( Loom2D.stage );
            if ( touches.length > 1 ) return;
            var touch:Touch = touches[ 0 ];
            if ( touch.phase == TouchPhase.BEGAN ) beginJump();
            else if ( touch.phase == TouchPhase.ENDED ) endJump();
        }
        
        private function onBroadcast( type:String, data:Object ):void
        {
            switch ( type )
            {
                case "dead":
                    gameStateManager.endGame();
                    break;
                    
                case "reset":
                    _cartSpatialDataCache = trackManager.getCartSpatialDataAt( 0 );
                    owner.setProperty( "@spatial.isDead", false );
                    owner.setProperty( "@spatial.position.x", 100 );
                    owner.setProperty( "@spatial.position.y", _cartSpatialDataCache.height );
                    break;
                    
                case "enemyHit":
                    owner.setProperty( "@spatial.isDead", true );
                    owner.setProperty( "@spatial.velocity.x", -200 );
                    owner.setProperty( "@spatial.velocity.y", -600 );
                    gameStateManager.gameEvent( GameEvents.SHOW_RED_TEXT, "such crash" );
                    break;
            }
        }
    }
}