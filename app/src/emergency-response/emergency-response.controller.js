const db = require("../../models");
const EmergencyResponse = db.emergencyResponse;

exports.postAddEmergencyResponse = async (req, res) => {
  try {
    const emergencies = Object.values(req.body).filter(
      (item) => item.Shift !== "" || item.HighRescuer !== ""
    );

    console.log(emergencies);

    if (emergencies.length === 0) {
      return res.status(400).json({
        status: false,
        message: "No emergency response resources data provided.",
      });
    }

    const siteValue = emergencies[0].Site;
    const dateInReport = emergencies[0].ReportDate;

    await EmergencyResponse.destroy({
      where: {
        site: siteValue,
        reportDate: dateInReport,
      },
    });

    const newEmergencies = await EmergencyResponse.bulkCreate(
      emergencies.map((emergency) => ({
        reportDate: new Date(emergency.ReportDate),
        site: emergency.Site,
        shift: emergency.Shift,
        firstAider: emergency.FirstAider,
        highRescuer: emergency.HighRescuer,
        dateUpdated: new Date(emergency.DateUpdated),
        updatedBy: emergency.UpdatedBy,
      }))
    );

    res.status(201).send({
      status: true,
      data: newEmergencies,
      message: "Newly Emergency Response Resource records added successfully.",
    });
  } catch (error) {
    console.error("Error inserting data:", error.message);
    res.status(400).json({
      status: false,
      message: "Please check the request and try again.",
      error: error.message,
    });
  }
};
