package com.lunarraid.dogecart.render
{
	import loom2d.math.Rectangle;
	import loom2d.ui.TextureAtlasManager;
	import loom2d.textures.Texture;
	import feathers.display.TiledImage;
	import loom2d.math.Point;
	import loom2d.display.Sprite;
	
    import com.lunarraid.dogecart.time.DeltaAnimatedComponent;
	
    public class BackgroundRenderer extends DeltaAnimatedComponent
    {
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        [Inject]
        public var viewManager:TrackViewManager;
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _image:ScrollingImage;
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        override public function onFrame( deltaTime:Number ):void
        {
            super.onFrame( deltaTime );
            var viewPort:Rectangle = viewManager.viewPort;
            _image.scrollX = -viewPort.x * 0.35;
            _image.scrollY = -viewPort.y * 0.25;
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        override protected function onAdd():Boolean
        {
            if ( !super.onAdd() ) return false;
            
            _image = new ScrollingImage( TextureAtlasManager.getTexture( "track", "background" ) );
            viewManager.backgroundLayer.addChild( _image );
            viewManager.resized += resize;
            resize();
            
            return true;
        }
        
        override protected function onRemove():void
        {
            viewManager.resized -= resize;
            _image.removeFromParent( true );
            _image = null;
            super.onRemove();
        }
        
        private function resize():void
        {
            _image.width = viewManager.viewPort.width;
            _image.height = viewManager.viewPort.height;
        }
    }
}