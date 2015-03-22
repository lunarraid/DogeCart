package
{
    import loom.Application;
	
	import loom2d.text.BitmapFont;
	import loom2d.text.TextField;
	
	import loom2d.ui.TextureAtlasManager;
    
    import com.lunarraid.dogecart.DogeCartGroup;

    public class DogeCart extends Application
    {
        override public function run():void
        {
            TextureAtlasManager.register( "track", "assets/spritesheets/track.xml" );
            TextField.registerBitmapFont( BitmapFont.load( "assets/fonts/comic-sans.fnt" ), "comic-sans" );
            
            var dogeCartGroup:DogeCartGroup = new DogeCartGroup();
            dogeCartGroup.owningGroup = group;
            dogeCartGroup.initialize( "DogeCartGroup" );
            stage.addChild( dogeCartGroup.viewComponent );
        }
    }
}