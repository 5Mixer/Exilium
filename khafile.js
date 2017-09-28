let project = new Project('Exilium');
project.addAssets('Assets/**');
project.addSources('Sources');
project.addLibrary("eskimo");
project.addLibrary("differ");
project.addLibrary("compiletime");
project.addLibrary("zui");
project.addLibrary("thx.promise");
project.addLibrary("hxNoise");
project.addLibrary("hxColorToolkit");
project.addLibrary("actuate");
// project.addLibrary('hxtelemetry');
// project.addCDefine('HXCPP_TELEMETRY');
// project.addCDefine('HXCPP_STACK_TRACE');

resolve(project);
