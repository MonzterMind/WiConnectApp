const db = require("../../models");
const Masterdata = db.masterdata;
const { Op } = require('sequelize');

exports.getActiveEmployeesBySiteSP = async (req, res) => {
  try {
    const { site, category,otherCondition } = req.params;


    // Execute the stored procedure using Sequelize
    const query = 'EXEC GetEmployeeBySite @Site = :Site, @Category = :Category, @OtherCondition = :OtherCondition';
    const employeesMasterData = await db.sequelize.query(query, {
      replacements: {
        Site: site,
        Category: category,
        OtherCondition: otherCondition || '', // Optional condition
      },
      type: db.Sequelize.QueryTypes.RAW,  // Ensure we're executing raw SQL query
    });

    // Check if data was returned
    if (!employeesMasterData || employeesMasterData.length === 0) {
      return res.status(404).send({
        status: false,
        message: "Requested data has not been found.",
      });
    }

    // Return the data as a response
    res.status(200).send({
      status: true,
      data: employeesMasterData,
      message: `Employees masterdata found successfully for site ${site}.`,
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

exports.getEmployeeMasterdata = async (req, res) => {
  try {
    const employeeName = req.params.name;
    const employeeMasterData = await Masterdata.findOne({
      where: { employeeName },
    });

    if (!employeeMasterData) {
      return res
        .status(404)
        .send({ message: "Employee masterdata has not been found." });
    }

    // res.status(200).send({
    //   status: true,
    //   data: employeeMasterData,
    //   message: "Employee masterdata found successfully.",

    // });
    res.render('pages/sample', {employeeMasterData});
  } catch (error) {
    res.status(400).json({
      status: false,
      message: "Please check the request and try again.",
      error: error.message,
    });
  }
};

exports.getActiveEmployeesBySiteStatus = async (req, res) => {
  try {
    const { site, status } = req.params;
    const employeesMasterData = await Masterdata.findAll({
		attributes: ["EmployeeName", "Position", "Category"],
      where: { 
        site,
        status, 
      },
    });

    if (employeesMasterData.length === 0) {
      return res
        .status(404)
        .send({ message: "Requested data has not been found." });
    }

    res.status(200).send({
      status: true,
      data: employeesMasterData,
      message: `Employees masterdata found successfully for site ${site}.`,
    });
  } catch (error) {
    res.status(400).json({
      status: false,
      message: "Please check the request and try again.",
      error: error.message,
    });
  }
};

exports.getActiveEmployeesBySiteStatusCategory = async (req, res) => {
  try {
    const { site, status, category } = req.params;
    const employeesMasterData = await Masterdata.findAll({
		attributes: ["EmployeeName", "Position"],
      where: { 
        site,
        status,
        category: {
          [Op.like]: `%${category}%`
        } 
      },
    });

    if (employeesMasterData.length === 0) {
      return res
        .status(404)
        .send({ message: "Requested data has not been found." });
    }

    res.status(200).send({
      status: true,
      data: employeesMasterData,
      message: `Employees masterdata found successfully for site ${site}.`,
    });
  } catch (error) {
    res.status(400).json({
      status: false,
      message: "Please check the request and try again.",
      error: error.message,
    });
  }
};

exports.postAddEmployees = async (req, res) => {
  try {
    const employees = Object.values(req.body);

    if (employees.length === 0) {
      return res.status(400).json({
        status: false,
        message: "No employee data provided.",
      });
    }

    const siteValue = employees[0].site;
    console.log('Received data:', employees);

    await Masterdata.destroy({
      where: {
        site: siteValue
      }
    });

    const newEmployees = await Masterdata.bulkCreate(employees.map(employee => ({
      site: employee.site,
      employeeName: employee.employeeName,
      position: employee.position,
      category: employee.category,
      zone: employee.zone,
      shift: employee.shift,
      status: employee.status,
      startDate: employee.startDate,
      dateUpdated: new Date(employee.dateUpdated), 
    })));

    res.status(201).send({
      status: true,
      data: newEmployees,
      message: "Employees added successfully.",
    });
  } catch (error) {
    console.error('Error inserting data:', error.message);
    res.status(400).json({
      status: false,
      message: "Please check the request and try again.",
      error: error.message,
    });
  }
};
