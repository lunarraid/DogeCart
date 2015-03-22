package com.lunarraid.dogecart.render
{
	import loom2d.math.Rectangle;
	import loom2d.ui.TextureAtlasManager;
	import loom2d.textures.Texture;
	import feathers.display.TiledImage;
	import loom2d.math.Point;
	import loom2d.display.Sprite;
	
    public class ScrollingImage extends Sprite
    {
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _textureSize:Point;
        private var _image:TiledImage;
        private var _width:Number;
        private var _height:Number;
        private var _scrollX:Number;
        private var _scrollY:Number;
        
        //--------------------------------------
        //  CONSTRUCTOR
        //--------------------------------------
        
        public function ScrollingImage( texture:Texture )
        {
            _image = new TiledImage( texture );
            addChild( _image );
            
            _textureSize.x = texture.width;
            _textureSize.y = texture.height;
            
            width = _textureSize.x;
            height = _textureSize.y;
        }
        
        //--------------------------------------
        //  GETTERS / SETTERS
        //--------------------------------------
        
        override public function get width():Number { return _width; }
        
        override public function set width( value:Number ):void
        {
            if ( _width == value ) return;
            _width = value;
            _image.width = _textureSize.x * ( Math.ceil( _width / _textureSize.x ) + 1 );
        }
        
        override public function get height():Number { return _height; }
        
        override public function set height( value:Number ):void
        {
            if ( _height == value ) return;
            _height = value;
            _image.height = _textureSize.y * ( Math.ceil( _height / _textureSize.y ) + 1 );
        }
        
        override public function get scrollX():Number { return _scrollX; }
        
        override public function set scrollX( value:Number ):void
        {
            if ( _scrollX == value ) return;
            _scrollX = value;
            _image.x = _scrollX % _textureSize.x - _textureSize.x;
        }
        
        override public function get scrollY():Number { return _scrollY; }
        
        override public function set scrollY( value:Number ):void
        {
            if ( _scrollY == value ) return;
            _scrollY = value;
            _image.y = _scrollY % _textureSize.y - _textureSize.y;
        }
    }
}