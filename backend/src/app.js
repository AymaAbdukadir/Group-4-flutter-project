const express = require("express");
const morgan = require("morgan");
const cors = require("cors");
const path = require("path");

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

app.use("/img", express.static(path.join(__dirname, "../public/img")));

if (process.env.NODE_ENV === "development") {
  app.use(morgan("dev"));
}

// Routes
const tourController = require("./routes/tourRoutes");
const userRouter = require("./routes/userRoutes");
const bookingRouter = require("./routes/bookingRoutes");
const reviewRouter = require("./routes/reviewRoutes");

// app.use('/api/v1/tours', tourRouter);
app.use("/api/v1/tours", tourController);
app.use("/api/v1/users", userRouter);
app.use("/api/v1/bookings", bookingRouter);
app.use("/api/v1/reviews", reviewRouter);

app.get("/", (req, res) => {
  res
    .status(200)
    .json({ message: "Hello from Tours App API!", app: "Tours App" });
});

module.exports = app;
