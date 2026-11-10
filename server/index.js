const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 5000;
const JWT_SECRET = process.env.JWT_SECRET || 'hexgen_super_secret_jwt_key_2026';

app.use(cors());
app.use(express.json());

// In-Memory Data Store (Easy to inspect and modify)
const users = new Map(); // phone -> user object
const otps = new Map();  // phone -> otp

const venues = [
  {
    id: 'v1',
    name: 'Hexgen Sports Arena',
    location: 'Shanthinagar, Bangalore',
    pitchType: 'Synthetic Turf Pitch',
    sport: 'Cricket',
    sportIcon: '🏏',
    price: '₹ 1,500 / hr',
    pricePerHour: 1500,
    rating: '4.9',
    reviews: '328',
    distance: '1.2 km',
    image: 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800&auto=format&fit=crop&q=80',
    amenities: ['Auto Machine', 'Floodlights', 'Speed Radar'],
    isPopular: true,
    totalLanes: 3,
  },
  {
    id: 'v2',
    name: 'Hexgen Turf Arena',
    location: 'Indiranagar, Bangalore',
    pitchType: 'FIFA Approved Turf',
    sport: 'Football',
    sportIcon: '⚽',
    price: '₹ 1,200 / hr',
    pricePerHour: 1200,
    rating: '4.8',
    reviews: '215',
    distance: '3.4 km',
    image: 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?w=800&auto=format&fit=crop&q=80',
    amenities: ['FIFA Turf', 'Locker Room', 'Dugouts'],
    isPopular: false,
    totalLanes: 2,
  },
  {
    id: 'v3',
    name: 'Royal Cricket Pavilion',
    location: 'Koramangala, Bangalore',
    pitchType: 'Pro Turf Pitch',
    sport: 'Cricket',
    sportIcon: '🏏',
    price: '₹ 1,800 / hr',
    pricePerHour: 1800,
    rating: '4.9',
    reviews: '210',
    distance: '2.8 km',
    image: 'https://images.unsplash.com/photo-1587280501635-68a0e82cd5ff?w=800&auto=format&fit=crop&q=80',
    amenities: ['Pro Turf Lane', 'Live Video Replay', 'Coach Sync'],
    isPopular: true,
    totalLanes: 4,
  },
  {
    id: 'v4',
    name: 'Smash Point Badminton & Pickleball',
    location: 'HSR Layout, Bangalore',
    pitchType: 'BWF Wooden Court',
    sport: 'Badminton',
    sportIcon: '🏸',
    price: '₹ 600 / hr',
    pricePerHour: 600,
    rating: '4.7',
    reviews: '180',
    distance: '4.1 km',
    image: 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800&auto=format&fit=crop&q=80',
    amenities: ['BWF Synthetic', 'Full AC', 'Pro Shop'],
    isPopular: false,
    totalLanes: 4,
  },
  {
    id: 'v5',
    name: 'KickOff Premier 7v7 Arena',
    location: 'Whitefield, Bangalore',
    pitchType: '7v7 Synthetic Turf',
    sport: 'Football',
    sportIcon: '⚽',
    price: '₹ 1,400 / hr',
    pricePerHour: 1400,
    rating: '4.8',
    reviews: '118',
    distance: '6.2 km',
    image: 'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800&auto=format&fit=crop&q=80',
    amenities: ['7v7 Pitch', 'Night Stadium Lights', 'Parking'],
    isPopular: false,
    totalLanes: 2,
  }
];

// Slot definitions template
const defaultSlotTimes = {
  morning: ['6:00', '7:00', '8:00', '9:00', '10:00', '11:00'],
  afternoon: ['12:00', '1:00', '2:00', '3:00', '4:00', '5:00'],
  evening: ['6:00', '7:00', '8:00', '9:00', '10:00', '11:00'],
};

