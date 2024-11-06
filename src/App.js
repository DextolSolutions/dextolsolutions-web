import React, { useEffect } from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import "./App.css";
import Home from './components/Home';
import About from './components/About';
import Projects from './components/Projects';
import Contact from './components/Contact';
import Navbar from './components/Navbar';
import Footer from './components/Footer';

function App() {
  // Function to create a star
  const createStar = () => {
    const star = document.createElement('div');
    star.className = 'star';

    const size = Math.random() * 2 + 1; // Random star size
    star.style.width = `${size}px`;
    star.style.height = `${size}px`;

    star.style.top = `${Math.random() * 100}%`; // Random vertical position
    star.style.left = `${Math.random() * 100}%`; // Random horizontal position
    star.style.animationDuration = `${Math.random() * 5 + 5}s`; // Random animation duration

    document.body.appendChild(star); // Append star to the body

    setTimeout(() => {
      star.remove(); // Remove star after animation duration
    }, (parseFloat(star.style.animationDuration) * 1000)); // Convert to milliseconds
  };

  // Create stars at intervals
  useEffect(() => {
    const starInterval = setInterval(createStar, 100); // Changed to 100ms
    return () => clearInterval(starInterval); // Clear interval on component unmount
  }, []);

  return (
    <Router>
      <div className="App">
        <div className="star-background"></div>
        <Navbar />
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
          <Route path="/projects" element={<Projects />} />
          <Route path="/contact" element={<Contact />} />
        </Routes>
        <Footer />
      </div>
    </Router>
  );
}

export default App;
