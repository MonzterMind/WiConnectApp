const db = require("../../models");

exports.addMsterDataReport = async (req, res) => {
  try {
    // Extract parameters from req.params (not req.body)
    const {
      site,
      reportdate,     
      data,  // This will come from the URL, not the body
    } = req.body;
     
    // Ensure `data` exists and is an object
    if (!data || typeof data !== "object" || Array.isArray(data)) {
      throw new Error("Invalid data format: Expected an object.");
    }

    // Convert `data` to a JSON string
    const formattedData = JSON.stringify( data );


    // SQL query to insert data into the database
    const query = `
      EXEC AddmMasterdataReport 
      @Site = :Site, 
      @ReportDate = :ReportDate, 
      @Json = :Data
    `;

    // Execute the query with replacements
    const masterdataReportData = await db.sequelize.query(query, {
      replacements: {
        Site: site,
        ReportDate: reportdate,  
        Data: formattedData,
      },
      type: db.Sequelize.QueryTypes.Exec,
    });

    // Send the response
    res.status(201).send({
      status: true,
      message: "Master Data Report added successfully.",
    });
  } catch (error) {
    console.error("Error in adding Master Data Report:", error.message);
    res.status(400).json({
      status: false,
      message: "Error adding Master Data Report.",
      error: error.message,
    });
  }
};



exports.getMasterDataReportBySite = async (req, res) => {
  try {
    const { site, otherCondition } = req.params;


    // Execute the stored procedure using Sequelize
    const query = 'EXEC GetMasterDataReportBySite @Site = :Site, @OtherCondition = :OtherCondition';
    const data = await db.sequelize.query(query, {
      replacements: {
        Site: site,
         OtherCondition: otherCondition || '', // Optional condition
      },
      type: db.Sequelize.QueryTypes.RAW,  // Ensure we're executing raw SQL query
      // raw: true,
      // limit: null,
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
      data: data,
      message: `Loto and Harness data found successfully for site ${site}.`,
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
