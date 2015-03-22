package com.lunarraid.dogecart.gameobject
{
	import loom.gameframework.LoomGroup;
	import loom.gameframework.LoomGameObject;
    
    import com.lunarraid.dogecart.spatial.CartSpatialComponent;
    import com.lunarraid.dogecart.collision.ColliderComponent;
    import com.lunarraid.dogecart.audio.CartAudioComponent;
    import com.lunarraid.dogecart.render.CartRenderer;
    import com.lunarraid.dogecart.controller.CartControllerComponent;
    
    public class PlayerCartObject extends LoomGameObject
    {
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        public function PlayerCartObject( group:LoomGroup )
        {
            owningGroup = group;
            initialize();
        }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        override public function initialize( objectName:String = null ):void
        {
            if ( objectName == null ) objectName = "player";
            
            super.initialize( objectName );
            
            var cartSpatialComponent:CartSpatialComponent = new CartSpatialComponent();
            addComponent( cartSpatialComponent, "spatial" );
            
            var cartColliderComponent:ColliderComponent = new ColliderComponent();
            cartColliderComponent.setCollisionBounds( -30, -50, 70, 46 );
            cartColliderComponent.isCollider = true;
            addComponent( cartColliderComponent, "collider" );
            cartColliderComponent.addBinding( "x", "@spatial.position.x" );
            cartColliderComponent.addBinding( "y", "@spatial.position.y" );
            
            var cartControllerComponent:CartControllerComponent = new CartControllerComponent();
            addComponent( cartControllerComponent, "controller" );
            
            var cartRenderer:CartRenderer = new CartRenderer();
            addComponent( cartRenderer, "renderer" );
            cartRenderer.addBinding( "x", "@spatial.position.x" );
            cartRenderer.addBinding( "y", "@spatial.position.y" );
            cartRenderer.addBinding( "rotation", "@spatial.rotation" );
            
            var cartAudio:CartAudioComponent = new CartAudioComponent();
            addComponent( cartAudio, "audio" );
            cartAudio.addBinding( "velocity", "@spatial.velocity.x" );
            cartAudio.addBinding( "state", "@spatial.state" );
        }
    }
}