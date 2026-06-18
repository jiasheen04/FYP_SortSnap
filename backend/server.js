const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");

dotenv.config();

const aiRoutes = require("./routes/ai_routes");

const app = express();

app.use(cors());
app.use(express.json());

app.get("/api/health", (req, res) => {
  res.json({
    status: "OK",
    message: "SortSnap AI backend is running",
  });
});

app.use("/api/chatbot", aiRoutes);

const PORT = process.env.PORT || 5000;

app.listen(PORT, "0.0.0.0", () => {
  console.log(`SortSnap AI backend running on port ${PORT}`);
});