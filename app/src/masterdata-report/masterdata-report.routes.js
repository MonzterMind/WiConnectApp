const controller = require('./masterdata-report.controller.js');

module.exports = function(app){

    app.get("/api/masterDataReport/site/:site/:otherCondition?", controller.getMasterDataReportBySite);
    app.post("/api/masterDataReport/add-masterDataReport/:site/:reportDate", controller.addMsterDataReport);
};