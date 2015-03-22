package com.lunarraid.dogecart.collision
{
    import com.lunarraid.dogecart.time.SimpleTimeManager;
    import com.lunarraid.dogecart.time.IDeltaAnimated;

    import loom.gameframework.ILoomManager;
    import loom2d.math.Rectangle;
    
    public class CollisionManager implements IDeltaAnimated, ILoomManager
    {
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        [Inject]
        public var timeManager:SimpleTimeManager;
        
        //--------------------------------------
        // PUBLIC
        //--------------------------------------
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private const _colliders:Vector.<ColliderComponent> = [];
        private const _collidees:Vector.<ColliderComponent> = [];
        
        private var _colliderCount:int = 0;
        private var _collideeCount:int = 0;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        //--------------------------------------
        //  GETTERS / SETTERS
        //--------------------------------------
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        public function initialize():void
        {
            timeManager.addAnimatedObject( this );
        }
        
        public function destroy():void
        {
            timeManager.removeAnimatedObject( this );
        }
        
        public function addCollider( collider:ColliderComponent ):void
        {
            Debug.assert( _colliders.indexOf( collider ) == -1, "Collider has already been added!" );
            _colliders.push( collider );
            _colliderCount = _colliders.length;
        }
        
        public function removeCollider( collider:ColliderComponent ):void
        {
            _colliders.remove( collider );
            _colliderCount = _colliders.length;
        }
        
        public function addCollidee( collidee:ColliderComponent ):void
        {
            Debug.assert( _collidees.indexOf( collidee ) == -1, "Collidee has already been added!" );
            _collidees.push( collidee );
            _collideeCount = _collidees.length;
        }
        
        public function removeCollidee( collidee:ColliderComponent ):void
        {
            _collidees.remove( collidee );
            _collideeCount = _collidees.length;
        }
        
        public function onFrame( deltaTime:Number ):void
        {
            if ( _colliderCount == 0 || _collideeCount == 0 ) return;
            
            for ( var i:int = 0; i < _collideeCount; i++ )
            {
                for ( var j:int = 0; j < _colliderCount; j++ )
                {
                    var collidee:ColliderComponent = _collidees[ i ];
                    var collider:ColliderComponent = _colliders[ j ];
                    
                    if ( collider == collidee ) continue;
                    
                    if ( boundsIntersect( collidee.bounds, collider.bounds ) )
                    {
                        collidee.onCollision( collider, collidee );
                        collider.onCollision( collider, collidee );
                    }
                }
            }
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        private static function boundsIntersect( a:Rectangle, b:Rectangle ):Boolean
        {
            return Math.max2( a.x, b.x ) <= Math.min2( a.right, b.right ) && Math.max2( a.y, b.y ) <= Math.min2( a.bottom, b.bottom );
        }
    }
}