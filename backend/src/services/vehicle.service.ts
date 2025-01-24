import { appId } from "../constants/bluelinkIds";
import { httpClient } from "../utils/http-client";

export interface Vehicle {
  vin: string;
  vehicleId: string;
  vehicleName: string;
  type: string;
  nickname: string;
  year: string;
  specYear: string;
  master: boolean;
  detailInfo: {
    inColor: string;
    outColor: string;
    carPackageType: string;
    bodyType: string;
    saleCarmdlCd: string;
    saleCarmdlEnNm: string;
  };
}

const getVehicles = async (
  accessToken: string,
  deviceId: string
): Promise<Vehicle[]> => {
  try {
    const vehiclesResponse = await httpClient.get(
      "https://br-ccapi.hyundai.com.br/api/v1/spa/vehicles",
      {
        headers: {
          "ccsp-application-id": appId,
          "ccsp-device-id": deviceId,
          Authorization: `Bearer ${accessToken}`,
        },
      }
    );
    return vehiclesResponse.data.resMsg.vehicles;
  } catch (error) {
    console.error("Error fetching vehicles:", error);
    throw new Error("Failed to fetch vehicles.");
  }
};

const getVehicleStatus = async (
  accessToken: string,
  deviceId: string,
  vehicleId: string
): Promise<any> => {
  try {
    const statusResponse = await httpClient.get(
      `https://br-ccapi.hyundai.com.br/api/v1/spa/vehicles/${vehicleId}/status/latest`,
      {
        headers: {
          "ccsp-application-id": appId,
          "ccsp-device-id": deviceId,
          Authorization: `Bearer ${accessToken}`,
        },
      }
    );
    return statusResponse.data.resMsg.doorLock;
  } catch (error) {
    console.error("Error fetching vehicle status:", error);
    throw new Error("Failed to fetch vehicle status.");
  }
};

const controlDoor = async (
  controlToken: string,
  vehicleId: string,
  deviceId: string,
  action: "open" | "close"
): Promise<string> => {
  await httpClient.post(
    `https://br-ccapi.hyundai.com.br/api/v2/spa/vehicles/${vehicleId}/control/door`,
    { action, deviceId },
    {
      headers: {
        "ccsp-device-id": deviceId,
        "ccsp-application-id": appId,
        Authorization: `Bearer ${controlToken}`,
      },
    }
  );
  return `Door ${action} successfully`;
};

export default { getVehicles, getVehicleStatus, controlDoor };
