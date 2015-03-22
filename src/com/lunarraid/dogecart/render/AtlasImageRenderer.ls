package com.lunarraid.dogecart.render 
{
	import loom2d.ui.TextureAtlasManager;
    import loom2d.display.DisplayObject;
    import loom2d.display.Image;
	import loom.gameframework.AnimatedComponent;
	
    public class AtlasImageRenderer extends BaseRenderComponent
    {
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        protected var _image:Image;
        protected var _atlasName:String;
        protected var _textureName:String;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        public function AtlasImageRenderer( atlasName:String, textureName:String ):void
        {
            _atlasName = atlasName;
            _textureName = textureName;
        }
        
        //--------------------------------------
        // GETTERS / SETTERS
        //--------------------------------------
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        override protected function createViewComponent():DisplayObject
        {
            _image = new Image( TextureAtlasManager.getTexture( _atlasName, _textureName ) );
            return _image;
        }
    }
}