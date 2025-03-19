
module.exports = (sequelize, Sequelize) => {
    const PackCornerCleaning = sequelize.define('packcornerCleaning', {
        id: {
            type: Sequelize.INTEGER,
            primaryKey: true,
            autoIncrement: true,
            field: 'ID'
        },
        site: {
            type: Sequelize.STRING,
            field: 'Site'
        },
        reportDate: {
            type: Sequelize.DATE,
            field: 'ReportDate'
        },
        supervisorName: {
            type: Sequelize.STRING,
            field: 'SupervisorName'
        },
        shift: {
            type: Sequelize.STRING,
            field: 'Shift'
        },
        packcornerNumber: {
            type: Sequelize.STRING,
            field: 'PackCornerNumber'
        },
        remarks: {
            type: Sequelize.STRING,
            field: 'Remarks'
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
        tableName: 'PackCornerCleaningLive',
        schema: 'dbo',
        timestamps: false,
    });

    return PackCornerCleaning;
}