// Bookings storage: venueId_date -> Set of booked times
const bookedSlots = new Map();
// Pre-populate some slots as booked for demo realism
bookedSlots.set('v1_today', new Set(['6:00', '8:00', '12:00', '5:00', '7:00', '10:00']));

// User Bookings storage (Pre-populated with upcoming and completed sessions)
const allUserBookings = [
  {
    bookingId: 'HEX-BK77492',
    venueId: 'v1',
    venueName: 'Hexgen Sports Arena',
    lane: 'Right-Hand Lane 1 • Synthetic Turf',
    location: 'Shanthinagar, Bangalore',
    date: 'Tomorrow • 23 Sep 2025',
    timeSlots: ['09:00 AM - 10:00 AM'],
    sport: 'Cricket',
    status: 'CONFIRMED',
    totalAmount: 1830,
    bowlerConfig: '120 km/h • Fast Seam • 6 Overs',
    tracking: '60fps AI Pose Calibration',
    coach: 'Coach Madhu (Assigned)',
    entryGate: 'Gate B • Lane Turnstile 01',
    createdAt: new Date().toISOString(),
  },
  {
    bookingId: 'HEX-BK77510',
    venueId: 'v2',
    venueName: 'Hexgen Turf Arena',
    lane: 'Court 2 • Hybrid Indoor Turf',
    location: 'Indiranagar, Bangalore',
    date: '26 Sep 2025',
    timeSlots: ['07:00 AM - 08:30 AM'],
    sport: 'Cricket',
    status: 'CONFIRMED',
    totalAmount: 2450,
    bowlerConfig: '105 km/h • In-Swinger • 10 Overs',
    tracking: 'Dual Camera 4K Replay',
    coach: 'Autonomous AI Machine Sync',
    entryGate: 'Gate A • Main Deck',
    createdAt: new Date(Date.now() - 86400000).toISOString(),
  },
  {
    bookingId: 'HEX-BK76104',
    venueId: 'v1',
    venueName: 'Hexgen Sports Arena',
    lane: 'Right-Hand Lane 3',
    location: 'Shanthinagar, Bangalore',
    date: '15 Sep 2025',
    timeSlots: ['06:00 PM - 07:00 PM'],
    sport: 'Cricket',
    status: 'COMPLETED',
    totalAmount: 1830,
    bowlerConfig: '112 km/h • Off stump',
    tracking: 'Pose Telemetry Streamed',
    coach: 'Coach Madhu',
    entryGate: 'Gate B • Lane 03',
    createdAt: new Date(Date.now() - 500000000).toISOString(),
  }
];

// ── Auth Routes ──────────────────────────────────────────────────────────────

// 1. Send OTP
app.post('/api/auth/send-otp', (req, res) => {
  const { phone } = req.body;
  if (!phone || phone.length < 10) {
    return res.status(400).json({ success: false, message: 'Valid 10-digit phone number is required' });
  }

  // Generate 6 digit OTP (Default 123456 for easy developer testing, or random)
  const otp = '123456';
  otps.set(phone, otp);

  console.log(`[AUTH] OTP for ${phone} is: ${otp}`);
  return res.json({
    success: true,
    message: 'OTP sent successfully',
    otp: otp, // Returned for dev testing
  });
});

// 2. Verify OTP
app.post('/api/auth/verify-otp', (req, res) => {
  const { phone, otp, name } = req.body;

  if (!phone || !otp) {
    return res.status(400).json({ success: false, message: 'Phone and OTP are required' });
  }

  const storedOtp = otps.get(phone) || '123456'; // Allow 123456 fallback
  if (otp !== storedOtp && otp !== '123456') {
    return res.status(401).json({ success: false, message: 'Invalid OTP. Use 123456 for testing.' });
  }

  // Clear OTP
  otps.delete(phone);

  let user = users.get(phone);
  if (!user) {
    user = {
      id: 'HEX-' + Math.floor(10000 + Math.random() * 90000),
      phone,
      name: name || 'Athlete ' + phone.slice(-4),
      email: `${phone}@hexgen.io`,
      role: 'player',
      createdAt: new Date().toISOString(),
      walletBalance: 250,
      tier: 'Pro Athlete',
    };
    users.set(phone, user);
  } else if (name && (!user.name || user.name.startsWith('Athlete '))) {
    user.name = name;
  }

  const token = jwt.sign({ id: user.id, phone: user.phone }, JWT_SECRET, { expiresIn: '30d' });

  return res.json({
    success: true,
    message: 'Login successful',
    token,
    user,
  });
});

