package com.lunarraid.dogecart.collision
{
	import loom2d.Loom2D;
	
    import com.lunarraid.dogecart.controller.GameStateManager;
	
    public class CoinColliderComponent extends ColliderComponent
    {
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        [Inject]
        public var gameStateManager:GameStateManager;
        
        //--------------------------------------
        //  PUBLIC
        //--------------------------------------
        
        public var collected:Boolean = false;
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        override public function onCollision( a:ColliderComponent, b:ColliderComponent ):void
        {
            collected = true;
            isCollidee = false;
            owner.setProperty( "@renderer.fps", 100 );
            Loom2D.juggler.tween( this, 0.5, { y: y - 500, onComplete: gameStateManager.collectCoin, onCompleteArgs: [ owner ] } );
            owner.broadcast( "CollectCoin", null );
        }
    }
}