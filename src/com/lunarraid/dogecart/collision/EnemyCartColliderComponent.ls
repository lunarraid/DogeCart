package com.lunarraid.dogecart.collision
{
    public class EnemyCartColliderComponent extends ColliderComponent
    {
        override public function onCollision( a:ColliderComponent, b:ColliderComponent ):void
        {
            isCollidee = false;
            var collidedWith:ColliderComponent = a == this ? b : a;
            collidedWith.owner.broadcast( "enemyHit", null );
            collidedWith.owner.broadcast( "Enemy", null );
        }
    }
}