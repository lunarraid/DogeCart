package com.lunarraid.dogecart.render
{
	import loom2d.display.QuadBatch;
	import loom2d.ui.TextureAtlasManager;
	import loom2d.display.Sprite;
	import loom2d.display.Image;
	import loom2d.textures.Texture;
	import loom2d.math.Matrix;
	
    import com.lunarraid.dogecart.TrackConstants;
    import com.lunarraid.dogecart.spatial.TrackData;
	
    public class TrackQuadBatch extends QuadBatch
    {
        public var slatSpacing:int = 4;
        
        private static var _matrix:Matrix = new Matrix();
        
        private var _segmentWidth:int;
        private var _currentSegment:int = 0;
        private var _trackData:TrackData;
        
        private static var _railImage:Image;
        private static var _railTextureHeight:int;
        private static var _railXScale:Number;
        
        private static var _slatImage:Image;
        private static var _slatHalfHeight:int;
        private static var _slatHalfWidth:int;
        
        private static var _narrowColumnImage:Image;
        private static var _narrowColumnWidth:int;
        private static var _narrowColumnHeight:int;
        
        private static var _leftColumnImage:Image;
        private static var _leftColumnWidth:int;
        private static var _leftColumnHeight:int;
        
        private static var _middleColumnImage:Image;
        private static var _middleColumnWidth:int;
        private static var _middleColumnHeight:int;
        
        private static var _rightColumnImage:Image;
        private static var _rightColumnWidth:int;
        private static var _rightColumnHeight:int;
        
        public function TrackQuadBatch( trackData:TrackData )
        {
            //var startTime:int = Platform.getTime();
            
            if ( !_railImage ) generateImageCache();
            _railTextureHeight = retrieveTexture( TrackConstants.RAIL ).height;
            
            if ( trackData.backgroundType == 1 ) addMiniPlatform( trackData );
            else if ( trackData.backgroundType > 1 ) addPlatform( trackData );
            
            _segmentWidth = TrackConstants.SEGMENT_WIDTH;
            _trackData = trackData;
            
            renderTracks();
            
            //trace( "Track Sprite instantiation took " + ( Platform.getTime() - startTime ) + " ms." );
        }
        
        public function get trackData():TrackData { return _trackData; }
        
        public function renderTracks():void
        {
            var segmentCount:int = _trackData.segmentCount - 1;
            var startHeight:Number = 0;
            
            for ( var i:int = 1; i < segmentCount; i += slatSpacing )
            {
                startHeight = _trackData.getHeightAtIndex( i );
                var endHeight:int = _trackData.getHeightAtIndex( i + 1 );
                _matrix.identity();
                _matrix.rotate( Math.atan2( endHeight - startHeight, _segmentWidth ) * 0.7 );
                _matrix.translate( i * _segmentWidth + _segmentWidth * 0.5 - _slatHalfWidth, ( startHeight + endHeight ) * 0.5 - _slatHalfHeight );
                addImage( _slatImage, 1, _matrix );
            }
            
            for ( var j:int = 0; j < segmentCount; j++ )
            {
                startHeight = _trackData.getHeightAtIndex( j );
                _matrix.identity();
                _matrix.skew( 0, Math.atan2( _trackData.getHeightAtIndex( j + 1 ) - startHeight, _segmentWidth ) );
                _matrix.scale( _railXScale, 1 );
                _matrix.translate( j * _segmentWidth, startHeight - _railTextureHeight * 2 );
                addImage( _railImage, 1, _matrix );
                _matrix.translate( 0, _railTextureHeight * 2 );
                addImage( _railImage, 1, _matrix );
            }
        }
        
        private function addMiniPlatform( trackData:TrackData ):void
        {
            _matrix.identity();
            var columnOffsetX:int = _narrowColumnWidth * 0.5 - ( _narrowColumnWidth + trackData.segmentCount * TrackConstants.SEGMENT_WIDTH ) * 0.25;
            _matrix.translate( -columnOffsetX, -TrackConstants.MINI_PLATFORM_BASELINE );
            addImage( _narrowColumnImage, 1, _matrix );
            _matrix.scale( 1, -1 );
            _matrix.translate( 0, TrackConstants.MINI_PLATFORM_BASELINE * 0.5 + _narrowColumnHeight );
            addImage( _narrowColumnImage, 1, _matrix );
        }
        
        private function addPlatform( trackData:TrackData ):void
        {
            var midSegments:int = trackData.backgroundType - 2;
            var totalColumnWidth:int = getPlatformWidth( midSegments );
            var offsetX:int = int( ( trackData.segmentCount * TrackConstants.SEGMENT_WIDTH - totalColumnWidth ) * 0.5 );
            
            for ( var j:int = 0; j < 3; j++ )
            {
                _matrix.identity();
                
                if ( j % 2 == 0 ) _matrix.scale( 1, -1 );
                if ( j == 2 ) _matrix.translate( 0, _leftColumnHeight * 2 );
                
		        _matrix.translate( offsetX, -TrackConstants.PLATFORM_BASELINE );
		        addImage( _leftColumnImage, 1, _matrix );
		        
		        _matrix.translate( _leftColumnWidth, 0 );
		        
		        for ( var i:int = 0; i < midSegments; i++ )
		        {
		            addImage( _middleColumnImage, 1, _matrix );
		            _matrix.translate( _middleColumnWidth, 0 );
		        }
		        
		        addImage( _rightColumnImage, 1, _matrix );
		    }
        }
        
        private static function generateImageCache():void
        {
            var slatTexture:Texture = retrieveTexture( TrackConstants.SLAT );
            _slatImage = new Image( slatTexture );
            _slatHalfWidth = slatTexture.width * 0.5;
            _slatHalfHeight = slatTexture.height * 0.5;
            
            var railTexture:Texture = retrieveTexture( TrackConstants.RAIL );
            _railImage = new Image( railTexture );
            _railXScale = TrackConstants.SEGMENT_WIDTH / railTexture.width;
            
            var narrowColumnTexture:Texture = retrieveTexture( TrackConstants.COLUMN_NARROW );
            _narrowColumnImage = new Image( narrowColumnTexture );
            _narrowColumnWidth = narrowColumnTexture.width;
            _narrowColumnHeight = narrowColumnTexture.height;
            
            var leftColumnTexture:Texture = retrieveTexture( TrackConstants.COLUMN_LEFT );
            _leftColumnImage = new Image( leftColumnTexture );
            _leftColumnWidth = leftColumnTexture.width;
            _leftColumnHeight = leftColumnTexture.height;
            
            var middleColumnTexture:Texture = retrieveTexture( TrackConstants.COLUMN_MIDDLE );
            _middleColumnImage = new Image( middleColumnTexture );
            _middleColumnWidth = middleColumnTexture.width;
            _middleColumnHeight = middleColumnTexture.height;
            
            var rightColumnTexture:Texture = retrieveTexture( TrackConstants.COLUMN_RIGHT );
            _rightColumnImage = new Image( rightColumnTexture );
            _rightColumnHeight = rightColumnTexture.height;
            _rightColumnWidth = rightColumnTexture.width;
        }
        
        private static function retrieveTexture( name:String ):Texture
        {
            return TextureAtlasManager.getTexture( "track", name );
        }
        
        private static function getPlatformWidth( midsegments:int ):int
        {
            return _leftColumnWidth + _rightColumnWidth + _middleColumnWidth * midsegments;
        }
    }
}