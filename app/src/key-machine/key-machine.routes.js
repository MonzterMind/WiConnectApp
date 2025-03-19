const controller = require('./key-machine.controller');
  
module.exports = function(app){
    app.post("/api/key-machine/save", controller.postAddKeyMachineRecord); 
}