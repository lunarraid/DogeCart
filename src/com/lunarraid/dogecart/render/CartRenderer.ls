package com.lunarraid.dogecart.render
{
    import loom2d.display.DisplayObject;
	
    public class CartRenderer extends BaseRenderComponent
    {
        //--------------------------------------
        //  PRIVATE / PROTECTED
        //--------------------------------------
        
        private var _cartSprite:CartSprite;
    
        //--------------------------------------
        //  GETTERS / SETTERS
        //--------------------------------------
        
        override public function set rotation( value:Number ):void
        {
            _cartSprite.setRotation( value );
        }
        
        override public function get priority():Number { return 1; }
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        override protected function createViewComponent():DisplayObject
        {
            _cartSprite = new CartSprite();
            return _cartSprite;
        }
    }
}