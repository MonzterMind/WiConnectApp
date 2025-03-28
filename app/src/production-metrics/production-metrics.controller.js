
const db = require("../../models");

exports.addProductionMetrics = async (req, res) => {
  try {
    // Extract parameters from req.params (not req.body)
    const { data } = req.body;
     
    // Ensure `data` exists and is an object
    if (!data || typeof data !== "object" || Array.isArray(data)) {
      throw new Error("Invalid data format: Expected an object.");
    }

    // Convert `data` to a JSON string
    const formattedData = JSON.stringify( data );


    // SQL query to insert data into the database
    const query = `
      EXEC AddProductionMetrics 
      @Site = :Site, 
      @reportDate = :reportDate,
      @COMHours = :COMHours,
      @Volume = :Volume,
      @CustomerDownTime =:CustomerDownTime,
      @PercentageProductiveHours =:PercentageProductiveHours,
      @NonConformanceCount =:NonConformanceCount,
      @LateRoutes = :LateRoutes,
      @ScratchRate =  :ScratchRate,
      @UpdatedBy =  :UpdatedBy
    `;

    // Execute the query with replacements
    const productionMetricsData = await db.sequelize.query(query, {
      replacements: {
        Site:  data.Site,
        reportDate: data.reportDate,
        COMHours: data.COMHours ? parseInt(data.COMHours, 10) : null, 
        Volume: data.Volume ? parseInt(data.Volume, 10) : null,
        CustomerDownTime: data.CustomerDownTime ? parseInt(data.CustomerDownTime, 10) : null,
        PercentageProductiveHours: data.PercentageProductiveHours ? parseFloat(data.PercentageProductiveHours) : null,
        NonConformanceCount: data.NonConformanceCount ? parseInt(data.NonConformanceCount, 10) : null,
        LateRoutes: data.LateRoutes ? parseInt(data.LateRoutes, 10) : null,
        ScratchRate: data.ScratchRate ? parseFloat(data.ScratchRate) : null,
        UpdatedBy: data.UpdatedBy,       
        
      },
      type: db.Sequelize.QueryTypes.Exec,
    });

    // Send the response
    res.status(201).send({
      status: true,
      message: "Production Metrics data added successfully.",
    });
  } catch (error) {
    console.error("Error in adding Production Metrics Data:", error.message);
    res.status(400).json({
      status: false,
      message: "Error adding Production Metrics Data.",
      error: error.message,
    });
  }
};



exports.getProductionMetricsBySite = async (req, res) => {
  try {
    const { site, otherCondition } = req.params;


    // Execute the stored procedure using Sequelize
    const query = 'EXEC GetProductionMetricsBySite @Site = :Site, @OtherCondition = :OtherCondition';
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
      message: `Production Metrics Data data found successfully for site ${site}.`,
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
