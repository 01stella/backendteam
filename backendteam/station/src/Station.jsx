import React, { useState, useEffect } from 'react';
import { io } from 'socket.io-client';

// Connect directly to your backend port
const serverIp = import.meta.env.VITE_SERVER_IP || 'localhost';

const socket = io(`http://${serverIp}:3000`);

const Station = () => {
  const [activeStation, setActiveStation] = useState('B'); 
  const [pendingItems, setPendingItems] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    // 1. Fetch data on load or when switching tabs
    fetchPendingItems(activeStation);

    // 2. Listen for new orders from the backend
    socket.on('queue_updated', () => {
      console.log("WebSocket heard a change! Refreshing queue...");
      fetchPendingItems(activeStation);
    });

    // Cleanup the listener when the component unmounts
    return () => {
      socket.off('queue_updated');
    };
  }, [activeStation]);

  const fetchPendingItems = async (stationCode) => {
    try {
      const response = await fetch(`http://${serverIp}:3000/api/station/pending/${stationCode}`);
      const data = await response.json();
      
      if (data.success) {
        setPendingItems(data.data);
        setError(null);
      } else {
        setError(data.message);
      }
    } catch (err) {
      setError("Failed to connect to the backend.");
    }
  };

  const handleProcess = async (itemId) => {
    try {
      const response = await fetch(`http://${serverIp}:3000/api/station/pending/${stationCode}`, {
        method: 'PATCH',
      });
      const data = await response.json();

      if (data.success) {
        // Instantly remove it from the screen for that snappy feel
        setPendingItems((currentItems) => 
          currentItems.filter((item) => item.order_item_id !== itemId)
        );
      }
    } catch (err) {
      console.error("Error updating status", err);
    }
  };

  return (
    <div style={{ padding: '20px', fontFamily: 'sans-serif' }}>
      
      {/* Station Selector Buttons */}
      <div style={{ marginBottom: '20px', display: 'flex', gap: '10px' }}>
        <button 
          onClick={() => setActiveStation('B')}
          style={{ padding: '10px 20px', fontWeight: 'bold', backgroundColor: activeStation === 'B' ? '#007bff' : '#eee', color: activeStation === 'B' ? 'white' : 'black', border: 'none', borderRadius: '5px', cursor: 'pointer' }}
        >
          🥤 Beverage Station
        </button>
        <button 
          onClick={() => setActiveStation('P')}
          style={{ padding: '10px 20px', fontWeight: 'bold', backgroundColor: activeStation === 'P' ? '#007bff' : '#eee', color: activeStation === 'P' ? 'white' : 'black', border: 'none', borderRadius: '5px', cursor: 'pointer' }}
        >
          🥐 Pastry Station
        </button>
        <button 
          onClick={() => setActiveStation('K')}
          style={{ padding: '10px 20px', fontWeight: 'bold', backgroundColor: activeStation === 'K' ? '#007bff' : '#eee', color: activeStation === 'K' ? 'white' : 'black', border: 'none', borderRadius: '5px', cursor: 'pointer' }}
        >
          🍳 Kitchen Station
        </button>
      </div>

      <h1>
        {activeStation === 'B' && 'Beverage Queue'}
        {activeStation === 'P' && 'Pastry Queue'}
        {activeStation === 'K' && 'Kitchen Queue'}
      </h1>
      
      {error && <p style={{ color: 'red' }}>{error}</p>}
      
      <div style={{ display: 'grid', gap: '15px', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))' }}>
        {pendingItems.length === 0 ? (
          <p>No pending orders for this station. Great job!</p>
        ) : (
          pendingItems.map((item) => (
            <div key={item.order_item_id} style={{ border: '2px solid #ccc', padding: '15px', borderRadius: '8px' }}>
              <h2>Order #{item.order_id}</h2>
              <h3 style={{ margin: '5px 0', color: '#0056b3' }}>
                {item.quantity}x {item.item_name}
              </h3>
              
              {/* Only show modifiers for Barista drinks */}
              {activeStation === 'B' && (
                <ul style={{ paddingLeft: '20px', color: '#555' }}>
                  <li>Ice: {item.ice_level || 'N/A'}</li>
                  <li>Sugar: {item.sugar_level || 'N/A'}</li>
                  <li>Strength: {item.coffee_strength || 'N/A'}</li>
                </ul>
              )}
              
              <button 
                onClick={() => handleProcess(item.order_item_id)}
                style={{ backgroundColor: '#28a745', color: 'white', border: 'none', padding: '10px 15px', borderRadius: '5px', cursor: 'pointer', width: '100%', fontSize: '16px', fontWeight: 'bold', marginTop: '10px' }}
              >
                Mark as Processed
              </button>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default Station;