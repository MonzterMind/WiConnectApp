const controller = require('./production-metrics.controller.js');

module.exports = function(app){

    app.get("/api/productionMetrics/site/:site/:otherCondition?", controller.getProductionMetricsBySite);
    app.post("/api/productionMetrics/add-productionMetrics", controller.addProductionMetrics);
};