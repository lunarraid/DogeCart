package com.lunarraid.dogecart.render
{
	import system.Boolean;
	import loom2d.display.DisplayObject;
	import loom2d.display.Sprite;
	import loom2d.display.Image;
	import loom2d.textures.Texture;
    import loom2d.math.Rectangle;
    import loom2d.math.Point;
	
	import loom.gameframework.LoomComponent;
	
    import com.lunarraid.dogecart.time.DeltaAnimatedComponent;
    import com.lunarraid.dogecart.spatial.TrackSpatialManager;
    import com.lunarraid.dogecart.spatial.TrackData;
	
    public class TrackRenderer extends DeltaAnimatedComponent
    {
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        [Inject]
        public var spatialManager:TrackSpatialManager;
        
        [Inject]
        public var viewManager:TrackViewManager;
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _trackSprites:Vector.<TrackQuadBatch>;
        private var _trackContainer:Sprite;
        private var _drawingDeferred:Boolean;
        
        //--------------------------------------
        // GETTERS / SETTERS
        //--------------------------------------
        
        override public function get priority():Number { return 5; }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        override public function onFrame( deltaTime:Number ):void
        {
            super.onFrame( deltaTime );
            update();
        }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        public function update():void
        {
            var tracks:Vector.<TrackData> = spatialManager.tracks;
            
            // Clear old tracks
            var firstData:TrackData = tracks.length > 0 ? tracks[ 0 ] : null;
            var firstTrack:TrackQuadBatch = _trackSprites.length > 0 ? _trackSprites[ 0 ] : null;
            while ( firstTrack != null && firstTrack.trackData != firstData )
            {
                firstTrack.removeFromParent( true );
                _trackSprites.shift();
                firstTrack = _trackSprites.length > 0 ? _trackSprites[ 0 ] : null;
            }
            
            // Early out if no data to draw
            if ( tracks.length == 0 ) return;
            
            // New tracks!
            var trackCount:int = tracks.length;
            var needsNewTrack:Boolean;
            var needsReplacementTrack:Boolean;
            
            for ( var i:int = 0; i < trackCount; i++ )
            {
                needsNewTrack = i >= _trackSprites.length;
                needsReplacementTrack = !needsNewTrack && tracks[ i ] != _trackSprites[ i ].trackData;
                
                if ( !needsNewTrack && !needsReplacementTrack ) continue;
                
                // Defer drawing one frame to see if this helps performance
                if ( !_drawingDeferred )
                {
                    _drawingDeferred = true;
                    return;
                }
                
                _drawingDeferred = false;
                
                var newTrack:TrackQuadBatch = new TrackQuadBatch( tracks[ i ] );
                newTrack.x = newTrack.trackData.startPosition;
                newTrack.y = newTrack.trackData.startHeight;
                
                if ( needsNewTrack )
                {
                    _trackContainer.addChild( newTrack );
                    _trackSprites.pushSingle( newTrack );
                }
                else
                {
                    _trackSprites[ i ].removeFromParent( true );
                    _trackSprites[ i ] = newTrack;
                    _trackContainer.addChild( newTrack );
                }
            }
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        override protected function onAdd():Boolean
        {
            if ( !super.onAdd() ) return false;
            
            _trackSprites = [];
            _trackContainer = new Sprite();
            viewManager.trackLayer.addChild( _trackContainer );
            
            return true;
        }
        
        override protected function onRemove():void
        {
            _trackContainer.removeFromParent( true );
            
            _trackContainer = null;
            _trackSprites.clear();
            _trackSprites = null;
            
            super.onRemove();
        }
    }
}