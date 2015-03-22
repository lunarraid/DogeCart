package com.lunarraid.dogecart.render
{
    import loom2d.Loom2D;
    import loom2d.textures.Texture;
    import loom2d.display.MovieClip;
	import loom2d.ui.TextureAtlasManager;
    import loom2d.display.DisplayObject;
    import loom2d.display.Sprite;
	import loom.gameframework.AnimatedComponent;
	
    public class AnimationRenderer extends BaseRenderComponent
    {
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _atlasName:String;
        private var _textureName:String;
        private var _movieClip:MovieClip;
        private var _enabled = false;
        private var _lastTime:int;
        
        private static const _textures:Dictionary.<String, Vector.<Texture>> = {};
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        public function AnimationRenderer( atlasName:String, textureName:String )
        {
            super();
            _atlasName = atlasName;
            _textureName = textureName;
        }
        
        //--------------------------------------
        // GETTERS / SETTERS
        //--------------------------------------
        
        public function get fps():Number { return _movieClip.fps; }
        public function set fps( value:Number ):void { _movieClip.fps = value; }
        
        public function get enabled():Boolean { return _enabled; }
        
        public function set enabled( value:Boolean ):void
        {
            if ( _enabled == value ) return;
            
            _enabled = value;
            
            if ( _enabled )
            {
                applyBindings();
                _lastTime = timeManager.virtualTime;
                viewManager.foregroundLayer.addChild( _movieClip );
                _movieClip.play();
            }
            else
            {
                _movieClip.stop();
                _movieClip.removeFromParent();
            }
        }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        override public function onFrame( deltaTime:Number ):void
        {
            super.onFrame( deltaTime );
            
            if ( ! _enabled ) return;
            
            _movieClip.advanceTime( ( timeManager.virtualTime - _lastTime ) * 0.001 );
            _lastTime = timeManager.virtualTime;
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        override protected function onAdd():Boolean
        {
            if ( !super.onAdd() ) return false;
            enabled = true;
            return true;
        }
        
        override protected function onRemove():void
        {
            enabled = false;
            super.onRemove();
        }
        
        override protected function createViewComponent():DisplayObject
        {
            _movieClip = new MovieClip( getTextureSet( _atlasName, _textureName ) );
            _movieClip.center();
            _movieClip.play();
            return _movieClip;
        }
        
        private static function getTextureSet( atlasName:String, textureName:String ):Vector.<Texture>
        {
            var textureKey:String = atlasName + textureName;
            var result:Vector.<Texture> = _textures[ textureKey ];
            
            if ( result ) return result;
            
            result = [];
            
            var i:int = 1;
            var texture:Texture;
            
            while ( texture = TextureAtlasManager.getTexture( atlasName, textureName + i ) )
            {
                result.push( texture );
                i++;
            }
            
            _textures[ textureKey ] = result;
            
            return result;
        }
    }
}