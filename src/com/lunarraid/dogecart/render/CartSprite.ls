package com.lunarraid.dogecart.render
{
	import loom2d.ui.TextureAtlasManager;
    import loom2d.display.DisplayObject;
    import loom2d.display.Image;
    import loom2d.display.Sprite;
	
    public class CartSprite extends Sprite
    {
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _cartBackImage:Image;
        private var _dogeImage:Image;
        private var _cartImage:Image;
        private var _pickaxeImage:Image;
        private var _pickaxeSprite:Sprite;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        public function CartSprite()
        {
            super();
            
            _cartBackImage = new Image( TextureAtlasManager.getTexture( "track", "cartback" ) );
            _cartBackImage.pivotX = _cartBackImage.width * 0.35;
            _cartBackImage.pivotY = _cartBackImage.height * 0.9;
            addChild( _cartBackImage );
            
            _dogeImage = new Image( TextureAtlasManager.getTexture( "track", "doge" ) );
            _dogeImage.pivotX = _dogeImage.width * 0.5 - 10;
            _dogeImage.pivotY = _dogeImage.height + 38;
            addChild( _dogeImage );
            
            _cartImage = new Image( TextureAtlasManager.getTexture( "track", "cart" ) );
            _cartImage.pivotX = _cartImage.width * 0.35;
            _cartImage.pivotY = _cartImage.height * 0.9;
            addChild( _cartImage );
            
            _pickaxeImage = new Image( TextureAtlasManager.getTexture( "track", "pickaxe" ) );
            _pickaxeImage.pivotX = 54;
            _pickaxeImage.pivotY = 20;
            
            _pickaxeSprite = new Sprite();
            _pickaxeSprite.pivotX = 5;
            _pickaxeSprite.pivotY = 72;
            _pickaxeSprite.addChild( _pickaxeImage );
            
            addChild( _pickaxeSprite );
        }
        
        //--------------------------------------
        // PUBLIC METHODS
        //--------------------------------------
        
        // I'd much prefer to override the rotation setter on Sprite, but a
        // bug in calling super properties that are fast path setters
        // doesn't allow for it. Revisit this when the bug is resolved.
        // <rcook 5/6/2014>
        
        public function setRotation( value:Number ):void
        {
            rotation = value;
            _dogeImage.rotation = value * -0.15;
            _pickaxeImage.rotation = value * 0.5;
        }
    }
}