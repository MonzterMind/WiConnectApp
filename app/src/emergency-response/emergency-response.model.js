
module.exports = (sequelize, Sequelize) => {
    const EmergencyResponse = sequelize.define('emergencyResponse', {
        id: {
            type: Sequelize.INTEGER,
            primaryKey: true,
            autoIncrement: true,
            field: 'ID'
        },
        reportDate: {
            type: Sequelize.DATE,
            field: 'ReportDate'
        },
        site: {
            type: Sequelize.STRING,
            field: 'Site'
        },
        shift: {
            type: Sequelize.STRING,
            field: 'Shift'
        },
        firstAider: {
            type: Sequelize.STRING,
            field: 'FirstAider'
        },
        highRescuer: {
            type: Sequelize.STRING,
            field: 'HighRescuer'
        },
        dateUpdated: {
            type: Sequelize.DATE,
            field: 'DateUpdated'
        },
        updatedBy: {
            type: Sequelize.STRING,
            field: 'UpdatedBy'
        }
    },{
        tableName: 'EmergencyResponseResourceLive',
        schema: 'dbo',
        timestamps: false,
    });

    return EmergencyResponse;
}