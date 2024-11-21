import React, { useEffect } from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import './App.css';
import Home from './components/Home';
import About from './components/About';
import Projects from './components/Projects';
import Optimizations from './components/Optimizations'
import Navbar from './components/Navbar';
import Footer from './components/Footer';

function App() {
  // Funktion zum Erstellen von Sternen
  const createStar = () => {
    const star = document.createElement('div');
    star.className = 'star';

    const size = Math.random() * 2 + 1; // Zufällige Sterngröße
    star.style.width = `${size}px`;
    star.style.height = `${size}px`;

    star.style.top = `${Math.random() * 100}%`; // Zufällige vertikale Position
    star.style.left = `${Math.random() * 100}%`; // Zufällige horizontale Position
    star.style.animationDuration = `${Math.random() * 5 + 5}s`; // Zufällige Animationsdauer

    document.body.appendChild(star); // Stern zum Body hinzufügen

    setTimeout(() => {
      star.remove(); // Stern nach der Animationsdauer entfernen
    }, (parseFloat(star.style.animationDuration) * 1000)); // Umrechnung in Millisekunden
  };

  // Erstellen von Sternen in Intervallen
  useEffect(() => {
    const starInterval = setInterval(createStar, 100); // Alle 100ms einen neuen Stern
    return () => clearInterval(starInterval); // Interval bei Unmount löschen
  }, []);

  // Laden des externen Skripts (linkvertise.js)
  useEffect(() => {
    // Dynamisch das linkvertise-Script laden
    const script = document.createElement('script');
    script.src = 'https://publisher.linkvertise.com/cdn/linkvertise.js';
    script.async = true;
    document.body.appendChild(script);

    script.onload = () => {
      // Sobald das Script geladen ist, linkvertise mit den entsprechenden Optionen initialisieren
      if (window.linkvertise) {
        window.linkvertise(1239691, {
          whitelist: ["youtube.com",""],
          blacklist: [''],
        });
      }
    };

    // Aufräumen: Script wieder entfernen, wenn der Component unmountet
    return () => {
      document.body.removeChild(script);
    };
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
          <Route path="/optimizations" element={<Optimizations />} />
        </Routes>
        <Footer />
      </div>
    </Router>
  );
}

export default App;
