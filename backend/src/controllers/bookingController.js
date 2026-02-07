const Booking = require('../models/bookingModel');

exports.getAllBookings = async (req, res) => {
    try {
        let filter = {};
        if (req.user.role !== 'admin') filter = { user: req.user.id };

        const bookings = await Booking.find(filter);

        res.status(200).json({
            status: 'success',
            results: bookings.length,
            data: {
                bookings
            }
        });
    } catch (err) {
        res.status(404).json({
            status: 'fail',
            message: err
        });
    }
};

exports.createBooking = async (req, res) => {
    try {
        if (!req.body.user) req.body.user = req.user.id;
        const newBooking = await Booking.create(req.body);

        res.status(201).json({
            status: 'success',
            data: {
                booking: newBooking
            }
        });
    } catch (err) {
        res.status(400).json({
            status: 'fail',
            message: err
        });
    }
};

exports.getBooking = async (req, res) => {
    try {
        const booking = await Booking.findById(req.params.id);

        res.status(200).json({
            status: 'success',
            data: {
                booking
            }
        });
    } catch (err) {
        res.status(404).json({
            status: 'fail',
            message: err
        });
    }
};
