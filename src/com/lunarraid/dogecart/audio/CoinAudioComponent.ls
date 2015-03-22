package com.lunarraid.dogecart.audio
{
    public class CoinAudioComponent extends BaseAudioComponent
    {
        //--------------------------------------
        // CONSTANTS
        //--------------------------------------
        
        private static const COLLECT_COIN:String = "CollectCoin";
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        override protected function onAdd():Boolean
        {
            if ( !super.onAdd() ) return false;
            
            registerSound( COLLECT_COIN, "assets/audio/coin.ogg", true );
            owner.broadcast += onBroadcast;
            
            return true;
        }
        
        override protected function onRemove():void
        {
            owner.broadcast -= onBroadcast;
            super.onRemove();
        }
        
        private function onBroadcast( type:String, data:Object ):void
        {
            if ( type == COLLECT_COIN ) playSound( COLLECT_COIN );
        }
    }
}