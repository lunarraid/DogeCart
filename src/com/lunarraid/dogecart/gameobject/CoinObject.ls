package com.lunarraid.dogecart.gameobject
{
	import loom.gameframework.LoomGroup;
	import loom.gameframework.LoomGameObject;
    
    import com.lunarraid.dogecart.audio.CoinAudioComponent;
    import com.lunarraid.dogecart.render.AnimationRenderer;
    import com.lunarraid.dogecart.collision.CoinColliderComponent;
    
    public class CoinObject extends LoomGameObject
    {
        //--------------------------------------
        // CONSTANTS
        //--------------------------------------
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _colliderComponent:CoinColliderComponent;
        private var _renderer:AnimationRenderer;
        private var _audioComponent:CoinAudioComponent;
        private var _active:Boolean = true;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        public function CoinObject( group:LoomGroup )
        {
            owningGroup = group;
            initialize();
        }
        
        //--------------------------------------
        // GETTERS / SETTERS
        //--------------------------------------
        
        public function get colliderComponent():CoinColliderComponent { return _colliderComponent; }
        public function get renderer():AnimationRenderer { return _renderer; }
        
        public function get active():Boolean { return _active; }
        
        public function set active( value:Boolean ):void
        {
            if ( _active == value ) return;
            
            _active = value;
            _colliderComponent.isCollidee = value;
            _renderer.enabled = value;
        }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        override public function initialize( objectName:String = null ):void
        {
            if ( objectName == null ) objectName = "coin";
            
            super.initialize( objectName );
            
            _colliderComponent = new CoinColliderComponent();
            _colliderComponent.registerForUpdates = false;
            _colliderComponent.setCollisionBounds( -36, -36, 72, 72 );
            _colliderComponent.isCollidee = true;
            addComponent( _colliderComponent, "collider" );
            
            _renderer = new AnimationRenderer( "track", "dogecoin/dogecoin" );
            addComponent( _renderer, "renderer" );
            
            _renderer.addBinding( "x", "@collider.x" );
            _renderer.addBinding( "y", "@collider.y" );
            
            _audioComponent = new CoinAudioComponent();
            addComponent( _audioComponent, "audio" );
        }
                
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
    }
}