package com.lunarraid.dogecart.spatial
{
	import loom.gameframework.ILoomManager;
    import com.lunarraid.dogecart.time.IDeltaAnimated;
    import com.lunarraid.dogecart.time.SimpleTimeManager;
    import com.lunarraid.dogecart.time.IPrioritizable;

	import loom2d.math.Rectangle;
    import loom2d.ui.TextureAtlasManager;
    import loom2d.math.Point;
    
    import com.lunarraid.util.PerlinNoise;
    
    import com.lunarraid.dogecart.TrackConstants;
    
    delegate TrackDelegate( trackData:TrackData );
    
    public class TrackSpatialManager implements IDeltaAnimated, IPrioritizable, ILoomManager
    {
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        [Inject]
        public var timeManager:SimpleTimeManager;
    
        //--------------------------------------
        // PUBLIC
        //--------------------------------------
        
        public const onTrackAdded:TrackDelegate;
        
        public var trackingObject:CartSpatialComponent;
        public var infiniteLoopMode:Boolean;
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _obstacleMap:Vector.<Number>;
        private var _trackGenerationSeed:int = 1;
        private var _position:int = 0;
        private var _tracks:Vector.<TrackData> = [];
        private var _width:int;
        
        private var _cartDataCache:CartSpatialData;
        
        private static const TEXTURE_WIDTHS:Dictionary.<String, Number> = {};
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        //--------------------------------------
        //  GETTERS / SETTERS
        //--------------------------------------
        
        public function set width( value:int ):void
        {
            _width = value;
            updateTrackData();
        }
        
        public function get width():int { return _width; }
        
        public function get position():int { return _position; }
        
        public function set position( value:int ):void
        {
            // For now, this only supports forward movement. Will change if feature is ever needed. <rcook 4/30/2014>
            if ( value <= _position ) return;
            
            _position = value;
            updateTrackData();
        }
        
        public function get tracks():Vector.<TrackData> { return _tracks; }
        
        public function get priority():Number { return 2; }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        public function initialize():void
        {
            if ( TEXTURE_WIDTHS[ TrackConstants.COLUMN_NARROW ] == null ) populateTextureWidths();
            reset();
            timeManager.addAnimatedObject( this );
        }
        
        public function destroy():void
        {
            timeManager.removeAnimatedObject( this );
        }
        
        public function reset():void
        {
            _position = 0;
            _tracks.clear();
            
            //var heightMap:Vector.<Number> = generateFlatHeightMap( getSegmentCountForBackgroundType( TrackConstants.MAX_MIDSECTION_COUNT ) );
            //var newTrack:TrackData = new TrackData( 0, 0, heightMap, TrackConstants.MAX_MIDSECTION_COUNT );
            //_tracks.pushSingle( newTrack );
            //onTrackAdded( newTrack );
            
            updateTrackData();
        }
        
        public function onFrame( deltaTime:Number ):void
        {
            if ( trackingObject ) position = trackingObject.position.x;
        }
        
        public function getSegmentCountForBackgroundType( backgroundType:int ):int
        {
            if ( backgroundType <= 0 ) return 0;
            if ( backgroundType == 1 ) return Math.floor( TEXTURE_WIDTHS[ TrackConstants.COLUMN_NARROW ] / TrackConstants.SEGMENT_WIDTH );
            return Math.floor( ( TEXTURE_WIDTHS[ TrackConstants.COLUMN_LEFT ] + TEXTURE_WIDTHS[ TrackConstants.COLUMN_RIGHT ] + TEXTURE_WIDTHS[ TrackConstants.COLUMN_MIDDLE ] * ( backgroundType - 2 ) ) / TrackConstants.SEGMENT_WIDTH );
        }
        
        public function generateHeightMap( segmentCount:uint ):Vector.<Number>
        {
            //return generateHeightMap2( segmentCount );
            
            segmentCount = Math.floor( segmentCount );
            _trackGenerationSeed = PerlinNoise.getNumberFromSeed( _trackGenerationSeed );
            var result:Vector.<Number> = PerlinNoise.getPerlinNoise_1D( _trackGenerationSeed, TrackConstants.MAXIMUM_TRACK_SEGMENTS, TrackConstants.PERLIN_OCTAVES, TrackConstants.PERLIN_DECAY );
            result.length = segmentCount;
            var heightOffset:int = result[ 0 ] * TrackConstants.MAXIMUM_HEIGHT;
            
            for ( var i:int = 0; i < segmentCount; i++ )  result[ i ] = result[ i ] * TrackConstants.MAXIMUM_HEIGHT - heightOffset;
            return result;
        }
        
        public function generateFlatHeightMap( segments:uint ):Vector.<Number>
        {
            var result:Vector.<Number> = [ 0 ];
            for ( var i:int = 0; i < segments; i++ ) result.push( Math.cos( i ) );
            return result;
        }
        
        public function generateNewTrackSegment( startPosition:int, startHeight:int ):TrackData
        {
            //var startTime:int = Platform.getTime();
            
            var trackType:int = Math.floor( Math.random() * 6 );
            var heightMap:Vector.<Number>;
            var backgroundType:int = 0;
            
            if ( trackType < 4 )
            {
                var segmentCount:int = Math.random() * ( TrackConstants.MAXIMUM_TRACK_SEGMENTS - TrackConstants.MINIMUM_TRACK_SEGMENTS ) + TrackConstants.MINIMUM_TRACK_SEGMENTS;
                heightMap = generateHeightMap( segmentCount );
            }
            else if ( trackType == 4 )
            {
                heightMap = generateFlatHeightMap( getSegmentCountForBackgroundType( 1 ) );
                backgroundType = 1;
            }
            else
            {
                backgroundType = Math.floor( Math.random() * TrackConstants.MAX_MIDSECTION_COUNT ) + 1;
                heightMap = generateFlatHeightMap( getSegmentCountForBackgroundType( backgroundType ) );
            }
            
            //trace( "Track Data generation took " + ( Platform.getTime() - startTime ) + " ms." );
            
            return new TrackData( startPosition, startHeight, heightMap, backgroundType );
        }
        
        public function getCartSpatialDataAt( x:int ):CartSpatialData
        {
            // Return the currently calculated cache if the last request was for the same position
            if ( x == _cartDataCache.position ) return _cartDataCache;
            
            var trackCount:int = _tracks.length;
            var gapWidthInPixels:int = TrackConstants.GAP_SEGMENTS * TrackConstants.SEGMENT_WIDTH;
            
            for ( var i:int = 0; i < trackCount; i++ )
            {
                var trackData:TrackData = _tracks[ i ];
                
                if ( x < trackData.startPosition )
                {
                    if ( i == 0 )
                    {
                        _cartDataCache.setTo( x, 0, trackData.startHeight, 1, true, trackData.startHeight, false );
                    }
                    else
                    {
                        var targetHeight:int = linearInterpolate( _tracks[ i - 1 ].endHeight, trackData.startHeight, ( x - _tracks[ i - 1 ].endPosition ) / gapWidthInPixels );
                        _cartDataCache.setTo( x, 0, targetHeight, 1, false, trackData.startHeight, false );
                    }
                    return _cartDataCache;
                }
                else if ( x < trackData.endPosition )
                {
                    var rotation:Number = trackData.getRotationAt( x );
                    _cartDataCache.setTo( x, rotation, trackData.getHeightAtPosition( x ) + trackData.startHeight, Math.cos( rotation ), trackData.backgroundType > 0, trackData.startHeight, true );
                    return _cartDataCache;
                }
            }
            
            return CartSpatialData.NONE;
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        private static function populateTextureWidths():void
        {
            var textureNames:Vector.<String> = [ TrackConstants.COLUMN_NARROW, TrackConstants.COLUMN_LEFT, TrackConstants.COLUMN_MIDDLE, TrackConstants.COLUMN_RIGHT ];
            for each ( var textureName:String in textureNames )
            {
                TEXTURE_WIDTHS[ textureName ] = TextureAtlasManager.getTexture( "track", textureName ).width;
                //trace( "ADDED WIDTH FOR", textureName, TEXTURE_WIDTHS[ textureName ] );
            }
        }
        
        private function updateTrackData():void
        {
            // Remove all tracks behind our current position
            while ( _tracks.length > 0 && _tracks[ 0 ].endPosition < _position - TrackConstants.SPATIAL_OVERDRAW )
            {
                _tracks.shift();
            }
            
            var startPos:int = _tracks.length > 0 ? _tracks[ _tracks.length - 1 ].endPosition : 0;
            var endPos:int = _position + _width + TrackConstants.SPATIAL_OVERDRAW;
            
            if ( startPos >= endPos ) return;
            
            if ( infiniteLoopMode )
            {
                var heightMap:Vector.<Number> = generateFlatHeightMap( TrackConstants.MAXIMUM_TRACK_SEGMENTS );
                var loopTrack:TrackData = new TrackData( startPos, 0, heightMap, Math.randomRangeInt( 1, 4 ) );
                _tracks.pushSingle( loopTrack );
                return;
            }
            
            if ( startPos > 0 ) startPos += TrackConstants.GAP_SEGMENTS * TrackConstants.SEGMENT_WIDTH;
            
            // Append tracks to fill width
            while ( startPos < endPos )
            {
                var previousTrack:TrackData = _tracks.length > 0 ? _tracks[ _tracks.length - 1 ] : null;
                var previousTrackHeight:int = previousTrack ? previousTrack.getHeightAtIndex( previousTrack.segmentCount - 1 ) + previousTrack.startHeight : 0;
                var verticalGap:int = TrackConstants.MAXIMUM_VERTICAL_GAP - Math.random() * TrackConstants.MAXIMUM_VERTICAL_GAP * 2;
                var newTrack:TrackData = generateNewTrackSegment( startPos, previousTrackHeight + verticalGap );
                _tracks.pushSingle( newTrack );
                onTrackAdded( newTrack );
                startPos = newTrack.endPosition + TrackConstants.GAP_SEGMENTS * TrackConstants.SEGMENT_WIDTH;
            }
        }
        
        private static function linearInterpolate( a:Number, b:Number, x:Number ):Number
        {
            return  a * ( 1 - x ) + b * x;
        }
    }
}