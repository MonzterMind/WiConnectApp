const controller = require('./masterdata.controller.js');

module.exports = function(app){
    app.get("/api/headcount/:name", controller.getEmployeeMasterdata); //Retrieves data by one single employee.
    app.get("/api/headcount/:site/:status", controller.getActiveEmployeesBySiteStatus); // Retrieves data by site, status.
    app.get("/api/headcount/:site/:status/:category", controller.getActiveEmployeesBySiteStatusCategory); // Retrieves data by site, status and category.
    app.get("/api/headcount/site/:site/category/:category/:otherCondition?", controller.getActiveEmployeesBySiteSP); // Retrieves data by site, category , otherCondition is optional, we will use in the future if needed.
    app.post("/api/headcount/add-employee", controller.postAddEmployees); //Posts data into db from Headcount Control file.
}