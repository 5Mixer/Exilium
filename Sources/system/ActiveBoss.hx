package system;

import kha.math.FastMatrix3;

class ActiveBoss extends System {
	var view:eskimo.views.View;
	public var active = true;
	public function new (entities:eskimo.EntityManager){
		view = new eskimo.views.View(new eskimo.filters.Filter([component.ActiveBoss]), entities);
		super();
	}

	override public function render (g:kha.graphics2.Graphics){
		super.render(g);

		for (entity in view.entities){
			var boss = entity.get(component.ActiveBoss);

			if (!boss.active)
				continue;
			
			if (boss.current <= 0){
				var valid = true;

				var s = entity.get(component.CorruptSoul);
				for (a in s.children){
					if (a.get(component.Health) != null && a.get(component.Health).current > 0) {
						valid = false;
						break;
					}
				}
				
				if (valid){
					entity.destroy();
					continue;
				}
			}
			// var health:component.Health = entity.get(component.Health);
			//var transformation:component.Transformation = entity.get(component.Transformation);
			var offsetx = 0.0;
			if (boss.rage){
				offsetx = -2+Math.random()*4;
			}
			
			g.pushTransformation(g.transformation);
			g.transformation = kha.math.FastMatrix3.identity();
			g.color = kha.Color.fromBytes(219,98,98);
			var x = kha.System.windowWidth()*.25;
			var y = 5;
			var width = kha.System.windowWidth()*.5;
			g.fillRect(x,y,width,4);
			g.color = kha.Color.fromBytes(219,219,98);
			g.fillRect(x,y,(Math.max(boss.current/boss.max,0))*width,4);

			g.color = !boss.rage ? kha.Color.fromBytes(234,211,220) : kha.Color.fromBytes(230,40,40);
			g.font = kha.Assets.fonts.trenco;
			g.fontSize = 38;
			
			var string = boss.name+" is "+boss.mode;
			g.drawString(string,(kha.System.windowWidth()/2)-(g.font.width(g.fontSize,string)/2)+offsetx, -1*4);
			g.color = kha.Color.White;
			g.popTransformation();
			
		}
	}
}