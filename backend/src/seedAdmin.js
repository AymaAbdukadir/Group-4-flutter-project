const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./models/userModel');

dotenv.config({ path: './config.env' });

const DB = process.env.DATABASE_LOCAL || 'mongodb://localhost:27017/natours';

// Admin user credentials
const adminUser = {
    name: 'Admin User',
    email: 'admin@tours.com',
    password: 'admin123',
    passwordConfirm: 'admin123',
    role: 'admin'
};

const seedAdmin = async () => {
    try {
        await mongoose.connect(DB);
        console.log('DB connection successful!');

        // Check if admin already exists
        const existingAdmin = await User.findOne({ email: adminUser.email });
        if (existingAdmin) {
            console.log('Admin user already exists!');
            console.log(`Email: ${adminUser.email}`);
            process.exit();
        }

        // Create admin user
        await User.create(adminUser);
        console.log('✅ Admin user created successfully!');
        console.log('-----------------------------------');
        console.log(`Email: ${adminUser.email}`);
        console.log(`Password: ${adminUser.password}`);
        console.log('-----------------------------------');
        console.log('You can now login with these credentials.');

        process.exit();
    } catch (err) {
        console.error('Error seeding admin user:', err.message);
        process.exit(1);
    }
};

seedAdmin();
