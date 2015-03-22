package com.lunarraid.dogecart.spatial
{
    import loom2d.math.Point;
    import loom2d.math.Rectangle;
    
    import com.lunarraid.dogecart.time.DeltaAnimatedComponent;
    
    public class CartSpatialComponent extends DeltaAnimatedComponent
    {
        //--------------------------------------
        // CONSTANTS
        //--------------------------------------
        
        public static const STATE_DEAD:String = "Dead";
        public static const STATE_DEFAULT:String = "Default";
        public static const STATE_JUMPING:String = "Jumping";
        public static const STATE_FALLING:String = "Falling";
        
        private static const JUMP_ANGLE:int = -40 * Math.PI / 180;
        private static const GRAVITY:Number = 3000;
        private static const ORIENTATION_HEIGHT:int = 30;
        private static const JUMP_VELOCITY:int = -550;
        private static const MAX_JUMP_DURATION_MS:int = 150;
        private static const MIN_JUMP_SPEED:int = 300;
        private static const ACCELERATION:Number = 200;
        
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        [Inject]
        public var trackManager:TrackSpatialManager;
        
        //--------------------------------------
        // PUBLIC
        //--------------------------------------
        
        public var position:Point;
        public var velocity:Point;
        public var velocityOnTrack:Number;
        public var rotation:Number;
        public var direction:int = 1;
        public var minSpeed:int = 350;
        public var maxSpeed:int = 750;
        
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _cartSpatialData:CartSpatialData;
        private var _state:String = STATE_DEFAULT;
        private var _lastJumpBegan:int = 0;
        
        //--------------------------------------
        //  GETTERS / SETTERS
        //--------------------------------------
        
        public function get state():String { return _state; }
        
        public function get isDead():Boolean { return _state == STATE_DEAD; }
        
        public function set isDead( value:Boolean ):void
        {
            if ( isDead == value ) return;
            
            if ( value )
            {
                _state = STATE_DEAD;
            }
	        else
	        {
	            _state = STATE_DEFAULT;
	            velocity.x = 0;
	            velocity.y = 0;
	            velocityOnTrack = 0;
	        }
        }
        
        override public function get priority():Number { return 0; }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        override public function onFrame( deltaTime:Number ):void
        {
            super.onFrame( deltaTime );
            
            position.x += velocity.x * deltaTime;
            position.y += velocity.y * deltaTime;
            
            _cartSpatialData = trackManager.getCartSpatialDataAt( position.x );
            
            updateState( timeManager.virtualTime );
            
            var sinRotation:Number = Math.sin( _cartSpatialData.rotation );
            
            switch ( _state )
            {
                case STATE_DEFAULT :
                    velocityOnTrack += ACCELERATION * direction * deltaTime;
                    velocityOnTrack += velocityOnTrack * sinRotation * 2 * direction * deltaTime;
                    
                    if ( direction < 0 ) velocityOnTrack = Math.clamp( velocityOnTrack, -maxSpeed, -minSpeed );
                    else velocityOnTrack = Math.clamp( velocityOnTrack, minSpeed, maxSpeed );
                    
                    velocity.x = velocityOnTrack * _cartSpatialData.speedCoefficient;
                    velocity.y = velocityOnTrack * sinRotation;
                    rotation = _cartSpatialData.rotation;
                    position.y = _cartSpatialData.height;
                    break;
                
                case STATE_JUMPING :
                    velocity.y = JUMP_VELOCITY;
                    // Continue to STATE_FALLING
                    
                case STATE_FALLING :
                    velocity.y += GRAVITY * deltaTime;
                    position.y += velocity.y * deltaTime;
                    if ( velocity.y > 0 ) setJumpRotation();
                    break;
                    
                case STATE_DEAD :
                    velocity.y += GRAVITY * deltaTime;
                    position.y += velocity.y * deltaTime;
                    if (position.y - _cartSpatialData.height > 2000) owner.broadcast( "dead", null );
                    break;
            }
            
            if ( _state == STATE_DEAD ) return;
            else if ( direction < 0 ) velocity.x = Math.clamp( velocity.x, -maxSpeed, -minSpeed );
            else velocity.x = Math.clamp( velocity.x, minSpeed, maxSpeed );
        }
        
        public function updateState( currentTime:int ):void
        {
            if ( _state == STATE_DEAD ) return;
            else if ( _state == STATE_DEFAULT && !_cartSpatialData.trackExists ) _state = STATE_FALLING;
            else if ( _state == STATE_JUMPING && currentTime - _lastJumpBegan > MAX_JUMP_DURATION_MS ) _state = STATE_FALLING; 
            else if ( _state == STATE_FALLING && position.y - _cartSpatialData.height >= 0 )
            {
                if ( _cartSpatialData.trackExists )
                {
                    _state = STATE_DEFAULT;
                    velocityOnTrack = velocity.x;
                }
                else _state = STATE_DEAD;
            }
        }
        
        public function beginJump():void
        {
            if ( _state != STATE_DEFAULT ) return;
            if ( direction < 0 && velocity.x > -MIN_JUMP_SPEED ) velocity.x = -MIN_JUMP_SPEED;
            else if ( velocity.x < MIN_JUMP_SPEED ) velocity.x = MIN_JUMP_SPEED;
            rotation = JUMP_ANGLE * direction;
            _lastJumpBegan = timeManager.virtualTime;
            _state = STATE_JUMPING;
        }
        
        public function endJump():void
        {
            if ( _state == STATE_JUMPING ) _state = STATE_FALLING;
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        override protected function onAdd():Boolean
        {
            if ( !super.onAdd() ) return false;
            
            owner.broadcast += onBroadcast;
            
            _cartSpatialData = trackManager.getCartSpatialDataAt( trackManager.position );
            position.x = _cartSpatialData.position;
            position.y = _cartSpatialData.height;
            
            return true;
        }
        
        override protected function onRemove():void
        {
            super.onRemove();
        }
        
        private function onBroadcast( type:String, data:Object ):void
        {
            switch ( type )
            {
                case "controllerBeginJump":
                    beginJump();
                    break;
                    
                case "controllerEndJump":
                    endJump();
                    break;
            }
        }
        
        private function setJumpRotation():void
        {
            var relativeY:int = _cartSpatialData.height - position.y;
            
            if ( _cartSpatialData.trackExists && relativeY < ORIENTATION_HEIGHT )
            {
                var heightPercent:Number = relativeY / ORIENTATION_HEIGHT;
                if ( heightPercent < 0 ) heightPercent = 0;
                rotation = _cartSpatialData.rotation * ( 1 - heightPercent ) + ( JUMP_ANGLE * heightPercent );
            }
        }
    }
}