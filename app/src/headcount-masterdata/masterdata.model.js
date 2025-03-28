
module.exports = (sequelize, Sequelize) => {
    const Masterdata = sequelize.define('masterdata', {
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
        employeeName: {
            type: Sequelize.STRING,
            field: 'EmployeeName'
        },
        position: {
            type: Sequelize.STRING,
            field: 'Position'
        },
        category: {
            type: Sequelize.STRING,
            field: 'Category'
        },
        zone: {
            type: Sequelize.STRING,
            field: 'Zone'
        },
        shift: {
            type: Sequelize.STRING,
            field: 'Shift'
        },
        status: {
            type: Sequelize.STRING,
            field: 'Status'
        },
        startDate: {
            type: Sequelize.STRING,
            field: 'StartDate'
        },
        dateUpdated: {
            type: Sequelize.DATE,
            field: 'DateUpdated'
        },
        hsRole: {
            type: Sequelize.STRING,
            field: 'HSRole'
        }
    },{
        tableName: 'HeadcountLive',
        schema: 'dbo',
        timestamps: false,
    });

    return Masterdata;
}