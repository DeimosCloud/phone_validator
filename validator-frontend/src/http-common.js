import axios from "axios";

export default axios.create({
  baseURL: "http://52.211.167.97:8080/api/v1",
  headers: {
    "Content-type": "application/json",
  },
});
