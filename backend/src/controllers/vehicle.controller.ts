import { Router } from "express";
import {
  getVehiclesSchema,
  controlDoorSchema,
} from "../validations/vehicle.validation";
import vehicleService from "../services/vehicle.service";

const router = Router();

router.get("/", async (req, res, next) => {
  try {
    const data = getVehiclesSchema.parse(req.query);
    const vehicles = await vehicleService.getVehicles(
      data.accessToken,
      data.deviceId
    );
    res.json(vehicles);
  } catch (err) {
    next(err);
  }
});

router.post("/control-door", async (req, res, next) => {
  try {
    const data = controlDoorSchema.parse(req.body);
    await vehicleService.controlDoor(
      data.controlToken,
      data.vehicleId,
      data.deviceId,
      data.action
    );

    res.json({ message: `Door ${data.action} successfully` });
  } catch (err) {
    next(err);
  }
});

router.get("/:vehicleId/status", async (req, res, next) => {
  try {
    const { vehicleId } = req.params;
    const data = getVehiclesSchema.parse(req.query);

    const doorStatus = await vehicleService.getVehicleStatus(
      data.accessToken,
      data.deviceId,
      vehicleId
    );
    res.json({ doorLock: doorStatus });
  } catch (err) {
    next(err);
  }
});

export default router;
