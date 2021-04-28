let project = new Project('Clase1');
project.addAssets('Assets/**');
project.addShaders('Shaders/**');
project.addSources('Sources');

//project.addDefine('DEBUGDRAW');
//project.addDefine('debugInfo');
project.addDefine('PIXEL_GAME');
//project.addParameter('-dce full');


await project.addProject('khawy');

resolve(project);
