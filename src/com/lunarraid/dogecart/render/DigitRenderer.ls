package com.lunarraid.dogecart.render
{
    import loom2d.Loom2D;
    import loom2d.display.Image;
    import loom2d.text.BitmapChar;
    import loom2d.text.BitmapFont;
    import loom2d.animation.Tween;
    import loom2d.animation.Transitions;
    
    public class DigitRenderer extends Image
    {
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private static const _characterMap:Dictionary.<String, Vector.<BitmapChar>> = {};
        private static const _characterWidthMap:Dictionary.<String, int> = {};
        
        private var _characterSet:Vector.<BitmapChar>;
        private var _digitWidth:int = 0;
        private var _displayedValue:Number = -1;
        private var _currentValue:Number = 0;
        private var _targetValue:int = 0;
        private var _tween:Tween;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        public function DigitRenderer( asset:String )
        {
            super();
            _characterSet = getCharacters( asset );
            _digitWidth = _characterWidthMap[ asset ];
            _tween = new Tween( this, 0.25 );
            currentValue = 0;
        }
        
        //--------------------------------------
        // GETTERS / SETTERS
        //--------------------------------------
        
        public function get digitWidth():int { return _digitWidth; }
        
        private function get currentValue():Number { return _currentValue; }
        
        private function set currentValue( value:Number ):void
        {
            _currentValue = value;
            
            var sanitizedValue:Number = sanitizeValue( value );
            
            if ( sanitizedValue == _displayedValue ) return;
            
            var oldValue:int = Math.round( _displayedValue );
            var newValue:int = Math.round( sanitizedValue );
            
            if ( oldValue != newValue )
            {
                texture = _characterSet[ newValue < 10 ? newValue : 0 ].texture;
                pivotX = texture.width * 0.5;
            }
            
            scaleX = 1 - Math.abs( sanitizedValue - newValue ) * 2;
            
            _displayedValue = sanitizedValue;
        }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        public function incrementTo( value:int, transitionTime:Number = 1, delay:Number = 0 ):void
        {
            var endValue:Number = sanitizeValue( value );
            if ( endValue == _targetValue ) return;
            if ( endValue < _displayedValue ) endValue += 10;
            animate( endValue, transitionTime, delay );
        }
        
        public function decrementTo( value:int, transitionTime:Number = 1, delay:Number = 0 ):void
        {
            var endValue:Number = sanitizeValue( value );
            if ( endValue == _targetValue ) return;
            if ( endValue > _displayedValue ) endValue -= 10;
            animate( endValue, transitionTime, delay );
        }
        
        public function setTo( value:int ):void
        {
            currentValue = Math.floor( value );
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        private static function getCharacters( asset:String ):Vector.<BitmapChar>
        {
            if ( _characterMap[ asset ] ) return _characterMap[ asset ];
            var font:BitmapFont = BitmapFont.load( asset );
            var result:Vector.<BitmapChar> = [];
            var widestChar:int = 0;
            
            for ( var i:int = 0; i < 10; i++ )
            {
                var character:BitmapChar = font.getChar( i.toString().charCodeAt( 0 ) );
                widestChar = Math.max2( widestChar, character.texture.width );
                result.push( character );
            }
            
            _characterMap[ asset ] = result;
            _characterWidthMap[ asset ] = widestChar;
            return result;
        }
        
        private static function sanitizeValue( value:Number ):Number
        {
            if ( value >= 10 || value <= -10 ) value %= 10;
            if ( value < 0 ) value += 10;
            return value;
        }
        
        private function animate( endValue:Number, transitionTime:Number, delay:Number ):void
        {
            _currentValue = _displayedValue;
            _targetValue = endValue;
            _tween.reset( this, transitionTime, Transitions.EASE_OUT );
            _tween.delay = delay;
            _tween.animate( 'currentValue', endValue );
            Loom2D.juggler.add( _tween );
        }
    }
}