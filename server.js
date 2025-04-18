require('dotenv').config();
const express = require("express");
const axios = require("axios");
const cors = require("cors");

const app = express();
app.use(express.json());
app.use(cors());

const API_GATEWAY_URL = process.env.API_GATEWAY_URL;  // Store in .env file

app.post("/submit-email", async (req, res) => {
    try {
        const { name, email } = req.body; // Extract both name and email

        if (!name || !email) {
            return res.status(400).json({ message: "Name and email are required" });
        }

        const response = await axios.post(API_GATEWAY_URL, { name, email }); // Send both fields to the API Gateway

        res.json(response.data);
    } catch (error) {
        res.status(500).json({ message: "Server error", error: error.message });
    }
});

app.listen(3000, () => console.log("Server running on port 3000"));