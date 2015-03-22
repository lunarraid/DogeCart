package com.lunarraid.dogecart.spatial
{
    public struct CartSpatialData
    {
        public static const NONE:CartSpatialData = new CartSpatialData();
        
        public var position:Number = -1;
        public var rotation:Number;
        public var height:Number;
        public var speedCoefficient:Number;
        public var isFlatTrack:Boolean;
        public var flatHeight:Number;
        public var trackExists:Boolean;
        
        public function setTo( position:Number, rotation:Number, height:Number, speedCoefficient:Number, isFlatTrack:Boolean, flatHeight:Number, trackExists:Boolean ):void
        {
            this.position = position;
            this.rotation = rotation;
            this.height = height;
            this.speedCoefficient = speedCoefficient;
            this.isFlatTrack = isFlatTrack;
            this.flatHeight = flatHeight;
            this.trackExists = trackExists;
        }
        
        public static operator function =( a:CartSpatialData, b:CartSpatialData):CartSpatialData
        {
            a.setTo( b.position, b.rotation, b.height, b.speedCoefficient, b.isFlatTrack, b.flatHeight, b.trackExists );
            return a;
        }
    }
}