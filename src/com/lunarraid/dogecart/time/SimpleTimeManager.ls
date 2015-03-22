package com.lunarraid.dogecart.time
{
    import loom2d.Loom2D;
    import loom2d.events.Event;
    
    import loom.gameframework.ILoomManager;
    
    public class SimpleTimeManager implements ILoomManager
    {
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        //--------------------------------------
        // PUBLIC
        //--------------------------------------
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        protected const _animatedQueue:Vector.<IDeltaAnimated> = [];
        
        protected var _platformTime:Number = 0;
        protected var _virtualTime:Number = 0;
        protected var _lastTime:Number = 0;
        protected var _active:Boolean = false;
        protected var _processingFrames:Boolean = false;
        protected var _queueCount:int = 0;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        //--------------------------------------
        //  GETTERS / SETTERS
        //--------------------------------------
        
        public function get virtualTime():Number { return _virtualTime; }
        
        public function get platformTime():Number { return _platformTime; }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        public function initialize():void
        {
            Loom2D.stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );
        }
        
        public function destroy():void
        {
            Loom2D.stage.removeEventListener( Event.ENTER_FRAME, onEnterFrame );
        }
        
        public function start():void
        {
            _active = true;
        }
        
        public function stop():void
        {
            _active = false;
        }
        
        public function addAnimatedObject( object:IDeltaAnimated ):void
        {
            _animatedQueue.push( object );
            _animatedQueue.sort( sortQueue );
            _queueCount = _animatedQueue.length;
        }

        public function removeAnimatedObject( object:IDeltaAnimated ):void
        {
            _animatedQueue.remove( object );
            _queueCount = _animatedQueue.length;
        }

        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        protected function onEnterFrame( e:Event ):void
        {
            _lastTime = _platformTime;
            _platformTime = Platform.getTime();
            
            if ( !_active ) return;
            
            var deltaTime:Number = _platformTime - _lastTime;
            
            _virtualTime += deltaTime;
            
            deltaTime *= 0.001;
            
            _processingFrames = true;
            for ( var i:int = 0; i < _queueCount; i++ ) _animatedQueue[ i ].onFrame( deltaTime );
            _processingFrames = false;
        }
        
        protected function sortQueue( a:IDeltaAnimated, b:IDeltaAnimated ):int
        {
            var priorityObjectA:IPrioritizable = a as IPrioritizable;
            var priorityObjectB:IPrioritizable = b as IPrioritizable;
            var priorityA:Number = priorityObjectA ? priorityObjectA.priority : 0;
            var priorityB:Number = priorityObjectB ? priorityObjectB.priority : 0;
            return priorityA > priorityB ? 1 : ( priorityA < priorityB ? -1 : 0 );
        }
    }
    
    public interface IDeltaAnimated
    {
        function onFrame( deltaTime:Number ):void;
    } 
    
    public interface IPrioritizable
    {
        function get priority():Number;
    }  
}