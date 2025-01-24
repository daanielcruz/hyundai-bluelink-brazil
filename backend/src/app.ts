import express from "express";
import bodyParser from "body-parser";
import compression from "compression";
import helmet from "helmet";
import swaggerUi from "swagger-ui-express";
import swaggerDocument from "./docs/swagger.json";

import authController from "./controllers/auth.controller";
import vehicleController from "./controllers/vehicle.controller";
import pinController from "./controllers/pin.controller";

import { errorHandler } from "./middlewares/errorHandler";

import logger from "./utils/logger";

console.log(logger);

const app = express();

app.use(compression());
app.use(helmet());
app.use(bodyParser.json());
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.url}`);
  next();
});

app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerDocument));

app.use("/auth", authController);
app.use("/vehicle", vehicleController);
app.use("/pin", pinController);

app.use(errorHandler);

export default app;
