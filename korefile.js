let fs = require('fs');
let path = require('path');
let project = new Project('Exilium', __dirname);
project.targetOptions = {"html5":{},"flash":{},"android":{},"ios":{}};
project.setDebugDir('build/windows');
Promise.all([Project.createProject('build/windows-build', __dirname), Project.createProject('c:/Users/Owner/Desktop/Dungeon Game/Kha', __dirname), Project.createProject('c:/Users/Owner/Desktop/Dungeon Game/Kha/Kore', __dirname)]).then((projects) => {
	for (let p of projects) project.addSubProject(p);
	let libs = [];
	if (fs.existsSync(path.join('C:/Users/Owner/Desktop/Dungeon Game/Kha/Tools/haxe/lib/eskimo', 'korefile.js'))) {
		libs.push(Project.createProject('C:/Users/Owner/Desktop/Dungeon Game/Kha/Tools/haxe/lib/eskimo', __dirname));
	}
	if (fs.existsSync(path.join('C:/Users/Owner/Desktop/Dungeon Game/Kha/Tools/haxe/lib/differ', 'korefile.js'))) {
		libs.push(Project.createProject('C:/Users/Owner/Desktop/Dungeon Game/Kha/Tools/haxe/lib/differ', __dirname));
	}
	if (fs.existsSync(path.join('C:/Users/Owner/Desktop/Dungeon Game/Kha/Tools/haxe/lib/compiletime', 'korefile.js'))) {
		libs.push(Project.createProject('C:/Users/Owner/Desktop/Dungeon Game/Kha/Tools/haxe/lib/compiletime', __dirname));
	}
	if (fs.existsSync(path.join('C:/Users/Owner/Desktop/Dungeon Game/Kha/Tools/haxe/lib/zui', 'korefile.js'))) {
		libs.push(Project.createProject('C:/Users/Owner/Desktop/Dungeon Game/Kha/Tools/haxe/lib/zui', __dirname));
	}
	if (fs.existsSync(path.join('C:/Users/Owner/Desktop/Dungeon Game/Kha/Tools/haxe/lib/thx,promise', 'korefile.js'))) {
		libs.push(Project.createProject('C:/Users/Owner/Desktop/Dungeon Game/Kha/Tools/haxe/lib/thx,promise', __dirname));
	}
	if (fs.existsSync(path.join('C:/Users/Owner/Desktop/Dungeon Game/Kha/Tools/haxe/lib/thx,core', 'korefile.js'))) {
		libs.push(Project.createProject('C:/Users/Owner/Desktop/Dungeon Game/Kha/Tools/haxe/lib/thx,core', __dirname));
	}
	if (fs.existsSync(path.join('Libraries/hxNoise', 'korefile.js'))) {
		libs.push(Project.createProject('Libraries/hxNoise', __dirname));
	}
	if (fs.existsSync(path.join('Libraries/hxColorToolkit', 'korefile.js'))) {
		libs.push(Project.createProject('Libraries/hxColorToolkit', __dirname));
	}
	Promise.all(libs).then((libprojects) => {
		for (let p of libprojects) project.addSubProject(p);
		resolve(project);
	});
});
