const db = require("../../models");

exports.addOrUpdateDynamicReportData = async (req, res) => {
    try {
      // Extract parameters from req.params (not req.body)
      const { data } = req.body;
      console.log("data",  data);
      // Ensure `data` exists and is an object
      if (!data || typeof data !== "object" || Array.isArray(data)) {
        throw new Error("Invalid data format: Expected an object.");
      }
  
      // Convert `data` to a JSON string
      const formattedData = JSON.stringify( data );
       
  
      // SQL query to insert data into the database
      const query = `
        EXEC AddOrEditUniversalTable 
        @Site = :Site, 
        @reportDate = :reportDate,
        @uniqueReportName = :uniqueReportName,
        @tabledata = :tabledata,
        @otherCondition = :otherCondition,
        @tableName = :tableName
      `;
  
      // Execute the query with replacements
      const productionMetricsData = await db.sequelize.query(query, {
        replacements: {
          Site:  data.Site,
          reportDate: data.reportDate,
          uniqueReportName: data.uniqueReportName,
          tabledata: data.tabledata,
          otherCondition: data.otherCondition,
          tableName: data.tableName
          
        },
        type: db.Sequelize.QueryTypes.Exec,
      });
  
      // Send the response
      res.status(201).send({
        status: true,
        message: "Data added successfully.",
      });
    } catch (error) {
      console.error("Error in adding  Data:", error.message);
      res.status(400).json({
        status: false,
        message: "Error adding Data.",
        error: error.message,
      });
    }
  };
  
  
  
  exports.getDynamicReportDataBySite = async (req, res) => {
     try {
       const { site, reportName } = req.params;
       const { otherCondition = '', tablename = 'UniversalTableLive' } = req.query; // Set default values  
   
       // Execute the stored procedure using Sequelize
       const query = `
         EXEC GetUniversalTableBySite 
         @SiteName = :Site, 
         @uniqueReportName = :ReportName, 
         @OtherCondition = :OtherCondition, 
         @TableName = :TableName
       `;
   
       const data = await db.sequelize.query(query, {
         replacements: {
           Site: site,
           ReportName: reportName,
           OtherCondition: otherCondition,
           TableName: tablename
         },
         type: db.Sequelize.QueryTypes.SELECT,  // Use SELECT for retrieving data
       });
   
       // Check if data was returned
       if (!data || data.length === 0) {
         return res.status(404).send({
           status: false,
           message: "Requested data has not been found.",
         });
       }
   
       // Return the data as a response
       res.status(200).send({
         status: true,
         data: data
         
       });
   
     } catch (error) {
       // Log the error for debugging
       console.error("Error executing query:", error);
       res.status(400).json({
         status: false,
         message: "Please check the request and try again.",
         error: error.message,
       });
     }
   };
   
  