// 3. Get Current User Profile
app.get('/api/auth/me', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: 'Authorization token missing' });
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const user = users.get(decoded.phone);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    return res.json({ success: true, user });
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid or expired token' });
  }
});

// ── Venues & Slots Routes ───────────────────────────────────────────────────

// 4. Get All Venues
app.get('/api/venues', (req, res) => {
  const { sport } = req.query;
  let filtered = venues;
  if (sport && sport.toLowerCase() !== 'all') {
    filtered = venues.filter(v => v.sport.toLowerCase() === sport.toLowerCase());
  }
  return res.json({ success: true, count: filtered.length, venues: filtered });
});

// 5. Get Venue Details & Live Slots for a Date
app.get('/api/venues/:id/slots', (req, res) => {
  const { id } = req.params;
  const dateStr = req.query.date || 'today';

  const venue = venues.find(v => v.id === id);
  if (!venue) {
    return res.status(404).json({ success: false, message: 'Venue not found' });
  }

  const key = `${id}_${dateStr}`;
  const bookedSet = bookedSlots.get(key) || new Set();

  const buildSlotsWithStatus = (slotArray) => {
    return slotArray.map(time => ({
      time,
      isAvailable: !bookedSet.has(time),
      status: bookedSet.has(time) ? 'booked' : 'available',
    }));
  };

  return res.json({
    success: true,
    venueId: id,
    date: dateStr,
    slots: {
      morning: buildSlotsWithStatus(defaultSlotTimes.morning),
      afternoon: buildSlotsWithStatus(defaultSlotTimes.afternoon),
      evening: buildSlotsWithStatus(defaultSlotTimes.evening),
    },
    totalAvailable: (
      defaultSlotTimes.morning.length +
      defaultSlotTimes.afternoon.length +
      defaultSlotTimes.evening.length -
      bookedSet.size
    ),
  });
});

// 6. Book a Slot / Confirm Booking
app.post('/api/bookings', (req, res) => {
  const { venueId, date, timeSlots, athleteDetails, totalAmount, paymentMethod } = req.body;

  if (!venueId || !timeSlots || !timeSlots.length) {
    return res.status(400).json({ success: false, message: 'Venue ID and at least one time slot are required' });
  }

  const dateStr = date || 'today';
  const key = `${venueId}_${dateStr}`;
  if (!bookedSlots.has(key)) {
    bookedSlots.set(key, new Set());
  }
  const bookedSet = bookedSlots.get(key);

  // Check if any slot is already booked
  for (const time of timeSlots) {
    if (bookedSet.has(time)) {
      return res.status(409).json({
        success: false,
        message: `Slot ${time} is already booked by another athlete. Please select another time.`,
        conflictingSlot: time,
      });
    }
  }

  // Mark all as booked
  for (const time of timeSlots) {
    bookedSet.add(time);
  }

  const booking = {
    bookingId: 'HEX-BK' + Math.floor(100000 + Math.random() * 900000),
    venueId,
    venueName: venues.find(v => v.id === venueId)?.name || 'Hexgen Sports Arena',
    date: dateStr,
    timeSlots,
    lane: 'Lane 01 (Smart AI Enabled)',
    totalAmount: totalAmount || 1830,
    paymentMethod: paymentMethod || 'UPI',
    paymentStatus: 'PAID',
    athleteDetails: athleteDetails || {
      name: 'Athlete',
      phone: '9886519422',
    },
    createdAt: new Date().toISOString(),
    status: 'CONFIRMED',
  };

  allUserBookings.unshift(booking);

  console.log(`[BOOKING] New booking created: ${booking.bookingId} for slots: ${timeSlots.join(', ')}`);

  return res.status(201).json({
    success: true,
    message: 'Booking confirmed successfully',
    booking,
  });
});

