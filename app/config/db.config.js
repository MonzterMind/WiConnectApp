require('dotenv').config();

module.exports = {
    development: {
        HOST: process.env.DEV_DB_HOST,
        USER: process.env.DEV_DB_USER,
        PASSWORD: process.env.DEV_DB_PASSWORD,
        DB: process.env.DEV_DB_NAME,
        PORT: process.env.DEV_DB_PORT,
        dialect: 'mssql',
        dialectOptions:{
            options:{
                encrypt: false,
                trustServerCertificate: true,
                // Connection timeout (time to wait for a connection to be established)
                connectionTimeout: 30000,  // 30 seconds
                // Request timeout for executing queries (time to wait for query execution)
                requestTimeout: 60000,  // 60 seconds for queries
            },
        },
        pool: {
            max: 5,
            min: 0,
            acquire: 60000,
            idle: 10000,
        },
    },
    
    // production: {
    //     HOST: process.env.PROD_DB_HOST,
    //     USER: process.env.PROD_DB_USER,
    //     PASSWORD: process.env.PROD_DB_PASSWORD,
    //     DB: process.env.PROD_DB_NAME,
    //     PORT: process.env.PROD_DB_PORT,
    //     dialect: 'mssql',
    //     dialectOptions:{
    //         options:{
    //             encrypt: false,
    //             trustServerCertificate: true
    //         },
    //     },
    //     pool: {
    //         max: 5,
    //         min: 0,
    //         acquire: 30000,
    //         idle: 10000,
    //     },
    // },    
};