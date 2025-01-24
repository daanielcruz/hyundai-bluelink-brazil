import { Router } from "express";
import { z } from "zod";
import authService from "../services/auth.service";
import { loginSchema } from "../validations/auth.validation";

const router = Router();

router.post("/login", async (req, res, next) => {
  try {
    const data = loginSchema.parse(req.body);
    const result = await authService.login(data.email, data.password);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

export default router;
