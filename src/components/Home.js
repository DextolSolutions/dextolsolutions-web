import React, { useEffect, useState } from 'react';
import './Home.css';
import projectImage from '../assets/thumb.png'; // Importing the project image
import { FaMousePointer, FaUndo, FaShieldAlt } from 'react-icons/fa'; // Importing icons from react-icons

function Home() {
  const [typedText, setTypedText] = useState(''); // Text to display
  const [textIndex, setTextIndex] = useState(0); // Current text index
  const [isTyping, setIsTyping] = useState(true); // Typing or erasing state
  const [charIndex, setCharIndex] = useState(0); // Current character index

  const texts = [
    "Click on 'Show Projects' to Download ZenSL!",
    "Welcome to DextolSolutions!"
  ]; // Array of texts

  useEffect(() => {
    let interval;
    if (isTyping) {
      // Typing animation
      if (charIndex < texts[textIndex].length) {
        interval = setInterval(() => {
          setTypedText((prev) => prev + texts[textIndex].charAt(charIndex));
          setCharIndex(charIndex + 1);
        }, 100); // Typing speed
      } else {
        // Pause after typing the full text
        setTimeout(() => setIsTyping(false), 2000); // Pause for 2 seconds
      }
    } else {
      // Erasing animation
      if (charIndex > 0) {
        interval = setInterval(() => {
          setTypedText((prev) => prev.slice(0, -1));
          setCharIndex(charIndex - 1);
        }, 50); // Erasing speed
      } else {
        // Move to the next text
        setTextIndex((prevIndex) => (prevIndex + 1) % texts.length);
        setIsTyping(true); // Start typing again
      }
    }

    return () => clearInterval(interval); // Cleanup interval on unmount
  }, [charIndex, isTyping, textIndex, texts]);

  const scrollToSection = () => {
    const element = document.getElementById('projects'); // Targeting the projects section
    if (element) {
      element.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  };

  return (
    <>
      {/* Avatar Section */}
      <div className="avatar-container">
        <div className="avatar-text">
          <p className="typewriter">{typedText}</p>
        </div>
      </div>

      <section className="hero-section">
        <h1 className="hero-title">DextolSolutions</h1>
        <h2 className="hero-subtitle">Coding is our Hobby</h2>
        <button className="hero-button-home" onClick={scrollToSection}>Show Projects</button>
      </section>

      <section id="projects" className="home-section">   
        <h1 className="home-title">RECENT PROJECT</h1>
        
        <div className="projects-description">
          <img src={projectImage} alt="Project Thumbnail" className="project-image" />
          <div className="project-info">
              <h3>ZenSL Lite</h3>
              <p>Optimize Your Computer For Gaming.</p>

              <button className="download-button">Download</button>

              <p className='os-compability'>Windows 10 / 11</p>
          </div>
          
          <div className="feature-boxes">
            <div className="feature-box">
              <p>ONE CLICK</p>
              <FaMousePointer className="feature-icon" />
            </div>
            <div className="feature-box">
              <p>ALWAYS REVERTABLE</p>
              <FaUndo className="feature-icon" />
            </div>
            <div className="feature-box">
              <p>NO SYSTEM INSTABILITY</p>
              <FaShieldAlt className="feature-icon" />
            </div>
          </div>
        </div>
      </section>
    </>
  );
}

export default Home;
