const bcrypt = require('bcryptjs');

// 1. GET ALL CUSTOMERS (Useful for your Admin Dashboard)
exports.getAllCustomers = async (req, res) => {
  try {
    const [customers] = await req.db.query('SELECT id, full_name, email, phone_number, birthday, created_at FROM customer');
    res.status(200).json(customers);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching customers', error });
  }
};

// 2. GET SINGLE CUSTOMER BY ID
exports.getCustomerById = async (req, res) => {
  try {
    const [customer] = await req.db.query('SELECT id, full_name, email, phone_number, birthday FROM customer WHERE id = ?', [req.params.id]);
    if (customer.length === 0) return res.status(404).json({ message: 'Customer not found' });
    res.status(200).json(customer[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching customer', error });
  }
};

// 3. ADD CUSTOMER / REGISTER (Upgraded with bcrypt!)
exports.addCustomer = async (req, res) => {
  try {
    const { full_name, phone_number, email, birthday, password } = req.body;

    // Validate
    if (!full_name || !phone_number || !email || !password) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    // Check if email already exists
    const [existing] = await req.db.query('SELECT id FROM customer WHERE email = ?', [email]);
    if (existing.length > 0) {
      return res.status(409).json({ message: 'Email already registered' });
    }

    // Hash the password
    const salt = await bcrypt.genSalt(10);
    const hashed_password = await bcrypt.hash(password, salt);

    // Insert into DB
    const [result] = await req.db.query(
      `INSERT INTO customer (full_name, phone_number, email, birthday, hashed_password) VALUES (?, ?, ?, ?, ?)`,
      [full_name, phone_number, email, birthday || null, hashed_password]
    );

    res.status(201).json({ message: 'Customer created successfully', id: result.insertId });
  } catch (error) {
    console.error("Registration Error:", error);
    res.status(500).json({ message: 'Server error during registration', error });
  }
};

// 4. UPDATE CUSTOMER
exports.updateCustomer = async (req, res) => {
  try {
    const { full_name, phone_number, email, birthday } = req.body;
    await req.db.query(
      'UPDATE customer SET full_name = ?, phone_number = ?, email = ?, birthday = ? WHERE id = ?',
      [full_name, phone_number, email, birthday || null, req.params.id]
    );
    res.status(200).json({ message: 'Customer updated' });
  } catch (error) {
    res.status(500).json({ message: 'Error updating customer', error });
  }
};

// 5. DELETE CUSTOMER
exports.deleteCustomer = async (req, res) => {
  try {
    await req.db.query('DELETE FROM customer WHERE id = ?', [req.params.id]);
    res.status(200).json({ message: 'Customer deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting customer', error });
  }
};

exports.loginCustomer = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password are required' });
    }

    // 1. Find the user by email
    const [users] = await req.db.query('SELECT id, full_name, hashed_password FROM customer WHERE email = ?', [email]);
    
    if (users.length === 0) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }

    const user = users[0];

    // 2. Compare the typed password with the saved hash
    const isMatch = await bcrypt.compare(password, user.hashed_password);
    
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }

    // 3. Success! Send the user's data back to Flutter
    res.status(200).json({ 
      success: true, 
      data: { id: user.id, full_name: user.full_name } 
    });

  } catch (error) {
    console.error("Login Error:", error);
    res.status(500).json({ success: false, message: 'Server error during login' });
  }
};

// GET CUSTOMER STAMPS
exports.getCustomerStamps = async (req, res) => {
  try {
    const { id } = req.params;

    const [result] = await req.db.query(
      `SELECT SUM(stamp_change) as total_stamps
       FROM stamps
       WHERE customer_id = ?`,
      [id]
    );

    const totalStamps = result[0].total_stamps || 0;

    res.status(200).json({
      success: true,
      total_stamps: parseInt(totalStamps, 10)
    });
  } catch (error) {
    console.error("Fetch Stamps Error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.getCustomerVouchers = async (req, res) => {
  try {
    const { id } = req.params;

    const [vouchers] = await req.db.query(
      `SELECT id, discount_percent, status, issued_at, used_at, order_id, source
       FROM vouchers
       WHERE customer_id = ? AND status = 'available'
       ORDER BY issued_at ASC`,
      [id]
    );

    res.status(200).json({
      success: true,
      data: vouchers
    });
  } catch (error) {
    console.error("Fetch Vouchers Error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.redeemStampVoucher = async (req, res) => {
  let connection;

  try {
    const { id } = req.params;

    connection = await req.db.getConnection();
    await connection.beginTransaction();

    const [stampRows] = await connection.query(
      `SELECT COALESCE(SUM(stamp_change), 0) as total_stamps
       FROM stamps
       WHERE customer_id = ?`,
      [id]
    );

    const totalStamps = parseInt(stampRows[0].total_stamps || 0, 10);
    if (totalStamps < 10) {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'You need 10 stamps to redeem a voucher.',
        total_stamps: totalStamps
      });
    }

    await connection.query(
      `INSERT INTO stamps (customer_id, order_id, stamp_change, description)
       VALUES (?, NULL, -10, ?)`,
      [id, 'Redeemed 10 stamps for 10% voucher']
    );

    const [voucherResult] = await connection.query(
      `INSERT INTO vouchers (customer_id, discount_percent, status, source)
       VALUES (?, 10.00, 'available', 'stamp_redemption')`,
      [id]
    );

    await connection.commit();

    res.status(201).json({
      success: true,
      message: 'Voucher redeemed successfully.',
      voucher_id: voucherResult.insertId,
      remaining_stamps: totalStamps - 10
    });
  } catch (error) {
    if (connection) {
      await connection.rollback();
    }
    console.error("Redeem Voucher Error:", error);
    res.status(500).json({ success: false, message: error.message });
  } finally {
    if (connection) {
      connection.release();
    }
  }
};
