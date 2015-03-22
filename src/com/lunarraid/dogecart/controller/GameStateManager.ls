package com.lunarraid.dogecart.controller
{
	import loom.Application;
	
	import loom.platform.UserDefault;
	
    import loom.gameframework.ILoomManager;
    import loom.gameframework.LoomGroup;
    import loom.gameframework.LoomGameObject;
    
    import loom2d.Loom2D;
    import loom2d.math.Rectangle;
    import loom2d.math.Point;
    
    import loom.platform.Mobile;
    
    import com.lunarraid.dogecart.TrackConstants;
    
    import com.lunarraid.dogecart.time.SimpleTimeManager;
    import com.lunarraid.dogecart.time.IDeltaAnimated;
    import com.lunarraid.dogecart.audio.AudioManager;
    import com.lunarraid.dogecart.spatial.TrackData;
    import com.lunarraid.dogecart.spatial.TrackSpatialManager;
    import com.lunarraid.dogecart.spatial.CartSpatialComponent;
    import com.lunarraid.dogecart.collision.CoinColliderComponent;
    
    import com.lunarraid.dogecart.gameobject.CoinObject;
    import com.lunarraid.dogecart.gameobject.PlayerCartObject;
    import com.lunarraid.dogecart.gameobject.EnemyCartObject;
    
    enum CoinDistributionType
    {
        NONE,
        TRACK_END,
        TRACK_MIDDLE,
        TRACK_ALL
    }
    
    delegate PauseDelegate();
    delegate GameOverDelegate( coins:int, coinRecord:int );
    delegate GameEventDelegate( type:String, payload:Object );
    
    public class GameStateManager implements IDeltaAnimated, ILoomManager
    {
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        [Inject]
        public var timeManager:SimpleTimeManager;
        
        [Inject]
        public var audioManager:AudioManager;
        
        [Inject]
        public var trackManager:TrackSpatialManager;
        
        [Inject]
        public var group:LoomGroup;
        
        //--------------------------------------
        // PUBLIC
        //--------------------------------------
        
        public const pause:PauseDelegate;
        public const unpause:PauseDelegate;
        public const gameOver:GameOverDelegate;
        public const gameEvent:GameEventDelegate;
        
        public var coinsCollected:int = 0;
        public var coinsMissed:int = 0;
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        private static const MISSED_COIN:String = "MissedCoin";
        private static const AVOIDED_ENEMY:String = "AvoidedEnemy";
        private static const HIT_ENEMY:String = "HitEnemy";
        
        private static const _phrases:Dictionary.<String, Vector.<String>> =
        {
            "MissedCoin" : [ "such miss", "very disappoint", "much loss", "such sad", "many tears" ],
            "AvoidedEnemy" : [ "wow", "much skill", "very jump", "so avoid", "many height" ],
            "HitEnemy" : [ "such crash", "so hit", "many ouch", "much fall" ]
        };
        
        private static const _lastRandomPhrases:Dictionary.<String, String> = {};
        
        private const _coinPool:Vector.<CoinObject> = [];
        private const _activeCoins:Vector.<CoinObject> = [];
        private var _lastCoinDistributionType:int = 0;
        
        private var _playerCart:PlayerCartObject;
        private var _enemyCart:EnemyCartObject;
        private var _nextEnemyCartSpawnPosition:Point;
        private var _nextEnemyCartTogglePosition:int = Number.MAX_VALUE;
        private var _enemyAvoided:Boolean = true;
        private var _paused:Boolean;
        private var _running:Boolean;
        
        private var _coinRecord:int = -1;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        //--------------------------------------
        //  GETTERS / SETTERS
        //--------------------------------------
        
        public function get paused():Boolean { return _paused; }
        
        public function set paused( value:Boolean ):void
        {
            if ( _paused == value ) return;
            
            _paused = value;
            
            if ( _paused )
            {
                pause();
                stop();
            }
            else
            {
                start();
                unpause();
            }
        }
        
        public function get coinRecord():int
        {
            if ( _coinRecord < 0 ) _coinRecord = UserDefault.sharedUserDefault().getIntegerForKey( "coinRecord" );
            return _coinRecord;
        }
        
        public function set coinRecord( value:int ):void
        {
            if ( value > coinRecord )
            {
                _coinRecord = value;
                UserDefault.sharedUserDefault().setIntegerForKey( "coinRecord", value );
            }
        }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        public function initialize():void
        {
            _playerCart = new PlayerCartObject( group );
            trackManager.trackingObject = _playerCart.lookupComponentByName( "spatial" ) as CartSpatialComponent;
            trackManager.onTrackAdded += onTrackAdded;
            Application.applicationDeactivated += onDeactivated;
            timeManager.addAnimatedObject( this );
            timeManager.stop();
        }
        
        public function destroy():void
        {
            timeManager.removeAnimatedObject( this );
            trackManager.onTrackAdded -= onTrackAdded;
        }
        
        public function start():void
        {
            Mobile.allowScreenSleep( false );
            _running = true;
            audioManager.paused = false;
            timeManager.start();
        }
        
        public function stop():void
        {
            _running = false;
            audioManager.paused = true;
            timeManager.stop();
            Mobile.allowScreenSleep( true );
        }
        
        public function reset():void
        {
            audioManager.clearPausedSounds();
            trackManager.onTrackAdded -= onTrackAdded;
            trackManager.infiniteLoopMode = true;
            trackManager.reset();
            clearCoins();
            trackManager.onTrackAdded += onTrackAdded;
            _nextEnemyCartTogglePosition = Number.MAX_VALUE;
            coinsCollected = 0;
            coinsMissed = 0;
            _playerCart.broadcast( "reset", null );
            _playerCart.setProperty( "@spatial.maxSpeed", TrackConstants.CART_BEGIN_MAX_SPEED );
            _enemyAvoided = true;
        }
        
        public function endInstructions():void
        {
            _playerCart.setProperty( "@spatial.maxSpeed", TrackConstants.CART_MAX_SPEED );
            trackManager.infiniteLoopMode = false;
        }
        
        public function onFrame( deltaTime:Number ):void
        {
            // Enemy handling
            
            if ( trackManager.position >= _nextEnemyCartTogglePosition )
            {
                _nextEnemyCartTogglePosition = Number.MAX_VALUE;
                spawnEnemy();
            }
            else if ( !_enemyAvoided
                && _playerCart.getProperty( "@collider.bounds.x" ) >= _enemyCart.getProperty( "@collider.bounds.right" )
                && _playerCart.getProperty( "@spatial.isDead" ) != true )
            {
                //trace( "AVOIDED ENEMY! ENEMY POSITION: " + _enemyCart.getProperty( "@collider.bounds.right" ) + ", PLAYER POSITION: " + _playerCart.getProperty( "@collider.bounds.x" ) );
                _enemyAvoided = true;
                _playerCart.broadcast( "Enemy", null );
                gameEvent( GameEvents.SHOW_TEXT, getRandomPhrase( AVOIDED_ENEMY ) );
            }
            
            // Check if we missed a coin
            for ( var i:int = 0; i < _activeCoins.length; i++ )
            {
                var coin:CoinObject = _activeCoins[ i ];
                if ( coin.colliderComponent.bounds.right > trackManager.position - 200 ) break;
                if ( !coin.colliderComponent.collected )
                {
                    _activeCoins.remove( coin );
                    returnCoinToPool( coin );
                    coinsMissed++;
                    gameEvent( GameEvents.SHOW_RED_TEXT, getRandomPhrase( MISSED_COIN ) );
                    _playerCart.broadcast( "MissedCoin", null );
                }
            }
            
            if ( coinsMissed >= TrackConstants.MAX_MISSED_COINS ) _playerCart.setProperty( "@spatial.isDead", true );
        }
        
        public function endGame():void
        {
            stop();
            gameOver( coinsCollected, coinRecord );
            if ( coinsCollected > coinRecord ) coinRecord = coinsCollected;
        }
        
        public function collectCoin( coin:CoinObject ):void
        {
            coinsCollected++;
            _activeCoins.remove( coin );
            returnCoinToPool( coin );
        }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        private function onTrackAdded( trackData:TrackData ):void
        {
            // Remove any coins that are past our bounds
            while ( _activeCoins.length > 0 && trackManager.position - _activeCoins[ 0 ].colliderComponent.x >= TrackConstants.SPATIAL_OVERDRAW )
            {
                returnCoinToPool( _activeCoins.shift() );
            }
            
            var coinDistribution:int = distributeCoins( trackData );
            if ( coinDistribution == CoinDistributionType.NONE || coinDistribution == CoinDistributionType.TRACK_END ) generateObstacle( trackData );
        }
        
        private function clearCoins():void
        {
            while ( _activeCoins.length > 0 ) returnCoinToPool( _activeCoins.pop() );
        }
        
        private function distributeCoins( trackData:TrackData ):int
        {
            var coinDistributionType:int = _lastCoinDistributionType;
            
            do coinDistributionType = Math.randomRangeInt( 0, 3 );
            while ( coinDistributionType == _lastCoinDistributionType && coinDistributionType > 0 ); 
            
            _lastCoinDistributionType = coinDistributionType;
            
            if ( coinDistributionType == 0 ) return CoinDistributionType.NONE;
            
            switch ( coinDistributionType )
            {
                case CoinDistributionType.TRACK_END:
                    circularDistributeCoins( 4, trackData.endPosition + 100, trackData.endHeight - 100, 100, Math.PI, Math.PI * 1.75 );
                    break;
                    
                case CoinDistributionType.TRACK_MIDDLE:
                    if ( trackData.segmentCount < 50 ) return CoinDistributionType.NONE;
                    var startX:int = ( trackData.startPosition + trackData.endPosition ) * 0.5;
                    var startY:int = trackData.getHeightAtPosition( startX ) + trackData.startHeight - 60;
                    circularDistributeCoins( 5, startX, startY, 120, Math.PI * 1.2, Math.PI * 1.8 );
                    break;
                    
                case CoinDistributionType.TRACK_ALL:
                    distributeCoinsAlongPath( trackData );
                    break;
            }
            
            return coinDistributionType;
        }
        
        private function circularDistributeCoins( coinCount:int, x:int, y:int, radius:int, startAngle:Number, endAngle:Number ):void
        {
            var angleDelta:Number = ( endAngle - startAngle ) / ( coinCount - 1 );
            
            for ( var i:int = 0; i < coinCount; i++ )
            {
                var coinObject:CoinObject = retrieveCoinFromPool();
                coinObject.colliderComponent.x = x + Math.cos( startAngle + angleDelta * i ) * radius;
                coinObject.colliderComponent.y = y + Math.sin( startAngle + angleDelta * i ) * radius;
                _activeCoins.push( coinObject );
            }
        }
        
        private function distributeCoinsAlongPath( trackData:TrackData, coinSpacing:int = 65 ):void
        {
            var startX:int = trackData.startPosition + coinSpacing;
            var endX:int = trackData.endPosition - coinSpacing;
            
            for ( var i:int = startX; i < endX; i += coinSpacing )
            {
                var coinObject:CoinObject = retrieveCoinFromPool();
                coinObject.colliderComponent.x = i;
                coinObject.colliderComponent.y = trackData.getHeightAtPosition( i ) + trackData.startHeight - 50;
                _activeCoins.push( coinObject );
            }
        }
        
        private function generateObstacle( trackData:TrackData ):void
        {
            if ( trackData.segmentCount > 60 && _nextEnemyCartTogglePosition == Number.MAX_VALUE )
            {
                _nextEnemyCartSpawnPosition.x = trackData.endPosition - 10;
                _nextEnemyCartSpawnPosition.y = trackData.endHeight;
                _nextEnemyCartTogglePosition = trackData.startPosition;
            }
        }
        
        private function spawnEnemy():void
        {
            //trace( "SPAWNING ENEMY AT: " + _nextEnemyCartSpawnPosition );
            //trace( "PLAYER AT: " + _playerCart.getProperty( "@spatial.position" ) );
            
            if ( !_enemyCart ) _enemyCart = new EnemyCartObject( group );
            _enemyCart.setProperty( "@spatial.isDead", false );
            _enemyCart.setProperty( "@spatial.position.x", _nextEnemyCartSpawnPosition.x );
            _enemyCart.setProperty( "@spatial.position.y", _nextEnemyCartSpawnPosition.y );
            _enemyCart.setProperty( "@collider.bounds.x", _nextEnemyCartSpawnPosition.x );
            _enemyCart.setProperty( "@collider.bounds.y", _nextEnemyCartSpawnPosition.y );
            _enemyCart.setProperty( "@collider.isCollidee", true );
            _enemyAvoided = false;
        }
        
        private function retrieveCoinFromPool():CoinObject
        {
            if ( _coinPool.length == 0 ) return new CoinObject( group );
            
            var result:CoinObject = _coinPool.pop();
            
            Debug.assert( result.active == false, "FOUND ACTIVE COIN, SHOULD NOT BE!" );
            
            result.colliderComponent.x = -9999;
            result.active = true;
            result.renderer.fps = 24;
            return result;
        }
        
        private function returnCoinToPool( coin:CoinObject ):void
        {
            coin.active = false;
            coin.colliderComponent.collected = false;
            _coinPool.push( coin );
        }
        
        private function onDeactivated():void
        {
            paused = true;
        }
        
        private static function getRandomPhrase( type:String ):String
        {
            var lastPhrase:String = _lastRandomPhrases[ type ];
            var returnPhrase:String = lastPhrase;
            var phrases:Vector.<String> = _phrases[ type ];
            
            while ( returnPhrase == lastPhrase )
            {
                returnPhrase = phrases[ Math.randomRangeInt( 0, phrases.length - 1 ) ];
            }
            
            _lastRandomPhrases[ type ] = returnPhrase;
            
            return returnPhrase;
        }
    }
}