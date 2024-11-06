import React from 'react';
import { MdHelpOutline } from "react-icons/md";
import { FiUsers, FiAlertTriangle } from "react-icons/fi";
import './About.css';

function About() {
  return (
    <div className='main'>
      <section className='about-section'>
        <h1 className="about-title">ABOUT US</h1>
      </section>
      <section className="hero-section hero-section-2">
        <h1 className="hero-title">DextolSolutions</h1>
        <h2 className="hero-subtitle">Coding is our Hobby</h2>
        <div className="hero-separator"></div>
        
        {/* Button Container */}
        <div className="button-container">
          <button className="hero-button-about">
            <MdHelpOutline className="button-icon" /> FAQ
          </button>
          <button className="hero-button-about">
            <FiUsers className="button-icon" /> Join Us
          </button>
          <button className="hero-button-about">
            <FiAlertTriangle className="button-icon" /> Report an Issue
          </button>
        </div>
      </section>

      <section className="about-content-section">
        <div className="about-info-container">
          <h2 className="about-heading">ABOUT DEXTOLSOLUTIONS</h2>
          <p className="about-text">
            We are on a mission to optimize computers all around the world. We want to enhance the gaming experience and create a competitive gaming environment, which can be used in several methods, such as gaming, streaming, and working with picture or video editors.
          </p>
          <p className="about-text">
            We base our work on the story of "DextolReiniger," who was on a 5-year long hunt for the best optimizations to apply to low-end or high-end PCs. He himself experienced both low-end and high-end gaming and working experiences and has optimized both environments to generate the best experience possible. Now, he has decided to share his discoveries within the developed optimizers, coded by him, for the public computer enthusiast community.
          </p>
        </div>



        {/* Stacked Subheadings Container */}
        <div className="subheading-wrapper">
          {/* Separator */}
          <div className="middle-separator"></div>
          <h2 className="about-subheading">IMPRESSIUM</h2>
          <p className="about-text">
            E-Mail: <a href="mailto:dextolbuisness@gmail.com">dextolbuisness@gmail.com</a>
          </p>
          <p className="about-text">Operator: DextolReiniger</p>
          <p className="about-text">Address: Zwenkauer Str. 15, 04420 Markranstädt, Germany</p>

          <h2 className="about-subheading">TERMS OF SERVICE</h2>
          <p className="about-text">
            Links: 
            <a href="https://dextolsolutions.com/about/legal/zensl-license-agreement" target="_blank" rel="noopener noreferrer"> ZenSL License Agreement</a>
          </p>
        </div>
      </section>
    </div>
  );
}

export default About;
