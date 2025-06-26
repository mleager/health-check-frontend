import React, { useState } from 'react';
import './App.css';

function App() {
  const backendUrl = 'https://api.zerodawndevops.com';
  const [healthData, setHealthData] = useState(null);
  const [showFullHash, setShowFullHash] = useState(false);

  function fetchHealth() {
    console.log('Fetching health data...');
    fetch(backendUrl + '/health')
      .then(response => {
        console.log('Response received:', response);
        console.log('Response headers:', response.headers);
        return response.json();
      })
      .then(data => {
        console.log('Data received:', data);
        setHealthData(data);
      })
      .catch(error => {
        console.error('Error:', error);
        setHealthData({ error: error.message });
      });
  };

  function formatHealthData() {
    if (!healthData) return 'Click the button to fetch health information...';
    if (healthData.error) return `Error fetching health data: ${healthData.error}`;

    return (
      <div className="health-data">
        <div className="health-item">
          <span className="health-label">Frontend Status:</span>
          <span className={`health-value ${healthData.frontend_status.toLowerCase()}`}>
            {healthData.frontend_status}
          </span>
        </div>
        <div className="health-item">
          <span className="health-label">Backend Uptime:</span>
          <span className="health-value">{healthData.uptime}</span>
        </div>
        <div className="health-item">
          <span className="health-label">Timestamp:</span>
          <span className="health-value">{new Date(healthData.timestamp).toLocaleString()}</span>
        </div>
        <div className="health-item">
          <span className="health-label">Commit Hash:</span>
          <span className="health-value">{healthData.commit_hash.substring(0, 7)}
            <button
              className="hash-toggle"
              onClick={() => setShowFullHash(!showFullHash)}
            >
              {showFullHash ? '▲' : '▼'}
            </button>
          </span>
        </div>
        {showFullHash && (
          <div className="heahlth-item full-hash">
            <span className="health-label">Full Hash:</span>
            <span className="health-value">{healthData.commit_hash}</span>
          </div>
        )}
      </div>
    );
  }

  return (
    <div className="container">
      <h1>Backend Health Check</h1>
      <button onClick={fetchHealth}>Refresh Health Status</button>
      <div id="health-info">
        {formatHealthData()}
      </div>
    </div>
  )
};

export default App;

