import { z } from "zod";

export const pinSchema = z.object({
  accessToken: z.string().nonempty("Access token is required."),
  pin: z.string().nonempty("PIN is required."),
  deviceId: z.string().nonempty("Device ID is required."),
});
