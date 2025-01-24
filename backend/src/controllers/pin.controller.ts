import express from "express";
import { pinSchema } from "../validations/pin.validation";
import pinService from "../services/pin.service";

const router = express.Router();

router.put("/", async (req, res, next) => {
  try {
    const data = pinSchema.parse(req.body);
    const controlToken = await pinService.submitPin(
      data.accessToken,
      data.pin,
      data.deviceId
    );
    res.json({ controlToken });
  } catch (err) {
    next(err);
  }
});

export default router;
