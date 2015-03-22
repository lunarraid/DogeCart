package com.lunarraid.dogecart.screen
{
    import feathers.text.BitmapFontTextRenderer;
    import feathers.text.BitmapFontTextFormat;
	import feathers.controls.Button;
    import loom2d.Loom2D;
    import loom2d.animation.Transitions;
	import loom2d.ui.TextureAtlasManager;
	import loom2d.ui.SimpleLabel;
    import loom2d.display.DisplayObject;
    import loom2d.display.Image;
    import loom2d.display.Sprite;
    import loom2d.math.Point;
    import loom2d.math.Rectangle;
    import loom2d.text.BitmapFont;
    import loom2d.events.Event;
    
    import com.lunarraid.dogecart.render.ScrollingImage;
    import com.lunarraid.dogecart.render.CartSprite;
    
    public class MainMenuScreen extends BaseScreen
    {
        //--------------------------------------
        // PUBLIC
        //--------------------------------------
        
        public const playButtonHit:ButtonDelegate;
        public const creditsButtonHit:ButtonDelegate;
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _dogeTextImage:Image;
        private var _cartSprite:CartSprite;
        private var _cartTextImage:Image;
        private var _playButton:Button;
        private var _creditsButton:Sprite;
        private var _copyrightText:BitmapFontTextRenderer;
        
        private var _scrollingImage:ScrollingImage;
        private var _dogeTextShowPosition:Point;
        private var _cartSpriteShowPosition:Point;
        private var _cartTextShowPosition:Point;
        private var _playButtonShowPosition:Point;
        private var _creditsButtonShowPosition:Point;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        public function MainMenuScreen()
        {
            super();
            
            _scrollingImage = new ScrollingImage( TextureAtlasManager.getTexture( "track", "background" ) );
            _scrollingImage.width = BaseScreen.DESIGN_WIDTH;
            _scrollingImage.height = _scaledHeight;
            addChild( _scrollingImage );
            
            _dogeTextImage = new Image( TextureAtlasManager.getTexture( "track", "doge-title" ) );
            _cartSprite = new CartSprite();
            _cartTextImage = new Image( TextureAtlasManager.getTexture( "track", "cart-title" ) );
            
            var cartBounds:Rectangle = _cartSprite.getBounds( _cartSprite );
            _cartSprite.pivotX = cartBounds.right - cartBounds.width * 0.5;
            _cartSprite.pivotY = cartBounds.bottom - cartBounds.height * 0.5;
            _cartSprite.rotation = -Math.PI * 0.15;
            
            addChild( _cartTextImage );
            addChild( _cartSprite );
            addChild( _dogeTextImage );
            
            _dogeTextShowPosition.x = 90;
            _dogeTextShowPosition.y = 150;
            
            _cartSpriteShowPosition.x = _dogeTextShowPosition.x + _dogeTextImage.width + 5;
            _cartSpriteShowPosition.y = _dogeTextShowPosition.y + 10;
            
            _cartTextShowPosition.x = _cartSpriteShowPosition.x + 45;
            _cartTextShowPosition.y = _dogeTextShowPosition.y;
            
            _playButton = createButton( "play", "play-button" );
            addChild( _playButton );
            
            _playButtonShowPosition.x = 160;
            _playButton.addEventListener( Event.TRIGGERED, onPlayButtonTriggered );
            
            _creditsButton = createButton( "credits", "credits-button" );
            addChild( _creditsButton );
            
            _creditsButtonShowPosition.x = 160;
            _creditsButton.addEventListener( Event.TRIGGERED, onCreditsButtonTriggered );
            
            _copyrightText = createLabel( 170, _scaledHeight - 100, this, new BitmapFontTextFormat( "comic-sans", 36, 0xffffff ), String.fromCharCode( 169 ) + "2014 lunarraid" );
        }
        
        //--------------------------------------
        // PUBLIC METHODS
        //--------------------------------------
        
        override public function show():void
        {
            super.show();
            
            clearTweens();
            
            alpha = 0;
            
            _dogeTextImage.x = _dogeTextShowPosition.x - 750;
            _dogeTextImage.y = _dogeTextShowPosition.y;
            
            _cartSprite.x = _cartSpriteShowPosition.x;
            _cartSprite.y = _cartSpriteShowPosition.y - 1000;

            _cartTextImage.x = _cartTextShowPosition.x + 750;
            _cartTextImage.y = _cartTextShowPosition.y;
            
            _playButton.x = _playButtonShowPosition.x;
            _playButton.y = _playButtonShowPosition.y + 50;
            _playButton.alpha = 0;
            
            _creditsButton.x = _creditsButtonShowPosition.x;
            _creditsButton.y = _creditsButtonShowPosition.y + 50;
            _creditsButton.alpha = 0;
            
            _copyrightText.alpha = 0;
            
            _scrollingImage.scrollX = 0;
            
            Loom2D.juggler.tween( this, 0.25, { alpha: 1 } );
            Loom2D.juggler.tween( _dogeTextImage, 1, { x: _dogeTextShowPosition.x, transition: Transitions.EASE_IN_OUT_BACK } );
            Loom2D.juggler.tween( _cartTextImage, 1, { x: _cartTextShowPosition.x, transition: Transitions.EASE_IN_OUT_BACK } );
            Loom2D.juggler.tween( _cartSprite, 2.5, { y: _cartSpriteShowPosition.y, transition: Transitions.EASE_OUT_BOUNCE } );
            Loom2D.juggler.tween( _scrollingImage, 10, { scrollX: -512, repeatCount: 0 } );
            Loom2D.juggler.tween( _playButton, 0.25, { y: _playButtonShowPosition.y, alpha: 1, delay: 2 } );
            Loom2D.juggler.tween( _creditsButton, 0.25, { y: _creditsButtonShowPosition.y, alpha: 1, delay: 2.15 } );
            Loom2D.juggler.tween( _copyrightText, 0.25, { alpha: 1, delay: 2 } );
        }
        
        override public function hide( callback:Function = null ):void
        {
            clearTweens();
            Loom2D.juggler.tween( _dogeTextImage, 1, { x: _dogeTextShowPosition.x - 750, transition: Transitions.EASE_OUT_IN_BACK } );
            Loom2D.juggler.tween( _cartTextImage, 1, { x: _cartTextShowPosition.x + 750, transition: Transitions.EASE_OUT_IN_BACK } );
            Loom2D.juggler.tween( _cartSprite, 2, { y: _cartSpriteShowPosition.y - 1000, transition: Transitions.EASE_OUT_BACK } );
            Loom2D.juggler.tween( _playButton, 0.25, { y: _playButtonShowPosition.y + 50, alpha: 0 } );
            Loom2D.juggler.tween( _creditsButton, 0.25, { y: _creditsButtonShowPosition.y + 50, alpha: 0 } );
            Loom2D.juggler.tween( _copyrightText, 0.25, { alpha: 0 } );
            super.hide( callback );
        }
        
        //--------------------------------------
        // PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        protected function resize():void
        {
            super.resize();
            
            trace( "\n\nSCALED HEIGHT: " + _scaledHeight + "\n\n" );
            
            _scrollingImage.height = _scaledHeight;
            _copyrightText.y = _scaledHeight - 100;
            _playButtonShowPosition.y = _scaledHeight * 0.5 - 90;
            _creditsButtonShowPosition.y = _scaledHeight * 0.5 + 30;
        }
        
        protected function onPlayButtonTriggered( e:Event ):void
        {
            playButtonHit();
        }
        
        protected function onCreditsButtonTriggered( e:Event ):void
        {
            creditsButtonHit();
        }
        
        protected function clearTweens():void
        {
            for ( var i:int = 0; i < numChildren; i++ )
            {
                Loom2D.juggler.removeTweens( getChildAt( i ) );
            }
        }
    }
}