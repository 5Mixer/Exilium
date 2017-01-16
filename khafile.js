let project = new Project('New Project');
project.addAssets('Assets/**');
project.addSources('Sources');
project.addLibrary("eskimo");
project.addLibrary("differ");
project.addLibrary("compiletime");
project.addLibrary("zui");
// project.addLibrary('hxtelemetry');
// project.addCDefine('HXCPP_TELEMETRY');
// project.addCDefine('HXCPP_STACK_TRACE');

resolve(project);
