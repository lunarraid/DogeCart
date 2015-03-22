package com.lunarraid.dogecart.render
{
	import loom2d.display.DisplayObject;
    import loom2d.display.DisplayObjectContainer;
    
    import com.lunarraid.dogecart.time.DeltaAnimatedComponent;
	
    public class BaseRenderComponent extends DeltaAnimatedComponent
    {
        //--------------------------------------
        // DEPENDENCIES
        //--------------------------------------
        
        [Inject]
        public var viewManager:TrackViewManager;
        
        //--------------------------------------
        // PRIVATE / PROTECTED
        //--------------------------------------
        
        protected var _viewComponent:DisplayObject;
        
        //--------------------------------------
        // CONSTRUCTOR
        //--------------------------------------
        
        //--------------------------------------
        // GETTERS / SETTERS
        //--------------------------------------
        
        public function get pivotX():Number { return _viewComponent.pivotX; }
        public function set pivotX( value:Number ):void { _viewComponent.pivotX = value; }
        
        public function get pivotY():Number { return _viewComponent.pivotY; }
        public function set pivotY( value:Number ):void { _viewComponent.pivotY = value; }
        
        public function get x():Number { return _viewComponent.x; }
        public function set x( value:Number ):void { _viewComponent.x = value; }
        
        public function get y():Number { return _viewComponent.y; }
        public function set y( value:Number ):void { _viewComponent.y = value; }
        
        public function get rotation():Number { return _viewComponent.rotation; }
        public function set rotation( value:Number ):void { _viewComponent.rotation = value; }
        
        public function get viewComponent():DisplayObject { return _viewComponent; }
        
        protected function get parentViewComponent():DisplayObjectContainer
        {
            return viewManager.foregroundLayer;
        }
        
        //--------------------------------------
        //  PUBLIC METHODS
        //--------------------------------------
        
        //--------------------------------------
        //  PRIVATE / PROTECTED METHODS
        //--------------------------------------
        
        override protected function onAdd():Boolean
        {
            if ( !super.onAdd() ) return false;
            
            _viewComponent = createViewComponent();
            if ( _viewComponent ) parentViewComponent.addChild( _viewComponent );

            return true;
        }
        
        override protected function onRemove():void
        {
            if ( _viewComponent )
            {
                _viewComponent.removeFromParent();
                _viewComponent.dispose();
            }
            _viewComponent = null;
            super.onRemove();
        }
        
        protected function createViewComponent():DisplayObject
        {
            // Override in subclasses
            return null;
        }
    }
}