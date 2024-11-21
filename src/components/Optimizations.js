import React, { useEffect, useState } from 'react';
import './Projects.css';

function Projects() {
  const [typedText, setTypedText] = useState(''); // Text to display
  const [textIndex, setTextIndex] = useState(0); // Current text index
  const [isTyping, setIsTyping] = useState(true); // Typing or erasing state
  const [charIndex, setCharIndex] = useState(0); // Current character index

  const texts = [
    "Nothing to show here yet!",
    "Come back later!"
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

  return (
    <div>
      <section className='projects-section'>
        <h1 className="projects-title">OPTIMIZATIONS</h1>
      </section>
      <div className="typewriter-container">
        <div className="typewriter-text">
          <p className="typewriter">{typedText}</p>
        </div>
      </div>
    </div>

  );
}

export default Projects;
