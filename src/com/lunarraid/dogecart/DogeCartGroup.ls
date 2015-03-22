package com.lunarraid.dogecart
{
	import system.platform.PlatformType;
	import system.platform.Platform;
	import loom2d.display.Cocos2D;
	import loom2d.events.KeyboardEvent;
	import loom.admob.BannerSize;
	import loom.admob.BannerAd;
	
    import loom2d.Loom2D;
    import loom2d.math.Point;
	import loom2d.math.Rectangle;
	import loom2d.display.DisplayObject;
    import loom2d.display.Sprite;
	import loom2d.textures.Texture;
    import loom2d.events.Event;
    import loom2d.events.Touch;
    import loom2d.events.TouchPhase;
    import loom2d.events.TouchEvent;
    
    import loom.gameframework.LoomGameObject;
    import loom.gameframework.LoomGroup;
	
    import com.lunarraid.dogecart.screen.MainMenuScreen;
    import com.lunarraid.dogecart.screen.GameOverScreen;
    import com.lunarraid.dogecart.screen.CreditsScreen;
    import com.lunarraid.dogecart.screen.InstructionDialog;
    
    import com.lunarraid.dogecart.audio.AudioManager;
    import com.lunarraid.dogecart.render.TrackViewManager;
    import com.lunarraid.dogecart.render.CoinCounterRenderer;
    import com.lunarraid.dogecart.render.DistanceCounterRenderer;
    import com.lunarraid.dogecart.render.BackgroundRenderer;
    import com.lunarraid.dogecart.render.PauseOverlayRenderer;
    import com.lunarraid.dogecart.render.TrackRenderer;
    import com.lunarraid.dogecart.render.SuchTextRenderer;
    import com.lunarraid.dogecart.render.MissedCoinWidgetRenderer;
    import com.lunarraid.dogecart.spatial.TrackSpatialManager;
    import com.lunarraid.dogecart.spatial.CartSpatialComponent;
    import com.lunarraid.dogecart.collision.CollisionManager;
    import com.lunarraid.dogecart.controller.GameStateManager;
	import com.lunarraid.dogecart.time.SimpleTimeManager;
	
    public class DogeCartGroup extends LoomGroup
    {
        //--------------------------------------
        // CLASS CONSTANTS
        //--------------------------------------
        
        public static const DESIGN_WIDTH:int = 680;
    
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _viewComponent:Sprite;
        private var _gameStateManager:GameStateManager;
        private var _viewManager:TrackViewManager;
        private var _distanceCounter:DistanceCounterRenderer;
        private var _mainMenu:MainMenuScreen;
        private var _gameOverScreen:GameOverScreen;
        private var _creditsScreen:CreditsScreen;
        private var _instructionDialog:InstructionDialog;
        private var _bannerAd:BannerAd;
        private var _bannerAdVisible = false;
        private var _currentSection:int = 0;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        //--------------------------------------
        //  GETTERS / SETTERS
        //--------------------------------------
        
        public function get viewComponent():DisplayObject { return _viewComponent; }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        override public function initialize( objectName:String = null ):void
        {
            super.initialize( objectName );
            
            // Allow our managers access to this group
            registerManager( this, LoomGroup );
            
            registerManager( new SimpleTimeManager() );
            
            _viewComponent = new Sprite();
            
            // Managers
            
            var spatialManager:TrackSpatialManager = new TrackSpatialManager();
            registerManager( spatialManager );
            spatialManager.width = Loom2D.stage.stageWidth;
            
            _viewManager = new TrackViewManager();
            _viewManager.cameraOffset.y = -500;
            registerManager( _viewManager );
            
            _viewComponent.addChild( _viewManager.viewComponent );
            
            registerManager( new AudioManager() );
            registerManager( new CollisionManager() );
            
            _gameStateManager = new GameStateManager();
            registerManager( _gameStateManager );
            
            // Menu Screens
            
            _mainMenu = new MainMenuScreen();
            _mainMenu.playButtonHit += onPlayButtonHit;
            _mainMenu.creditsButtonHit += onCreditsButtonHit;
            
            _gameOverScreen = new GameOverScreen();
            _gameStateManager.gameOver += showGameOverScreen;
            _gameOverScreen.backButtonHit += onBackButtonHit;
            _gameOverScreen.replayButtonHit += onReplayButtonHit;
            
            _creditsScreen = new CreditsScreen();
            _creditsScreen.backButtonHit += onCreditsBackButtonHit;
            
            // Track Game Object         
            
            var trackObject:LoomGameObject = new LoomGameObject();
            trackObject.owningGroup = this;
            trackObject.initialize( "track" );
            
            trackObject.addComponent( new BackgroundRenderer(), "background" );
            trackObject.addComponent( new PauseOverlayRenderer(), "overlay" );
            trackObject.addComponent( new TrackRenderer(), "track" );
            trackObject.addComponent( new SuchTextRenderer(), "textRenderer" );
            trackObject.addComponent( new MissedCoinWidgetRenderer(), "missedCoinsWidgetRenderer" );
            
            var coinCounter:CoinCounterRenderer = new CoinCounterRenderer();
            trackObject.addComponent( coinCounter, "coinCounter" );
            coinCounter.x = 20;
            coinCounter.y = 20;
            
            //_distanceCounter = new DistanceCounterRenderer();
            //trackObject.addComponent( _distanceCounter, "distanceCounter" );
            //_distanceCounter.y = 30;
            
            Loom2D.stage.addEventListener( Event.RESIZE, onResize );
            Loom2D.stage.addEventListener( KeyboardEvent.BACK_PRESSED, onBackButton );
            
            onResize();
            
            showMainMenuScreen();
        }
        
        public function showMainMenuScreen():void
        {
            _gameOverScreen.removeFromParent();
            _viewComponent.addChild( _mainMenu );
            _viewManager.viewComponent.visible = false;
            _mainMenu.show();
            _currentSection = GameSection.MAIN_MENU;
        }
        
        public function startGame():void
        {
            hideBannerAd();
            
            _mainMenu.removeFromParent();
            _gameOverScreen.removeFromParent();
            _viewManager.viewComponent.alpha = 0;
            _viewManager.viewComponent.visible = true;
            Loom2D.juggler.tween( _viewManager.viewComponent, 0.25, { alpha: 1 } );
            _gameStateManager.reset();
            if ( _gameStateManager.paused ) _gameStateManager.paused = false;
            else _gameStateManager.start();
            
            showInstructionDialog();
            _currentSection = GameSection.MAIN_GAME;
        }
        
        public function showGameOverScreen( coins:int, coinRecord:int ):void
        {
            _gameOverScreen.configure( coins, coinRecord );
            _viewComponent.addChild( _gameOverScreen );
            _gameOverScreen.show();
            showBannerAd();
            _currentSection = GameSection.GAME_OVER;
        }
        
        public function showCreditsScreen():void
        {
            _viewComponent.addChild( _creditsScreen );
            _creditsScreen.show();
            _currentSection = GameSection.CREDITS;
        }
        
        public function showInstructionDialog():void
        {
            if ( !_instructionDialog )
            {
                _instructionDialog = new InstructionDialog();
                _instructionDialog.x = ( 640 - _instructionDialog.width ) * 0.5;
                _instructionDialog.y = ( _viewManager.viewPort.height - _instructionDialog.height ) * 0.5;
            }
            
            _viewManager.uiLayer.addChild( _instructionDialog );
            Loom2D.stage.addEventListener( TouchEvent.TOUCH, onTrackViewTouched );
        }
        
        public function showBannerAd():void
        {
            var bannerAdId:String;
            if ( Platform.getPlatform() == PlatformType.IOS ) bannerAdId = "ca-app-pub-8178394255107530/2985384642";
            else if ( Platform.getPlatform() == PlatformType.ANDROID ) bannerAdId = "ca-app-pub-8178394255107530/2706183049";
            else return;
            
            _bannerAd = new BannerAd( bannerAdId, BannerSize.SMART_PORTRAIT );
            _bannerAd.show();
            _bannerAd.y = Platform.getPlatform() == PlatformType.IOS ? 0 : Loom2D.stage.nativeStageHeight - _bannerAd.height;
            _bannerAdVisible = true;
        }
        
        public function hideBannerAd():void
        {
            if ( _bannerAdVisible )
            {
                _bannerAdVisible = false;
                _bannerAd.hide();
            }
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        private function onPlayButtonHit():void
        {
            _mainMenu.hide( startGame );
        }
        
        private function onCreditsButtonHit():void
        {
            _mainMenu.hide( showCreditsScreen );
        }
        
        private function onCreditsBackButtonHit():void
        {
            _creditsScreen.hide( showMainMenuScreen );
        }
        
        private function onReplayButtonHit():void
        {
            _gameOverScreen.hide( startGame );
        }
        
        private function onBackButtonHit():void
        {
            hideBannerAd();
            _gameOverScreen.hide( showMainMenuScreen );
        }
        
        private function onTrackViewTouched( e:TouchEvent ):void
        {
            var touch:Touch = e.getTouch( Loom2D.stage, TouchPhase.BEGAN );
            if ( !touch ) return;
            
            Loom2D.stage.removeEventListener( TouchEvent.TOUCH, onTrackViewTouched );
            _instructionDialog.removeFromParent();
            _gameStateManager.endInstructions();
        }
        
        private function onResize( e:Event = null ):void
        {
            var targetScale:Number = Loom2D.stage.stageWidth / DESIGN_WIDTH;
            var newViewPort:Rectangle = new Rectangle();
            newViewPort.width = DESIGN_WIDTH;
            newViewPort.height = Math.ceil( Loom2D.stage.stageHeight / targetScale );
            _viewManager.viewPort = newViewPort;
            _viewManager.cameraOffset.x = newViewPort.width * -0.2;
            _viewManager.cameraOffset.y = Math.min2( newViewPort.height * -0.6, -365 );
            _viewManager.viewComponent.scale = targetScale;
            //_distanceCounter.x = newViewPort.width - 300;
            
            _mainMenu.width = Loom2D.stage.nativeStageWidth;
            _mainMenu.height = Loom2D.stage.nativeStageHeight;
            _gameOverScreen.width = Loom2D.stage.nativeStageWidth;
            _gameOverScreen.height = Loom2D.stage.nativeStageHeight;
            _creditsScreen.width = Loom2D.stage.nativeStageWidth;
            _creditsScreen.height = Loom2D.stage.nativeStageHeight;
            
            if ( _instructionDialog ) _instructionDialog.y = ( _viewManager.viewPort.height - _instructionDialog.height ) * 0.5;
        }
        
        private function onBackButton( e:Event ):void
        {
            switch ( _currentSection )
            {
                case GameSection.MAIN_MENU:
                    Cocos2D.shutdown();
                    break;
                
                case GameSection.CREDITS:
                    _creditsScreen.hide( showMainMenuScreen );
                    break;
                    
                case GameSection.MAIN_GAME:
                    _gameStateManager.stop();
                    showMainMenuScreen();
                    break;
                    
                case GameSection.GAME_OVER:
                    hideBannerAd();
                    _gameOverScreen.hide( showMainMenuScreen );
                    break;
            }
        }
    }
    
    public enum GameSection
    {
        MAIN_MENU,
        CREDITS,
        MAIN_GAME,
        GAME_OVER
    }
}