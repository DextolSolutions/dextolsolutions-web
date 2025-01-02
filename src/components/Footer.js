import React from 'react';
import './Footer.css';

function Footer() {
  // Get the current year dynamically
  const currentYear = new Date().getFullYear();

  return (
    <footer>
      <p className='copyright-text'>
        &copy; {currentYear} DextoSolutions
      </p>
    </footer>
  );
}

export default Footer;
