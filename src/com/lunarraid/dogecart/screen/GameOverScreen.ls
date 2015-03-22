package com.lunarraid.dogecart.screen
{
	import loom2d.utils.HAlign;
	import feathers.textures.Scale9Textures;
	import feathers.display.Scale9Image;
    import loom2d.Loom2D;
    import loom2d.display.DisplayObject;
    import loom2d.display.DisplayObjectContainer;
    import loom2d.display.Quad;
    import loom2d.display.Image;
    import loom2d.display.Sprite;
	
	import loom.sound.Sound;
    
    import loom2d.animation.Transitions;
	
	import loom2d.ui.TextureAtlasManager;
	import loom2d.ui.SimpleLabel;

    import loom2d.math.Point;
    import loom2d.math.Rectangle;
    import loom2d.events.Event;
    
    import feathers.controls.Button;
    import feathers.controls.Label;
    import feathers.text.BitmapFontTextFormat;
    import feathers.text.BitmapFontTextRenderer;
    
    import com.lunarraid.dogecart.render.ScrollingImage;
    import com.lunarraid.dogecart.render.CartSprite;
    
    public class GameOverScreen extends BaseScreen
    {
        //--------------------------------------
        // CONSTANTS
        //--------------------------------------
        
        private static const COIN_SOUND_INTERVAL:int = 80;
    
        //--------------------------------------
        // PUBLIC
        //--------------------------------------
        
        public const replayButtonHit:ButtonDelegate;
        public const backButtonHit:ButtonDelegate;
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _dialogContainer:Sprite;
        private var _replayButton:Button;
        private var _backButton:Button;
        
        private var _background:Quad;
        private var _title:BitmapFontTextRenderer;
        private var _coinCountTitleLabel:BitmapFontTextRenderer;
        private var _coinCountLabel:BitmapFontTextRenderer;
        private var _recordCountTitleLabel:BitmapFontTextRenderer;
        private var _recordCountLabel:BitmapFontTextRenderer;
        
        private var _coinCount:int;
        private var _coinRecord:int;
        
        private var _lastCoinSoundTime:int = 0;
        private var _coinSound:Sound;
        
        private var _displayedCoinCount:int;
        private var _displayedRecordCount:int;
        
        private var _greenHeaderTextFormat:BitmapFontTextFormat;
        private var _redHeaderTextFormat:BitmapFontTextFormat;
        private var _headerLabel:BitmapFontTextRenderer;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        public function GameOverScreen()
        {
            super();
            
            var nameTextFormat:BitmapFontTextFormat = new BitmapFontTextFormat( "comic-sans", 26, 0xffff00 );
            var valueTextFormat:BitmapFontTextFormat = new BitmapFontTextFormat( "comic-sans", 32, 0xffffff );
            
            _coinSound = Sound.load( "assets/audio/coin.ogg" );
            
            _background = new Quad( BaseScreen.DESIGN_WIDTH, 100, 0x000000 );
            addChild( _background );
            
            _dialogContainer = new Sprite();
            _dialogContainer.x = ( BaseScreen.DESIGN_WIDTH - 320 ) * 0.5;
            addChild( _dialogContainer );
            
            var dialogTexture:Scale9Textures = new Scale9Textures( TextureAtlasManager.getTexture( "track", "dialog" ), new Rectangle( 24, 24, 16, 16 ) );
            var dialogSkin:Scale9Image = new Scale9Image( dialogTexture );
            dialogSkin.width = 320;
            dialogSkin.height = 320;
            _dialogContainer.addChild( dialogSkin );
            
            var headerSkin:Scale9Image = new Scale9Image( dialogTexture, 1 );
            headerSkin.width = dialogSkin.width * 0.75;
            headerSkin.height = 80;
            headerSkin.x = dialogSkin.width * 0.125;
            headerSkin.y = -30;
            _dialogContainer.addChild( headerSkin );
            
            _greenHeaderTextFormat = new BitmapFontTextFormat( "comic-sans", 32, 0x00ff00, false, HAlign.CENTER );
            _redHeaderTextFormat = new BitmapFontTextFormat( "comic-sans", 32, 0xff0000, false, HAlign.CENTER );
            _headerLabel = createLabel( -5, -34, _dialogContainer, _redHeaderTextFormat );
            _headerLabel.width = dialogSkin.width;
            
            _coinCountTitleLabel = createLabel( 60, 66, _dialogContainer, nameTextFormat, "coins:" );
            _coinCountLabel = createLabel( _coinCountTitleLabel.x + _coinCountTitleLabel.measureText().x, 60, _dialogContainer, valueTextFormat );
            
            _recordCountTitleLabel = createLabel( 60, 116, _dialogContainer, nameTextFormat, "record:" );
            _recordCountLabel = createLabel( _recordCountTitleLabel.x + _recordCountTitleLabel.measureText().x, 110, _dialogContainer, valueTextFormat );
            
            _replayButton = createButton( "replay", "play-button" );
            _replayButton.paddingTop = _replayButton.paddingBottom = 64;
            _replayButton.scale = 0.5;
            _replayButton.x = 70;
            _replayButton.y = 168;
            _replayButton.addEventListener( Event.TRIGGERED, onReplayButtonTriggered );
            _dialogContainer.addChild( _replayButton );
            
            _backButton = createButton( "back", "back-button" );
            _backButton.scale = 0.5;
            _backButton.paddingTop = _backButton.paddingBottom = 64;
            _backButton.x = 70;
            _backButton.y = 316;
            _backButton.addEventListener( Event.TRIGGERED, onBackButtonTriggered );
            _dialogContainer.addChild( _backButton );
        }
        
        //--------------------------------------
        // GETTERS / SETTERS
        //--------------------------------------
        
        public function get displayedCoinCount():Number { return _displayedCoinCount; }
        
        public function set displayedCoinCount( value:int ):void
        {
            value = int( value );
            if ( value > _displayedCoinCount && Platform.getTime() - _lastCoinSoundTime > COIN_SOUND_INTERVAL )
            {
                _lastCoinSoundTime = Platform.getTime();
                _coinSound.play();
            }
            
            _displayedCoinCount = value;
            
            if ( _displayedCoinCount > -1 )
            {
                _coinCountTitleLabel.visible = true;
                _coinCountLabel.text = _displayedCoinCount.toString();
            }
            else
            {
                _coinCountTitleLabel.visible = false;
                _coinCountLabel.text = "";
            }
        }
        
        public function get displayedRecordCount():Number { return _displayedRecordCount; }
        
        public function set displayedRecordCount( value:int ):void
        {
            value = int( value );
            if ( value > _displayedRecordCount && Platform.getTime() - _lastCoinSoundTime > COIN_SOUND_INTERVAL )
            {
                _lastCoinSoundTime = Platform.getTime();
                _coinSound.play();
            }
            
            _displayedRecordCount = value;
            
            if ( _displayedRecordCount > -1 )
            {
                _recordCountTitleLabel.visible = true;
                _recordCountLabel.text = _displayedRecordCount.toString();
            }
            else
            {
                _recordCountTitleLabel.visible = false;
                _recordCountLabel.text = "";
            }
        }
        
        //--------------------------------------
        // PUBLIC METHODS
        //--------------------------------------
        
        override public function show():void
        {
            super.show();
            
            clearTweens();
            
            alpha = 1;
            _background.alpha = 0;
            _replayButton.alpha = 0;
            _backButton.alpha = 0;
            
            displayedCoinCount = -1;
            displayedRecordCount = -1;
            
            _dialogContainer.y = -320;
            
            Loom2D.juggler.tween( _background, 0.5, { alpha: 0.5 } );
            Loom2D.juggler.tween( _dialogContainer, 1, { y: _scaledHeight * 0.5 - 160, transition: Transitions.EASE_OUT_ELASTIC, delay: 0.25 } );
            Loom2D.juggler.tween( this, 0.5, { displayedCoinCount: _coinCount, delay: 0.5 } );
            Loom2D.juggler.tween( this, 0.5, { displayedRecordCount: _coinRecord, delay: 1.5 } );
            Loom2D.juggler.tween( _replayButton, 0.1, { alpha: 1, delay: 2 } );
            Loom2D.juggler.tween( _backButton, 0.1, { alpha: 1, delay: 2 } );
        }
        
        override public function hide( callback:Function = null ):void
        {
            touchable = false;
            clearTweens();
            this.alpha = 0;
            callback();
        }
        
        public function configure( coinCount:int, coinRecord:int ):void
        {
            _coinCount = coinCount;
            
            if ( coinCount > coinRecord )
            {
                _coinRecord = coinCount;
                _headerLabel.textFormat = _greenHeaderTextFormat;
                _headerLabel.text = "very record!";
            }
            else
            {
                _coinRecord = coinRecord;
                _headerLabel.textFormat = _redHeaderTextFormat;
                _headerLabel.text = "so over";
            }
        }
        
        //--------------------------------------
        // PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        protected function onReplayButtonTriggered( e:Event ):void
        {
            replayButtonHit();
        }
        
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