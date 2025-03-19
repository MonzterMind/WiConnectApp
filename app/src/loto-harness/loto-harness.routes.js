const controller = require('./loto-harness.controller.js');
 
module.exports = function(app){
    app.get("/api/loto-harness/site/:site/:otherCondition?", controller.getLotoHarnessBySite); // Retrieves data by site,  otherCondition is optional, we will use in the future if needed.
    app.get("/api/loto-harness/year/:year/:otherCondition?", controller.getLotoHarnessSummaryByYear); // Retrieves data by year,  otherCondition is optional, we will use in the future if needed.
    app.get("/api/loto-harness/:otherCondition?", controller.getLotoHarnessSummaryByMonthAndYear); // Retrieves data by Month,  otherCondition is optional, we will use in the future if needed.
    app.post("/api/loto-harness/add-lotoandharness/:site/:supervisorName/:reportDate/:shift/:data/:fieldstoshow", controller.AddLotoAndHarness); //Posts data into db from Loto Harness Control file.
}