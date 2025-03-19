const db = require("../../models");
const PackCornerCleaning = db.packcornerCleaning;

exports.postAddPackcornerRecord = async (req, res) => {
  try {
    const packcorners = Object.values(req.body).filter(item => item.ReportDate !== "");

    if (packcorners.length === 0) {
      return res.status(400).json({
        status: false,
        message: "No packcorners data provided.",
      });
    }

    const siteValue = packcorners[0].Site;
    const dateInReport = packcorners[0].ReportDate;

    await PackCornerCleaning.destroy({
      where: {
        site: siteValue,
        reportDate: dateInReport,
      },
    });

    const newPackcorners = await PackCornerCleaning.bulkCreate(
      packcorners.map((packcorner) => ({
        site: packcorner.Site,
        reportDate: new Date(packcorner.ReportDate),
        supervisorName: packcorner.SupervisorName,
        shift: packcorner.Shift,
        packcornerNumber: packcorner.PackCornerNumber,
        remarks: packcorner.Remarks,
        dateUpdated: new Date(packcorner.DateUpdated),
        updatedBy: packcorner.UpdatedBy,
      }))
    );

    res.status(201).send({
      status: true,
      data: newPackcorners,
      message: "Newly cleaned Packcorners records added successfully.",
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
