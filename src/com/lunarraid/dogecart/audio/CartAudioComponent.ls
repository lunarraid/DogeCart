package com.lunarraid.dogecart.audio
{
	import loom.sound.Sound;
	import loom2d.Loom2D;
	import loom2d.events.TouchPhase;
    import loom2d.events.TouchEvent;
    import loom2d.events.Touch;
	import loom.gameframework.LoomComponent;
	
    import com.lunarraid.dogecart.time.DeltaAnimatedComponent;
    import com.lunarraid.dogecart.spatial.CartSpatialComponent;
    
    public class CartAudioComponent extends BaseAudioComponent
    {
        //--------------------------------------
        // CONSTANTS
        //--------------------------------------
        
        public static const VELOCITY_MEDIAN:Number = 400;
        
        public static const ENEMY:String = "Enemy";
        public static const TRACK:String = "Track";
        public static const JUMP:String = "Jump";
        public static const LAND:String = "Land";
        public static const MISSED_COIN:String = "MissedCoin";
        
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _trackSound:Sound;
        private var _velocity:Number;
        private var _state:String;
        
        //--------------------------------------
        // GETTERS / SETTERS
        //--------------------------------------
        
        public function get velocity():Number { return _velocity; }
        
        public function set velocity( value:Number ):void
        {
            if ( _velocity == value ) return;
            _velocity = value;
            _trackSound.setPitch( ( _velocity / VELOCITY_MEDIAN ) * 0.5 + 0.5 );
        }
        
        public function set state( value:String ):void
        {
            if ( _state == value ) return;
            
            if ( value == CartSpatialComponent.STATE_DEFAULT )
            {
                playSound( TRACK );
                playSound( LAND );
            }
            else if ( value == CartSpatialComponent.STATE_FALLING || value == CartSpatialComponent.STATE_DEAD ) pauseSound( TRACK );
            
            if ( _state == CartSpatialComponent.STATE_JUMPING ) playSound( JUMP );
            else if ( value == CartSpatialComponent.STATE_DEAD ) playSound( LAND );
            
            _state = value;
        }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        override protected function onAdd():Boolean
        {
            if ( !super.onAdd() ) return false;
            
            audioManager.audioEvent += onAudioEvent;
            owner.broadcast += onBroadcast;
            
            _trackSound = registerSound( TRACK, "assets/audio/cart.ogg" );
            _trackSound.setLooping( true );
            
            registerSound( JUMP, "assets/audio/jump.ogg" );
            registerSound( LAND, "assets/audio/land.ogg" );
            registerSound( ENEMY, "assets/audio/enemycart.ogg" );
            registerSound( MISSED_COIN, "assets/audio/missedcoin.ogg" );
            
            return true;
        }
        
        override protected function onRemove():void
        {
            owner.broadcast -= onBroadcast;
            super.onRemove();
        }
        
        protected function onBroadcast( type:String, payload:Object ):void
        {
            if ( type == ENEMY ) playSound( ENEMY );
            else if ( type == MISSED_COIN ) playSound( MISSED_COIN );
        }
    }
}