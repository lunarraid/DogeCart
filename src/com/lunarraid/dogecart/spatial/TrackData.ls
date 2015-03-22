package com.lunarraid.dogecart.spatial
{
    import com.lunarraid.dogecart.TrackConstants;
    
    public class TrackData
    {
        private var _startPosition:int;
        private var _endPosition:int;
        private var _heightMap:Vector.<Number>;
        private var _backgroundType:int;
        private var _segmentCount:int;
        private var _startHeight:int;
        
        public function TrackData( startPosition:int, startHeight:int, heightMap:Vector.<Number>, backgroundType:int )
        {
            setData( startPosition, startHeight, heightMap, backgroundType );
        }
        
        public function get startPosition():int { return _startPosition; }
        public function get endPosition():int { return _endPosition; }
        public function get backgroundType():int { return _backgroundType; }
        public function get segmentCount():int { return _segmentCount; }
        public function get startHeight():int { return _startHeight; }
        
        public function get endHeight():int
        {
            return _heightMap[ segmentCount - 1 ] + _startHeight;
        }
        
        public function setData( startPosition:int, startHeight:int, heightMap:Vector.<Number>, backgroundType:int ):void
        {
            _startPosition = startPosition;
            _startHeight = startHeight;
            _heightMap = heightMap;
            _backgroundType = backgroundType;
            _segmentCount = _heightMap.length;
            _endPosition = _startPosition + ( _segmentCount - 1 ) * TrackConstants.SEGMENT_WIDTH;
        }
        
        public function getHeightAtPosition( x:Number ):int
        {
            Debug.assert( !outOfBounds( x ), "Requested out of bounds value " + x + ", startPosition: " + _startPosition + ", endPosition: " + _endPosition );
            
            x = ( x - _startPosition ) / TrackConstants.SEGMENT_WIDTH;
            var index:int = Math.floor( x );
            var interpolationFactor:Number = x - index;
            if ( x < 0 ) interpolationFactor = 1 - interpolationFactor;
            var interpolatedHeight:Number = linearInterpolate( _heightMap[ index ], _heightMap[ index + 1 ], interpolationFactor ); 
            return interpolatedHeight;
        }
        
        public function getHeightAtIndex( index:int ):int
        {
            Debug.assert( index >= 0 && index < _heightMap.length, "NaN!" );
            return _heightMap[ index ]; 
        }
        
        public function getRotationAt( x:int ):Number
        {
            if ( outOfBounds( x ) ) return 0;
            var index:int = Math.floor( ( x - _startPosition ) / TrackConstants.SEGMENT_WIDTH );
            Debug.assert( index+1 < _heightMap.length, "INDEX OUT OF BOUNDS, " + x + " : " + endPosition ); 
            return Math.atan2( ( _heightMap[ index + 1 ] - _heightMap[ index ] ), TrackConstants.SEGMENT_WIDTH );
        }
        
        private function outOfBounds( x:int ):Boolean
        {
            return ( x < _startPosition || x  >= _endPosition );
        }
        
        private static function linearInterpolate( a:Number, b:Number, x:Number ):Number
        {
            return  a * ( 1 - x ) + b * x;
        }
    }
}