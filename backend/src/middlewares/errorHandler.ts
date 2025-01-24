import { Request, Response, NextFunction } from "express";
import { ZodError } from "zod";
import logger from "../utils/logger";

export const errorHandler = (
  err: Error | ZodError,
  req: Request,
  res: Response,
  next: NextFunction
): Response => {
  // console.error("Error captured:", err);
  logger.error(err.stack);

  if (err instanceof ZodError) {
    return res.status(400).json({
      error: true,
      message: "Validation failed",
      details: err.errors.map((e) => ({
        field: e.path.join("."),
        message: e.message,
      })),
    });
  }

  const statusCode = res.statusCode !== 200 ? res.statusCode : 500;
  return res.status(statusCode).json({
    error: true,
    message: err.message || "Internal Server Error",
  });
};
