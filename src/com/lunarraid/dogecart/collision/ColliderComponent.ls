package com.lunarraid.dogecart.collision
{
    import loom2d.math.Point;
    import loom2d.math.Rectangle;
    import loom2d.display.Quad;
    
    import com.lunarraid.dogecart.time.DeltaAnimatedComponent;
    
    public class ColliderComponent extends DeltaAnimatedComponent
    {
        //--------------------------------------
        // CONSTANTS
        //--------------------------------------
        
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        [Inject]
        public var collisionManager:CollisionManager;
        
        //--------------------------------------
        // PUBLIC
        //--------------------------------------
        
        public var bounds:Rectangle = new Rectangle();
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        protected var _collisionBounds:Rectangle = new Rectangle( 0, 0, 1, 1 );
        protected var _isCollider:Boolean = false;
        protected var _isCollidee:Boolean = false;
        protected var _position:Point;
        
        //--------------------------------------
        //  GETTERS / SETTERS
        //--------------------------------------
        
        public function get isCollider():Boolean { return _isCollider; }
        
        public function set isCollider( value:Boolean ):void
        {
            if ( value == _isCollider ) return;
            _isCollider = value;
            
            if ( !collisionManager ) return;
            
            if ( _isCollider ) collisionManager.addCollider( this );
            else collisionManager.removeCollider( this );
        }
        
        public function get isCollidee():Boolean { return _isCollidee; }
        
        public function set isCollidee( value:Boolean ):void
        {
            if ( value == _isCollidee ) return;
            _isCollidee = value;
            
            if ( !collisionManager ) return;
            
            if ( _isCollidee ) collisionManager.addCollidee( this );
            else collisionManager.removeCollidee( this );
        }
        
        public function get x():int { return _position.x; }
        
        public function set x( value:int ):void
        {
            _position.x = value;
            bounds.x = _collisionBounds.x + value;
        }
        
        public function get y():int { return _position.y; }
        
        public function set y( value:int ):void
        {
            _position.y = value;
            bounds.y = _collisionBounds.y + value;
        }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        public function setCollisionBounds( x:int, y:int, width:int, height:int ):void
        {
            _collisionBounds.setTo( x, y, width, height );
            bounds.width = _collisionBounds.width;
            bounds.height = _collisionBounds.height;
        }
        
        public function onCollision( collider:ColliderComponent, collidee:ColliderComponent ):void
        {
            // Do something here
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        override protected function onAdd():Boolean
        {
            if ( !super.onAdd() ) return false;
            
            if ( _isCollider ) collisionManager.addCollider( this );
            if ( _isCollidee ) collisionManager.addCollidee( this );
            
            return true;
        }
        
        override protected function onRemove():void
        {
            if ( _isCollider ) collisionManager.removeCollider( this );
            if ( _isCollidee ) collisionManager.removeCollidee( this );
            
            collisionManager = null;
            
            super.onRemove();
        }
    }
}