// 7. Get My Bookings
app.get('/api/bookings/my-bookings', (req, res) => {
  return res.json({
    success: true,
    count: allUserBookings.length,
    bookings: allUserBookings,
  });
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', serverTime: new Date().toISOString() });
});

// Root route - Welcome page & API Endpoints list
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>Hexgen Connect API Server</title>
      <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #0a0f1d; color: #f0f6fc; padding: 40px; margin: 0; }
        .card { max-width: 700px; margin: 0 auto; background: #161b2e; border: 1px solid #233154; border-radius: 16px; padding: 32px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        h1 { color: #00D4FF; margin-top: 0; display: flex; align-items: center; gap: 10px; }
        .badge { background: #0052FF; color: white; font-size: 12px; padding: 4px 10px; border-radius: 20px; font-weight: bold; }
        .endpoint { background: #0e1424; padding: 12px 16px; border-radius: 8px; margin: 10px 0; border: 1px solid #1f2a47; display: flex; justify-content: space-between; align-items: center; }
        .method { font-weight: bold; padding: 3px 8px; border-radius: 4px; font-size: 12px; }
        .get { background: #1e3a2f; color: #4ade80; }
        .post { background: #3b2a1a; color: #fbbf24; }
        a { color: #00D4FF; text-decoration: none; }
        a:hover { text-decoration: underline; }
      </style>
    </head>
    <body>
      <div class="card">
        <h1>⚡ Hexgen Connect REST API <span class="badge">ONLINE</span></h1>
        <p style="color: #94a3b8;">Welcome! Hexgen Mobile App Backend Server is running smoothly.</p>

        <h3 style="margin-top: 24px; color: #e2e8f0;">Available Endpoints:</h3>

        <div class="endpoint">
          <div><span class="method get">GET</span> <a href="/api/health" target="_blank">/api/health</a></div>
          <span style="color: #64748b; font-size: 13px;">Server Health Status</span>
        </div>

        <div class="endpoint">
          <div><span class="method get">GET</span> <a href="/api/venues" target="_blank">/api/venues</a></div>
          <span style="color: #64748b; font-size: 13px;">All Sports Arenas</span>
        </div>

        <div class="endpoint">
          <div><span class="method get">GET</span> <a href="/api/venues/v1/slots" target="_blank">/api/venues/v1/slots</a></div>
          <span style="color: #64748b; font-size: 13px;">Live Slots for Arena 1</span>
        </div>

        <div class="endpoint">
          <div><span class="method post">POST</span> <span style="color: #cbd5e1;">/api/auth/send-otp</span></div>
          <span style="color: #64748b; font-size: 13px;">Send OTP (Dev: 123456)</span>
        </div>

        <div class="endpoint">
          <div><span class="method post">POST</span> <span style="color: #cbd5e1;">/api/auth/verify-otp</span></div>
          <span style="color: #64748b; font-size: 13px;">Verify OTP & Get JWT</span>
        </div>

        <div class="endpoint">
          <div><span class="method post">POST</span> <span style="color: #cbd5e1;">/api/bookings</span></div>
          <span style="color: #64748b; font-size: 13px;">Create Real-time Booking</span>
        </div>
      </div>
    </body>
    </html>
  `);
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`===============================================`);
  console.log(`⚡ Hexgen REST API Server running on port ${PORT}`);
  console.log(`👉 Local:   http://localhost:${PORT}`);
  console.log(`👉 Android: http://10.0.2.2:${PORT}`);
  console.log(`===============================================`);
});
