import axios, { AxiosInstance } from "axios";
import { CookieJar } from "tough-cookie";
import { wrapper } from "axios-cookiejar-support";

const cookieJar = new CookieJar();

const httpClient: AxiosInstance = wrapper(
  axios.create({
    withCredentials: true,
    jar: cookieJar,
    headers: {
      "User-Agent":
        "BR_BlueLink/1.0.13 (com.hyundai.bluelink.br; build:10120; iOS 18.1.1) Alamofire/5.9.1",
      Accept: "*/*",
      "Accept-Encoding": "gzip, deflate, br",
      "Accept-Language": "pt-BR;q=1.0",
      Connection: "keep-alive",
    },
  })
);

export { httpClient, cookieJar };
