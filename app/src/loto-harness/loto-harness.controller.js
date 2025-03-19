const db = require("../../models");
const { Op } = require("sequelize");

exports.AddLotoAndHarness = async (req, res) => {
  try {
    // Extract parameters from req.params
    const {
      site,
      supervisorName,
      reportDate,
      shift,
      data,
      fieldstoshow,
    } = req.body;

    const formattedData = `"data" :${JSON.stringify(data)}`;

    console.log("Formatted Data:", formattedData);

    const query = `
      EXEC AddLotoAndHarnessReport 
      @Site = :Site, 
      @SupervisorName = :SupervisorName, 
      @ReportDate = :ReportDate, 
      @Shift = :Shift, 
      @Json = :Data, 
      @FieldsToShow = :FieldsToShow
    `;

    // Make sure to pass the correct replacements
    const lotoAndHarnessData = await db.sequelize.query(query, {
      replacements: {
        Site: site,                // Ensure these match the query placeholders
        SupervisorName: supervisorName,
        ReportDate: reportDate,
        Shift: shift,
        Data: formattedData,
        FieldsToShow: fieldstoshow,
      },
      type: db.Sequelize.QueryTypes.Exec,
    });

    res.status(201).send({
      status: true,
      message: "Loto and Harness data added successfully.",
    });
  } catch (error) {
    console.error("Error in AddLotoAndHarness:", error.message);
    res.status(400).json({
      status: false,
      message: "Error adding Loto and Harness data.",
      error: error.message,
    });
  }
};


exports.getLotoHarnessBySite = async (req, res) => {
  try {
    const { site, otherCondition } = req.params;


    // Execute the stored procedure using Sequelize
    const query = 'EXEC GetLotoHarnessBySite @Site = :Site, @OtherCondition = :OtherCondition';
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


exports.getLotoHarnessSummaryByYear = async (req, res) => {
  try {
    const { year, otherCondition } = req.params;


    // Execute the stored procedure using Sequelize
    const query = 'EXEC GetLotoHarnessSummaryByYear @Year = :Year, @OtherCondition = :OtherCondition';
    const data = await db.sequelize.query(query, {
      replacements: {
        Year: year,
         OtherCondition: otherCondition || '', // Optional condition
      },
      type: db.Sequelize.QueryTypes.RAW,  // Ensure we're executing raw SQL query
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
      message: `Loto and Harness data found successfully for Year ${year}.`,
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


exports.getLotoHarnessSummaryByMonthAndYear = async (req, res) => {
  try {
    const {  otherCondition } = req.params;


    // Execute the stored procedure using Sequelize
    const query = 'EXEC GetLotoHarnessSummaryByMonthAndYear  @OtherCondition = :OtherCondition';
    const data = await db.sequelize.query(query, {
      replacements: {
        
         OtherCondition: otherCondition || '', // Optional condition
      },
      type: db.Sequelize.QueryTypes.RAW,  // Ensure we're executing raw SQL query
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
      message: `Loto and Harness data found successfully.`,
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
