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
    
    public class BaseAudioComponent extends DeltaAnimatedComponent
    {
        //--------------------------------------
        // CONSTANTS
        //--------------------------------------
        
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        [Inject]
        public var audioManager:AudioManager;
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private static const _sharedSounds:Dictionary.<String, Sound> = {};
        
        private const _soundMap:Dictionary.<String, Sound> = {};
        private const _pausedSounds:Vector.<Sound> = [];
        
        private static var _sharedCount:int = 0;
        
        //--------------------------------------
        // GETTERS / SETTERS
        //--------------------------------------
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        public function playSound( name:String ):void
        {
            var sound:Sound = _soundMap[ name ];
            if ( sound ) sound.play();
        }
        
        public function pauseSound( name:String ):void
        {
            var sound:Sound = _soundMap[ name ];
            if ( sound ) sound.pause();
        }
        
        public function pauseSounds():void
        {
            for each ( var sound:Sound in _soundMap )
            {
                if ( sound.isPlaying() )
                {
                    sound.pause();
                    _pausedSounds.pushSingle( sound );
                }
            }
        }
        
        public function unpauseSounds():void
        {
            var pausedCount:int = _pausedSounds.length;
            for ( var i:int = 0; i < pausedCount; i++ ) _pausedSounds[ i ].play();
            _pausedSounds.clear();
        }
        
        public function removeSounds():void
        {
            _pausedSounds.clear();
            clearSoundDictionary( _soundMap );
            if ( _sharedCount <= 0 ) clearSoundDictionary( _sharedSounds );
        }
        
        public function clearPausedSounds():void
        {
            var pausedCount:int = _pausedSounds.length;
            for ( var i:int = 0; i < pausedCount; i++ ) _pausedSounds[ i ].stop();
            _pausedSounds.clear();
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        override protected function onAdd():Boolean
        {
            if ( !super.onAdd() ) return false;
            audioManager.audioEvent += onAudioEvent;
            _sharedCount++;
            return true;
        }
        
        override protected function onRemove():void
        {
            audioManager.audioEvent -= onAudioEvent;
            _sharedCount--;
            removeSounds();
            super.onRemove();
        }
        
        protected function onAudioEvent( eventType:String ):void
        {
            switch ( eventType )
            {
                case AudioManager.PAUSE_EVENT:
                    if ( audioManager.paused ) pauseSounds();
                    else ( unpauseSounds() );
                    break;
                    
                case AudioManager.CLEAR_EVENT:
                    clearPausedSounds();
                    break;
            }
        }
        
        protected function registerSound( name:String, path:String, shared:Boolean = false ):Sound
        {
            Debug.assert( _soundMap[ name ] == null, "Sound already registered!" );
            var sound:Sound = shared ? registerSharedSound( name, path ) : Sound.load( path );
            _soundMap[ name ] = sound;
            return sound;
        }
        
        protected function registerSharedSound( name:String, path:String ):Sound
        {
            var sound:Sound = _sharedSounds[ name ];
            if ( sound ) return sound;
            
            sound = Sound.load( path );
            _sharedSounds[ sound ] = sound;
            
            return sound;
        }
        
        protected function getSound( name:String ):Sound
        {
            return _soundMap[ name ];
        }
        
        protected function clearSoundDictionary( soundDictionary:Dictionary.<String, Sound> ):void
        {
            for ( var name:String in soundDictionary )
            {
                var sound:Sound = soundDictionary[ name ];
                soundDictionary.deleteKey( name );
                sound.stop();
                sound.deleteNative();
            }
        }
    }
}