package com.lunarraid.dogecart.screen
{
    import loom2d.Loom2D;
    import loom2d.display.DisplayObject;
    import loom2d.display.DisplayObjectContainer;
    import loom2d.display.Image;
    import loom2d.display.Sprite;
    
    import loom2d.ui.TextureAtlasManager;
    
    import feathers.text.BitmapFontTextFormat;
    import feathers.text.BitmapFontTextRenderer;
    
    import feathers.controls.Button;
    import feathers.controls.Label;
    
    delegate ButtonDelegate();
    
    public class BaseScreen extends Sprite
    {
        //--------------------------------------
        // CLASS CONSTANTS
        //--------------------------------------
        
        public static const DESIGN_WIDTH:int = 640;
        
        public static const DEFAULT_BUTTON_LABEL_PROPERTIES:Dictionary.<String, Object> = {};
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        protected var _width:Number;
        protected var _height:Number;
        protected var _scaledHeight:Number;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        public function BaseScreen()
        {
            super();
            
            if ( !DEFAULT_BUTTON_LABEL_PROPERTIES[ "textFormat" ] )
            {
                DEFAULT_BUTTON_LABEL_PROPERTIES[ "textFormat" ] =  new BitmapFontTextFormat( "comic-sans", 64, 0xffffff );
            }
        }
        
        //--------------------------------------
        // GETTERS / SETTERS
        //--------------------------------------
        
        override public function get width():Number { return _width; }
        
        override public function set width( value:Number ):void
        {
            if ( _width == value ) return;
            _width = value;
            resize();
        }
        
        override public function get height():Number { return _height; }
        
        override public function set height( value:Number ):void
        {
            if ( _height == value ) return;
            _height = value;
            resize();
        }
        
        //--------------------------------------
        // PUBLIC METHODS
        //--------------------------------------
        
        public function show():void
        {
            touchable = true;
        }
        
        public function hide( callback:Function = null ):void
        {
            touchable = false;
            Loom2D.juggler.tween( this, 1, { alpha: 0, onComplete: callback } );
        }
        
        //--------------------------------------
        // PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        protected static function createButton( label:String, iconName:String, iconWidth:int = 96, iconHeight:int = 96 ):Button
        {
            var result:Button = new Button();
            
            var icon:Image = new Image(  TextureAtlasManager.getTexture( "track", iconName ) );
            icon.width = iconWidth;
            icon.height = iconHeight;
            
            result.defaultIcon = icon;
            result.verticalAlign = Button.VERTICAL_ALIGN_MIDDLE;
            result.defaultLabelProperties = DEFAULT_BUTTON_LABEL_PROPERTIES;
            result.labelOffsetY = -20;
            result.gap = 6;
            result.label = label;
            return result;
        }
        
        protected static function createLabel( x:int, y:int, parent:DisplayObjectContainer, textFormat:BitmapFontTextFormat, text:String = "" ):BitmapFontTextRenderer
        {
            var result:BitmapFontTextRenderer = new BitmapFontTextRenderer();
            result.textFormat = textFormat;
            result.x = x;
            result.y = y;
            result.text = text;
            parent.addChild( result );
            return result;
        }
        
        protected function resize():void
        {
            scale = _width / DESIGN_WIDTH;
            _scaledHeight = _height / scale;
        }
    }
}