
module.exports = (sequelize, Sequelize) => {
    const LotoHarness = sequelize.define('loto-harness', {
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
        supervisorName: {
            type: Sequelize.STRING,
            field: 'SupervisorName'
        },
        shift: {
            type: Sequelize.STRING,
            field: 'Shift'
        },
        employeeName: {
            type: Sequelize.STRING,
            field: 'EmployeeName'
        },
        location: {
            type: Sequelize.STRING,
            field: 'Location'
        },
        lotoHarness: {
            type: Sequelize.STRING,
            field: 'LotoHarness'
        },
        yesNo: {
            type: Sequelize.STRING,
            field: 'YesNo'
        },
        comments: {
            type: Sequelize.STRING,
            field: 'Comments'
        },
        rowId: {
            type: Sequelize.STRING,
            field: 'RowID'
        },
        dateUpdated: {
            type: Sequelize.DATE,
            field: 'DateUpdated'
        }
    },{
        tableName: 'Loto-HarnessLive',
        schema: 'dbo',
        timestamps: false,
    });

    return LotoHarness;
}