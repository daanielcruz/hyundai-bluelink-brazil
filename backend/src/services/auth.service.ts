import { httpClient } from "../utils/http-client";
import { appId, clientId } from "../constants/bluelinkIds";
import generateHash from "../utils/generateHash";

const login = async (
  email: string,
  password: string
): Promise<{
  accessToken: string;
  refreshToken: string;
  deviceId: string;
}> => {
  const registerResponse = await httpClient.post(
    "https://br-ccapi.hyundai.com.br/api/v1/spa/notifications/register",
    {
      pushRegId: generateHash(64),
      pushType: "APNS",
      uuid: generateHash(40),
    },
    {
      headers: {
        "ccsp-application-id": appId,
        "ccsp-service-id": clientId,
        offset: "-3",
      },
    }
  );

  const deviceId = registerResponse.data.resMsg.deviceId;

  await httpClient.get(
    "https://br-ccapi.hyundai.com.br/api/v1/user/oauth2/authorize",
    {
      params: {
        response_type: "code",
        client_id: clientId,
        redirect_uri:
          "https://br-ccapi.hyundai.com.br/api/v1/user/oauth2/redirect",
        lang: "pt",
      },
      withCredentials: true,
    }
  );

  await httpClient.post(
    "https://br-ccapi.hyundai.com.br/api/v1/user/language",
    {
      lang: "pt",
    },
    {
      withCredentials: true,
    }
  );

  const signinResponse = await httpClient.post(
    "https://br-ccapi.hyundai.com.br/api/v1/user/signin",
    {
      email,
      password,
      mobileNum: "",
    },
    {
      withCredentials: true,
    }
  );

  const redirectUri = signinResponse.data.redirectUrl;

  if (!redirectUri) {
    throw new Error("Redirect URI is missing in /signin response.");
  }

  const code = new URL(redirectUri).searchParams.get("code");

  if (!code) {
    throw new Error("Authorization code is missing or invalid.");
  }

  const tokenResponse = await httpClient.post(
    "https://br-ccapi.hyundai.com.br/api/v1/user/oauth2/token",
    new URLSearchParams({
      client_id: clientId,
      code,
      grant_type: "authorization_code",
      redirect_uri:
        "https://br-ccapi.hyundai.com.br/api/v1/user/oauth2/redirect",
    }),
    {
      headers: {
        "Content-Type": "application/x-www-form-urlencoded;charset=utf-8",
        Authorization:
          "Basic MDNmN2RmOWItNzYyNi00ODUzLWI3YmQtYWQxZThkNzIyYmQ1OnlRejJiYzZDbjhPb3ZWT1I3UkRXd3hUcVZ3V0czeUtCWUZEZzBIc09Yc3l4eVBsSA==",
      },
    }
  );

  return {
    accessToken: tokenResponse.data.access_token,
    refreshToken: tokenResponse.data.refresh_token,
    deviceId,
  };
};

export default { login };
