const controller = require('./emergency-response.controller');
  
module.exports = function(app){
    app.post("/api/emergency-response/add-record", controller.postAddEmergencyResponse); 
}