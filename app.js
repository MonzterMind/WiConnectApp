require("dotenv").config();
const express = require("express");
const cors = require("cors");

const app = express();

app.use(
  cors({
    origin: "http://localhost:4200",
    methods: ["GET", "POST", "PUT", "DELETE"],
    credentials: true,
  })
);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Database
const db = require("./app/models");

// Simple route
app.get("/", (req, res) => {
  res.json({ message: "Welcome application" });
});

app.get("/stop", (req, res) => {
  res.send("Stopping server...");
  process.exit(0);
});

// Routes
require("./app/src/headcount-masterdata/masterdata.routes.js")(app);
require("./app/src/loto-harness/loto-harness.routes.js")(app);
require("./app/src/management-kpidata/kpidata.routes.js")(app);
require("./app/src/packcorner-cleaning-tracker/packcorner-cleaning.routes.js")( app);
require("./app/src/production-metrics/production-metrics.routes.js")(app);
require("./app/src/masterdata-report/masterdata-report.routes.js")(app);
require("./app/src/packcorner-cleaning-tracker/packcorner-cleaning.routes.js")(
  app
);
require("./app/src/emergency-response/emergency-response.routes.js")(app);
require("./app/src/key-machine/key-machine.routes.js")(app);

// Set port, listen for requests
const PORT = process.env.PORT || 3000;

app.listen(PORT, "0.0.0.0", async () => {
  console.log(`Server is running on port ${PORT}.`);
  try {
    await db.sequelize.sync();
    console.log("Models synchronized with the database.");
  } catch (err) {
    console.error("Failed to synchronize the models with the database:", err);
    process.exit(1);
  }
});
