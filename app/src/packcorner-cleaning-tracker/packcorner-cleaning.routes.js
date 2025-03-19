const controller = require('./packcorner-cleaning.controller');
  
module.exports = function(app){
    app.post("/api/packcorner-cleaning/add-record", controller.postAddPackcornerRecord); //Posts new cleaned packcorner records.
}