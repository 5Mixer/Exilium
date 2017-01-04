let project = new Project('New Project');
project.addAssets('Assets/**');
project.addSources('Sources');
project.addLibrary("eskimo");
project.addLibrary('hxtelemetry');
project.addCDefine('HXCPP_TELEMETRY');
project.addCDefine('HXCPP_STACK_TRACE');
resolve(project);
