import React, { useEffect, useState } from "react";
import "./Projects.css";

function Projects() {
  const [typedText, setTypedText] = useState("");
  const [textIndex, setTextIndex] = useState(0);
  const [isTyping, setIsTyping] = useState(true);
  const [charIndex, setCharIndex] = useState(0);

  const texts = ["Nothing to show here yet!", "Come back later!"];

  useEffect(() => {
    let interval;
    if (isTyping) {
      if (charIndex < texts[textIndex].length) {
        interval = setInterval(() => {
          setTypedText((prev) => prev + texts[textIndex].charAt(charIndex));
          setCharIndex(charIndex + 1);
        }, 100);
      } else {
        setTimeout(() => setIsTyping(false), 2000);
      }
    } else {
      if (charIndex > 0) {
        interval = setInterval(() => {
          setTypedText((prev) => prev.slice(0, -1));
          setCharIndex(charIndex - 1);
        }, 50);
      } else {
        setTextIndex((prevIndex) => (prevIndex + 1) % texts.length);
        setIsTyping(true);
      }
    }

    return () => clearInterval(interval);
  }, [charIndex, isTyping, textIndex, texts]);

  return (
    <div>
      <section className="projects-section">
        <h1 className="projects-title">OUR PROJECTS</h1>
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
