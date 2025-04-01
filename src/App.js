import React, { useEffect } from "react";
import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import "./App.css";
import Home from "./components/Home";
import About from "./components/About";
import Projects from "./components/Projects";
import Navbar from "./components/Navbar";
import Footer from "./components/Footer";

function App() {
  const createStar = () => {
    const star = document.createElement("div");
    star.className = "star";

    const size = Math.random() * 2 + 1;
    star.style.width = `${size}px`;
    star.style.height = `${size}px`;

    star.style.top = `${Math.random() * 100}%`;
    star.style.left = `${Math.random() * 100}%`;
    star.style.animationDuration = `${Math.random() * 5 + 5}s`;

    document.body.appendChild(star);

    setTimeout(() => {
      star.remove();
    }, parseFloat(star.style.animationDuration) * 1000);
  };

  useEffect(() => {
    const starInterval = setInterval(createStar, 100);
    return () => clearInterval(starInterval);
  }, []);

  useEffect(() => {
    const script = document.createElement("script");
    script.src = "https://publisher.linkvertise.com/cdn/linkvertise.js";
    script.async = true;
    document.body.appendChild(script);

    script.onload = () => {
      if (window.linkvertise) {
        window.linkvertise(1239691, {
          whitelist: ["youtube.com", ""],
          blacklist: [""],
        });
      }
    };

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
        </Routes>
        <Footer />
      </div>
    </Router>
  );
}

export default App;
