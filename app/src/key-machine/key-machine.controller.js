const db = require("../../models");
const os = require("os");

exports.postAddKeyMachineRecord = async (req, res) => {
  try {
    const {
      site,
      zone,
      systemPart,
      gc,
      lac,
      element,
      location,
      quantityOnTheFloor,
      quantitySpare,
      installedBy,
      installedDate,
      comments,
      keyNumber,
      dateUpdated,
    } = req.body;

    console.log(
      site,
      zone,
      systemPart,
      gc,
      lac,
      element,
      location,
      quantityOnTheFloor,
      quantitySpare,
      installedBy,
      installedDate,
      comments,
      keyNumber,
      dateUpdated
    );

    const updatedBy = os.userInfo().username;
    console.log(updatedBy);

    const operation = "insert";
    console.log(operation);

  

    // SQL query to insert data into the database
    const query = `
      EXEC ManageKeyMachineRecord 
      @Site = :Site,
      @Zone = :Zone, 
      @SystemPart = :SystemPart,
      @GC = :GC,
      @LAC = :LAC,
      @Element = :Element,
      @Location = :Location,
      @QuantityOnTheFloor = :QuantityOnTheFloor,
      @QuantitySpare = :QuantitySpare,
      @InstalledBy = :InstalledBy,
      @InstalledDate = :InstalledDate,
      @Comments = :Comments,
      @KeyNumber = :KeyNumber,
      @DateUpdated = :DateUpdated,
      @UpdatedBy = :UpdatedBy,
      @Operation = :Operation
    `;

    const keyMachineData = await db.sequelize.query(query, {
      replacements: {
        Site: site,
        Zone: zone,
        SystemPart: systemPart,
        GC: gc,
        LAC: lac,
        Element: element,
        Location: location,
        QuantityOnTheFloor: quantityOnTheFloor,
        QuantitySpare: quantitySpare,
        InstalledBy: installedBy,
        InstalledDate: installedDate,
        Comments: comments,
        KeyNumber: keyNumber,
        DateUpdated: dateUpdated,
        UpdatedBy: updatedBy,
        Operation: operation,
      },
    });

    res.status(201).send({
      status: true,
      data: keyMachineData,
      message: "Newly Key Machine record added successfully.",
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
