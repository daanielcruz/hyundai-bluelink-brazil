import { z } from "zod";

export const getVehiclesSchema = z.object({
  accessToken: z.string().nonempty("Access token is required."),
  deviceId: z.string().nonempty("Device ID is required."),
});

export const controlDoorSchema = z.object({
  controlToken: z.string().nonempty("Control token is required."),
  vehicleId: z.string().nonempty("Vehicle ID is required."),
  action: z.enum(["open", "close"], {
    errorMap: () => ({ message: "Action must be 'open' or 'close'." }),
  }),
  deviceId: z.string().nonempty("Device ID is required."),
});
