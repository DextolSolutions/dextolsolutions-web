import { useRef } from "react";
import "./Navbar.css";
import logo from "../assets/logo.png"; 

function Navbar() {
  const navRef = useRef();
  const scrollToSection = () => {
    const element = document.getElementById("projects");
    if (element) {
      element.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  };

  return (
    <header>
      <img src={logo} alt="Logo" className="logo" />
      <div className="logo-text">
        <span className="logo-title">DextolSolutions</span>
        <span className="logo-subtitle">Coding is our Hobby.</span>
      </div>
      <nav ref={navRef} className="nav-links">
        <a href="/#projects" onClick={scrollToSection}>
          ZenSL Optimizer
        </a>{" "}
        <a href="/projects">Projects</a>
        <a href="/about">About</a>
        <a
          href="https://discord.com/invite/jTpB2VZZ4q"
          className="join-discord"
        >
          Join Discord
        </a>{" "}
      </nav>
    </header>
  );
}

export default Navbar;
