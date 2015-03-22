package com.lunarraid.dogecart.screen
{
    import loom2d.Loom2D;
    
    import loom2d.utils.HAlign;
    
    import loom2d.display.DisplayObject;
    import loom2d.display.DisplayObjectContainer;
    import loom2d.display.Quad;
    import loom2d.display.Image;
    import loom2d.display.Sprite;
	
    import loom2d.animation.Transitions;
	
	import loom2d.ui.TextureAtlasManager;

    import loom2d.math.Rectangle;
    import loom2d.events.Event;
    
    import feathers.controls.Button;
    import feathers.text.BitmapFontTextFormat;
    import feathers.text.BitmapFontTextRenderer;
    import feathers.textures.Scale9Textures;
    import feathers.display.Scale9Image;
    
    public class CreditsScreen extends BaseScreen
    {
        //--------------------------------------
        // CONSTANTS
        //--------------------------------------
        
        //--------------------------------------
        // PUBLIC
        //--------------------------------------
        
        public const backButtonHit:ButtonDelegate;
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _dialogContainer:Sprite;
        private var _backButton:Button;
        
        private var _background:Quad;
        private var _title:BitmapFontTextRenderer;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        public function CreditsScreen()
        {
            super();
            
            _background = new Quad( BaseScreen.DESIGN_WIDTH, 100, 0x000000 );
            addChild( _background );
            
            var dialogHeight:int = 600;
            var dialogWidth:int = BaseScreen.DESIGN_WIDTH * 0.75;
            
            _dialogContainer = new Sprite();
            _dialogContainer.x = ( BaseScreen.DESIGN_WIDTH - dialogWidth ) * 0.5;
            addChild( _dialogContainer );
            
            var dialogTexture:Scale9Textures = new Scale9Textures( TextureAtlasManager.getTexture( "track", "dialog" ), new Rectangle( 24, 24, 16, 16 ) );
            var dialogSkin:Scale9Image = new Scale9Image( dialogTexture );
            dialogSkin.width = dialogWidth;
            dialogSkin.height = dialogHeight;
            _dialogContainer.addChild( dialogSkin );
            
            var headerSkin:Scale9Image = new Scale9Image( dialogTexture );
            headerSkin.width = dialogWidth * 0.75;
            headerSkin.height = 80;
            headerSkin.x = dialogWidth * 0.125;
            headerSkin.y = -30;
            _dialogContainer.addChild( headerSkin );
            
            var headerTextFormat:BitmapFontTextFormat = new BitmapFontTextFormat( "comic-sans", 32, 0xffffff, false, "center" );
            var headerLabel:BitmapFontTextRenderer = createLabel( -5, -34, _dialogContainer, headerTextFormat, "credits" );
            headerLabel.width = dialogWidth;
            
            var creditsText:String = "DogeCart, copyright 2014 LunarRaid." + "\n\n" +
                                     "Code, art and design by Raymond Cook. Animated 3D DogeCoin graphic by reddit user cinemagfx." + "\n\n" +
                                     "Like the game, and want to leave a tip?";
                                     
            var creditsTextFormat:BitmapFontTextFormat = new BitmapFontTextFormat( "comic-sans", 20, 0xffffff );
            var creditsLabel:BitmapFontTextRenderer = createLabel( 50, 90, _dialogContainer, creditsTextFormat, creditsText );
            creditsLabel.width = dialogWidth - 100;
            
            var walletTitleTextFormat:BitmapFontTextFormat = new BitmapFontTextFormat( "comic-sans", 20, 0xffff00 );
            var walletTitleLabel:BitmapFontTextRenderer = createLabel( 50, 280, _dialogContainer, walletTitleTextFormat, "DogeCoin Wallet Address:" );
            
            var walletValueTextFormat:BitmapFontTextFormat = new BitmapFontTextFormat( "comic-sans", 16, 0x00ff00 );
            var walletValueLabel:BitmapFontTextRenderer = createLabel( 50, 310, _dialogContainer, walletValueTextFormat, "DF8Qb1gkvBWqNFAvtLZPFA3DpkJD5ycoRR" );
            
            var loomButton:Button = new Button();
            loomButton.defaultSkin = new Image( TextureAtlasManager.getTexture( "track", "loom-logo" ) );
            loomButton.scale = 0.75;
            loomButton.center();
            loomButton.x = dialogWidth * 0.5 - 113;
            loomButton.y = dialogHeight - 220;
            _dialogContainer.addChild( loomButton );
            
            _backButton = createButton( "back", "back-button" );
            _backButton.scale = 0.5;
            _backButton.paddingTop = _backButton.paddingBottom = 64;
            _backButton.x = ( dialogWidth - 150 ) * 0.5;
            _backButton.y = dialogHeight;
            _backButton.addEventListener( Event.TRIGGERED, onBackButtonTriggered );
            _dialogContainer.addChild( _backButton );
        }
        
        //--------------------------------------
        // GETTERS / SETTERS
        //--------------------------------------
        
        
        //--------------------------------------
        // PUBLIC METHODS
        //--------------------------------------
        
        override public function show():void
        {
            super.show();
            
            clearTweens();
            
            alpha = 1;
            _background.alpha = 0;
            
            _dialogContainer.y = -_scaledHeight;
            
            var targetDialogY:int = ( _scaledHeight - 700 ) * 0.5;
            
            Loom2D.juggler.tween( _background, 0.5, { alpha: 0.5 } );
            Loom2D.juggler.tween( _dialogContainer, 0.5, { y: targetDialogY, transition: Transitions.EASE_OUT } );
        }
        
        override public function hide( callback:Function = null ):void
        {
            touchable = false;
            clearTweens();
            this.alpha = 0;
            callback();
        }
        
        //--------------------------------------
        // PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        protected function onBackButtonTriggered( e:Event ):void
        {
            backButtonHit();
        }
        
        protected function clearTweens():void
        {
            Loom2D.juggler.removeTweens( this );
            
            for ( var i:int = 0; i < numChildren; i++ )
            {
                Loom2D.juggler.removeTweens( getChildAt( i ) );
            }
        }
        
        override protected function resize():void
        {
            super.resize();
            _background.height = _scaledHeight;
        }
    }
}