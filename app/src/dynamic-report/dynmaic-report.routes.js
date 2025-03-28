const controller = require('./dynamic-report.controller');
  
module.exports = function(app){
    app.post("/api/dynamic-report/addorupdate", controller.addOrUpdateDynamicReportData); 
    // We have optional parametr other condition and tablename
    //other condition we can use it in the future to join tables
    //tablename is the table name that we want to get the data from it. we can create archive tables for each year and we can get the data from the archive table
    //how to use the api
    //no optional parameters
    // http://localhost:3000/api/dynamic-report/site/all/reportname/Test
    //optional parameters other condition
    //http://localhost:3000/api/dynamic-report/site/all/reportname/test?otherCondition=year=2024
    //optional parameters tablename
    //http://localhost:3000/api/dynamic-report/site/all/reportname/test?tablename=archive
    //optional parameters other condition and tablename
    //http://localhost:3000/api/dynamic-report/site/all/reportname/test?otherCondition=year=2024&tablename=archive
    app.get("/api/dynamic-report/site/:site/reportname/:reportName", controller.getDynamicReportDataBySite);

}