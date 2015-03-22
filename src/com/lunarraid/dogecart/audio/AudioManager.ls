package com.lunarraid.dogecart.audio
{
	import com.lunarraid.dogecart.time.SimpleTimeManager;

	import loom.gameframework.IAnimated;
    import loom.gameframework.ILoomManager;
    import loom2d.math.Rectangle;
    
    delegate AudioDelegate( eventType:String );
    
    public class AudioManager implements ILoomManager
    {
        //--------------------------------------
        // CLASS CONSTANTS
        //--------------------------------------
        
        public static const PAUSE_EVENT:String = "PauseEvent";
        public static const CLEAR_EVENT:String = "ClearEvent";
        
        //--------------------------------------
        // PUBLIC
        //--------------------------------------
        
        public const audioEvent:AudioDelegate;
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _paused:Boolean;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        //--------------------------------------
        //  GETTERS / SETTERS
        //--------------------------------------
        
        public function get paused():Boolean { return _paused; }
        
        public function set paused( value:Boolean ):void
        {
            if ( _paused == value ) return;
            _paused = value;
            audioEvent( PAUSE_EVENT );
        }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        public function initialize():void
        {
        }
        
        public function destroy():void
        {
        }
        
        public function clearPausedSounds():void
        {
            audioEvent( CLEAR_EVENT );
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
    }
}