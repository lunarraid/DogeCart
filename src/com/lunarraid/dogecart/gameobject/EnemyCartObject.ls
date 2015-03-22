package com.lunarraid.dogecart.gameobject
{
	import loom.gameframework.LoomGroup;
	import loom.gameframework.LoomGameObject;
    
    import com.lunarraid.dogecart.spatial.CartSpatialComponent;
    import com.lunarraid.dogecart.collision.EnemyCartColliderComponent;
    import com.lunarraid.dogecart.render.AtlasImageRenderer;
    
    public class EnemyCartObject extends LoomGameObject
    {
        //--------------------------------------
        // CONSTANTS
        //--------------------------------------
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        public function EnemyCartObject( group:LoomGroup )
        {
            owningGroup = group;
            initialize();
        }
        
        //--------------------------------------
        // GETTERS / SETTERS
        //--------------------------------------
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        override public function initialize( objectName:String = null ):void
        {
            if ( objectName == null ) objectName = "enemy";
            
            super.initialize( objectName );
            
            var cartSpatialComponent:CartSpatialComponent = new CartSpatialComponent();
            addComponent( cartSpatialComponent, "spatial" );
            cartSpatialComponent.direction = -1;
            
            var cartColliderComponent:EnemyCartColliderComponent = new EnemyCartColliderComponent();
            cartColliderComponent.setCollisionBounds( -30, -30, 80, 26 );
            cartColliderComponent.isCollidee = true;
            addComponent( cartColliderComponent, "collider" );
            cartColliderComponent.addBinding( "x", "@spatial.position.x" );
            cartColliderComponent.addBinding( "y", "@spatial.position.y" );
            
            var cartRenderer:AtlasImageRenderer = new AtlasImageRenderer( "track", "enemycart" );
            addComponent( cartRenderer, "renderer" );
            cartRenderer.viewComponent.pivotX = cartRenderer.viewComponent.width * 0.35;
            cartRenderer.viewComponent.pivotY = cartRenderer.viewComponent.height * 0.9;
            cartRenderer.addBinding( "x", "@spatial.position.x" );
            cartRenderer.addBinding( "y", "@spatial.position.y" );
            cartRenderer.addBinding( "rotation", "@spatial.rotation" );
        }
                
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
    }
}