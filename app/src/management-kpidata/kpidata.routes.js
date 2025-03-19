const controller = require('./kpidata.controller.js');

module.exports = function(app){

    //usage with other condition parameter use. I added year to filter. keyword is year. SP will read the last 4 character as year
    //http://10.154.226.203:3000/api/managementKPI/site/cy/year=2024 or http://10.154.226.203:3000/api/managementKPI/site/cy/year2024

    app.get("/api/managementKPI/site/:site/:otherCondition?", controller.getManagementKPIBySite);
    app.post("/api/managementKPI/add-managementKPI/:site/:yearWeek/:updatedby/:reportmonth/:data", controller.AddManagementKPI);
};