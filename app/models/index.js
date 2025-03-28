const config = require('../config/db.config').development;
const Sequelize = require('sequelize');

const sequelize = new Sequelize(config.DB, config.USER, config.PASSWORD, {
    host: config.HOST,
    dialect: config.dialect,
    port: config.PORT,
    dialectOptions: config.dialectOptions,
    pool: {
        max: config.pool.max,
        min: config.pool.min,
        acquire: config.pool.acquire,
        idle: config.pool.idle,
    },
});

// Initialize an empty object to hold all models.
const db ={};

// Add the Sequelize instance and library to the db object
db.Sequelize = Sequelize;
db.sequelize = sequelize;

// Import the models and add it to the db object.
db.masterdata = require('../src/headcount-masterdata/masterdata.model.js')(sequelize, Sequelize);
db.lotoharness = require('../src/loto-harness/loto-harness.model.js')(sequelize, Sequelize);
db.kpidata = require('../src/management-kpidata/kpidata.model.js')(sequelize, Sequelize);
db.packcornerCleaning = require('../src/packcorner-cleaning-tracker/packcorner-cleaning.model.js')(sequelize, Sequelize);
db.emergencyResponse = require('../src/emergency-response/emergency-response.model.js')(sequelize, Sequelize);
db.masterdataReport = require('../src/masterdata-report/masterdata-report.model.js')(sequelize, Sequelize);
db.productionMetricsData = require('../src/production-metrics/production-metrics.model.js')(sequelize, Sequelize);
db.dynamicReportData = require('../src/dynamic-report/dynamic-report.model.js')(sequelize, Sequelize);
db.keyMachine = require('../src/key-machine/key-machine.model.js')(sequelize, Sequelize);
module.exports = db;