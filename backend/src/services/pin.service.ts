import { httpClient } from "../utils/http-client";

const submitPin = async (
  accessToken: string,
  pin: string,
  deviceId: string
): Promise<string> => {
  const response = await httpClient.put(
    "https://br-ccapi.hyundai.com.br/api/v1/user/pin",
    { pin, deviceId },
    {
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        Authorization: `Bearer ${accessToken}`,
      },
    }
  );

  return response.data.controlToken;
};

export default { submitPin };
